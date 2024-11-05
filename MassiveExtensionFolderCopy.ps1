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

# $CopySubdirectoriesOption = Read-Host -Prompt "Copy subdirectories? y/n"

#add subdirectory support for copying subdirectories with certain file types (for onedrive)
#Duplicate file checker, add support for overwriting and copying with (1) or whatever

# Exits if user had selected
if($CopyCutChoice.ToLower().Trim() -ne "e") 
{
    # Check if bothpaths exist
    if ((Test-Path -LiteralPath $OriginalFolder) -and (Test-Path -LiteralPath $DestinationFolder)) {
        # Get all files of the specified type from the original folder
        $allFiles = Get-ChildItem -LiteralPath $OriginalFolder -Filter "*.$FileType" -File -Recurse
        $allErrors = New-Object String[] $allFiles.Count #String array to track all errors

        $transitionedAllFilesSuccessfully = $true # Tracks if all files were transitioned successfully

        if ($allFiles.Count -gt 0) {
            # Move or copy each file directly to the destination folder
            for($i = 0; $i -lt $allFiles.Count; $i++)
            {
                # Current file being processed (not using for each loop in order to write progress)
                $file = $allFiles[$i]

                # Define the destination path as the destination folder + file name only (no subdirectories)
                $destinationPath = Join-Path -Path $DestinationFolder -ChildPath $file.Name

                # Calculate+round percentage complete and shows progress bar
                $percentComplete = [math]::Round(($i + 1) / $allFiles.Count * 100)
                Write-Progress -Activity "$MovingOrCopying Files" -Status "$($file.Name) to $destinationPath; $percentComplete% Complete" -PercentComplete $percentComplete
                
                # Tries to move/copy items over
                try {
                    & $MoveOrCopyCommand -LiteralPath $file.FullName -Destination $destinationPath -Force
                }
                catch { # catch isn't catching errors for moving into folder with the same name; it just overwrites
                    $allErrors[$i] = "Failed to $MoveOrCopy $($file.Name) to $destinationPath"
                    $transitionedAllFilesSuccessfully = $false
                }
            }

            # Checks if all files were successfully moved/copied
            if ($transitionedAllFilesSuccessfully) {
                Write-Host "$MovingOrCopying all $($allFiles.Count) of '*.$FileType' files to '$DestinationFolder' was a success." -ForegroundColor Green
            }
            else {
                $NumFailedFiles = 0
                Write-Host "ALL FILE $($MovingOrCopying.ToUpper()) ERRORS BELOW: "

                # Loop through string array of all errors found
                while($NumFailedFiles -lt $allFiles.Count) {
                    if($null -ne $allErrors[$i]) {
                        Write-Host "FILE $($MoveOrCopy.ToUpper()) AT $($NumFailedFiles+1) OUT OF $($allFiles.Count) FILES HAS FAILED: $($allErrors[$NumFailedFiles])" -ForegroundColor Red
                        $NumFailedFiles++
                    }
                }
                Write-Host "$NumFailedFiles files have failed to $MoveOrCopy. Any errors are listed in detail above. Total *.$FileType failed files $($MovingOrCopying.ToLower): $NumFailedFiles out of $($allFiles.Count)"
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