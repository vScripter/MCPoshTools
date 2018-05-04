function Get-VcenterServerId {
<#
.SYNOPSIS
    Returns the unique vCenter Server ID
.DESCRIPTION
    Returns the unique vCenter Server ID

    This is particulary important because the Unique IS is used to calculate hashed values for virtual network adapter MAC addresses. If two vCenters in a given
    environment have the same Unique ID, you can run into MAC address conflicts if the Unique ID is the same if you need to migrate guests, want to configure linked mode, etc.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.INPUTS
    System.String
    System.Management.Automation.PSCredential
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20171006
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Added logic to skip directly connected ESXi hosts
#>

    [OutPutType([System.Management.Automation.PSCustomObject])]
    [CmdLetBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default')]
        [System.String[]]
        $Server
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        if ( -not ( $PsBoundParameters.ContainsKey('Server') ) ) {

            if (Test-Path Variable:\Global:defaultViServers) {

                try {

                    $Server = ((Get-Variable -Scope Global -Name defaultViServers -ErrorAction 'Stop').Value).Name

                } catch {

                    throw "No valid vCenter Server connection could be found."

                } # end try/catch

            } # end if Test-Path

        } # end if

    } # end BEGIN block

    PROCESS {

        foreach ($vcenter in $Server) {

            try {

                $siView      = $null
                $settingView = $null
                $uniqueId    = $null
                $endpointType      = $null

                $siView      = Get-View -Server $vcenter ServiceInstance -ErrorAction 'Stop'

                $endpointType = $siView.Content.About.FullName

                if ($endpointType -like '*esx*'){

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Skipping directly connected ESXi host { $vcenter }"

                } else {

                    $settingView = Get-View -Server $vcenter $siView.Content.Setting -ErrorAction 'Stop'
                    $uniqueId    = ($settingView.QueryOptions("instance.id")).Value

                    [PSCustomObject] @{
                        vCenter  = $vcenter
                        UniqueID = $uniqueID
                    } # end psObj

                } # end if/else

            } catch {

                throw "Could not retrieve information from vCenter { $vcenter }. Try Reconnecting and try again. $_"

            } # end try/catch

        } # end foreach

    } # end PROCESS block

} # end function Get-VcenterServerId
