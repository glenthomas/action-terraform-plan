terraform {
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.35"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "s3" {
    key     = "action-terraform-plan/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

data "aws_s3_bucket" "terraform" {
  bucket = var.bucket
}

output "arn" {
  value = data.aws_s3_bucket.terraform.arn
}

resource "random_id" "rng" {
  keepers = {
    first = timestamp()
  }
  byte_length = 8
}

output "random" {
  value = random_id.rng.hex
}
