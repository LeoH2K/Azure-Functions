<#
.SYNOPSIS
Exports data about Azure VMs to a CSV file.

.DESCRIPTION
This function retrieves information about all Azure VMs in the subscription and exports selected details to a CSV file. It includes VM name, resource group name, SKU, location, disk type, and disk SKUs. The function provides a progress update as it processes each VM, making it suitable for environments with a large number of VMs.

.PARAMETER CsvPath
Specifies the path where the CSV file will be saved. The file will contain columns for VM Name, Resource Group Name, SKU, Location, Disk Type, and Disk SKUs.

.EXAMPLE
Export-AzVMDataToCsv -CsvPath "C:\VMData.csv"

This command exports the VM data to a CSV file named 'VMData.csv' in the C: drive.

.NOTES
Requires Azure PowerShell module. Ensure you are logged into your Azure account with appropriate permissions to access VM information.
#>
function Export-AzVMDataToCsv {
    param (
        [string]$CsvPath
    )

    # Get a list of Azure VMs
    $vms = Get-AzVM

    # Create an array to store VM data
    $vmList = @()

    # Initialize progress counter
    $count = 0
    $totalVms = $vms.Count

    foreach ($vm in $vms) {
        # Update progress
        $count++
        $progress = @{
            Activity = "Processing Azure VMs"
            Status   = "Processing $($vm.Name)"
            PercentComplete = ($count / $totalVms) * 100
        }
        Write-Progress @progress

        # Get the disks attached to the VM
        

        # Extract disk SKUs
        $diskSkus = $disks | ForEach-Object { $_.Sku.Name }

        # Create a hashtable for VM data including disk SKUs
        $vmData = @{
            "Name"              = $vm.Name
            "ResourceGroupName" = $vm.ResourceGroupName
            "Sku"               = $vm.HardwareProfile.VmSize
            "Location"          = $vm.Location
            "DiskType"          = $vm.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
            "DiskSKUs"          = ($diskSkus -join ', ')
        }

        # Add the VM data to the array
        $vmList += New-Object PSObject -Property $vmData
    }

    # Export the VM data to a CSV file
    $vmList | Export-Csv -Path $CsvPath -NoTypeInformation
}
