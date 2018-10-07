# keys

The code in here uses the AWS cli and `ssh-keygen` to create SSH keypairs for several users. The private key is stored in SecretsManager, and the public key stored in the provisioning bucket.

This means of generating the keypairs is likely to change for your situation, particularly if the users are generating their own keypairs and only providing the public part of the key.

Obviously if the private keys are being stored in SecretsManager as shown here, they should have policies on them that only allow the owner of the key to retrieve them, which is not done in our example.

Retrieving the private key for use in testing later can be done using something like:

```
aws --profile ??? secretsmanager \
  get-secret-value \
  --secret-id ssh/betty \
  --query SecretString \
  --output text
```

## Usage

First copy `env.rc.template` to `env.rc` and update the missing values, which would have been obtained by executing the `bootstrap/infrastructure` project.

Then execute `create.sh` - this will report progress as it creates the KMS encryption key (if necessary) and the user SSH key pairs.
