<#
.SYNOPSIS
    Get-SetsList
.DESCRIPTION
    This method enables the user to retrieve the list of Sets.
.PARAMETER LoginRegion
    The geographical region in which your EPM server resides.
.PARAMETER Version
    API version.  Version number. Format is x.x.x.x (for example, 11.5.0.1)
.PARAMETER Offset
    Number of sets to skip.  Valid value will be zero or greater.  Default is zero.
.PARAMETER Limit
    Maximum number of sets to return.  Valid Value will be between 1 and 1000.  Default value is 50.
.PARAMETER Authorization
    Token generated in the EPM authentication or SAML authentication API.
.Example
    Get-SetsList -LoginRegion "US" -Version 22.11.1.2879 -Offset 1 -Limit 2 -Token $Token
#>

Function Get-SetsList
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
        $Version,

        # Offset - Must be 0 or greater
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [int]
        [ValidateRange(0,[int]::MaxValue)]
        $Offset,

        # Limit - Must be between 1 and 1000.
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [int]
        [ValidateRange(1,1000)]
        $Limit,

        # Token - Authentication Token from EPM or SAML Authentication.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Token
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
            $URI = "https://$DataCenter.epm.cyberark.com/EPM/API/$Version/Sets"
        }else
        {
            $URI = "https://$DataCenter.epm.cyberark.com/EPM/API/Sets"
        }
        
        # Add URI Query Parameters
        if($Offset -and !$Limit)
        {
            $URI = $URI + "?Offset=$Offset"
            $URI
        }
        if($Limit -and !$Offset)
        {
            $URI = $URI + "?Limit=$Limit"
            $URI
        }
        If($Offset -and $Limit)
        {
            $URI = $URI + "?Offset=$Offset&Limit=$Limit"
            $URI
        }
        # Method for the EPM Authentication API
        $Method = "GET"

        # Headers for EPM Authentication API
        $Headers = @{"Content-Type" = "application/json"}
        $Headers.add("Authorization","basic $Token")

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