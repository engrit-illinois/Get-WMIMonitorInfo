function Build-ArrayObject {
	param(
		$Monitor
	)
	
	[PSCustomObject]@{
		PSComputerName =		($Monitor.PSComputerName).Trim()
		Manufacturer =			(Get-Manufacturer $Monitor.ManufacturerName).Trim()
		ProductCode =			(Decode $Monitor.ProductCodeID).Trim()
		Serial =				(Decode $Monitor.SerialNumberID).Trim()
		Name =					(Decode $Monitor.UserFriendlyName).Trim()
		WeekOfManufacture =		("$($Monitor.WeekOfManufacture)").Trim()
		YearOfManufacture =		("$($Monitor.YearOfManufacture)").Trim()
		Size =					(Measure-Diagonal $Monitor.DisplayParams.MaxHorizontalImageSize $Monitor.DisplayParams.MaxVerticalImageSize).Trim()
		Ratio =					(Measure-Ratio $Monitor.DisplayParams.MaxHorizontalImageSize $Monitor.DisplayParams.MaxVerticalImageSize).Trim()
		VideoOutputTechnology =	(Get-VideoOutputTechnology $Monitor.ConnectionParams.VideoOutputTechnology).Trim()
	}
}