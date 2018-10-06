# bootstrap

This is broken into two parts. `backend` sets up assets for Terraform to store it's state in later stages and creates an SSH key pair we will later assign to the instance.

## Usage

First enter the `backend` folder and read the `README.md` for instructions there, before executing it. Note the outputs of that project, you will need to supply them for the definitions of the `infrastructure` and other projects.

Next enter the `infrastucture` folder, use the values from `backend` as described in the README.md, and apply the assets there.
