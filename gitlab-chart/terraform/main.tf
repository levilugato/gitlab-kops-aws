provider "aws" {
  region = var.REGION
}

terraform {
  backend "s3" {
  }
}

resource "random_string" "random" {
  length = 16
  special = true
  override_special = "/@£$"
}


data "aws_region" "current" {}