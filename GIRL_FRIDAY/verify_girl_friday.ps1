# Girl Friday Directory Structure Verification Script
# Created: 2025-12-23 14:17:44 EST
# Purpose: Verify D:\JARVIS\GIRL_FRIDAY\ is set up correctly

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GIRL FRIDAY DIRECTORY VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Set base path
$BasePath = "D:\JARVIS\GIRL_FRIDAY"

# Check if base directory exists
if (Test-Path $BasePath) {
    Write-Host "✅ Base directory found: $BasePath" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: Base directory not found: $BasePath" -ForegroundColor Red
    Write-Host "   Please verify the path is correct." -ForegroundColor Yellow
    exit
}

Write-Host "`n--- Checking Core Files ---`n" -ForegroundColor Yellow

# Check required files
$RequiredFiles = @{
    "CLAUDE.md" = "Operating instructions for Claude"
    "ROADMAP.md" = "Task tracking with P0/P1/P2 priorities"
}

foreach ($file in $RequiredFiles.Keys) {
    $FilePath = Join-Path $BasePath $file
    if (Test-Path $FilePath) {
        $FileSize = (Get-Item $FilePath).Length
        $FileSizeKB = [math]::Round($FileSize / 1KB, 2)
        Write-Host "✅ $file ($FileSizeKB KB)" -ForegroundColor Green
        Write-Host "   Purpose: $($RequiredFiles[$file])" -ForegroundColor Gray
    } else {
        Write-Host "❌ MISSING: $file" -ForegroundColor Red
        Write-Host "   Expected at: $FilePath" -ForegroundColor Yellow
    }
}

Write-Host "`n--- Checking .worklog Directory ---`n" -ForegroundColor Yellow

# Check .worklog directory
$WorklogPath = Join-Path $BasePath ".worklog"
if (Test-Path $WorklogPath) {
    Write-Host "✅ .worklog directory found" -ForegroundColor Green
    
    # Check carry_forward.md
    $CarryForwardPath = Join-Path $WorklogPath "carry_forward.md"
    if (Test-Path $CarryForwardPath) {
        $FileSize = (Get-Item $CarryForwardPath).Length
        $FileSizeKB = [math]::Round($FileSize / 1KB, 2)
        Write-Host "✅ carry_forward.md ($FileSizeKB KB)" -ForegroundColor Green
        Write-Host "   Purpose: Critical details that persist between sessions" -ForegroundColor Gray
    } else {
        Write-Host "❌ MISSING: carry_forward.md" -ForegroundColor Red
        Write-Host "   Expected at: $CarryForwardPath" -ForegroundColor Yellow
    }
    
    # Check sessions directory
    $SessionsPath = Join-Path $WorklogPath "sessions"
    if (Test-Path $SessionsPath) {
        Write-Host "✅ sessions directory found" -ForegroundColor Green
        
        # List session files
        $SessionFiles = Get-ChildItem -Path $SessionsPath -Filter "*.md" | Sort-Object Name
        if ($SessionFiles.Count -gt 0) {
            Write-Host "`n   Session files found:" -ForegroundColor Gray
            foreach ($SessionFile in $SessionFiles) {
                $FileSize = [math]::Round($SessionFile.Length / 1KB, 2)
                Write-Host "   ✅ $($SessionFile.Name) ($FileSize KB)" -ForegroundColor Green
            }
        } else {
            Write-Host "   ⚠️  No session files found (this is OK for first time setup)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ MISSING: sessions directory" -ForegroundColor Red
        Write-Host "   Expected at: $SessionsPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ MISSING: .worklog directory" -ForegroundColor Red
    Write-Host "   Expected at: $WorklogPath" -ForegroundColor Yellow
}

Write-Host "`n--- Checking Optional Directories ---`n" -ForegroundColor Yellow

# Check optional docs directory
$DocsPath = Join-Path $BasePath "docs"
if (Test-Path $DocsPath) {
    Write-Host "✅ docs directory found (optional)" -ForegroundColor Green
    
    # Check subdirectories
    $OptionalDirs = @("architectures", "research", "decisions")
    foreach ($dir in $OptionalDirs) {
        $DirPath = Join-Path $DocsPath $dir
        if (Test-Path $DirPath) {
            Write-Host "   ✅ docs\$dir" -ForegroundColor Green
        }
    }
} else {
    Write-Host "⚠️  docs directory not found (optional - can be created later)" -ForegroundColor Yellow
}

Write-Host "`n--- Directory Tree ---`n" -ForegroundColor Yellow

# Display directory tree
try {
    Push-Location $BasePath
    Write-Host "GIRL_FRIDAY\" -ForegroundColor Cyan
    Get-ChildItem -Recurse | ForEach-Object {
        $Depth = ($_.FullName.Substring($BasePath.Length) -split '\\').Count - 1
        $Indent = "  " * $Depth
        if ($_.PSIsContainer) {
            Write-Host "$Indent├── $($_.Name)\" -ForegroundColor Cyan
        } else {
            $FileSize = [math]::Round($_.Length / 1KB, 2)
            Write-Host "$Indent├── $($_.Name) ($FileSize KB)" -ForegroundColor White
        }
    }
    Pop-Location
} catch {
    Write-Host "Could not generate directory tree" -ForegroundColor Red
}

Write-Host "`n--- Summary ---`n" -ForegroundColor Yellow

# Count files and directories
$TotalFiles = (Get-ChildItem -Path $BasePath -Recurse -File).Count
$TotalDirs = (Get-ChildItem -Path $BasePath -Recurse -Directory).Count

Write-Host "Total files: $TotalFiles" -ForegroundColor White
Write-Host "Total directories: $TotalDirs" -ForegroundColor White

# Final status
Write-Host "`n========================================" -ForegroundColor Cyan
$RequiredFilesExist = (Test-Path (Join-Path $BasePath "CLAUDE.md")) -and `
                      (Test-Path (Join-Path $BasePath "ROADMAP.md")) -and `
                      (Test-Path (Join-Path $WorklogPath "carry_forward.md"))

if ($RequiredFilesExist) {
    Write-Host "✅ GIRL FRIDAY IS READY TO USE!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Host "Next step: Tell Claude to 'Check ROADMAP before working'" -ForegroundColor Yellow
} else {
    Write-Host "❌ SETUP INCOMPLETE" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Host "Please ensure all required files are in place." -ForegroundColor Yellow
}
