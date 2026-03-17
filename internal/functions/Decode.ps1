function Decode {
	# Source: https://support.moonpoint.com/os/windows/PowerShell/monitor_mfg.php
	if($args[0] -is [System.Array]) {
		$decoded = [System.Text.Encoding]::ASCII.GetString($args[0])
	}
	else {
		$decoded = "Undecodable"
	}
	
	"$decoded"
}