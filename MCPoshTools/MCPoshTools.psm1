#
# Module file for module 'MCPoshTools'
#
# Generated by: Kevin M. Kirkpatrick
#
# Generated on: 3/18/2015
#

# Dot source Public & Private functions
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach ($import in @($Public + $Private)) {

    try {   # dot-source all functions

        . $import.FullName

    } catch {

        Write-Warning -Message "Could not load function { $($import.Name) }. $_"

    } # end t/c

} # end foreach


<#

TODO
-----------

- Need support loading modules using the code below, however, it seems to break any reference to files that rely on $PSScriptRoot.
Upon initial change, the $PSScriptRoot is set to the active working directory that a user is calling the command from.

- Need to figure out how to best move the vCenter/Jump Server config file out of the module and into a common system path

------------


param (
    [bool]$DebugModule = $false
)

# Dot source Public & Private functions
$Public      = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private     = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$FilesToLoad = @([object[]]$Public + [object[]]$Private) | Where-Object {$_}
$ModuleRoot  = $PSScriptRoot

# Dot source the files
# Thanks to Bartek, Constatine
# https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
Foreach ($File in $FilesToLoad) {

    Try {

        if ($DebugModule) {

            . $File.FullName

        } else {
            . (
                [scriptblock]::Create(
                    [io.file]::ReadAllText($File.FullName, [Text.Encoding]::UTF8)
                )
            )
        } # end if/else

    } Catch {

        Write-Error -Message "Could not load function { $($File.fullname) }"
        Write-Error $_

    } # end try/catch

} # end foreach

#>

# set custom alias
Set-Alias -Name gtn -Value Get-TypeName