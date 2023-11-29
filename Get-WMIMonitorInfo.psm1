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
        WAC {$output = "Wacom"}
        TSB {$output = "Toshiba"}
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
    switch($Ratio){
        {$_ -ge 1.70 -and $_ -le 1.85} {$Numerator = 16; $Denominator = 9}
        {$_ -ge 1.57 -and $_ -le 1.63} {$Numerator = 16; $Denominator = 10}
        {$_ -ge 1.20 -and $_ -le 1.40} {$Numerator = 4; $Denominator = 3}
    }

    if($Numerator -and $Denominator){
        $output = "$($Numerator):$($Denominator)"
    }
    if($output){
        $output
    }else{
        $Ratio
    }
}

function Get-VideoOutputTechnology {
    param(
        $Monitor
    )

    $output = $Monitor.VideoOutputTechnology

    switch($output) {
        -2          {"Unassigned"}
        -1          {"Unknown"}
        0           {"VGA"}
        1           {"S-vidio"}
        2           {"Composite Video"}
        3           {"Component Video"}
        4           {"DVI"}
        5           {"HDMI"}
        6           {"LVDS"}
        8           {"D-Jpn"}
        9           {"SDI"}
        10          {"External DisplayPort"}
        11          {"Embedded DisplayPort"}
        12          {"External UDI"}
        13          {"Embedded UDI"}
        14          {"SDTV"}
        15          {"Miracast"}
        16          {"Wired Indirect Display"}
        2147483648  {"Internal Laptop Display"}
        Default     {$output}
    }
    
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
        VideoOutputTechnology =     Get-VideoOutputTechnology -Monitor $Monitor
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
                throw "Need to be admin to install dependency JoinModule! Aborting operation."
            }
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
        $WMIMonitorID =                 Get-CimInstance -Namespace root\wmi -ClassName WMIMonitorID -ComputerName $ComputerName -ErrorAction SilentlyContinue
        $WmiMonitorBasicDisplayParams = Get-Ciminstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ComputerName $ComputerName -ErrorAction SilentlyContinue
        $WmiMonitorConnectionParams   = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams -ComputerName $ComputerName -ErrorAction SilentlyContinue
    }else{
        $WMIMonitorID =                 Get-CimInstance -ClassName WMIMonitorID -Namespace root\wmi -ErrorAction SilentlyContinue
        $WmiMonitorBasicDisplayParams = Get-Ciminstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction SilentlyContinue
        $WmiMonitorConnectionParams   = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams -ErrorAction SilentlyContinue
    }

    # Join the two WMI Classes so they can be parsed together
    if($WMIMonitorID -and $WmiMonitorBasicDisplayParams){
        $Combined = $WMIMonitorID | 
            Join-Object $WmiMonitorBasicDisplayParams -On InstanceName,PSComputerName |
            Join-Object $WmiMonitorConnectionParams -On InstanceName,PSComputerName
    }else{
        Write-Error "No result returned for Monitor Info. Does your target computer actually have monitors?"
        break
    }

    foreach($Monitor in $Combined) {
        Write-Verbose $Monitor
        $Member = Build-ArrayObject -Monitor $Monitor
        $output.Add($Member) | Out-Null
    }
    $output
}
Export-ModuleMember Get-WMIMonitorInfo