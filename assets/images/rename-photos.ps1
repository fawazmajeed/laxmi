# ─────────────────────────────────────────────────────────
#  Laxmi Tharavadu — Photo Rename Script
#  Run this once from PowerShell inside assets/images/
#  It renames uploaded photos to the website's standard names.
#
#  Usage:
#    cd C:\Users\Fawaz\Documents\GitHub\laxmi\assets\images
#    .\rename-photos.ps1
#
#  After running, commit and push:
#    git add assets/images/*.jpg
#    git commit -m "Add property photos"
#    git push
# ─────────────────────────────────────────────────────────

$targetNames = @(
    "hero-bg",          # Hero section background — wide exterior / forest shot
    "story",            # About section — courtyard / interior / nadumuttam
    "room-patio",       # The Patio Room — ground floor, patio access
    "room-nadumuttam",  # The Nadumuttam Room — courtyard view
    "room-attic",       # The Attic Room — upper floor heritage room
    "room-garden",      # The Garden Room — garden wing
    "gallery-1",        # Gallery — largest/hero image (portrait or wide)
    "gallery-2",        # Gallery — top right
    "gallery-3",        # Gallery — mid right
    "gallery-4",        # Gallery — bottom left
    "gallery-5"         # Gallery — bottom right
)

# Get all JPG/JPEG/PNG files NOT already named correctly, sorted by creation time
$photos = Get-ChildItem -Path . -Include "*.jpg","*.jpeg","*.png" -File |
          Where-Object { $_.BaseName -notmatch "^(hero-bg|story|room-|gallery-|logo|README)" } |
          Sort-Object CreationTime

Write-Host ""
Write-Host "Found $($photos.Count) unassigned photo(s)." -ForegroundColor Cyan
Write-Host ""

if ($photos.Count -eq 0) {
    Write-Host "No new photos to rename. Exiting." -ForegroundColor Yellow
    exit
}

# Show a preview of the renaming plan
Write-Host "Rename plan (files sorted by creation date):" -ForegroundColor White
Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray

for ($i = 0; $i -lt [Math]::Min($photos.Count, $targetNames.Count); $i++) {
    $src  = $photos[$i].Name
    $ext  = $photos[$i].Extension.ToLower().Replace(".jpeg",".jpg")
    $dest = "$($targetNames[$i])$ext"
    Write-Host "  $src  →  $dest" -ForegroundColor Green
}

if ($photos.Count -gt $targetNames.Count) {
    Write-Host ""
    Write-Host "  Note: $($photos.Count - $targetNames.Count) extra photo(s) will not be renamed (no slot defined)." -ForegroundColor Yellow
}

Write-Host ""
$confirm = Read-Host "Proceed with rename? (Y/N)"

if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit
}

# Execute renames
for ($i = 0; $i -lt [Math]::Min($photos.Count, $targetNames.Count); $i++) {
    $src  = $photos[$i].FullName
    $ext  = $photos[$i].Extension.ToLower().Replace(".jpeg",".jpg")
    $dest = Join-Path (Split-Path $src) "$($targetNames[$i])$ext"

    if (Test-Path $dest) {
        Write-Host "  SKIP (already exists): $dest" -ForegroundColor Yellow
    } else {
        Rename-Item -Path $src -NewName (Split-Path $dest -Leaf)
        Write-Host "  Renamed: $($photos[$i].Name) → $(Split-Path $dest -Leaf)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Done. Now run:" -ForegroundColor Cyan
Write-Host "  git add assets/images/*.jpg" -ForegroundColor White
Write-Host "  git commit -m `"Add property photos`"" -ForegroundColor White
Write-Host "  git push" -ForegroundColor White
Write-Host ""
