function Set-ExplorerFolderOption {

    [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('HideFileExt')]
        [System.String]$Option,

        [parameter(Mandatory = $true, Position = 1)]
        [System.Int32]$Value
    )

    BEGIN {

        $regKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Set-ExplorerFolderOption] Setting option {$Option} to value {$Value}"
        try {

            Set-ItemProperty $regKey $Option $Value -ErrorAction Stop

        } catch {

            Write-Warning -Message "[Set-ExplorerFolderOption][ERROR] Could not set option {$Option} to value {$Value}. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Set-ExplorerFolderOption] Processing Complete."

    } # end END block


} # end function Set-ExplorerFolderOption