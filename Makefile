cnf ?= config.env
include $(cnf)

APP_NAME = realtime-costs
APP_PATH = /usr/src/app

.PHONY: help venv

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

init: bucket stop build run state

build: ## Build the container
	docker build -t $(APP_NAME) .

build-nc: ## Build the container without caching
	docker build --no-cache -t $(APP_NAME) .

run: ## Run container on port configured in `config.env`
	docker run -d --rm --env-file ./config.env \
		-v ~/.aws:/root/.aws \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)"/temp:$(APP_PATH)/temp \
		--mount type=bind,source="$(shell pwd)",target=$(APP_PATH) \
		--name="$(APP_NAME)" $(APP_NAME)

shell: ## Access to the container
	docker exec -ti $(APP_NAME) sh

stop: ## Stop and remove a running container
	@docker stop $(APP_NAME) &>/dev/null || true
	@docker rm $(APP_NAME) &>/dev/null || true

bucket: ## Create state bucket
	aws s3 mb s3://$(BUCKET_STATE) &>/dev/null || true

state: ## Initialize Terraform
	docker exec -it $(APP_NAME) terraform init -backend-config="bucket=$(BUCKET_STATE)" \
		-backend-config="key=$(BUCKET_STATE_KEY)" \
		-backend-config="region=$(BUCKET_STATE_REGION)"

plan: ## Run Terraform plan
	docker exec -it $(APP_NAME) terraform plan

apply: ## Run Terraform plan
	docker exec -it $(APP_NAME) terraform apply -auto-approve

destroy: ## Run Terraform destroy
	docker exec -it $(APP_NAME) terraform destroy -auto-approve