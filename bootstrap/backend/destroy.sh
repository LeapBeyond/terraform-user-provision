#!/bin/bash

cd `dirname $0`
[[ -s ./env.rc ]] && source ./env.rc

cd terraform
terraform init
terraform destroy
rm terraform.tfvars
cd ..

for KEY_NAME in $KEY_NAMES
do
    aws ec2 delete-key-pair --key-name $KEY_NAME
done

rm -rf ../data
