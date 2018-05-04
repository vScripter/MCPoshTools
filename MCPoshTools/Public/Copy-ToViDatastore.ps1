function Copy-ToViDatastore {

<#
.SYNOPSIS
    Allows you to copy a single file from a local location to a remote Datastore
.DESCRIPTION
    Allows you to copy a single file from a local location to a remote Datastore

    It will prompt you for all necessary inputs through familiar GUI windows.

    All file transfers on the remote datastore happen in a directory named 'ISO'

    This function assumes that you are already connected to a vCenter Server.
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20161207
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Added to module

#>

    [OutputType()]
    [cmdletbinding()]
    param()

    BEGIN {

        #requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        Write-Warning -Message 'Select local file you wish to copy to the datastore'
        $sourceFile = Select-FileName

        # connect to a datastore
        Write-Warning -Message 'Select Destination Datastore you want to copy a file to'
        $dataStore = Get-DataStore | Out-GridView -OutputMode Single -Title "Select Destination Datastore and press 'Ok'"

        if (Get-PSDrive -Name 'ds' -ea 0) {
            [void](Remove-PSDrive -Name 'ds' -Force -Confirm:$false -ea SilentlyContinue)
        }

        # create PSDrive using VimDatastore provider
        [void](New-PSDrive -Name ds -PSProvider VimDatastore -Location $dataStore -Root '' -ErrorAction Stop)

        # check/create ISO folder in selected datastore
        if (!(Test-Path ds:\ISO)){
        [void](New-Item -Name ISO -Path ds:\)
        }

        # copy in using PSDrive
        Copy-DataStoreItem -Item $sourceFile -Destination ds:\ISO -Verbose

    } # end PROCESS block

    END {

        [void](Remove-PSDrive -Name ds -Force -ErrorAction 'SilentlyContinue')

    } # end END block

} # end function Copy-ToViDatastore
