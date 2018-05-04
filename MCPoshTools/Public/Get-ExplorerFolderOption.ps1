function Get-ExplorerFolderOption {

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false, Position = 0, DontShow = $true)]
        [System.String]$RegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    )

    BEGIN {


    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Get-ExplorerFolderOption] Getting Windows Explorer Folder Options"
        try {

            Get-ItemProperty $RegKey -ErrorAction Stop

        } catch {

            Write-Warning -Message "[Get-ExplorerFolderOption][ERROR] Could not read or access Windows Explorer Options from the registry. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-ExplorerFolderOption] Processing Complete."

    } # end END block


} # end function Get-ExplorerFolderOption