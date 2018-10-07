# terraform-user-provision

This project explores a niggling problem - how to provision individual SSH keys and user accounts onto a linux host in a convenient fashion.

There are many solutions to this problem, but the key to this solution is that it ensures that a set of user accounts and SSH keys are provisioned reliably onto the host when the host is created.

Some other solutions which are feasible according to your needs include:

  - storing public keys in Git and making them part of the Terraform assets;
  - manually creating the accounts, but storing the user home directories and account definitions on persistent volumes attached to the instance at boot time;
  - using Ansible or similar orchestration tools to install the user accounts after the instance has been deployed.

The specific intention of the illustrated solution here is to disconnect definition and storage of the user public keys and other startup assets from the definition of the instance itself.

Be aware when reading this that this is not illustrating a general-purpose user management solution - the set of users is fixed at the time of instance deployment, and there's no mechanism for adding and removing users subsequent to that point. In part this is driven by a philosophy of the hosts being ephemeral and discarded and rebuilt rather than being updated.

There are three sub-projects here, separating out the different "layers" in a simulation of a more complete solution:

 - `bootstrap` is used to setup a VPC and subnet to place the instance in, and an S3 bucket used to hold provisioning materials. In a "real" solution this is likely to seldom change, and for the deployed assets to have very long life spans;
 - `keys` creates and deploys public keys into the provisioning bucket. Again, in a "real" solution this part of the mechanism would need to customised for local requirements and needs. In the demonstration project, dummy users are setup, and we take advantage of ability of EC2 to store private keys securely;
 - `instance` creates the EC2 instance we deploy onto.

## Security
An important note on security in this solution: the scripts all assume they are being executed by a user or role with a very high level of AWS permissions.

Additionally, there is minimal treatment of the security of the EC2 host or storage of the keys. In a real solution considerably more thought needs to be put into managing access to the S3 provisioning bucket, and (in this case) managing access to the private keys in EC2.


## Usage

  1. apply `bootstrap/backend` according to the instructions there.
  1. apply `bootstrap/infrastucture` according to the instructions there, and using the values from the previous step.
  1. apply `keys` according to the instructions there, and using the values from the previous step.
  1. apply `instance` according to the instructions there, and using the values from the previous step.

To tear down what has been created, go in the reverse order, noting the instructions in each of the sub projects on how to teardown what they created:

  1. `instance`
  1. `keys`
  1. `bootstrap/infrastucture`
  1. `bootstrap/backend`
