# Define the paths where SDKs and Runtimes are located
$dotnetSDKPath = "C:\Program Files\dotnet\sdk"
$dotnetRuntimePath = "C:\Program Files\dotnet\shared"

# Function to list versions in a specific path
function Get-DotNetVersions {
    param (
        [string]$path
    )

    if (Test-Path $path) {
        return Get-ChildItem -Path $path -Directory | Select-Object -ExpandProperty Name
    } else {
        Write-Host "The path $path does not exist on the system."
        return @()
    }
}

# Function to find registry keys related to a specific version
function Get-RegistryKey {
    param (
        [string]$keyPath,
        [string]$version
    )

    $registryPath = "Registry::$keyPath\$version"
    if (Test-Path $registryPath) {
        return $registryPath
    } else {
        return $null
    }
}

# Function to remove a folder and its contents
function Remove-VersionFiles {
    param (
        [string]$path
    )
    if (Test-Path $path) {
        Remove-Item -Recurse -Force -Path $path
        Write-Host "Files removed: $path"
    } else {
        Write-Host "The path $path does not exist."
    }
}

# Function to remove a registry key
function Remove-RegistryKey {
    param (
        [string]$keyPath
    )
    if (Test-Path $keyPath) {
        Remove-Item -Recurse -Force -Path $keyPath
        Write-Host "Registry key removed: $keyPath"
    } else {
        Write-Host "The registry key $keyPath does not exist."
    }
}

# Generate a random confirmation code of 8 alphanumeric characters
function Generate-ConfirmationCode {
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $confirmationCode = -join ((65..90) + (48..57) | Get-Random -Count 8 | ForEach-Object {[char]$_})
    return $confirmationCode
}

# List all SDK and Runtime versions
$allVersions = @()
$index = 0

Write-Host "Available .NET Core SDK Versions:"
$sdkVersions = Get-DotNetVersions -path $dotnetSDKPath
foreach ($version in $sdkVersions) {
    $index++
    $path = Join-Path -Path $dotnetSDKPath -ChildPath $version
    if (Test-Path $path) {
        $allVersions += [PSCustomObject]@{
            Index = $index
            Type = "SDK"
            Name = "SDK"
            Version = $version
            Path = $path
            RegistryKey = $null
        }
        Write-Host "$index. SDK $version"
    } else {
        Write-Host "Invalid path for SDK $version"
    }
}

Write-Host "`nAvailable .NET Core Runtime Versions:"
if (Test-Path $dotnetRuntimePath) {
    Get-ChildItem -Path $dotnetRuntimePath -Directory | ForEach-Object {
        $runtimeGroup = $_.Name
        $runtimeVersions = Get-DotNetVersions -path $_.FullName
        foreach ($version in $runtimeVersions) {
            $index++
            $path = Join-Path -Path $_.FullName -ChildPath $version
            if (Test-Path $path) {
                $allVersions += [PSCustomObject]@{
                    Index = $index
                    Type = "Runtime"
                    Name = "Runtime ($runtimeGroup)"
                    Version = $version
                    Path = $path
                    RegistryKey = $null
                }
                Write-Host "$index. Runtime ($runtimeGroup) $version"
            } else {
                Write-Host "Invalid path for Runtime ($runtimeGroup) $version"
            }
        }
    }
}

# Assign registry keys
$registryPaths = @(
    "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x86\sdk",
    "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sdk",
    "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x86\shared",
    "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\shared"
)

foreach ($version in $allVersions) {
    $versionString = $version.Version
    foreach ($registryPath in $registryPaths) {
        $registryKey = Get-RegistryKey -keyPath $registryPath -version $versionString
        if ($registryKey) {
            $version.RegistryKey = $registryKey
            break
        }
    }
}

# Prompt user to select versions to remove
$selectedIndices = Read-Host "`nEnter the numbers of the versions you want to remove, separated by commas"
$selectedIndices = $selectedIndices -split ',' | ForEach-Object { $_.Trim() }

$selectedVersions = $allVersions | Where-Object { $selectedIndices -contains $_.Index.ToString() }

if ($selectedVersions.Count -gt 0) {
    Write-Host "`nSelected versions for removal:"
    $selectedVersions | ForEach-Object {
        Write-Host "Version: $($_.Name) $($_.Version)"
        Write-Host "Files Location: $($_.Path)"
        if ($_.RegistryKey) {
            Write-Host "Registry Key: $($_.RegistryKey)"
        } else {
            Write-Host "No registry key found for this version."
        }
    }

    # Generate and show confirmation code
    $confirmationCode = Generate-ConfirmationCode
    Write-Host "`nTo confirm the removal, type the following 8-character alphanumeric code: $confirmationCode"
    $userConfirmation = Read-Host "Enter the code to confirm"

    if ($userConfirmation -eq $confirmationCode) {
        foreach ($version in $selectedVersions) {
            # Remove files and registry key
            Remove-VersionFiles -path $version.Path
            if ($version.RegistryKey) {
                Remove-RegistryKey -keyPath $version.RegistryKey
            }
        }
        Write-Host "All selected versions have been removed."
    } else {
        Write-Host "Incorrect confirmation code. No changes were made."
    }
} else {
    Write-Host "No valid versions found for removal."
}
