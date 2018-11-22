# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv C:\Users\502770535\Desktop\BulkUserCreationAndUpdate\NewUserCreation\Users_12-Oct-18.csv

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below	
	$EmployeeID 	= $User.EMPLOYEE_ID
	$Password 	= $User.Password
	$name 		= $User.EMPLOYEE_NAME
	$Firstname,$Middlename,$Lastname = $User.EMPLOYEE_NAME –split ' '
	$surname	= ('{0} {1}' -f $Middlename, $Lastname).TrimEnd()
	$OU 		= $User.OU
    	$email      	= $User.EMAIL_ID
   	$jobtitle   	= $User.DESIGNATIONNAME
	$manager	= $User.REPORTINGTO
    	$department	= $User.BUSINESS
	$company	= $User.OUNAME
	$office		= $User.LOCATION
	$i		= 1

	#Check to see if the user already exists in AD
	if (Get-ADUser -Filter {SamAccountName -eq $EmployeeID})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $EmployeeID : $name already exist in Active Directory."
	}
	else
	{
	if (Get-ADUser -F {Name -eq $name})
	{
		#Username already exists, now we will add "1" to the surname of new user account
        	#Account will be created in the OU provided by the $OU variable read from the CSV file
	New-ADUser `
	-SamAccountName $EmployeeID `
	-UserPrincipalName "$EmployeeID@clix.local" `
	-Name "$name$i" `
	-Enabled $True `
	-DisplayName "$name$i" `
	-EmailAddress $email `
	-GivenName $Firstname `
	-Surname "$surname$i" `
	-Office $office `
	-Path $OU `
	-Title $jobtitle `
	-Manager $manager `
	-Department "$department" `
	-Company $company `
	-AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
	Write-output "User $EmployeeID : $name created successfully!"
	}
	else {
		#User does not exist then proceed to create the new user account
        	#Account will be created in the OU provided by the $OU variable read from the CSV file
	New-ADUser `
	-SamAccountName $EmployeeID `
	-UserPrincipalName "$EmployeeID@clix.local" `
	-Name "$name" `
	-Enabled $True `
	-DisplayName "$name" `
	-EmailAddress $email `
	-GivenName $Firstname `
	-Surname $surname `
	-Office $office `
	-Path $OU `
	-Title $jobtitle `
	-Manager $manager `
	-Department "$department" `
	-Company $company `
	-AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
	Write-output "User $EmployeeID : $name created successfully!"
	}
	}
}
