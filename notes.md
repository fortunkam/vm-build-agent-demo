wish list

Create Windows Server VM with IIS on vnet (with public IP address)
Use managed build agent to grab index.md from repo, convert to html and publish to build artifacts.
Use self hosted deploy agent (on vnet) to push file to server using powershell

Build agent needs to run as an administrator account
server needs to have winrm https (5986?) port allowed on local firewall

demo_project contains a sample AzureDevops Pipeline to transform a markdown file to html and copy to the target server.