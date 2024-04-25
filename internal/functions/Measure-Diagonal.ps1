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