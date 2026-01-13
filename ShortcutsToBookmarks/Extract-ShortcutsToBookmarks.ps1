<#
.SYNOPSIS
    Extracts URLs from Windows shortcut files organized by folder and creates a bookmarks HTML file
.DESCRIPTION
    Scans for .url files in specified directories, organizes them by folder name,
    and creates a Netscape bookmarks HTML file with folder structure
.PARAMETER SearchPath
    Directory path to search for shortcuts (default: Desktop)
.PARAMETER OutputFile
    Output bookmarks HTML file path (default: ShortcutsBookmarks.html)
.PARAMETER Recurse
    Search subdirectories recursively
#>
param(
    [string]$SearchPath = "$env:USERPROFILE\Desktop",
    [string]$OutputFile = "ShortcutsBookmarks.html",
    [switch]$Recurse
)

Write-Host "Extracting URLs from shortcuts in: $SearchPath" -ForegroundColor Green

# Create WScript.Shell COM object for reading shortcuts
$shell = New-Object -ComObject WScript.Shell

# Find all .url files
$searchOption = if ($Recurse) { [System.IO.SearchOption]::AllDirectories } else { [System.IO.SearchOption]::TopDirectoryOnly }
$urlFiles = Get-ChildItem -Path $SearchPath -Filter "*.url" -File -Recurse:$Recurse

Write-Host "Found $($urlFiles.Count) shortcut files" -ForegroundColor Yellow

# Organize bookmarks by folder
$folderBookmarks = @{}

foreach ($file in $urlFiles) {
    try {
        # Get the folder name (parent directory name)
        $folderName = $file.Directory.Name
        if ($folderName -eq "Desktop") { $folderName = "Desktop Shortcuts" }
        
        # Read the URL from the .url file
        $content = Get-Content $file.FullName -Raw
        $urlMatch = [regex]::Match($content, "(?<=URL=)([^\r\n]+)")
        
        if ($urlMatch.Success) {
            $url = $urlMatch.Value.Trim()
            $name = $file.BaseName
            
            # Create folder entry if it doesn't exist
            if (-not $folderBookmarks.ContainsKey($folderName)) {
                $folderBookmarks[$folderName] = @()
            }
            
            # Add bookmark to folder
            $folderBookmarks[$folderName] += @{
                Name = $name
                URL = $url
                FilePath = $file.FullName
            }
            
            Write-Host "Extracted [$folderName]: $name -> $url" -ForegroundColor Cyan
        } else {
            Write-Warning "No URL found in: $($file.Name)"
        }
    }
    catch {
        Write-Warning "Error processing $($file.Name): $_"
    }
}

# Generate Netscape bookmarks HTML format
$htmlContent = @"
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
"@

# Add each folder and its bookmarks
foreach ($folder in $folderBookmarks.Keys | Sort-Object) {
    $timestamp = [int][double]::Parse((Get-Date -Date (Get-Date).ToUniversalTime() -UFormat %s))
    
    $htmlContent += "    <DT><H3 ADD_DATE=`"$timestamp`" LAST_MODIFIED=`"$timestamp`">$folder</H3>`n"
    $htmlContent += "    <DL><p>`n"
    
    foreach ($bookmark in $folderBookmarks[$folder]) {
        $htmlContent += "        <DT><A HREF=`"$($bookmark.URL)`" ADD_DATE=`"$timestamp`">$($bookmark.Name)</A>`n"
    }
    
    $htmlContent += "    </DL><p>`n"
}

$htmlContent += "</DL><p>"

# Save the HTML file
$htmlContent | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nBookmarks exported to: $OutputFile" -ForegroundColor Green
Write-Host "Found $($folderBookmarks.Keys.Count) folders with total $($urlFiles.Count) shortcuts" -ForegroundColor Green
Write-Host "Folder structure preserved in bookmarks!" -ForegroundColor Green

# Show folder summary
Write-Host "`nFolder Summary:" -ForegroundColor Yellow
foreach ($folder in $folderBookmarks.Keys | Sort-Object) {
    Write-Host "  $folder`: $($folderBookmarks[$folder].Count) shortcuts" -ForegroundColor White
}

Write-Host "`nYou can import this file into Chrome, Firefox, Edge, or other browsers" -ForegroundColor Green

# Cleanup COM object
[Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null