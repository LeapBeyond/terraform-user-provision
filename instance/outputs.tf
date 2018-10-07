output "public_dns" {
  value = "${aws_instance.test.public_dns}"
}
