<#
.SYNOPSIS
Updates the storage type of disks attached to an Azure VM.

.DESCRIPTION
This script stops the specified Azure VM, updates all its attached disks to the specified storage type (either Premium_LRS or StandardSSD_LRS), and then restarts the VM. This is useful for adjusting disk performance characteristics in Azure.

.PARAMETER vmId
The ID of the Azure VM whose disks are to be updated. The VM ID is typically in the format of a GUID.

.PARAMETER StorageType
The storage type to which the VM's disks will be updated. Valid options are 'Premium_LRS' for premium locally redundant storage, and 'StandardSSD_LRS' for standard SSD locally redundant storage.

.EXAMPLE
Update-AzVmDisk -vmId "/subscriptions/12345678-abcd-1234-efgh-123456abcdef/resourceGroups/resourceGroupname/providers/Microsoft.Compute/virtualMachines/theVMname" -StorageType "Premium_LRS"

This example updates all disks of the VM with the ID '/subscriptions/12345678-abcd-1234-efgh-123456abcdef/resourceGroups/resourceGroupname/providers/Microsoft.Compute/virtualMachines/theVMname' to use Premium_LRS storage.

.NOTES
Requires the Azure PowerShell module. The user must have appropriate permissions to stop/start VMs and update disk configurations in Azure.

#>
function Set-AzVmDisk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $vmId,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Standard_LRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Premium_ZRS", "Premium_LRS")]
        [string]$StorageType
    )

    # Stop VM
    Write-Verbose "Stopping VM with ID: $vmId"
    Stop-AzVM -Id $vmId -Force
    Write-Verbose "VM stopped successfully."

    # Get all the disks used by the VM
    Write-Verbose "Retrieving disks for VM ID: $vmId"
    $vmDisks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $vmId }

    # Update storage type for each disk
    foreach ($disk in $vmDisks) {
        Write-Verbose "Updating disk $($disk.Name) to $StorageType"
        $disk.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
        $disk | Update-AzDisk
        Write-Verbose "Disk $($disk.Name) updated."
    }

    # Start VM
    Write-Verbose "Starting VM with ID: $vmId"
    Start-AzVM -Id $vmId -Force
    Write-Verbose "VM started successfully."
}