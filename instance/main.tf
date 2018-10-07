data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}

data "aws_subnet" "selected" {
  cidr_block = "${var.subnet_cidr}"
}

# ------------------------------------------------------------------
# ensure the bootstrap script is present
# ------------------------------------------------------------------
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = "${var.bucket}"
  key    = "provisioning/bootstrap.sh"
  source = "${path.module}/provisioning/bootstrap.sh"
  etag   = "${md5(file("${path.module}/provisioning/bootstrap.sh"))}"
}

# ------------------------------------------------------------------
# security groups to attach to the instance
# ------------------------------------------------------------------
resource "aws_security_group" "test_ssh_access" {
  name        = "provision-test-ssh-in"
  description = "allows ssh access to the test host"
  vpc_id      = "${data.aws_subnet.selected.vpc_id}"
  tags        = "${merge(map("Name", "provision-test-ssh"), var.tags)}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound}"]
  }
}

resource "aws_security_group" "test_http_out" {
  name        = "provision-test-http-out"
  description = "allows http and https from the test host"
  vpc_id      = "${data.aws_subnet.selected.vpc_id}"
  tags        = "${merge(map("Name", "provision-test-ssh"), var.tags)}"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------------
# role to attach to the instance
# ------------------------------------------------------------------
resource "aws_iam_role" "test" {
  name        = "test"
  description = "privileges for the test instance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test" {
  role       = "${aws_iam_role.test.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "test" {
  name = "test"
  role = "${aws_iam_role.test.name}"
}

# ------------------------------------------------------------------
# test instance
# ------------------------------------------------------------------
resource "aws_instance" "test" {
  depends_on = ["aws_s3_bucket_object.bootstrap"]

  ami                         = "${data.aws_ami.target_ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.test_key}"
  subnet_id                   = "${data.aws_subnet.selected.id}"
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.test.name}"

  vpc_security_group_ids = [
    "${aws_security_group.test_ssh_access.id}",
    "${aws_security_group.test_http_out.id}",
  ]

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_vol_size}"
  }

  tags        = "${merge(map("Name", "provision-test"), var.tags)}"
  volume_tags = "${var.tags}"

  user_data = <<EOF
#!/bin/bash
aws s3 cp s3://${var.bucket}/provisioning/bootstrap.sh bootstrap.sh
chmod 750 bootstrap.sh
./bootstrap.sh ${var.bucket}
EOF
}
