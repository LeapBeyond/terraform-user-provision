variable "tags" {
  default = {
    "Owner"   = "rahook"
    "Project" = "provision-test"
    "Client"  = "Internal"
  }
}

variable "ec2_subnet_cidr" {
  default = "172.32.10.0/26"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_name" {
  default = "amzn2-ami-hvm-2.0.20180810-x86_64-gp2"
}

variable "root_vol_size" {
  default = 8
}

variable "ssh_inbound" {
  type = "list"
}

variable "test_key" {
  description = "ec2 keypair set up by bootstrap/backend"
  default     = "testinstance"
}

variable "aws_account_id" {}
variable "aws_profile" {}
variable "aws_region" {}

variable "bucket" {
  description = "name of the provisioning bucket created by bootstrap/infrastructure"
}

variable "subnet_cidr" {
  description = "cidr block for subnet set up by bootstrap/infrastructure"
}
