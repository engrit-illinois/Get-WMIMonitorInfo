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
	
	# Initialize the output arraylist
	$output = New-Object System.Collections.ArrayList
	
	$cimParams = @{
		"ErrorAction" = "Stop"
		"Namespace" = "root\wmi"
	}
	
	if($ComputerName) {
		
		# Bail if the computer can't be pinged
		if(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
			Write-Verbose "Successfully pinged $ComputerName"
		}
		else {
			Throw "Could not ping remote computer $ComputerName."
		}
		
		$cimParams.ComputerName = $ComputerName
	}
	
	# Get all monitor info for all monitors
	try {
		$id = Get-CimInstance -ClassName WMIMonitorID @cimParams
		$displayParams = Get-Ciminstance -ClassName WmiMonitorBasicDisplayParams @cimParams
		$connectionParams = Get-CimInstance -ClassName WmiMonitorConnectionParams @cimParams
	}
	catch {
		Throw "Error gathering monitor info from computer `"$ComputerName`"!"
	}
	
	# Loop through each monitor's ID info object
	$monitors = $id | ForEach-Object {
		$monitor = $_
		
		# Add this monitor's display param info object as a child object
		$monitorDisplayParams = $displayParams | Where { $_.InstanceName -eq $monitor.InstanceName }
		$monitor | Add-Member -NotePropertyName "DisplayParams" -NotePropertyValue $monitorDisplayParams
		
		# Add this monitor's connection param info object as a child object
		$monitorConnectionParams = $connectionParams | Where { $_.InstanceName -eq $monitor.InstanceName }
		$monitor | Add-Member -NotePropertyName "ConnectionParams" -NotePropertyValue $monitorConnectionParams
		
		$monitor
	}
	
	$monitors | ForEach-Object {
		Build-ArrayObject -Monitor $_
	}
}