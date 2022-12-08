function New-SAMLInteractive{

    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[string] $EPMLoginURL
	)

    Begin{

        $RegEx = '(?i)name="SAMLResponse"(?: type="hidden")? value=\"(.*?)\"(?:.*)?\/>'

        Add-Type -AssemblyName System.Windows.Forms 
        Add-Type -AssemblyName System.Web

    }

    Process{

        # create window for embedded browser
        $form = New-Object Windows.Forms.Form
        $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
        $form.Width = 640
        $form.Height = 700
        $form.showIcon = $false
	$form.Topmost = $true
    
        $web = New-Object Windows.Forms.WebBrowser
        $web.Size = $form.ClientSize
        $web.Anchor = "Left,Top,Right,Bottom"
        $web.ScriptErrorsSuppressed = $true

        $form.Controls.Add($web)

        $web.Navigate($EPMLoginURL)
    
        $web.add_Navigating({
    
            if ($web.DocumentText -match "SAMLResponse"){

                $_.cancel = $true

                if ($web.DocumentText -match $RegEx){
            
                    $form.Close()
                    $Script:SAMLResponse = $(($Matches[1] -replace '&#x2b;', '+') -replace '&#x3d;', '=')
                    

                }

            }

        })
    
        # show browser window, waits for window to close
        if($form.ShowDialog() -ne "OK") {
            
            if ($null -ne $Script:SAMLResponse){

                Write-Output $Script:SAMLResponse
                $form.Close()
                Remove-Variable -Name SAMLResponse -Scope Script -ErrorAction SilentlyContinue

            }
            Else{
            
                throw "SAMLResponse not matched"
            
            }
    
        }
    }

    End{
        
        $form.Dispose()
        
    }

}
