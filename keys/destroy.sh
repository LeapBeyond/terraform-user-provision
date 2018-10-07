#!/usr/bin/env bash
cd `dirname $0`

[[ -s ./env.rc ]] && source ./env.rc

for USER in $USERS
do
  echo "==> removing $USER public key "
  aws s3 rm s3://$BUCKET/users/$USER/$USER.pub

  echo "==> removing $USER private key "
  aws secretsmanager delete-secret --secret-id ssh/$USER --query ARN --output text
done


KEY_ID=$(aws kms describe-key --key-id "alias/$KMS_ALIAS" --query 'KeyMetadata.KeyId' --output text)

aws kms delete-alias --alias alias/$KMS_ALIAS
aws kms schedule-key-deletion --key-id $KEY_ID
