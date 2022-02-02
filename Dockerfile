FROM hashicorp/terraform:0.15.4

RUN apk add --update \
    python3 \
    py-pip \
    py-cffi \
    py-cryptography \
    make \
    git \
    curl \
    which \
    bash \
    jq \
    docker \
    mysql-client \
  && pip install --upgrade pip \
  && apk add --virtual build-deps \
    gcc \
    libffi-dev \
    python3-dev \
    linux-headers \
    musl-dev \
    openssl-dev \
  && pip install awscli==1.22.43 boto3==1.20.26 \
  && apk del build-deps \
  && rm -rf /var/cache/apk/*

# Create app directory
WORKDIR /usr/src/app

ENTRYPOINT sleep 36000