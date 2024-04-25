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