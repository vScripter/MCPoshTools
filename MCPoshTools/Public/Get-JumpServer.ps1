function Get-JumpServer {

    <#
    .SYNOPSIS
        Returns a list of jump servers which are used for remote system administration tasks
    .DESCRIPTION
        Returns a list of jump servers which are used for remote system administration tasks.

        The file must be manually created and updated, but it gives a quick and easy way to reference a list of jump servers.

        The .JSON file MUST contain at least the following:
        - ComputerName
        - Region
        - Tenant
        - Description
        - IPv4Address

        By default, the function will look for the file in a folder called 'Inputs' that resides in the root module directory. "$PSScriptRoot\..\Inputs\serverInventoryConfig.json"

        It's reccomended that you keep a custom config file in a location outside of the module path, so that it's not overwritten by module updates, etc.

        You can set a default path value for the cmdlet by adding the folling to your PSProfile:

        $PSDefaultParameterValues = @{
		    "Get-JumpServer:Path" = '$Home\Path\To\serverInventoryConfig.json'
	    }

    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20171101
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added logic to warn about having example entries in the config file.
        - Changed the name of the template config file so that at least something is returned, even if nothing is customized by the end user.
    #>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default')]
        [validatescript( { Test-Path -LiteralPath $_ -PathType Leaf })]
        [System.String]
        $Path = "$PSScriptRoot\..\Inputs\serverInventoryConfig.json"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        # Use Get-Item to return a full/proper UNC path in the event ".." is used (makes it easier to read and work worth)
        $sicPath = $null
        $sicPath = (Get-Item -Path $Path).FullName

    } # end BEGIN block
    PROCESS {

        try {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Reading Jump Server list from file { $sicPath }"

            $jsonQuery = (Get-Content -Path $Path -Raw -ErrorAction 'Stop' | ConvertFrom-Json -ErrorAction 'Stop').jumpServer

            if ($jsonQuery.Tenant -like '*Example*') {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] It looks like there are still example entries in your configuration file. Edit the example file { $sicPath }, or specify a location to a new one."

            } # end if

            # casting to a new object for each entry seems redundant but I'm setting it up this way to support the use
            # of something like metadata for each entry, in the future
            foreach ($entry in $jsonQuery) {

                [PSCustomObject]@{
                    ComputerName = $entry.ComputerName
                    Region       = $entry.Region
                    Tenant       = $entry.Tenant
                    IPv4Address  = $entry.IPv4Address
                    Description  = $entry.Description
                }

            } # end foreach

        } catch {

            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not access input file { $sicPath }. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-JumpServer
