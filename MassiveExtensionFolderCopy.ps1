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
$CopyCutChoice = Read-Host "Enter cut to move files from origin to destination. E to exit (following prompts), or any key to copy."
    $MovingOrCopying = if ($CopyCutChoice.Trim().ToLower() -eq "cut") { "Moving" } else { "Copying" }
    $MoveOrCopy = if ($MovingOrCopying -eq "Moving") { "move" } else { "copy"}
    $MoveOrCopyCommand = if ($MovingOrCopying.Trim().ToLower() -eq "moving") { "Move-Item" } else { "Copy-Item" }
$OriginalFolder = Optimize-Path (Read-Host -Prompt "Enter the folder path to $MoveOrCopy from (ex: C:\Test)")
$DestinationFolder = Optimize-Path (Read-Host -Prompt "Enter the destination folder path to $MoveOrCopy files to (ex: C:\Destination)")
$FileType = Read-Host -Prompt "Please provide the file type you want to $MoveOrCopy from the original folder. If it's a screenshot (*.png), type 'docx'. If a screen recording/downloaded video, enter mp4. Go ahead"

# save all errors for end using string array (if length less than 0, print no errors found)
#add subdirectory support for copying subdirectories with certain file types (for onedrive)

# Exits if user had selected
if($CopyCutChoice.ToLower().Trim() -ne "e") 
{
# Check if bothpaths exist
if ((Test-Path -LiteralPath $OriginalFolder) -and (Test-Path -LiteralPath $DestinationFolder)) {
    # Get all files of the specified type from the original folder
    $allFiles = Get-ChildItem -LiteralPath $OriginalFolder -Filter "*.$FileType" -File -Recurse
    $transitionedAllFilesSuccessfully = $true # Tracks if all files were transitioned successfully

    if ($allFiles.Count -gt 0) {
        # Move or copy each file directly to the destination folder
        for($i = 0; $i -lt $allFiles.Count; $i++)
        {
            # Current file being processed (not using for each loop in order to write progress)
            $file = $allFiles[$i]

            # Define the destination path as the destination folder + file name only (no subdirectories)
            $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name

            # Tries to move/copy items over
            try {
                & $MoveOrCopyCommand -LiteralPath $file.FullName -Destination $destinationPath -Force
                # Write-Host "$MovingOrCopying: $($file.Name) to $destinationPath" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to $MoveOrCopy $($file.Name) to $destinationPath" -ForegroundColor Red
                Write-Host "Error message: $_" -ForegroundColor Red
                $transitionedAllFilesSuccessfully = $false
            }

            # Calculate+round percentage complete and shows progress bar
            $percentComplete = [math]::Round(($i + 1) / $allFiles.Count * 100)
            Write-Progress -Activity "$MovingOrCopying Files" -Status "$($file.Name)); $percentComplete% Complete" -PercentComplete $percentComplete

        }

        # Checks if all files were successfully moved/copied
        if ($transitionedAllFilesSuccessfully) {
            Write-Host "$MovingOrCopying $($allFiles.Count) of '*.$FileType' files to '$DestinationFolder' was a success."
        }
        else {
            Write-Host "Some files have failed to $MoveOrCopy. Total amount of $FileType files $MovingOrCopying`: $($allFiles.Count)"
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
else {
    Write-Host "Quitting..."
}