function Decode {
    # Source: https://support.moonpoint.com/os/windows/PowerShell/monitor_mfg.php
    If ($args[0] -is [System.Array]) {
        [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
        "Not Found"
    }
}

function Get-Manufacturer {
    param (
        $Monitor
    )
    $output = Decode $Monitor.ManufacturerName
    Write-Verbose "Raw decoded output for ManufacturerName is $output"
    switch ($output) {
        DEL {$output = "Dell"}
        HPN {$output = "HP"}
        HWP {$output = "HP"}
    }
    $output
}

function Build-ArrayObject {
    param(
        $WMIMonitorID,
        $WmiMonitorBasicDisplayParams
    )
    $output = New-Object System.Collections.ArrayList
    
    $output = [PSCustomObject]@{
        Manufacturer = Get-Manufacturer -Monitor $WMIMonitorID
        ProductCode = Decode $WMIMonitorID.ProductCodeID
        Serial = Decode $WMIMonitorID.SerialNumberID
        Name = Decode $WMIMonitorID.UserFriendlyName
        WeekOfManufacture = $WMIMonitorID.WeekOfManufacture
        YearOfManufacture = $WMIMonitorID.YearOfManufacture
        PSComputerName = $WMIMonitorID.PSComputerName
    }
    Write-Verbose $output
    $output
}

function Get-WMIMonitorInfo {
    [CmdletBinding()]
    param(
        [string]$ComputerName
    )
    $output = New-Object System.Collections.ArrayList

    $WMIMonitorID = Get-CimInstance -ClassName WMIMonitorID -Namespace root\wmi -ComputerName $ComputerName

    foreach($Monitor in $WMIMonitorID) {
        Write-Verbose $Monitor
        $Member = Build-ArrayObject -WMIMonitorID $Monitor
        $output.Add($Member) | Out-Null
    }
    $output
}
Export-ModuleMember Get-WMIMonitorInfo