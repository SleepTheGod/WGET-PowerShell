# Contents of WGET-PowerShell.ps1

function Download-Website {
    param (
        [string]$Url,
        [string]$OutputDirectory
    )

    try {
        # Set a custom User-Agent header
        $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        $Headers = @{
            "User-Agent" = $UserAgent
        }

        # Create the output directory if it doesn't exist
        if (-not (Test-Path $OutputDirectory -PathType Container)) {
            New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
        }

        # Download the page with custom User-Agent header
        $webpage = Invoke-WebRequest -Uri $Url -Headers $Headers

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

# Remote script execution example
Write-Host "To execute this script from a remote location, use:"
Write-Host "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SleepTheGod/WGET-PowerShell/master/WGET-PowerShell.ps1').Content"
