variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "aws_jumpbox_ami" {}
variable "aws_bosh_lite_ami" {}
variable "prefix" {}
variable "bosh_lite_stemcell" {}

variable "aws_region" {
  default = "us-east-1"
}

# Variables for Jumpbox

variable "aws_jumpbox_instance_type" {
  default = "m4.large"
}

variable "jumpbox_name" {
  default = "jumpbox"
}

variable "jumpbox_security_group" {
  default = "allow-ssh"
}

# Variables for BOSH Lite

variable "aws_bosh_lite_instance_type" {
  default = "m3.xlarge"
}

variable "bosh_lite_box_name" {
  default = "bosh-lite"
}

variable "bosh_lite_security_group" {
  default = "allow-ssh-bosh-lite-cf"
}
