<#
.SYNOPSIS
Exports Azure Disk data for multiple subscriptions to a CSV file.

.DESCRIPTION
This function connects to each specified Azure subscription, retrieves a list of all Azure Disks within those subscriptions, and exports detailed information about each disk to a CSV file. It's designed to aid in inventory management and audit processes across multiple Azure subscriptions.

.PARAMETER Subscriptions
An array of Azure subscription IDs. The function will iterate through each subscription in this array to gather and export Azure Disk data.

.PARAMETER DiskCsvPath
The file path where the disk data CSV file will be saved. This file will contain columns for Disk Name, Subscription, Resource Group Name, Disk ID, Location, SKU, and Disk State.

.EXAMPLE
$subscriptions = @("Sub1", "Sub2", "Sub3")
Export-AzDiskData -Subscriptions $subscriptions -DiskCsvPath "C:\PATH\disk_data.csv"

This example will connect to subscriptions 'Sub1', 'Sub2', and 'Sub3', retrieve disk data from each, and export the data to 'C:\PATH\disk_data.csv'.

.NOTES
Requires the Azure PowerShell module and authentication to Azure with sufficient permissions to access disk information in the specified subscriptions. Ensure that the Azure account is properly configured for automated login if running this script unattended.
#>
function Export-AzDiskDataToCsv {
    param (
        [string[]]$Subscriptions,
        [string]$DiskCsvPath
    )

    # Create an array to store Disk data
    $Disklist = @()

    foreach ($sub in $Subscriptions) {
        Connect-AzAccount -Subscription $sub

        # Get a list of Azure VMs and export to a CSV file
        # Note: Ensure $vmList is defined and populated before this script
        $vmList | Export-Csv -Path $VmCsvPath -NoTypeInformation

        # Get a list of Azure Disks
        $Disks = Get-AzDisk

        foreach ($disk in $disks) {
            # Create a hashtable for Disk data
            $DiskData = @{
                "Name"                = $disk.Name
                "Subscription"        = $sub
                "ResourceGroupName"   = $disk.ResourceGroupName
                "Id"                  = $disk.Id
                "Location"            = $disk.Location
                "Sku"                 = $disk.Sku.Name
                "DiskState"           = $disk.DiskState
            }

            # Add the disk data to the array
            $Disklist += New-Object psobject -Property $DiskData
        }
    }

    # Export the Disk data to a CSV file
    $DiskList | Export-Csv -Path $DiskCsvPath -NoTypeInformation
}