function Build-ArrayObject {
	param(
		$Monitor
	)
	
	[PSCustomObject]@{
		PSComputerName			= $Monitor.PSComputerName
		Manufacturer			= Get-Manufacturer $Monitor.ManufacturerName
		#ProductCodeRaw			= $Monitor.ProductCodeID
		#ProductCodeRawFull		= "$($Monitor.ProductCodeID -join ",")"
		ProductCode				= Decode $Monitor.ProductCodeID
		#SerialRaw				= $Monitor.SerialNumberID
		#SerialRawFull			= "$($Monitor.SerialNumberID -join ",")"
		Serial					= Decode $Monitor.SerialNumberID
		#NameRaw				= $Monitor.UserFriendlyName
		#NameRawFull			= "$($Monitor.UserFriendlyName -join ",")"
		Name					= Decode $Monitor.UserFriendlyName
		WeekOfManufacture		= "$($Monitor.WeekOfManufacture)"
		YearOfManufacture		= "$($Monitor.YearOfManufacture)"
		Size					= Measure-Diagonal $Monitor.DisplayParams.MaxHorizontalImageSize $Monitor.DisplayParams.MaxVerticalImageSize
		Ratio					= Measure-Ratio $Monitor.DisplayParams.MaxHorizontalImageSize $Monitor.DisplayParams.MaxVerticalImageSize
		VideoOutputTechnology	= Get-VideoOutputTechnology $Monitor.ConnectionParams.VideoOutputTechnology
		RawMonitorInfo			= $Monitor
	}
}