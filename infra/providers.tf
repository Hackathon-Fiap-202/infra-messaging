terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }

  backend "s3" {
    bucket  = "nextime-frame-state-bucket"
    key     = "infra-messaging/infra.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  # LocalStack-specific configuration
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_region_validation      = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      sqs          = var.localstack_endpoint
      s3           = var.localstack_endpoint
      ses          = var.localstack_endpoint
      iam          = var.localstack_endpoint
      cognitoidp   = var.localstack_endpoint
      apigateway   = var.localstack_endpoint
      apigatewayv2 = var.localstack_endpoint
    }
  }

  # Force S3 to use path-style URLs for LocalStack
  s3_use_path_style = var.use_localstack
}
