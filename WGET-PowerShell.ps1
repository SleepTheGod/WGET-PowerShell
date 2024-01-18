# Contents of Download-WebsiteTool.ps1

function Download-Website {
    param (
        [string]$Url,
        [string]$OutputDirectory
    )

    try {
        # Create the output directory if it doesn't exist
        if (-not (Test-Path $OutputDirectory -PathType Container)) {
            New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
        }

        # Download the page
        $webpage = Invoke-WebRequest -Uri $Url

        # Save the HTML content to a file
        $fileName = [System.IO.Path]::Combine($OutputDirectory, [System.IO.Path]::GetFileName($Url))
        $webpage.Content | Out-File -FilePath $fileName -Encoding UTF8

        # Find and download linked resources (recursively)
        $webpage.Links | ForEach-Object {
            $resourceUrl = $_.href
            $resourceOutputDirectory = [System.IO.Path]::Combine($OutputDirectory, $_.href -replace '[:/\\?]', '_')

            Download-Website -Url $resourceUrl -OutputDirectory $resourceOutputDirectory
        }
    } catch {
        Write-Host "Error: $_"
    }
}

# Help command
function Get-HelpCommands {
    Write-Host "Available Commands:"
    Write-Host "  Download-Website -Url <URL> -OutputDirectory <OutputDirectory>   - Downloads a website recursively."
    Write-Host "  Get-HelpCommands                                                  - Displays available commands."
}

# Specify the path to this script
$scriptPath = $MyInvocation.MyCommand.Path

# Get the user's profile path
$profilePath = $PROFILE

# Check if the profile script exists
if (Test-Path $profilePath) {
    # Append the script loading to the user's profile
    Add-Content -Path $profilePath -Value "`r`n# Load Download-WebsiteTool script`r`n. $scriptPath"
    
    Write-Host "Download-WebsiteTool script loaded into the PowerShell profile."
    Write-Host "You can now use the 'Download-Website' function as a command-line tool."
    Write-Host "Type 'Get-HelpCommands' for a list of available commands."
    
    # Remote script execution example
    Write-Host "To execute a script from a remote location, use:"
    Write-Host "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/path/to/Download-WebsiteTool.ps1').Content"
} else {
    Write-Host "Unable to locate user's profile. Please manually add the following line to your PowerShell profile:"
    Write-Host ". $scriptPath"
}
