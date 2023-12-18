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
        $disks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $vm.Id }

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
