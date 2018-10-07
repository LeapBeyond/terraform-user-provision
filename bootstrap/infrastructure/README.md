# infrastructure

This projects sets up a VPC to place the instance in later, and the S3 bucket used for provisioning.

## Usage

 - use values from `bootstrap` to update `backend.tf`
 - create  `terraform.tfvars` from `terraform.tfvars.template`
 - apply `terraform init` then `terraform apply`

On successful completion, information is reported that you may need to set up other assets:

```
bucket_arn = arn:aws:s3:::provisioning20181006085255551300000001
key_arn = arn:aws:kms:eu-west-2:889199313043:key/706a950a-111a-4a11-a140-88f3dc94897a
subnet_cidr = 172.32.10.0/26
subnet_id = subnet-007dabb84342bd201
vpc_cidr = 172.32.0.0/16
vpc_id = vpc-06ffd2d2c157e9544
```

## Note

Please note that the KMS key policy for encryption on the provisioning bucket has a hardwired assumption about the ARN for the role that the deployed instances will use - specifically, the instance role is created in the `instance` project, so the KMS policy definition here has an assumption about the name of the role created by that external project.

## Teardown

To teardown the infrastructure, execute `terraform destroy`.

It is possible this will fail because the provisioning bucket is not empty. If that is the case, manually delete the bucket from the AWS console and re-run `terraform destroy`
