# Uses user input for certain folder to be able to copy all files of a given type to a specified destination folder

# User input variables
$OriginalFolder = Read-Host -Prompt "Enter the folder path to copy from (ex: C:\Test)"
$DestinationFolder = Read-Host -Prompt "Enter the destination folder path to copy files to (ex: C:\Test)"
$FileType = Read-Host -Prompt "Please provide the file type you want to copy from the original folder. For example, if it's a document (*.docx), type 'docx'. Go ahead"
$AmountOfFiles = 0 # keeps track of number of files

# ISSUE-INCOMPLETE -> DO LATER      # $CopyCutChoice = Read-Host -Prompt "Enter Cut to cut files, or enter/any other key to continue. Type e to exit."

# Prevent logic errors by trimming backslashes at the end if existent
if ($OriginalFolder.EndsWith("\")) {
    $OriginalFolder = $OriginalFolder.TrimEnd("\")
}
if ($DestinationFolder.EndsWith("\")) {
    $DestinationFolder = $DestinationFolder.TrimEnd("\")
}

$OriginalFolder = $OriginalFolder.Replace('\','\\')
$DestinationFolder = $DestinationFolder.Replace('\','\\')


# Check if paths exist
if ((Test-Path $OriginalFolder) -and (Test-Path $DestinationFolder)) {
    # Get all files of the specified type from the original folder
    $allFiles = Get-ChildItem -Path "$OriginalFolder" -Filter "*.$FileType" -File -Recurse #-ErrorAction SilentlyContinue

    $copiedAllFilesSuccessfully = $true

    Write-Output "TEXT BEGIN ALL FILES BELOW"
    Write-Output $allFiles
    Write-Output "TEXT END ALL FILES ABOVE"

    if ($allFiles.Count -gt 0) {
        # Copy each file to the destination folder
        foreach ($file in $allFiles) {
            # New variable to track path created for where the file goes
            $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name

            $sourcePath = $file.FullName
            if(Copy-Item -Path $sourcePath -Destination $destinationPath -Force) {
                Write-Host "Copied: $($file.Name) to $destinationPath"
            } else {
                Write-Host "Failed to copy: $($file.Name) to $destinationPath"
            }

            $AmountOfFiles++
        }

        # Checks if all files were successfully copied
        if($copiedAllFilesSuccessfully) {
            Write-Output "Successfully copied $($allFiles.Count) '*.$FileType' files to '$DestinationFolder'. Total amount of $FileType files handled: $AmountOfFiles"
        }
        else {
            Write-Output "Some files failed to copy. Please try again. Total amount of $FileType files handled: $AmountOfFiles"
        }
    }
    else {
        Write-Output "No files of type '*.$FileType' were found in '$OriginalFolder'."
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
