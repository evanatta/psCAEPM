<#
.SYNOPSIS
    Send-EPMAuthentication
.DESCRIPTION
    This method authenticates a user to EPM using username and password and returns a token that can be used in subsequent Rest API calls.
.PARAMETER Credential
    Required to be defined in the cmdlet.  Create a PSCredential utilizing Get-Credential.  Example: $cred = Get-Credential
.PARAMETER LoginRegion
    The geographical region in which your EPM server resides.
.PARAMETER ApplicationID
    Source application ID that distinguishes between REST API calls from EPM and REST API calls from another application. We recommend that you specify the customer's name.
.PARAMETER Version
    API version.  Version number. Format is x.x.x.x (for example, 11.5.0.1)
.Example
    Send-EPMAuthentication -Credential $cred -LoginRegion "US" -Version 22.11.1.2879 -ApplicationID "CyberArk REST API Script"
#>

Function Send-EPMAuthentication{

    # Enable Advanced Funciton Parameters
    [CmdletBinding()]
    
    # Define Parameters
    param(

        # Credential Object for EPM Authentication.  Use $Cred = Get-Credential and pass via pipline to function
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$Credential,

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
        
        # Application ID - Source application ID that distinguishes between REST API calls from EPM and REST API 
        # calls from another application. We recommend that you specify the customer's name
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'EPMAuthentication'
        )]
        [string]
        $ApplicationID        
    )

    # Initial Configuration
    BEGIN{

        # Establish DataCenter Region Identifier
        if($LoginRegion -eq 'US'){
            $DataCenter = 'login'
        }else{
            $DataCenter = $LoginRegion
        }

        if($null -eq $ApplicationID -or $ApplicationID -eq ''){
            $ApplicationID = "PowerShell Script excuted " + "$(Get-Date -Format 'MM-dd-yyyy HH:mm')"
        }

        # URL for EPM Authentication API
        if($Version){
            # If the Version is defined as a parameter
            $URI = "https://$DataCenter.epm.cyberark.com/EPM/API/$Version/Auth/EPM/Logon"
        }else{
            $URI = "https://$DataCenter.epm.cyberark.com/EPM/API/Auth/EPM/Logon"
        }
        
        # Method for the EPM Authentication API
        $Method = "POST"

        # Headers for EPM Authentication API
        $Headers = @{"Content-Type" = "application/json"}

        # Body parameters for EPM Authentication API
        $Body = @"
        {
            "Username": "$($Credential.Username)",
            "Password": "$($Credential.GetNetworkCredential().Password)",
            "ApplicationID": "$ApplicationID"
        }
"@

        # Set the session variable so script can be tracked between functions
        $SessionVariable = "EPMSession"

    } # End of BEGIN

    # Main Function 
    PROCESS{
        # Send REST request and save the response
        $Response = Invoke-RestMethod -Uri $URI -Method $Method -Headers $Headers -Body $Body -SessionVariable $SessionVariable

        # Write output of response for validation 
        $Response | ConvertTo-Json
    } # End of PROCESS

    # Wrap things up
    END{
        Return $Response
    } # End of END
} # End of Send-EPMAuthentication

