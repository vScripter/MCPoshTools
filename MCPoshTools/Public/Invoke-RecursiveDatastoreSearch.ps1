function Invoke-RecursiveDatastoreSearch {

    <#
.SYNOPSIS
    Perform recursive search against ALL datastores managed by a given vCenter server
.DESCRIPTION
    Perform recursive search against ALL datastores managed by a given vCenter server.

    The value that is provided to the $SearchString parameter is used to execute a wildcard search for the folder name that you wish to
    resolve. In larger environments, this script could potentially take hours to complete. Execution time is further delayed if there are
    datastores or LUNs that cannot be resolved due to various reasons (All Paths Down, LUN was decommissioned but never detached from the host, etc.)

    Each datastore is mounted as a PSDrive using the 'VimDatastore' PSProvider, at which point Get-ChildItem is used to search for the folder names, in the
    root of the datastore, that contain the string you provided to the -SearchString param.


    Overall, the primary reason this script was written was to perform a deep search for guests that, for multiple reason, cannot be found using a known
    display name (removed from inventory but not deleted, renamed, etc.)

    Sample output searching for a VM named 'server-123' in the environment managed by vCenter server 'vcenter-server.cor.domain.com'.
    Note: the 'FullName' value is the following format: <PSDrive Name>:\<vCenter Server@port>\<vSphere Datacenter Name>\<Datastore Name>\<Folder Name>


FolderName     Datastore          FullName
--------       ---------          --------
SERVER-123     DatastoreName_02   viDatastore:\vcenter-server.cor.domain.com@443\VI-Datacenter\DatastoreName_02\SERVER-123
SERVER-123     DatastoreName_03   viDatastore:\vcenter-server.cor.domain.com@443\VI-Datacenter\DatastoreName_03\SERVER-123
SERVER-123_1   DatastoreName_03   viDatastore:\vcenter-server.cor.domain.com@443\VI-Datacenter\DatastoreName_03\SERVER-123_1

.PARAMETER Server
    FQDN of vCenter Server
.PARAMETER SearchString
    Value to be used in wildcard search
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Invoke-RecursiveDatastoreSearch -Server $viServer -SearchString 'prod-vm-01' -Verbose
.EXAMPLE
    Invoke-RecursiveDatastoreSearch -Server $viServer -SearchString 'prod-vm-01' -Verbose | Export-Csv C:\Datastore_Search_Report.csv -NoTypeInformation -Force
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20170126
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Fixed debug output that needed double-quotes
    - Fixed try/catch block to throw an error instead of a warning, when trying to remove the PSDrive
    - Fixed variable inconsistency when referncing the name of the PSDrive that gets created; all references now use the variable instead of a string value of the name
#>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'default')]
        [System.String[]]$Server,

        [parameter(Mandatory = $true, Position = 1, ParameterSetName = 'default')]
        [System.String]$SearchString
    )

    BEGIN {

        Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Start of BEGIN block"

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] end of BEGIN block"

    } # end BEGIN block

    PROCESS {

        Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Start of PROCESS block"

        foreach ($viserver in $Server) {

            $datastoreQuery = $null

            $datastoreQuery = Get-Datastore -Server $viserver

            foreach ($datastore in $datastoreQuery) {

                $fileQuery = $null
                $psdriveDatastoreName = 'viDatastore'

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver] Checking for PSDrive with provided name { $psdriveDatastoreName }"
                Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver] Checking for PSDrive with provided name { $psdriveDatastoreName }"
                if ((Test-PSDrive -Name $psdriveDatastoreName) -eq $true) {

                    try {

                        Remove-PSDrive -Name $psdriveDatastoreName -Force -ErrorAction 'Stop'

                    } catch {

                        throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver][Remove-PSDrive][ERROR] Cannot remove PSDrive { $psdriveDatastoreName }"

                    } # end try/catch

                } # end if

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver] Creating PSDrive"
                Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver] Creating PSDrive"
                try {

                    $newPSDriveDescription = 'Automatically created by script. If you are not sure what this drive is for, you can safely remove it'
                    [void](New-PSDrive -Name $psdriveDatastoreName -PSProvider VimDatastore -Datastore $datastore -Root '\' -Description $newPSDriveDescription -Confirm:$false -ErrorAction 'Stop')

                } catch {

                    throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver][New-PSDrive][ERROR] Cannot create PSDrive { $psdriveDatastoreName }. $_"

                } # end try/catch

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver] Running Datastore query on {$datastore}"
                Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver] Running Datastore query on {$datastore}"
                $folderQuery = Get-ChildItem "$($psdriveDatastoreName):" | Where-Object { $psitem.Name -like "*$SearchString*" -and $psitem.PSIsContainer -eq $true }

                foreach ($folder in $folderQuery) {

                    [PSCustomObject] @{
                        FolderName = $folder.Name
                        Datastore  = $folder.Datastore
                        FullName   = $folder.FullName
                    }

                } # end foreach $folder

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver][Remove-PSDrive] Removig PSDrive { $psdriveDatastoreName }"
                Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver][Remove-PSDrive] Removig PSDrive { $psdriveDatastoreName }"
                try {

                    Remove-PSDrive -Name viDatastore -Force -ErrorAction 'Stop'

                } catch {

                    throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$viserver][Remove-PSDrive][ERROR] Cannot remove PSDrive { $psdriveDatastoreName }. $_"

                } # end try/catch

            } # end foreach $datastore

        } # end foreach $viserver


        Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] End of PROCESS block"

    } # end PROCESS block

    END {

        Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Start of END block"

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

        Write-Debug -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] End of END block"

    } # end END block

} # end function Invoke-RecursiveDatastoreSearch
