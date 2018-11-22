Import-Module ActiveDirectory  

$users = Import-Csv -Path C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\UserDetailsUpdate\SetExpiry.csv
$Date = (Get-Date -Format "dd-MMM-yyyy")

foreach ($user in $users)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$SAM 		= $User.SSOID
	$Name		= $User.Name
	$TimeSpan	= $User.ExpiresOn
If ($SAM)
	{
	Set-ADAccountExpiration -Identity $SAM -TimeSpan $TimeSpan
	$Expiry = [DateTime](Get-ADuser $SAM -Properties *).accountExpires
	$ExpDate1 = $Expiry.AddYears(1600).ToLocalTime()
	$ExpDate = $ExpDate1.AddDays(-1).ToString('dd-MMM-yyyy')
	Write-output "Expiry Date of $SAM : $Name has been set to $ExpDate successfully!"
	Write-output "Expiry Date of $SAM : $Name has been set to $ExpDate successfully!" | `
	Out-File -FilePath "C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\UserDetailsUpdate\Logs\Expiry-Updated-$Date-Log.txt" -Append
	}
Else 
	{
	Write-Warning "User $SAM : $Name not available in AD"
	Write-Warning "User $SAM : $Name not available in AD" | `
	Out-File -FilePath "C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\UserDetailsUpdate\Logs\Expiry-Updated-$Date-Log.txt" -Append
	}
} #End ForEach
