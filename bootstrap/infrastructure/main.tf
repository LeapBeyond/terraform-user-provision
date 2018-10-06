# ------------------------------------------------------------------------------
# define the test VPC
# ------------------------------------------------------------------------------

resource "aws_vpc" "test_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${merge(map("Name", "usertest-vpc"), var.tags)}"
}

# seal off the default NACL
resource "aws_default_network_acl" "test_default" {
  default_network_acl_id = "${aws_vpc.test_vpc.default_network_acl_id}"
  tags                   = "${merge(map("Name", "usertest-default"), var.tags)}"
}

# seal off the default security group
resource "aws_default_security_group" "test_default" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  tags   = "${merge(map("Name", "usertest-default"), var.tags)}"
}

resource "aws_internet_gateway" "testgateway" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  tags   = "${merge(map("Name", "usertest-gateway"), var.tags)}"
}

# ------------------------------------------------------------------------------
# define the test subnet
# ------------------------------------------------------------------------------

resource "aws_subnet" "ec2" {
  vpc_id                  = "${aws_vpc.test_vpc.id}"
  cidr_block              = "${var.ec2_subnet_cidr}"
  map_public_ip_on_launch = false
  tags                    = "${merge(map("Name", "usertest-ec2"), var.tags)}"
}

resource "aws_route_table" "ec2" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testgateway.id}"
  }

  tags = "${merge(map("Name", "usertest-ec2"), var.tags)}"
}

resource "aws_route_table_association" "ec2" {
  subnet_id      = "${aws_subnet.ec2.id}"
  route_table_id = "${aws_route_table.ec2.id}"
}

resource "aws_network_acl" "ec2" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  subnet_ids = ["${aws_subnet.ec2.id}"]
  tags       = "${merge(map("Name", "usertest-ec2"), var.tags)}"
}

resource "aws_network_acl_rule" "ec2_http_out" {
  network_acl_id = "${aws_network_acl.ec2.id}"
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "ec2_https_out" {
  network_acl_id = "${aws_network_acl.ec2.id}"
  rule_number    = 101
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ec2_ephemeral_out" {
  network_acl_id = "${aws_network_acl.ec2.id}"
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "ec2_ephemeral_in" {
  network_acl_id = "${aws_network_acl.ec2.id}"
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "ec2_ssh_in" {
  network_acl_id = "${aws_network_acl.ec2.id}"
  rule_number    = 101
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# ------------------------------------------------------------------------------
# set up the provisioning bucket and key for SSE
# ------------------------------------------------------------------------------

resource "aws_kms_key" "provisioning" {
  deletion_window_in_days = 7

  tags = "${merge(map("Name", "provisioning"), var.tags)}"
}

resource "aws_kms_alias" "a" {
  name          = "alias/provisioning"
  target_key_id = "${aws_kms_key.provisioning.key_id}"
}

resource "aws_s3_bucket" "provisioning" {
  bucket_prefix = "${var.bucket_prefix}"
  acl           = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.provisioning.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = "${merge(map("Name", "Terraform_State_Store"), var.tags)}"
}
