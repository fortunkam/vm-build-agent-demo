# VM self host build agent talking to VM using WinRM

This repo contains a terraform script that will deploy the following

* A vnet containing 2 subnets
* An Azure DevOps build agent on the vnet (build subnet) with no public ip
* A VM with IIS installed and configured for WinRM over HTTPS
* A Key Vault containing the cert used to secure WinRM and the passwords for both VMs

There is a sample azure devops project including a multi stage pipeline that will

## Build Stage (uses a built-in MS Hosted agent)
* "Build" the included markdown file, turning it into HTML
* Store the HTML as a Build artifact

## Deploy Stage (uses the deployed self host agent)
* Deploy the HTML file to the server (browse to the ip address of the server over http to see the updated file)
* This uses WinRM and powershell to deploy.

For more details see the Notes.md