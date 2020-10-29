<#
	.NOTES
	Script name: vmware.ps1
	Created on: 20/09/2020
	Author: MVSourceCode & Rafli Setiawan
	
	.DESCRIPTION
	Script adds community network drivers that are no longer supported by VMWARE and generate a new ISO bootable file
	Do not create EXI image for production use only for testing and lab environment
	
	http://mvsourcecode.com
#>

$mvFiles = Get-ChildItem *.zip
$mvDir = $mvFiles | Select -First 1 |  Select-Object -Property DirectoryName
$mvFullName = $mvFiles | Select -First 1 | Select-Object -Property FullName
$mvISOName = $mvDir.DirectoryName +"\..\ISO\VMWARE_ESXI_6.7.ISO" 
$mvImageProfile = ""

#Seek Files in the current directory
if ($mvFiles.Count -eq 2){
Write-Host "Step1: " -ForegroundColor DarkCyan
    foreach($mvFile in $mvFiles){
        Write-Host "File was found: $mvFile" -ForegroundColor Green 
        Add-EsxSoftwareDepot $mvFile | Select -Property FullName

    }


  
#Determine correct standard exi image profile
   $EXIProfile = Get-EsxImageProfile  | Where-Object Name -like '*-standard' 
       if($EXIProfile[0].Name.Length -ge $EXIProfile[1].Name.Length){
            $mvImageProfile =  $EXIProfile[1].Name
       }
       Else{
            $mvImageProfile =  $EXIProfile[0].Name
       }
Write-host Write-Host "Step2: " -ForegroundColor DarkCyan
Write-Host "EXI Image Profile: $mvImageProfile" -ForegroundColor Green


Write-host Write-Host "Step3: " -ForegroundColor DarkCyan
Write-Host "Start Clonning EXI Image Profile" -ForegroundColor Green

#Clone EXI image profile    
    New-EsxImageProfile -CloneProfile $mvImageProfile -Name "VMWARE ESXI 6.7" -Vendor "VMWARE"


Write-host Write-Host "Step4: " -ForegroundColor DarkCyan
Write-Host "Set AcceptanceLevel for CommunitySupport" -ForegroundColor Green

#Set AcceptanceLevel for CommunitySupport
    Set-EsxImageProfile -Name "VMWARE ESXI 6.7" -AcceptanceLevel CommunitySupported -ImageProfile "VMWARE ESXI 6.7"


Write-host Write-Host "Step5: " -ForegroundColor DarkCyan
Write-Host "Add Realtek software package into Software package" -ForegroundColor Green
Write-Host " "
#Add Realtek software package into Software package
    $package = Get-EsxSoftwarePackage | Where-Object Vendor -EQ "Realtek" | select Name
    Add-EsxSoftwarePackage -ImageProfile "VMWARE ESXI 6.7" -SoftwarePackage $package.Name


Write-host Write-Host "Step6: " -ForegroundColor DarkCyan
Write-Host "Exporting ISO image $msISOName" -ForegroundColor Green
#Export ISO image to current directory
    Export-EsxImageProfile -ImageProfile "VMWARE ESXI 6.7" -ExportToIso -FilePath $mvISOName

}
