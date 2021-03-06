#########################################################
# This Script enables you to create bulk users in AD	#
# using csv file. 					#
# Last Updated: 22-Nov-2018				#
# Author: Aslam Khan (HELLPC.NET)			#
#########################################################

# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
#Store the data from CSV file to the $ADUsers variable
$ADUsers = Import-csv Path_to_file\filename.csv

# Looping through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each column in each row of CSV and assign the data to variables	
	$EmployeeID 	= $User.EMPLOYEE_ID
	$Password 	= $User.Password
	$name 		= $User.EMPLOYEE_NAME
	$Firstname,$Middlename,$Lastname = $User.EMPLOYEE_NAME –split ' ' # Split the name into Firstname, Middlename & Surname.
	$surname	= ('{0} {1}' -f $Middlename, $Lastname).TrimEnd() # Combines Middlename & Surname into Surname.
	$OU 		= $User.OU # Name of OU in AD where user account will be created.
    	$email      	= $User.EMAIL_ID
   	$jobtitle   	= $User.DESIGNATIONNAME
	$manager	= $User.REPORTINGTO
    	$department	= $User.DEPARTMENT
	$company	= $User.COMPANY
	$office		= $User.LOCATION
	$i		= 1 # This variable will be used if two users have same name. Second user will get 1 added to their surname.

	# Check to see if the user already exists in AD
	if (Get-ADUser -Filter {SamAccountName -eq $EmployeeID})
	{
		 # If user already exists, give a warning.
		 Write-Warning "A user account with Employee ID $EmployeeID : $name already exist in Active Directory."
	}
	else
	{
	if (Get-ADUser -Filter {Name -eq $name})
	{
	# Username already exists, now we will add "1" to the surname of new user account
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
	-Department "$department" `
	-Company $company `
	-AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
	-ChangePasswordAtLogon $True `
	-Manager $manager # Don't set Manager if you are creating users in new (blank) AD as manager accounts won't be present in AD.
	Write-output "User $EmployeeID : $name created successfully!"
	}
	else {
	# User does not exist in AD. Proceed to create the new user account without adding "1" to surname.
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
	-Department "$department" `
	-Company $company `
	-AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
	-ChangePasswordAtLogon $True `
	-Manager $manager # Don't set Manager if you are creating users in new (blank) AD as manager accounts won't be present in AD.
	Write-output "User $EmployeeID : $name created successfully!"
	}
	}
} #End foreach.
