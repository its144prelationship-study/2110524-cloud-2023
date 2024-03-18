terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}
provider "aws" {
    region = var.region
}

module "vpc" {
    source = "./modules"
}

module "gateway" {
    source = "./modules"
}

module "route" {
    source = "./modules"
}

module "security_group" {
    source = "./modules"
}

module "instance" {
    source = "./modules"
}

module "iam" {
    source = "./modules"
}

module "s3" {
    source = "./modules"
}