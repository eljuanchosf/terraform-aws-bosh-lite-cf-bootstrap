#!/bin/bash

set -e

SSH_CONFIG_FILE=~/.ssh/config
ADD_TO_SSH_CONFIG=false
MYSQL=false
LOGSEARCH=false
FORCE=false
PREFIX=""

until [[ $PREFIX =~ ^[A-Za-z_]+$ ]]; do
  PREFIX=$(shuf -n 1 /usr/share/dict/words) # This line gets a random word from dictionary
done

TERRAFORM_COMMAND=$1
shift

if [[ $TERRAFORM_COMMAND = "help" ]]; then

  cat <<EOL
Usage:
  ./shape.sh command -p=[prefix] --add-jumpbox --mysql --logsearch

  command: any Terraform command
  -p (or --prefix): the prefix for the infrastructure names.
  --add-jumpbox: once the deploy is done, this flag will add the jumpbox SSH configuration to the SSH config file.
  --mysql - NOT IMPLEMENTED -: deploys also the MySQL BOSH Release
  --logsearch - NOT IMPLEMENTED -: deploys also the ELK BOSH Releases

EOL
fi

for i in "$@"
do
case $i in
    -p=*|--prefix=*)
    PREFIX="${i#*=}"
    shift # past argument=value
    ;;
    --force)
    FORCE=true
    shift
    ;;
    --add-jumpbox)
    ADD_TO_SSH_CONFIG=true
    shift
    ;;
    --mysql)
    MYSQL=true
    shift
    ;;
    --logsearch)
    LOGSEARCH=true
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

if [[ $TERRAFORM_COMMAND = "apply" ]]; then
  echo You will be deploying Bosh Lite/CF with the following config:
  echo -------------------------------------------------------------
  echo -e "AWS Resource Prefix: \e[32m${PREFIX}\e[0m"
  echo -e "Add Jumpbox to $SSH_CONFIG_FILE: \e[31m${ADD_TO_SSH_CONFIG}\e[0m"
  echo -e "Deploy MySQL BOSH Release: \e[31m${MYSQL}\e[0m"
  echo -e "Deploy Logsearch BOSH Release: \e[31m${LOGSEARCH}\e[0m"

  if [[ $FORCE = false ]]; then
    echo
    read -p "Are you sure? (Y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo
        exit 1
    fi
  fi
fi

export TF_VAR_prefix="${PREFIX}"
terraform $TERRAFORM_COMMAND

if [[ $TERRAFORM_COMMAND = "apply" ]]; then
  JUMPBOX_IP=$(terraform output jumpbox_ip)
  KEY_PATH=$(terraform output aws_key_path)

  if [[ $ADD_TO_SSH_CONFIG = true ]]; then
    cat >> $SSH_CONFIG_FILE <<EOL
Host ${PREFIX}_jumpbox
  User ubuntu
  HostName ${JUMPBOX_IP}
  Port 22
  IdentityFile ${KEY_PATH}
EOL
    echo -e "\nYou can access the jumpbox by doing: \e[97mssh ${PREFIX}_jumpbox\e[0m\n"
  else
    echo -e "\nYou can access the jumpbox by doing: \e[97mssh -i ${KEY_PATH} ubuntu@${JUMPBOX_IP}\e[0m\n"
  fi
fi
