<#
.SYNOPSIS
    Send-SAMLAuthentication
.DESCRIPTION
    This method authenticates a user to EPM with a SAML token and returns a token that can be used in subsequent web service calls.
.PARAMETER LoginRegion
    The geographical region in which your EPM server resides.
.PARAMETER ApplicationID
    Source application ID that distinguishes between REST API calls from EPM and REST API calls from another application. We recommend that you specify the customer's name.
.PARAMETER Version
    API version.  Version number. Format is x.x.x.x (for example, 11.5.0.1)
.Example
    Send-EPMAuthentication -Credential $cred -LoginRegion "US" -Version 22.11.1.2879
#>


function Send-SAMLAuthentication {
    # Enable Advanced Funciton Parameters
    [CmdletBinding()]

    # Define Parameters
    Param
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
        
        # The segment that is added to the EPM service provider Entity ID and turns it into a unique EPM login URL for your organization. Value is case-sensitive. 
        # This value was configured in your EPM Tenant --> Administration --> SAML Integration.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $OrganizationIdentifier 
    )

    Begin
    {
        # Establish DataCenter Region Identifier
        if($LoginRegion -eq 'US'){
            $DataCenter = 'login'
        }else{
            $DataCenter = $LoginRegion
        }

        # URL for SAML Authentication API
        $URI = "https://$DataCenter.epm.cyberark.com/SAML/Logon"
        

        # Method for the EPM Authentication API
        $Method = "POST"

        # Headers for EPM Authentication API
        $Headers = @{"Content-Type" = "application/x-www-form-urlencoded"}

        # Call Helper function to retrieve the SAML Response
        $SAMLResponse = New-SAMLInteractive  -EPMLoginURL "https://$DataCenter.epm.cyberark.com/SAML/$OrganizationIdentifier"

        # Body parameters for EPM Authentication API
        $Body = @{SAMLResponse= "$SAMLResponse"}

        # Set the session variable so script can be tracked between functions
        $SessionVariable = "EPMSession"        
    }
    Process
    {
        # Send REST request and save the response
        $Response = Invoke-RestMethod -Uri $URI -Method $Method -Headers $Headers -Body $Body -SessionVariable $SessionVariable

        # Write output of response for validation 
        $Response | ConvertTo-Json
    }
    End
    {
        Return $Response
    }
}