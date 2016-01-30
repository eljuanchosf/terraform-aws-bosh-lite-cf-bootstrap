#!/bin/bash

BOSH_LITE_IP=${1}

set -e
tmux new -d -s cf-install "/home/ubuntu/provision_cf.sh $BOSH_LITE_IP" \;
