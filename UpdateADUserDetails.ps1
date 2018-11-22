Import-Module ActiveDirectory  

$users = Import-Csv -Path C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\UserDetailsUpdate\Updated_Users_03-Oct-18.csv
$Date = (Get-Date -Format "dd-MMM-yyyy")

foreach ($user in $users)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$EmployeeID 	= $User.EMPLOYEE_ID
	$name 		= $User.EMPLOYEE_NAME
	$Firstname,$Middlename,$Lastname = $User.EMPLOYEE_NAME –split ' '
	$surname	= ('{0} {1}' -f $Middlename, $Lastname).TrimEnd()
	$OU 		= $User.OU #OU the user account is to be created in
	$Office		= $User.LOCATION
    	$email      	= $User.EMAIL_ID
   	$jobtitle   	= $User.DESIGNATIONNAME
	$manager	= $User.REPORTINGTO
    	$department	= $User.BUSINESS
	$company	= $User.OUNAME 
If ($EmployeeID -And $manager)
	{
	Get-ADUser -Filter "sAMaccountname -eq $EmployeeID" |
	Set-ADUser `
	-EmailAddress $email `
	-Department $department `
	-Title $jobtitle `
	-Office $office `
	-Company $company `
	-Manager $Manager
	Write-output "Details of $EmployeeID : $name updated successfully!" | `
	Out-File -FilePath "C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\UserDetailsUpdate\Logs\Updated-Users-$Date-Log.txt" -Append
	}
Else 
	{
	Write-Warning "Manager name for $name Not available." | `
	Out-File -FilePath "C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\UserDetailsUpdate\Logs\Updated-Users-$Date-Log.txt" -Append
	}
} #End ForEach
