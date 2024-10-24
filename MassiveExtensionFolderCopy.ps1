# Uses user input for certain folder to be able to copy all files of a given type to a specified destination folder

# User input variables
$OriginalFolder = Read-Host -Prompt "Enter the folder path to copy from (ex: C:\Test)"
$DestinationFolder = Read-Host -Prompt "Enter the folder path to copy files to (ex: C:\Test)"
$FileType = Read-Host -Prompt "Please provide the file type you want to copy from the original folder. For example, if it's a document (*.docx), type 'docx'. Go ahead"

# ISSUE-INCOMPLETE -> DO LATER      # $CopyCutChoice = Read-Host -Prompt "Enter Cut to cut files, or enter/any other key to continue. Type e to exit."

# Prevent logic errors by trimming backslashes at the end if existent
if ($OriginalFolder.EndsWith("\")) {
    $OriginalFolder = $OriginalFolder.TrimEnd("\")
}
if ($DestinationFolder.EndsWith("\")) {
    $DestinationFolder = $DestinationFolder.TrimEnd("\")
}

# Check if paths exist
if ((Test-Path $OriginalFolder) -and (Test-Path $DestinationFolder)) {
    # Get all files of the specified type from the original folder
    $allFiles = Get-ChildItem -Path "$OriginalFolder" -Filter "*.$FileType" -File -Recurse -ErrorAction SilentlyContinue

    if ($allFiles.Count -gt 0) {
        # Copy each file to the destination folder
        foreach ($file in $allFiles) {
            $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name
            Copy-Item -Path $file.FullName -Destination $destinationPath -Force
            Write-Host "Copied: $($file.FullName) to $destinationPath"
        }
            Write-Host "Successfully copied $($allFiles.Count) '*.$FileType' files to '$DestinationFolder'."
    }
    else {
        Write-Host "No files of type '*.$FileType' were found in '$OriginalFolder'."
    }
}
else {
    if (-not (Test-Path $OriginalFolder)) {
        throw "The path '$OriginalFolder' does NOT exist. Please try again."
    }
    if (-not (Test-Path $DestinationFolder)) {
        throw "The path '$DestinationFolder' does NOT exist. Please try again."
    }
}
