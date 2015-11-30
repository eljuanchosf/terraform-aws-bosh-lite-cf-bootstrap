# Terraform Bosh Lite Cloud Foundry Bootstrap

## Installation

First, go get [terraform](https://terraform.io/downloads.html). Unzip the file and make sure that the executable `terraform` is somewhere in your PATH.

## Configuring

Copy the `terraform.tfvars.example` to `terraform.tfvars` and edit this file. Replace the values of the placeholder variables with your values.

## Running
`terraform plan` will tell you the execution plan.
`terraform apply` will apply the changes, create the infrastructure and install Bosh Lite and Cloud Foundry.
To remove all components from AWS, do `terraform destroy`

## Disclaimer!

This is NOT for production use. I use it mainly to create Bosh Lite instances for demos, trainings and so on.
