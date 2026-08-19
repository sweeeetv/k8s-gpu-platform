terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "azurerm" { 
      resource_group_name = "rg-terraform-state"
      storage_account_name = "tfstatepersonalxgao"
      container_name = "tfstate"
      key = "gpu-infra/aws.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
} 