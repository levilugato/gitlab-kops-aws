provider "aws" {
  region = var.REGION
}

terraform {
  backend "s3" {
  }
}

data "aws_region" "current" {}
