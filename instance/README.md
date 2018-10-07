# instance
This project will launch a fleet of small EC2 instances, running a recent Amazon Linux 2 AMI, and deploy our set of users onto them.

## Usage

First create a `terraform.tfvars` from the `terraform.tfvars.template` using the values from the previous stages. In particular note that the `ssh_inbound` CIDR block list should be sufficient to allow SSH from where you are working - I suggest `[ "your-ip-here/32" ]`, e.g.:

```
bucket="provisioning20181006085255551300000001"
ssh_inbound = ["88.98.207.26/32"]
subnet_cidr = "172.32.10.0/26"
```

Then execute Terraform to create the instances

'''
terraform init
terraform apply
'''

At the end of execution, you should see a report of the public DNS of the created instances:

```
Outputs:

public_dns = [
    ec2-18-130-192-191.eu-west-2.compute.amazonaws.com,
    ec2-35-178-172-238.eu-west-2.compute.amazonaws.com,
    ec2-35-176-149-92.eu-west-2.compute.amazonaws.com,
    ec2-18-130-90-8.eu-west-2.compute.amazonaws.com,
    ec2-18-130-175-28.eu-west-2.compute.amazonaws.com
]
```

You can test the success of the deployment by retrieving one of the user's private keys from SecretsManager:

```
aws --profile ??? secretsmanager \
  get-secret-value \
  --secret-id ssh/gwen \
  --query SecretString \
  --output text > gwen.pem
chmod 400 gwen.pem
```

and then SSH as them to one of the target instances:

```
$ ssh -i gwen.pem gwen@ec2-35-176-149-92.eu-west-2.compute.amazonaws.com
You are required to change your password immediately (root enforced)

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
WARNING: Your password has expired.
You must change your password now and login again!
Changing password for user gwen.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
Connection to ec2-35-176-149-92.eu-west-2.compute.amazonaws.com closed.
$ ssh -i gwen.pem gwen@ec2-35-176-149-92.eu-west-2.compute.amazonaws.com
Last login: Sun Oct  7 11:03:59 2018 from 88.98.207.26

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[gwen@ip-172-32-10-53 ~]$
```

## Teardown

To destroy the instances and other assets:

```
terraform destroy
```
