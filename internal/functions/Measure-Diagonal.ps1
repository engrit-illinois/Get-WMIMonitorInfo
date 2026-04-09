function Measure-Diagonal {
	param (
		$Horizontal,
		$Vertical
	)
	Write-Verbose "Horizontal in.: $Horizontal, Vertical in.: $Vertical"
	
	# Convert to Inches from CM
	$Horizontal	= [System.Math]::Round(($Horizontal/2.54),2)
	$Vertical	= [System.Math]::Round(($Vertical/2.54),2)
	Write-Verbose "Horizontal cm.: $Horizontal, Vertical cm.: $Vertical"
	
	# Pythagorean Theorem rounded to the nearest inch
	$Diagonal = [System.Math]::Round([System.Math]::Sqrt([System.Math]::Pow($Horizontal,2) + [System.Math]::Pow($Vertical,2)),0)
	Write-Verbose "Diagonal: $Diagonal"
	
	"$Diagonal"
}