<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.PARAMETER ParameterName
    Description of parameter input

.EXAMPLE
    PS>

    Example of how to use this cmdlet

.EXAMPLE
    PS>

    Another example of how to use this cmdlet

.LINK
    Any related function or website

.NOTES
    General notes
#>


<#PSScriptInfo
.VERSION 1.0.0

.AUTHOR USERNAME

.GUID be7e5b3f-2024-0415-1759-32afcca5c65a

.TAGS tags

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.RELEASENOTES
    1.0.0 - Initial Release
#>

[CmdletBinding()]

param(
    [Parameter()]
    [PSObject] $ParameterName
)

function Get-WMIMonitorInfo {
    [CmdletBinding()]
    param(
        [string]$ComputerName
    )

    if(-not (Get-Module JoinModule)){
        Write-Verbose "JoinModule was not detected!"
        if($PSVersionTable.PSEdition -eq "Core") {
            Write-Verbose "PowerShell Core detected, Installing JoinModule..."
            Install-Module JoinModule
        }else{
            if(([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent() `
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                Write-Verbose "Admin check succeeded, Installing JoinModule..."
                Install-Module JoinModule    
            }else{
                Write-Error "Need to be admin to install dependency JoinModule! Aborting operation."
            }
        }
    }

    # Initialize the output arraylist
    $output = New-Object System.Collections.ArrayList

    if($ComputerName){
        if(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            Write-Verbose "Successfully pinged $ComputerName"
        }else{
            Write-Error "Could not ping remote computer $ComputerName."
        }
        $WMIMonitorID =                 Get-CimInstance -Namespace root\wmi -ClassName WMIMonitorID -ComputerName $ComputerName -ErrorAction SilentlyContinue
        $WmiMonitorBasicDisplayParams = Get-Ciminstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ComputerName $ComputerName -ErrorAction SilentlyContinue
        $WmiMonitorConnectionParams   = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams -ComputerName $ComputerName -ErrorAction SilentlyContinue
    }else{
        $WMIMonitorID =                 Get-CimInstance -ClassName WMIMonitorID -Namespace root\wmi -ErrorAction SilentlyContinue
        $WmiMonitorBasicDisplayParams = Get-Ciminstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction SilentlyContinue
        $WmiMonitorConnectionParams   = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams -ErrorAction SilentlyContinue
    }

    # Join the two WMI Classes so they can be parsed together
    if($WMIMonitorID -and $WmiMonitorBasicDisplayParams -and $WmiMonitorConnectionParams){
        $Combined = $WMIMonitorID | 
            Join-Object $WmiMonitorBasicDisplayParams -On InstanceName,PSComputerName |
            Join-Object $WmiMonitorConnectionParams -On InstanceName,PSComputerName
    }else{
        Write-Error "No result returned for Monitor Info for $ComputerName. Does your target computer actually have monitors?"
    }

    foreach($Monitor in $Combined) {
        Write-Verbose $Monitor
        $Member = Build-ArrayObject -Monitor $Monitor
        $output.Add($Member) | Out-Null
    }
    $output
}