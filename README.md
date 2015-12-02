# Terraform Bosh Lite Cloud Foundry Bootstrap

## Installation

First, go get [terraform](https://terraform.io/downloads.html). Unzip the file and make sure that the executable `terraform` is somewhere in your PATH.

## Configuring

Copy the `terraform.tfvars.example` to `terraform.tfvars` and edit this file. Replace the values of the placeholder variables with your values.
In order to protect and secure the AWS keys, you need to create two environment variables that will hold the AWS Key and secret key values.

* TF_VAR_aws_access_key
* TF_VAR_aws_secret_key

Example:

```
export TF_VAR_aws_access_key="THE_ACCESS_KEY_VALUE"
export TF_VAR_aws_secret_key="THE_SECRET_KEY_VALUE"
```

### Resource prefix

It is STRONGLY recommended that you assign a personal or unique identifier in the `prefix` variable in the `terraform.vars` file for better resource identification.
The default value is `my`, that will turn the names of the resources in `my-jumpbox`, `my-ssh-only`, etc.
Change it to something meaningful for you and your organization.
Other way of doing this is specifying the variable in the command line for using this script inside a bash script:

```
$ TF_VAR_prefix=myCoolPrefix terraform apply
```

## Running
`terraform plan` will tell you the execution plan.
`terraform apply` will apply the changes, create the infrastructure and install Bosh Lite and Cloud Foundry.
To remove all components from AWS, do `terraform destroy`

## Disclaimer!

This is NOT for production use. I use it mainly to create Bosh Lite instances for demos, trainings and so on.
