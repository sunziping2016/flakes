## Get Started

This directory contains the Terraform code for our basic infrastructure.
It is structured like this:
- `/modules/`: reuseable modules. See [Standard Module Layout](https://developer.hashicorp.com/terraform/language/modules/develop/structure) for the structure of each module.
- `/roots/`: root modules.
- `/files/`: static files referred from modules. Templates should use the file extension `.tftpl`.


## Step 0: setup backends

These steps have been done to setup basic environment needed by this repo.
TODO: make the following setup to be code. See [this](https://angelo-malatacca83.medium.com/aws-terraform-s3-and-dynamodb-backend-3b28431a76c1) for an example.
1. register an AWS account and create a IAM user
2. update `dotenv.secrets.yaml` with the IAM user's credentials.
3. create a s3 bucket `szpio-apse1-terraform-backend`, in which versioning, object locking and service side encryption are all enabled.
4. create a dynamodb table `TerraformStateLock` whose partition key is `LockID`
