<#
.SYNOPSIS
    Get-EPMVersion
.DESCRIPTION
    This method enables the user to retrieve the EPM version.
.PARAMETER LoginRegion
    The geographical region in which your EPM server resides.
.PARAMETER Version
    API version.  Version number. Format is x.x.x.x (for example, 11.5.0.1)
.Example
    Get-EPMVersion -LoginRegion "US" -Version 22.11.1.2879
#>

Function Get-EPMVersion
{

    # Enable Advanced Funciton Parameters
    [CmdletBinding()]
    
    # Define Parameters
    param
    (

        # Region that your EPM Server is located.  Default = 'US'
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [ValidateSet('AU', 'BETA', 'CA', 'EU', 'IN', 'IT', 'JP', 'SG', 'UK', 'US', IgnoreCase = $true)]
        $LoginRegion, 

        # API Version - Must be in format x.x.x.x (example 11.5.0.1)
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [ValidatePattern("\d{1,}\d{1,}\d{1,}\d{1,}")]
        $Version
    )

    # Initial Configuration
    BEGIN
    {

        # Establish DataCenter Region Identifier
        if($LoginRegion -eq 'US')
        {
            $DataCenter = 'login'
        }else
        {
            $DataCenter = $LoginRegion
        }

        # URL for EPM Authentication API
        if($Version)
        {
            # If the Version is defined as a parameter
            $URI = "https://$DataCenter.epm.cyberark.com/EPM/API/$Version/Server/Version"
        }else
        {
            $URI = "https://$DataCenter.epm.cyberark.com/EPM/API/Server/Version"
        }
        
        # Method for the EPM Authentication API
        $Method = "GET"

        # Headers for EPM Authentication API
        $Headers = @{"Content-Type" = "application/json"}

        # Set the session variable so script can be tracked between functions
        $SessionVariable = "EPMSession"

    } # End of BEGIN

    # Main Function 
    PROCESS
    {
        # Send REST request and save the response
        $Response = Invoke-RestMethod -Uri $URI -Method $Method -Headers $Headers -SessionVariable $SessionVariable

        # Write output of response for validation 
        $Response | ConvertTo-Json
    } # End of PROCESS

    # Wrap things up
    END
    {
        Return $Response
    } # End of END
} # End of Get-EPMVersion