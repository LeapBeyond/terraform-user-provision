#!/usr/bin/env bash
cd `dirname $0`

[[ -s ./env.rc ]] && source ./env.rc

#
# create the encryption key if not present
#
echo "======= checking encryption key ======="
aws kms describe-key --key-id "alias/$KMS_ALIAS" >/dev/null 2>&1
if [ $? -gt 0 ]
then
    echo "======= setting up encryption key ======="
    KEY_ARN=$(aws kms create-key --description 'Key for encrypting SSH private keys' --query 'KeyMetadata.Arn' --output text)
    aws kms create-alias --alias-name "alias/$KMS_ALIAS" --target-key-id $KEY_ARN
    aws kms tag-resource \
        --key-id $KEY_ARN \
        --tags TagKey=Owner,TagValue=rahook \
               TagKey=Project,TagValue=provision-test\
               TagKey=Name,TagValue=$KMS_ALIAS
fi
KEY_ARN=$(aws kms describe-key --key-id "alias/$KMS_ALIAS" --query 'KeyMetadata.Arn' --output text)
echo "Encryption key ARN = $KEY_ARN"


# for each user, if they don't have a private key in secretsmanager,
# make a new keypair and store it
mkdir -p data
cd data
for USER in $USERS
do
  aws secretsmanager describe-secret --secret-id ssh/$USER >/dev/null 2>&1
  if [ $? -gt 0 ]
  then
      echo "======= making key for $USER ======="
      ssh-keygen -b 4048 -t rsa -C $USER -f $USER -N  "" -q
      mv $USER $USER.pem
      chmod 400 $USER*

      echo "==> storing $USER private key "
      # store private key in secrets manager
      aws secretsmanager create-secret\
        --name ssh/$USER \
        --secret-string file://$USER.pem \
        --kms-key-id $KEY_ARN \
        --description "SSH private key for $USER" \
        --query ARN --output text

      echo "==> storing $USER public key "
      # store public key in provisioning bucket!
      aws s3api put-object \
        --bucket $BUCKET \
        --key users/$USER/$USER.pub \
        --body $USER.pub \
        --acl bucket-owner-full-control \
        --query ETag --output text
  fi
done
cd ..
rm -rf data
