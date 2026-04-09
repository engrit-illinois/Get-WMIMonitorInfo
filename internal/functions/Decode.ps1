function Decode {
	param(
		$Value
	)
	
	if(-not($Value -is [System.Array])) {
		return "Undecodable"
	}
	
	# https://learn.microsoft.com/en-us/answers/questions/1525390/command-to-get-monitor-model-number-and-serial-num
	# Filters out padding from EDID codes
	$valueUnpadded = $Value | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }
	
	$valueString = $valueUnpadded -join ""
	
	# Source: https://support.moonpoint.com/os/windows/PowerShell/monitor_mfg.php
	#$decoded = [System.Text.Encoding]::Unicode.GetString($args[0])
	
	$valueString
}