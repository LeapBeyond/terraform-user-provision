#!/bin/bash

cd `dirname $0`
[[ -s ./env.rc ]] && source ./env.rc

mkdir ../data 2>/dev/null

echo "======= setting up key pairs ======="
for KEY_NAME in $KEY_NAMES
do
  aws ec2 describe-key-pairs --output text --key-name $KEY_NAME >/dev/null 2>&1
  if [ $? -gt 0 ]
  then
    aws ec2 create-key-pair \
      --key-name $KEY_NAME \
      --query 'KeyMaterial' \
      --output text > ../data/$KEY_NAME.pem
    chmod 400 ../data/$KEY_NAME.pem
  fi
  aws ec2 describe-key-pairs --output text --key-name $KEY_NAME
done

echo "======== setting up terraform back end ========"
cat <<EOF > terraform/terraform.tfvars
aws_region="$AWS_DEFAULT_REGION"
aws_profile="$AWS_PROFILE"
aws_account_id="$AWS_ACCOUNT_ID"
EOF

cd terraform
terraform init
terraform apply
