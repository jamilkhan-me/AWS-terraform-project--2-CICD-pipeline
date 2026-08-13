terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Reuse the same state bucket/table from your other Terraform project
    # if you like - just make sure the "key" below is unique.
    bucket       = "project-2-ci-cd-pipeline-prod-environment"
    key          = "ecs-fargate-cicd/prod/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}
