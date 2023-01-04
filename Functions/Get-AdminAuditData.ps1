<#
.SYNOPSIS
    Get-AdminAuditData
.DESCRIPTION
    This method enables the user to retrieve the list of Sets.
.PARAMETER LoginRegion
    The geographical region in which your EPM server resides.
.PARAMETER Version
    API version.  Version number. Format is x.x.x.x (for example, 11.5.0.1)
.PARAMETER SetID
    ID of a set that the user has permission to view, generated in the Get sets list API
.PARAMETER DateFrom
    Only include events since the given date. ISO-8601 to format dates and UTC time zone - YYYY-MM-DDThh:mm:ssZ
    If DateFrom and DateTo are not set, only events from the last day are returned
    If only DateFrom is set, all events from that date are returned
.PARAMETER DateTo
    Only include events until the given date.  ISO-8601 to format dates and UTC time zone - YYYY-MM-DDThh:mm:ssZ
    If DateFrom and DateTo are not set, only events from the last day are returned
    If only DateTo is set, all events until that date are returned
.PARAMETER Offset
    Number of sets to skip.  Valid value will be zero or greater.  Default is zero.
.PARAMETER Limit
    Maximum number of sets to return.  Valid Value will be between 1 and 1000.  Default value is 50.
.PARAMETER Authorization
    Token generated in the EPM authentication or SAML authentication API.
.Example
    Get-AdminAuditData -LoginRegion "US" -Version 22.11.1.2879 -DateFrom 2020-05-26T08:00:00Z -DateTo 2020-05-28T:09:00:00Z -Offset 1 -Limit 2 -Token $Token
#>

Function Get-AdminAuditData
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

        # ID of a set that the user has permission to view, generated in the Get sets list API
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [ValidatePattern("^[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}$")]  # 8 Hex Values - 4 Hex Values 3 times - 12 Hex Values 01234567-89AB-CDEF-0123-456789ABCDEF
        $SetID,

        # Only include events since the given date
        # ISO-8601 to format dates and UTC time zone - YYYY-MM-DDThh:mm:ssZ
        # If DateFrom and DateTo are not set, only events from the last day are returned
        # If only DateFrom is set, all events from that date are returned
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [ValidatePattern()]
        $DateFrom,

        # Only include events until the given date
        # ISO-8601 to format dates and UTC time zone - YYYY-MM-DDThh:mm:ssZ
        # If DateFrom and DateTo are not set, only events from the last day are returned
        # If only DateTo is set, all events until that date are returned
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        $DateTo,

        # Offset - Number of events to skip
        # 0 (zero) or Higher
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [int]
        [ValidateRange(0,[int]::MaxValue)]
        $Offset,

        # Limit - Maximum number of events to return
        # Higher than 0 (zero)
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [int]
        [ValidateRange(1,1000)]
        $Limit,

        # Authorization - Authentication Token from EPM or SAML Authentication.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Authorization
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
        # Add URI Search Parameters
        $SearchParameterCount = 0
        if($Offset){
            $SearchParameterCount += 1
            if($SearchParameterCount -gt 1){
                $URI = $URI + "&Offset=$Offset"
            }else{
                $URI = $URI + "?Offset=$Offset"
            }
        }
        If($Limit){
            $SearchParameterCount += 1
            if($SearchParameterCount -gt 1){
                $URI = $URI + "&Limit=$Limit"
            }else{
                $URI = $URI + "?Limit=$Limit"
            }
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