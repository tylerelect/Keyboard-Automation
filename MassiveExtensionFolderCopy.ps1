# Function to prevent logic errors by trimming backslashes at the end of path, if existent
function Optimize-Path {
    param (
        [string]$Path
    )
    if ($Path.EndsWith("\")) {
        $Path = $Path.TrimEnd("\")
    }
    return $Path
}

# Use helper to normalize folder paths
$OriginalFolder = Optimize-Path (Read-Host -Prompt "Enter the folder path to copy from (ex: C:\Test)")
$DestinationFolder = Optimize-Path (Read-Host -Prompt "Enter the destination folder path to copy files to (ex: C:\Destination)")
$FileType = Read-Host -Prompt "Please provide the file type you want to copy from the original folder. For example, if it's a document (*.docx), type 'docx'. Go ahead"
$AmountOfFiles = 0 # keeps track of number of files

# Check if paths exist
if ((Test-Path -LiteralPath $OriginalFolder) -and (Test-Path -LiteralPath $DestinationFolder)) {
    # 
    $copiedAllFilesSuccessfully = $true

    # Get all files of the specified type from the original folder
    $allFiles = Get-ChildItem -LiteralPath $OriginalFolder -Filter "*.$FileType" -File -Recurse

    if ($allFiles.Count -gt 0) {
        # Copy each file directly to the destination folder
        foreach ($file in $allFiles) {
            # Define the destination path as the destination folder + file name only (no subdirectories)
            $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name

            try {
                Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
                Write-Host "Copied: $($file.Name) to $destinationPath" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to copy: $($file.Name) to $destinationPath" -ForegroundColor Red
                Write-Host "Error message: $_" -ForegroundColor Red
                $copiedAllFilesSuccessfully = $false
            }
            $AmountOfFiles++
        }

        # Checks if all files were successfully copied
        if ($copiedAllFilesSuccessfully -eq $true) {
            Write-Host "Successfully copied $($allFiles.Count) '*.$FileType' files to '$DestinationFolder'. Total amount of $FileType files handled: $AmountOfFiles"
        }
        else {
            Write-Host "Some files failed to copy. Please try again. Total amount of $FileType files handled: $AmountOfFiles"
        }
    }
    else {
        Write-Host "No files of type '*.$FileType' were found in '$OriginalFolder'."
    }
}
else {
    if (-not (Test-Path -LiteralPath $OriginalFolder)) {
        throw "The path '$OriginalFolder' does NOT exist. Please try again."
    }
    if (-not (Test-Path -LiteralPath $DestinationFolder)) {
        throw "The path '$DestinationFolder' does NOT exist. Please try again."
    }
}
