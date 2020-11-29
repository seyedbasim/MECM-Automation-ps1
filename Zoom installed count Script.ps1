##########SCCM Login###########################################################################
#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '4/7/2020 6:59:43 AM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "001" # Site code 
$ProviderMachineName = "sccm.censoni.local" # SMS Provider machine name
# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

###########Path Content########################################################################
$contentpath = "C:\zoom.csv"
Add-Content -Path $contentpath  -Value '"Computer","Zoom","Error"'
#################################################################################################
$collection = "Windows Client"
$Allcomputers = Get-CMCollectionMember -CollectionName $collection
Set-Location "C:\windows\system32\"
foreach($computer in $Allcomputers){
    $value = $false
    $computername = $computer.Name
    ############################################################################################
    $pathu = "\\"+$computername+"\c$\users\"
    $errore = $null
    $allusers = $null
    try{
        $allusers = Get-ChildItem -Path $pathu -ErrorAction stop
    }catch{
        $errore = "Error Accessing the Path " + $pathu
    }
    foreach($name in $allusers.name){
 
     $path = "\\"+$computername+"\c$\users\"+$name+"\AppData\Roaming\Zoom\bin\zoom.exe"
     $val = Test-Path -Path $path -ErrorAction SilentlyContinue
     if($val -eq $true){
        $value = $true
     }
    }
    $hash = @{
             "Computer" = $computername 
             "Zoom" = $value
             "Error" = $errore
             }
    $newRow = New-Object PsObject -Property $hash
    Export-Csv $contentpath -inputobject $newrow -append -Force
}


