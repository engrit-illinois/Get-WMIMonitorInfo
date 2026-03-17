function Get-Manufacturer {
	param (
		$ManufacturerName
	)
	switch(Decode $ManufacturerName) {
		"DEL" { "Dell" }
		"HPN" { "HP" }
		"HWP" { "HP" }
		"ACI" { "ASUS" }
		"WAC" { "Wacom" }
		"TSB" { "Toshiba" }
		"VSC" { "ViewSonic" }
		"BBY" { "Best Buy" }
		"CEI" { "Crestron" }
		"ATL" { "Atlona" }
		"PNR" { "Planar" }
	}
}