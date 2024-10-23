# Uses user input for certain folder to be able to copy all files of a given type to specified destination folder

# User input variables
$OriginalFolder = Read-Host -Prompt "Enter the folder path to copy from (ex: C:\Test)"
$FileType = Read-Host -Prompt "Now, provide the file type you want to copy from original folder. For example, if it's a document (*.docx), type docx. Go ahead"
$DestinationFolder = Read-Host -Prompt "Enter the folder path to copy files to (ex: C:\Test)"
# ISSUE-INCOMPLETE -> DO LATER 
# $CopyCutChoice = Read-Host -Prompt "Enter Cut to cut files, or enter/any other key to continue. Type e to exit."

# Prevents logic errors by trimming backslash at end if existent
if($OriginalFolder.EndsWith("\")) {
    $OriginalFolder = $OriginalFolder.TrimEnd("\")
}

if ((Test-Path "$OriginalFolder") -and (Test-Path "$DestinationFolder")) {
    $allFiles = Get-ChildItem -Path "($OriginalFolder\*.$FileType)"

    Write-Host "TESTING: OG Folder: $OriginalFolder ; Destination: $DestinationFolder" # This test shows the correct file location. However, something weird is going on with each file path, and it might need the double "\\"

    foreach($file in $allFiles)
    {
        $file = $file.Name

        # Issue: find file's location
        Copy-Item -Path "$OriginalFolder\$file" -Destination "$DestinationFolder\$file"
    }
}
elseif ((Test-Path "$OriginalFolder") -and -not(Test-Path "$DestinationFolder")) {
    throw "The path $DestinationFolder does NOT exist. Please try again."
}
elseif (-not(Test-Path "$OriginalFolder") -and (Test-Path "$DestinationFolder")) {
    throw "The path $OriginalFolder does NOT exist. Please try again."
}
else {
    throw "The paths $DestinationFolder AND $OriginalFolder do NOT exist. Please try again."
}