# Usage

## Pre-Requisites

Please make sure you have `sshpass` installed locally. You can do this by simply `sudo apt-get install sshpass -y`

Please also make sure you have Terraform v0.11.13 installed and have logged into the Azure CLI with `az login`

# Creating Infrastructure

To start with, initialise terraform and plan and apply the infrastructure hosted on Azure. It will bring up an Ubuntu 18.04-LTS OS with a public IP which we will use to configure ansible later.

`terrafrom init`

`terraform plan`

`terrafrom apply` and type "yes" to apply changes

This should create 7 resources within the Azure resource group and output the public IP (keep this handy for the next part)

Note: If no Public IP is displayed, you will need to log into the Azure portal to get it

## Configuring Ansible Inventory

Within the body of the repository will be a file name `hosts`. 

Open this file with vim and replace the XXXXXXXX with the public IP.

Now we need to copy the contents of this file to append the contents of `/etc/ansible/hosts`

`sudo cat hosts >> /etc/ansible/hosts`

## Ignore Fingerprint Check

Extra step to ignore finger print checking when running playbook on a new machine

Run `export ANSIBLE_HOST_KEY_CHECKING=False`


# Run Playbook

Pre-configuration is now complete and we can run the playbook

Run `ansible-playbook InstallTomcat.yml`

This will run for 7-10 mins


## Browser Test

If all of the above ran successfully, you should now be able to open a browser and get the tomcat splashpage `http://PUBLIC_IP:8080`


### Cleanup

Make sure to destroy the infrastructure after finishing up to save on costs of on demand resources.

Run `terraform destroy` and type "yes" when prompted



Author - Dan Kulkarni





