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
        ACI {$output = "ASUS"}
    }
    $output
}

function Measure-Diagonal {
    param (
        $Monitor
    )

    $Horizontal =   $Monitor | Select-Object -ExpandProperty MaxHorizontalImageSize
    $Vertical =     $Monitor | Select-Object -ExpandProperty MaxVerticalImageSize

    # Convert to Inches from CM
    $Horizontal =   [System.Math]::Round(($Horizontal/2.54),2)
    $Vertical =     [System.Math]::Round(($Vertical/2.54),2)

    # Pythagorean Theorem rounded to the nearest inch
    $Diagonal = [System.Math]::Round([System.Math]::Sqrt([System.Math]::Pow($Horizontal,2) + [System.Math]::Pow($Vertical,2)),0)
    $Diagonal
}

function Measure-Ratio {
    param(
        $Monitor
    )

    $Horizontal =   $Monitor | Select-Object -ExpandProperty MaxHorizontalImageSize
    $Vertical =     $Monitor | Select-Object -ExpandProperty MaxVerticalImageSize

    # Convert to Inches from CM
    $Horizontal =   [System.Math]::Round(($Horizontal/2.54),2)
    $Vertical =     [System.Math]::Round(($Vertical/2.54),2)

    $Ratio = [System.Math]::Round(($Horizontal/$Vertical),2)
    $Ratio
}

function Build-ArrayObject {
    param(
        $Monitor
    )
    $output = New-Object System.Collections.ArrayList
    
    $output = [PSCustomObject]@{
        Manufacturer =              Get-Manufacturer -Monitor $Monitor
        ProductCode =               Decode $Monitor.ProductCodeID
        Serial =                    Decode $Monitor.SerialNumberID
        Name =                      Decode $Monitor.UserFriendlyName
        WeekOfManufacture =         $Monitor.WeekOfManufacture
        YearOfManufacture =         $Monitor.YearOfManufacture
        Size =                      Measure-Diagonal -Monitor $Monitor
        Ratio =                     Measure-Ratio -Monitor $Monitor
        PSComputerName =            $Monitor.PSComputerName
    }
    Write-Verbose $output
    $output
}

function Get-WMIMonitorInfo {
    [CmdletBinding()]
    param(
        [string]$ComputerName
    )

    if(-not (Get-Module JoinModule)){
        Write-Verbose "JoinModule was not detected!"
        if($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Verbose "Running on normal PowerShell; Checking if we're running as Admin..."
            if(([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent() `
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {       # Check that we're running as Admin before installing the module
                Write-Verbose "Admin check succeeded, Installing JoinModule..."
                Install-Module JoinModule    
            }else{
                throw "Need to be admin to install dependency JoinModule! Aborting operation."
            }
        }else{ 
            Write-Verbose "Installing JoinModule..."
            Install-Module JoinModule
        }
    }

    # Initialize the output arraylist
    $output = New-Object System.Collections.ArrayList

    if($ComputerName){
        if(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            Write-Verbose "Successfully pinged $ComputerName"
        }else{
            throw "Could not ping remote computer."
        }
        $WMIMonitorID =                 Get-CimInstance -Namespace root\wmi -ClassName WMIMonitorID -ComputerName $ComputerName
        $WmiMonitorBasicDisplayParams = Get-Ciminstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ComputerName $ComputerName
    }else{
        $WMIMonitorID =                 Get-CimInstance -ClassName WMIMonitorID -Namespace root\wmi
        $WmiMonitorBasicDisplayParams = Get-Ciminstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
    }

    # Join the two WMI Classes so they can be parsed together
    $Combined = $WMIMonitorID | Join-Object $WmiMonitorBasicDisplayParams -On InstanceName,PSComputerName

    foreach($Monitor in $Combined) {
        Write-Verbose $Monitor
        $Member = Build-ArrayObject -Monitor $Monitor
        $output.Add($Member) | Out-Null
    }
    $output
}
Export-ModuleMember Get-WMIMonitorInfo