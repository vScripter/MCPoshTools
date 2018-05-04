function Select-FileName {

<#
.SYNOPSIS
    Allows you to browse the file system via Windows Explorer and select a file, which returns the full path to the file, as a string.
.DESCRIPTION
    Allows you to browse the file system via Windows Explorer and select a file, which returns the full path to the file, as a string.
.EXAMPLE
    Select-FileName -InitialDirectory $Home\Documents -Verbose
.INPUTS
    System.String
.OUTPUTS
    System.String
.NOTES

#>

    [OutputType()]
    [cmdletbinding()]
        param (
            [parameter(Mandatory = $false, Position = 0)]
            [System.String]$initialDirectory = 'C:\'
        )

        PROCESS {

            [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

            $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $OpenFileDialog.initialDirectory = $initialDirectory
            $OpenFileDialog.filter = "All files (*.*)| *.*"
            $OpenFileDialog.ShowDialog() | Out-Null
            $OpenFileDialog.filename

        } # end PROCESS block

} # end function Select-FileName