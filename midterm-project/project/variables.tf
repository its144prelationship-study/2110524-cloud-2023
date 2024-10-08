variable "region" {
    description = "The AWS region to deploy the infrastructure"
    type = string
    default = "us-east-2"
}

variable "availability_zone" {
    description = "The AWS availability zone to deploy the infrastructure"
    type = string
    default = "us-east-2a"
}

variable "ami" {
    description = "The AMI to use for the instances"
    type = string
    default = "ami-0b8b44ec9a8f90422"
}

variable "instance_type" {
    description = "The instance type to use for the instances"
    type = string
    default = "t2.micro"
}

variable "bucket_name" {
    description = "The name of the S3 bucket"
    type = string
    default = "onetwothreesharkashores"
}

variable "wordpress_instance" {
    description = "The name of the wordpress instance"
    type = string
    default = "wordpress-instance"
}

variable "database_instance" {
    description = "The name of the database instance"
    type = string
    default = "database-instance"
}

variable "database_name" {
    description = "The name of the database"
    type = string
    default = "wordpress"
}

variable "database_user" {
    description = "The username of the database"
    type = string
    default = "username"
}

variable "database_pass" {
    description = "The password of the database"
    type = string
    default = "password"
}

variable "admin_user" {
    description = "The admin username"
    type = string
    default = "admin"
}

variable "admin_pass" {
    description = "The admin password"
    type = string
    default = "password"
}

variable "iam_user" {
    description = "The IAM user"
    type = string
    default = "user"
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type = string
    default = "10.97.0.0/16"
}

variable "wordpress_public_subnet_cidr" {
    description = "The CIDR block for the public subnet"
    type = string
    default = "10.97.1.0/24"
}

variable "wordpress_private_subnet_cidr" {
    description = "The CIDR block for the private subnet"
    type = string
    default = "10.97.2.0/24"
}

variable "database_subnet_cidr" {
    description = "The CIDR block for the database subnet"
    type = string
    default = "10.97.3.0/24"
}

variable "nat_subnet_cidr" {
    description = "The CIDR block for the NAT subnet"
    type = string
    default = "10.97.4.0/24"
}
