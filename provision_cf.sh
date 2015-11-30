#!/bin/bash
BOSH_DIRECTOR_IP=${1}
STEMCELL=${2}
WORKSPACE=$HOME/workspace
CF_RELEASE=$WORKSPACE/cf-release
AWS_MANIFEST_STUB=$WORKSPACE/aws_manifest_stub.yml

echo Bosh director lives on: $BOSH_DIRECTOR_IP
echo CF_RELEASE is at $CF_RELEASE

cd $HOME

echo Updating Aptitude and installing dependencies...
sudo apt-get update -y
sudo apt-get install -y git unzip wget
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

echo Installing Bosh CLI

#sudo chown ubuntu:ubuntu .gem -R

curl -s https://raw.githubusercontent.com/cloudfoundry-community/traveling-bosh/master/scripts/installer | bash
source /home/ubuntu/.bashrc
sudo gem install bundler --no-ri --no-doc

echo Installing spiff
wget -qq https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip
unzip -q -o spiff_linux_amd64.zip
sudo cp spiff /usr/bin/

mkdir -p $WORKSPACE

cd $WORKSPACE

echo Creating stub manifest for system domain $BOSH_DIRECTOR_IP.xip.io

cat > $AWS_MANIFEST_STUB <<EOL
---
properties:
  domain: $BOSH_DIRECTOR_IP.xip.io
EOL

echo Targeting Bosh Lite
bosh -u admin -p admin target $BOSH_DIRECTOR_IP
bosh login admin admin

echo Uploading stemcell
bosh -q -n upload stemcell https://s3.amazonaws.com/bosh-warden-stemcells/bosh-stemcell-3126-warden-boshlite-ubuntu-trusty-go_agent.tgz

echo Cloning Bosh Lite from GitHub...
git clone -q https://github.com/cloudfoundry/cf-release.git

cd $CF_RELEASE

echo Updating CF release
./scripts/update &>/dev/null

echo Generating manifest
sudo ./scripts/generate-bosh-lite-dev-manifest $AWS_MANIFEST_STUB

echo Creating release
bosh create release --name cf
echo Uploading release
bosh -n upload release
echo Deploying!
bosh -n deploy
echo Done! Use "'cf api --skip-ssl-validation https://api.$BOSH_DIRECTOR_IP.xip.io'" to connect to the CF deployment.
