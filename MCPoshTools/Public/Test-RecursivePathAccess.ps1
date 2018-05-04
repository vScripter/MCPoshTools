function Test-RecursivePathAccess {

<#
.SYNOPSIS
 Recurse through a directory structure and test to see if you have access to all directories.

.DESCRIPTION
 Recurse through a directory structure and test to see if you have access to all directories. The path that you supply will be treated as the root.

 As it recurses through the hierarchy, it stores access errors into an error variable.

 Once processing is complete, the errors are filtered out and reformated to pipe the Error and Path to a .CSV file for review.

 Individual files are skipped.

.PARAMETER <Path>

.INPUTS
 None. This script does not accept pipeline input.

.EXAMPLE
 ./Get-RecursivePathAccess.ps1 -Path C:\Test

 If there are no spaces, you can simply supply the path

.EXAMPLE
 ./Get-RecursivePathAccess.ps1 -Path "C:\Test Folder With Spaces"

 If there are spaces in the path, you much enclose with double quotes
 .NOTES
     --------------------------------
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20141017
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Added to module
#>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    Param(
    [Parameter(Mandatory=$True, Position = 0)]
    [String]$Path
    )

    BEGIN {

        #Requires -Version 3

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        # Write verbose output to report current status
        Write-Verbose "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Testing access to all directories under { $Path }"

        # Get all child directories under the path specified by the -Path parameter and setup the error action preference to send all errors to the 'access_errors variable
        get-childitem -Path $Path -Recurse -ErrorAction SilentlyContinue -ErrorVariable access_errors|Out-Null

        # Setup hash tables to re-format the column titles in the Excel file so they are more clearly defined
        $Reason = @{
            Label = 'Reason'
            Expression = { $_.Category }
        }

        $FolderPath = @{
            Label = 'Path'
            Expression = { $_.TargetName }
        }

        # Pass the error values stored in the $access_errors variable through the pipeline and expand their properties so that the reason and path can be extracted
        # then export all of that data to .csv
        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Listing access errors, if any exist."
        ($access_errors).CategoryInfo | Select-Object $Reason,$FolderPath

    } # end PROCESS Block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function
