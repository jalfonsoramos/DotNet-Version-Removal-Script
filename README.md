# README - DotNet Version Removal Script

## Overview

This PowerShell script is designed to help users identify and remove specific versions of .NET Core SDKs and Runtimes from their Windows 10 system. The script provides a comprehensive method for listing installed versions, checking for corresponding registry keys, and safely removing selected versions by deleting their associated files and registry entries.

## Objective of the Script

The primary goal of this script is to facilitate the cleanup of obsolete or unwanted .NET Core SDK and Runtime versions from your system. It enables users to:
- List all installed .NET Core SDKs and Runtimes.
- View the file locations and registry keys associated with each version.
- Select one or more versions for removal.
- Confirm the removal action with a randomly generated code to prevent accidental deletions.

## High-Level Implementation Details

1. **List Installed Versions:**
   - The script scans predefined directories for .NET Core SDKs and Runtimes and collects information about each version installed.

2. **Identify Registry Keys:**
   - It checks common registry paths to find associated registry keys for the listed SDKs and Runtimes.

3. **User Interaction:**
   - Users are presented with a list of available versions with indices, paths, and registry keys.
   - Users can select multiple versions to remove by entering indices separated by commas.

4. **Confirm Removal:**
   - A randomly generated alphanumeric code is displayed for confirmation.
   - Users must enter this code to confirm the removal of selected versions, which adds an additional layer of safety to prevent accidental deletions.

5. **Remove Selected Versions:**
   - The script deletes the files associated with the selected versions and removes corresponding registry entries if they exist.

## Disclaimer

This script was generated with the assistance of ChatGPT, an AI language model developed by OpenAI. While the script is designed to be functional and safe, it is always recommended to review and test scripts in a controlled environment before deploying them in a production setting.