# Universal psm file
# Requires -Version 5.0

# Get functions' files
$Functions = @( Get-ChildItem -Path -$PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach($Import in @($Functions)){
    Try{
        .$Import.fullname
    }
    Catch{
        Write-Error -Message "Failed to import function $($Import.fullname): $_"
    }
}

# Export everything in the public folder
Export-ModuleMember -Function * -Cmdlet * -Alias *
