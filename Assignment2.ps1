$WebAppCount = $args[0] # will take command line arguement 

# The SubscriptionId in which to create our resources
$SubscriptionId = Read-Host "Please enter your subscription ID"

<#
The admin username and password should stay as the following because
the website is connected to HMLA-Database through a connection string 
which contains the following credentials username: $adminSqlLogin and password:$password
#>
$adminSqlLogin = Read-Host "Please enter your server username"
$password = Read-Host "Please enter your server password"


# install all the necessary modules for running this script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Install-Module -Name AzureRM -AllowClobber
Install-Module -Name SqlServer # install the SqlServer module to populate the database

# import Az.Resources module
Import-Module Az.Resources


# connect to your azure account before creating anything on azure
Connect-AzAccount


# 1 create a resource group
$resourceGroupName = "rg-CMPE363-assignment2-HMLA"
New-AzResourceGroup -Name $resourceGroupName -Location "East US"


# 2 Create an Azure SQL DB
$location = "East US"
# Set an admin login and password for your server

# Set server name - the logical server name has to be unique in the system
$serverName = "server-hmla"
# The sample database name
$databaseName = "HMLA-Database"
# The ip address range that you want to allow to access your server
$startIp = "0.0.0.0"
$endIp = "255.255.255.255"

# suppress the breaking change warning messages in Azure PowerShell
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

# Set subscription 
Set-AzContext -SubscriptionId $subscriptionId 

#create server
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential 
    -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

# Create a server firewall rule that allows access from the specified IP range
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

# Create a blank database with an S0 performance level
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0" `
    -SampleName "AdventureWorksLT"



# 3 create and query table 'tblEmployee'

# store necessary information needed to be used populate the database
$SQLServer = "server-HMLA.database.windows.net"
$db = "HMLA-Database"


#create table SQL query
$create = "CREATE TABLE tblEmployee (EmpID int IDENTITY(1, 1), EmpName NVARCHAR(20), EmpSurname NVARCHAR(20), EmpAddress NVARCHAR(20), EmpPhone int );"


# selecting from table SQL query
$select= "SELECT * FROM tblEmployee;"


# firstly, create a table tblEmployee
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $create -Username $adminSqlLogin -Password $password -Verbose 


# secondly, populate the table with 51 rows
for ($i = 0; $i -lt 51; $i++) 
{
$EmpName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$EmpSurname = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$EmpAddress = -join ((65..90) + (97..122) | Get-Random -Count 15 | % {[char]$_})
$EmpPhone = Get-Random -Minimum 90000000 -Maximum 90999999

$insert = "INSERT INTO tblEmployee VALUES " + "('$($EmpName)', '$($EmpSurname)', '$($EmpAddress)', $($EmpPhone));"

# insert rows in the table 'tblEmployee'
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $insert -Username $adminSqlLogin -Password $password -Verbose 
}

# select rows from the table 'tblEmployee'
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $select -Username $adminSqlLogin -Password $password -Verbose 


# 4 Create $WebAppCount times

# get the arguement input and convert it to number to create webappcount many webapps

$WebAppCount = $WebAppCount -as [int]

For ($x=1; $x –lt ($WebAppCount + 1); $x++) { # create $WebAppCount many webapps 

Connect-AzAccount # you must be asked to connect to azure for everytime you create a webapp

# deploy code from github to webapp
$webappname="webapp-CMPE363-assignment2-HMLA-$x"
$gitrepo="https://github.com/lindaabdullah/Employee-Information-Management.git"
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
    isManualIntegration = "true";
}

# creates a new webapp
New-AzWebApp -ResourceGroupName $resourceGroupName -Name $webappname -Location $location -AppServicePlan "ASP-rgCMPE363assignment2HMLA-a1588" -GitRepositoryPath "https://github.com/lindaabdullah/Employee-Information-Management.git"


Set-AzResource -Properties $PropertiesObject -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $webappname/web -ApiVersion 2015-08-01 -Force

}