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

# Use optimize function to normalize folder paths
$CopyCutChoice = Read-Host "Enter cut to move all found files from origin to destination. Enter or anything else to continue copying."
$OriginalFolder = Optimize-Path (Read-Host -Prompt "Enter the folder path to copy/move from (ex: C:\Test)")
$DestinationFolder = Optimize-Path (Read-Host -Prompt "Enter the destination folder path to copy/move files to (ex: C:\Destination)")
$FileType = Read-Host -Prompt "Please provide the file type you want to copy/move from the original folder. If it's a screenshot (*.png), type 'docx'. If a screen recording/downloaded video, enter mp4. Go ahead"

# ISSUE-INCOMPLETE -> DO LATER      # $CopyCutChoice = Read-Host -Prompt "Enter Cut to cut files, or enter/any other key to continue. Type e to exit."
# save all errors for end using string array (if length less than 0, print no errors found)
#add subdirectory support for copying subdirectories with certain file types (for onedrive)

if($CopyCutChoice.ToLower() -eq "cut")
{
    # Check if paths exist
    if ((Test-Path -LiteralPath $OriginalFolder) -and (Test-Path -LiteralPath $DestinationFolder)) {
        # Get all files of the specified type from the original folder
        $allFiles = Get-ChildItem -LiteralPath $OriginalFolder -Filter "*.$FileType" -File -Recurse
        $movedAllFilesSuccessfully = $true # Tracks if all files were moved successfully

        if ($allFiles.Count -gt 0) {
            # Move each file directly to the destination folder
            for($i = 0; $i -lt $allFiles.Count; $i++)
            {
                # Declares current file (not using for each loop in order to write progress)
                $file = $allFiles[$i]

                # Define the destination path as the destination folder + file name only (no subdirectories)
                $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name

                # Tries to move/copy items over
                try {
                    Move-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
                    # Write-Host "Moved: $($file.Name) to $destinationPath" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to move: $($file.Name) to $destinationPath" -ForegroundColor Red
                    Write-Host "Error message: $_" -ForegroundColor Red
                    $movedAllFilesSuccessfully = $false
                }

                # Calculate+round percentage complete and shows progress bar
                $percentComplete = [math]::Round(($i + 1) / $allFiles.Count * 100)
                Write-Progress -Activity "Moving Files" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
            }

            # Checks if all files were successfully moved
            if ($movedAllFilesSuccessfully -eq $true) {
                Write-Host "Successfully moved $($allFiles.Count) '*.$FileType' files to '$DestinationFolder'."
            }
            else {
                Write-Host "Some files failed to move. Please try again. Total amount of $FileType files handled: $($allFiles.Count)"
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
}
# Copies files instead of moving
else {
    # Check if paths exist
    if ((Test-Path -LiteralPath $OriginalFolder) -and (Test-Path -LiteralPath $DestinationFolder)) {
        # Get all files of the specified type from the original folder
        $allFiles = Get-ChildItem -LiteralPath $OriginalFolder -Filter "*.$FileType" -File -Recurse
        $copiedAllFilesSuccessfully = $true # Tracks if all files were copied successfully

        if ($allFiles.Count -gt 0) {
            # For each file, copy directly to the destination folder
            for($i = 0; $i -lt $allFiles.Count; $i++)
            {
                # Declares current file (not using for each loop in order to write progress)
                $file = $allFiles[$i]

                # Define the destination path as the destination folder + file name only (no subdirectories)
                $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name

                # Tries to copy items over
                try {
                    Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
                    # Write-Host "Copied: $($file.Name) to $destinationPath" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to copy: $($file.Name) to $destinationPath" -ForegroundColor Red
                    Write-Host "Error message: $_" -ForegroundColor Red
                    $copiedAllFilesSuccessfully = $false
                }

                # Calculate percentage complete and shows progress bar
                $percentComplete = [math]::Round(($i + 1) / $allFiles.Count * 100)
                Write-Progress -Activity "Copying Files" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
            }

            # Checks if all files were successfully copied
            if ($copiedAllFilesSuccessfully -eq $true) {
                Write-Host "Successfully copied $($allFiles.Count) '*.$FileType' files to '$DestinationFolder'."
            }
            else {
                Write-Host "Some files failed to copy. Please try again. Total amount of $FileType files handled: $($allFiles.Count)"
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
}