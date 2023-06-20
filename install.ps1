$ErrorActionPreference = "Stop"

# Define software URLs and installation commands
$software = @(
    @{
        Name = "Google Chrome"
        Url = "https://{STORAGE-ACCOUNT}.blob.core.windows.net/software/ChromeSetup.exe"
        InstallerArgs = "/silent /install"
    },
    @{
        Name = "VLC Media Player"
        Url = "https://{STORAGE-ACCOUNT}.blob.core.windows.net/software/vlc-3.0.18-win64.exe"
        InstallerArgs = "/L=1033 /S"
    },
    @{
        Name = "Visual Studio Code"
        Url = "https://{STORAGE-ACCOUNT}.blob.core.windows.net/software/VSCodeSetup-x64-1.79.2.exe"
        InstallerArgs = "/VERYSILENT /MERGETASKS=!runcode"
    }
)

# Create an event log source
$source = "SoftwareInstallation"

# Check if the event log source exists, and create it if it doesn't
if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
    [System.Diagnostics.EventLog]::CreateEventSource($source, "Application")
}

# Download and install each software
foreach ($item in $software) {
    $installer = "$env:TEMP\$($item.Name.Replace(" ", "_")).exe"
    $logMessage = "Installing $($item.Name)..."
    
    # Write a log entry with information level
    Write-EventLog -LogName "Application" -Source $source -EntryType Information -EventId 1 -Message $logMessage
    
    try {
        # Download the installer
        Invoke-WebRequest -Uri $item.Url -OutFile $installer
        
        # Install the software
        Start-Process -FilePath $installer -ArgumentList $item.InstallerArgs -Wait
        
        # Write a log entry with success information
        $successMessage = "$($item.Name) installation completed successfully."
        Write-EventLog -LogName "Application" -Source $source -EntryType Information -EventId 2 -Message $successMessage
    }
    catch {
        # Write a log entry with error information
        $errorMessage = "Failed to install $($item.Name). Error: $($_.Exception.Message)"
        Write-EventLog -LogName "Application" -Source $source -EntryType Error -EventId 3 -Message $errorMessage
    }
    finally {
        # Clean up
        Remove-Item -Path $installer -ErrorAction SilentlyContinue
    }
}
