
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project           = var.project_name
      terraform_managed = "true"
    }
  }
}

provider "aws" {
  region = var.region_replica
  default_tags {
    tags = {
      project           = var.project_name
      terraform_managed = "true"
    }
  }
  alias = "replica"
}

provider "aws" {
  alias  = "cloudfront-acm-certs"
  region = "us-east-1"
}

terraform {
  required_version = "= 0.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
    null = {
      version = "~> 3.1.0"
    }
    external = {
      version = "~> 2.1.0"
    }
    random = {
      version = "~> 3.1.0"
    }
    local = {
      version = "~> 2.1.0"
    }
    archive = {
      version = "~> 2.2.0"
    }
    http = {
      version = "~> 2.1.0"
    }
    template = {
      version = "~> 2.2.0"
    }
  }
}
