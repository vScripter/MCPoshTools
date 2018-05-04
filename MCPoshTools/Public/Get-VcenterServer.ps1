function Get-VcenterServer {

    <#
    .SYNOPSIS
        Returns a list or particular connection status for one, or more, vCenter (VI) Servers
    .DESCRIPTION
        Returns a list or particular connection status for one, or more, vCenter (VI) Servers.

        Depending on the desired output, you can supply the following to the -QueryType parameter:
        - List: Reads in a custom list of vCenter servers from a specified path. This can be useful if you wish to keep a static list of
        vCenter Servers for quick reference (especially in large environments). By default, the function will look for the file in a folder called 'Inputs'
        that resides in the root module directory. "$PSScriptRoot\..\Inputs\serverInventoryConfig.json"

        It's reccomended that you keep a custom config file in a location outside of the module path, so that it's not overwritten by module updates, etc.

        You can set a default path value for the cmdlet by adding the folling to your PSProfile:

        $PSDefaultParameterValues = @{
		    "Get-VcenterServer:Path" = '$Home\Path\To\serverInventoryConfig.json'
	    }

        - Status: Returns the connection status/details from all vCenter Servers stored in the $Global:DefaultVIServers variable, which is automatically
        created/updated when connecting to one, or more, vCenters using PowerCLI

        - Connected: Returns a list (string array) of only the vCenter Servers reporting a 'Connected' status in the $Global:DefaultVIServers variable
    .PARAMETER QueryType
        The type of query you wish to execute
    .PARAMETER Path
        The UNC path to the location of the .CSV file you wish to read in the list of vCenter servers, from.
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
        System.String
    .EXAMPLE
        Get-VcenterServer

        Will read in the list of vCenter servers provided in the .CSV file assigned to the -Path parameter
    .EXAMPLE
        Get-VcenterServer -QueryType Connected | Format-Table -AutoSize
    .EXAMPLE
        Get-VcenterServer -QueryType Status |  Format-Table -AutoSize
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
    [OutputType([System.String])]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default')]
        [ValidateSet('List', 'Status', 'Connected')]
        [System.String]$QueryType = 'List',

        [parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'default')]
        [validatescript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [System.String]$Path = "$PSScriptRoot\..\Inputs\serverInventoryConfig.json"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        # Use Get-Item to return a full/proper UNC path in the event ".." is used (makes it easier to read and work worth)
        $sicPath = $null
        $sicPath = (Get-Item -Path $Path).FullName

    } # end BEGIN block

    PROCESS {

        switch ($QueryType) {

            'List' {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Reading vCenter Server list from file { $sicPath }"
                try {

                    $jsonQuery = (Get-Content -Path $Path -Raw -ErrorAction 'Stop' | ConvertFrom-Json -ErrorAction 'Stop').vcenterServer

                    if ($jsonQuery.Tenant -like '*Example*') {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] It looks like there are still example entries in your configuration file. Edit the example file { $sicPath }, or specify a location to a new one."

                    } # end if

                    # casting to a new object for each entry seems redundant but I'm setting it up this way to support the use
                    # of something like metadata for each entry, in the future
                    foreach ($entry in $jsonQuery) {

                        [PSCustomObject]@{
                            ComputerName = $entry.ComputerName
                            IPv4Address  = $entry.IPv4Address
                            Region       = $entry.Region
                            Tenant       = $entry.Tenant
                            Description  = $entry.Description
                        } # PSObj

                    } # end foreach

                } catch {

                    throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Cannot access input file at { $sicPath }. $_"

                } # end try/catch

            } # end 'List'


            'Status' {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering current status detail on connected vCenter (VI) Servers"

                $vcenterServerStatus = $null
                $vcenterServerStatus = $Global:DefaultVIServers | Select-Object Name, User, IsConnected
                $vcenterServerStatus

            } # end 'Status'


            'Connected' {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Generating list of all connected vCenter (VI) Servers"

                [System.String[]]$connectedVIServers = $null
                $connectedVIServers = ($Global:DefaultVIServers | Where-Object { $psitem.IsConnected -eq $true }).Name
                $connectedVIServers

            } # end 'Connected'

        } # end switch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-VcenterServer
