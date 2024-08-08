#!/bin/bash
sudo apt-get update
sudo apt-get upgrade

#install NodeJs 18/npm
sudo apt-get install curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install nodejs

sudo apt-get update
sudo apt-get upgrade
#install nginx
sudo apt-get install -y nginx
systemctl start nginx
#git clone the app and cd into the app to install NPM
git clone https://github.com/DonovanSalgado2209/AzureJenkinsTerraform.git
cd https://github.com/DonovanSalgado2209/AzureJenkinsTerraform.git

npm install
npm run build
npm run start
#navigate to uripaddress:3000

