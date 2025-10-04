<#
.SYNOPSIS
  Script to easily generate an SSH keygen
.DESCRIPTION
  This PowerShell script helps to create an SSH key for Windows OS.
.EXAMPLE
	PS> ./gen_ssh.ps1
    Generate-SSHKey
    Check-SSHAgent
    Add-SSH
    Open-PubKey
.LINK
	https://github.com/ademarmanyener/scripts
.NOTES
	Author: Âdem Arman Yener <ademarmanyener@gmail.com>
#>

param(
    [ValidateSet("dsa", "ecdsa", "ecdsa-sk", "ed25519", "ed25519-sk", "rsa")]
    [string]$Algorithm = "ed25519",

    [int]$KeyLength = 0,

    [Parameter(Mandatory=$true, HelpMessage="Provide an e-mail address.")]
    [string]$EmailAddress
)

function Generate-SSHKey {
    Process {
        if ($Algorithm -eq "rsa") {
           Write-Host "RSA algorithm"
           ssh-keygen -t $Algorithm -b $KeyLength -C $EmailAddress
        } else {
           Write-Host "Other algorithm ($($Algorithm))"
           ssh-keygen -t $Algorithm -C $EmailAddress
        }
    }
}

function Check-SSHAgent {
    $agent_serv_stat = (Get-Service -Name "ssh-agent").Status

    if ($agent_serv_stat -ne "Running") {
        Get-Service -Name ssh-agent | Set-Service -StartupType Manual

        Start-Service ssh-agent
    }
}

function Add-SSH {
    ssh-add "$($HOME)\.ssh\$($Algorithm)"
}

function Open-PubKey {
    notepad "$($HOME)\.ssh\$($Algorithm).pub"
}

try {
    $stop_watch = [system.diagnostics.stopwatch]::startNew()

    Generate-SSHKey
    Check-SSHAgent
    Add-SSH
    Open-PubKey

    [int]$elapsed_time = $stop_watch.Elapsed.TotalSeconds
    Write-Output "Total elapsed time (in seconds): $($elapsed_time)s"
    exit 0
} catch {
    Write-Output "Error: $($Error[0]) (Script line: $($_.InvocationInfo.ScriptLineNumber))"
    exit 1
}
