variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "provision-test"
    "client"  = "Internal"
  }
}

variable "bucket_prefix" {
  default = "provisioning"
}
# -----------------------------------------------------------------------------
# network configuration
# -----------------------------------------------------------------------------

# 172.32.0.0 - 172.32.255.255
variable "vpc_cidr" {
  default = "172.32.0.0/16"
}

variable "ec2_subnet_cidr" {
  default = "172.32.10.0/26"
}

# -----------------------------------------------------------------------------
# variables to inject via terraform.tfvars or environment
# -----------------------------------------------------------------------------

variable "aws_account_id" {}
variable "aws_profile" {}
variable "aws_region" {}
