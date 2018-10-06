terraform {
  backend "s3" {
    region         = "eu-west-2"
    profile        = "adm_rhook_cli"
    dynamodb_table = "terraform-state-lock"
    bucket         = "terraform-state20181006075541946900000001"
    key            = "terraform-user-provision/infrastructure"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-2:889199313043:key/55082f1b-3a57-4a0d-b590-920b6ce4cede"
  }
}
