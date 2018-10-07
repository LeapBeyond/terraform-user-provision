note key policy in bootstrap/infrastucture has hardwired ARN for role

aws --profile adm_rhook_cli secretsmanager   get-secret-value   --secret-id ssh/betty   --query SecretString   --output text > betty.pem ; chmod 400 betty.pem

$ ssh -i gwen.pem gwen@52.56.150.94
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
Connection to 52.56.150.94 closed.
Rozencrantz:data robert$ ssh -i gwen.pem gwen@52.56.150.94
Last login: Sun Oct  7 11:03:59 2018 from 88.98.207.26

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[gwen@ip-172-32-10-53 ~]$
