
$ip = Read-Host("Enter the IP of the printer you want to search: ")

$url = "https://" + $ip + "/DevMgmt/ProductConfigDyn.xml"
$urlConsumables = "https://" + $ip + "/DevMgmt/ConsumableConfigDyn.xml"
function get_ink_levels(){
	$res = Invoke-Webrequest -SkipCertificateCheck $urlConsumables
	[xml]$data = $res.Content
	$levels = New-Object System.Object
	foreach($level in $data.ConsumableConfigDyn.ConsumableInfo){
		switch ($level.ConsumableStation){
			0 {$levels | ADD-MEMBER -Membertype NoteProperty -Name "Printhead" -Value "Ignored"}
			1 {$levels | ADD-MEMBER -Membertype NoteProperty -Name "Yellow" -Value $level.ConsumablePercentageLevelRemaining}
			2 {$levels | ADD-MEMBER -Membertype NoteProperty -Name "Magenta" -Value $level.ConsumablePercentageLevelRemaining}
			3 {$levels | ADD-MEMBER -Membertype NoteProperty -Name "Cyan" -Value $level.ConsumablePercentageLevelRemaining}
			4 {$levels | ADD-MEMBER -Membertype NoteProperty -Name "Black" -Value $level.ConsumablePercentageLevelRemaining}
		}
	}
	return $levels
}

function get_serial(){
	try{
		$res = Invoke-Webrequest -SkipCertificateCheck $url
		[xml]$xml = $res.Content
	}catch {
		Write-Host "Error"
	}
	return $xml.ProductConfigDyn.ProductInformation.SerialNumber
}

$serial = get_serial
$y = get_ink_levels

Write-Host $serial ($y | Format-List | Out-String)
