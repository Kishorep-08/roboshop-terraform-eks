terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.28.0"
    }
  }

  backend "s3" {
    bucket = "kishore-remote-state-tf"   # name of your S3 bucket
    key    = "roboshop-aws-ecr"   # name of the file to store the state
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}