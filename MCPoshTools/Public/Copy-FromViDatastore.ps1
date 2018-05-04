function Copy-FromViDatastore {

<#
.SYNOPSIS
    Allows you to copy a single file to a remote datastore from a local location
.DESCRIPTION
    Allows you to copy a single file to a remote datastore from a local location

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

    [cmdletbinding()]
    param()

    BEGIN {

        #requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        # connect to a datastore
        Write-Warning -Message 'Select Datastore you want to copy a file from'
        $dataStore = Get-DataStore | Out-GridView -OutputMode Single -Title "Select Datastore and press 'Ok'"

        if (Get-PSDrive -Name 'ds' -ea 0) {
            [void](Remove-PSDrive -Name 'ds' -Force -Confirm:$false -ea SilentlyContinue)
        }

        # create PSDrive using VimDatastore provider
        [void](New-PSDrive -Name ds -PSProvider VimDatastore -Location $dataStore -Root '' -ErrorAction Stop)

        # check/create ISO folder in selected datastore
        if (!(Test-Path ds:\ISO)){
            [void](New-Item -Name ISO -Path ds:\)
        }


        # copy out using PSDrive
        Write-Warning -Message 'Select Datastore file you want to copy local'
        $selectItem = $null
        $selectItem = Get-ChildItem ds:\ISO | Where-Object {$_.ItemType -like 'File'} | Out-GridView -OutputMode Single -Title "Select File and press 'Ok' "
        $fileName   = 'ds:\ISO\' + $selectItem.Name

        Write-Warning -Message 'Select destination folder you want to copy file to'
        $sourceDirectory = Get-FolderName

        # copy in using PSDrive
        Copy-DataStoreItem -Item $fileName -Destination $sourceDirectory -Verbose

    } # end PROCESS block

} # end function Copy-FromViDatastore
