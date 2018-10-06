output "bucket_arn" {
  value = "${aws_s3_bucket.provisioning.arn}"
}

output "key_arn" {
  value = "${aws_kms_key.provisioning.arn}"
}

output "subnet_cidr" {
  value = "${aws_subnet.ec2.cidr_block}"
}

output "subnet_id" {
  value = "${aws_subnet.ec2.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.test_vpc.cidr_block}"
}

output "vpc_id" {
  value = "${aws_vpc.test_vpc.id}"
}
