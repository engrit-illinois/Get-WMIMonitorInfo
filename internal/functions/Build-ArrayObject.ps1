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