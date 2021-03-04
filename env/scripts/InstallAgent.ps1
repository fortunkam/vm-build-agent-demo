param ([String]$patToken,
        [string]$devopsUrl,
        [string]$agentPool,
        [string]$agentName)

mkdir c:\agent ; 
Set-Location c:\agent

Invoke-WebRequest "https://vstsagentpackage.azureedge.net/agent/2.165.0/vsts-agent-win-x64-2.165.0.zip" -OutFile "c:\agent\vsts-agent-win-x64-2.165.0.zip"


Add-Type -AssemblyName System.IO.Compression.FileSystem ; 

[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\agent\vsts-agent-win-x64-2.165.0.zip", "$PWD")

&"c:\agent\config.cmd" --unattended --url $devopsUrl --auth pat --token $patToken --pool $agentPool --agent $agentName --runAsService

powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\InstallChocolateyComponents.ps1



