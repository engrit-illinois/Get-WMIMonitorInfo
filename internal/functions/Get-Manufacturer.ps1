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
        VSC {$output = "ViewSonic"}
    }
    $output
}