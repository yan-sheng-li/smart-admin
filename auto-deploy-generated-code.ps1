param(
    [Parameter(Mandatory=$true)]
    [string]$zipPath,
    [string]$backendRoot = "G:\ai-projects\smart-admin\smart-admin-api-java17-springboot3",
    [string]$frontendRoot = "G:\ai-projects\smart-admin\smart-admin-web-javascript",
    [string]$backendPackage = "com\example"
)

if (!(Test-Path $zipPath)) {
    Write-Host "File not found: $zipPath" -ForegroundColor Red
    exit 1
}

$tempDir = Join-Path $env:TEMP "codegen_$([guid]::NewGuid())"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "Extracting..." -ForegroundColor Cyan
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempDir)

# Get module name from java\{moduleName}
$javaDir = Join-Path $tempDir "java"
$moduleDir = Get-ChildItem $javaDir -Directory | Select-Object -First 1
$moduleName = $moduleDir.Name

Write-Host "Module: $moduleName" -ForegroundColor Yellow

# Backend: copy to sa-admin/src/main/java/{backendPackage}/sa/admin/module/business/{moduleName}
Write-Host "Copying backend files..." -ForegroundColor Cyan
$backendModuleRoot = Join-Path $backendRoot "sa-admin\src\main\java\$backendPackage\sa\admin\module\business\$moduleName"
New-Item -ItemType Directory -Path $backendModuleRoot -Force | Out-Null

$srcModuleDir = Join-Path $javaDir $moduleName
@("controller", "dao", "domain", "manager", "service") | ForEach-Object {
    $src = Join-Path $srcModuleDir $_
    $dst = Join-Path $backendModuleRoot $_
    if (Test-Path $src) {
        if (!(Test-Path $dst)) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
        }
        Get-ChildItem $src -Recurse | ForEach-Object {
            if ($_.PSIsContainer) {
                $targetPath = $_.FullName.Replace($src, $dst)
                if (!(Test-Path $targetPath)) {
                    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                }
            } else {
                $targetPath = $_.FullName.Replace($src, $dst)
                Copy-Item $_.FullName -Destination $targetPath -Force
            }
        }
        Write-Host "  OK $_" -ForegroundColor Green
    }
}

# Backend: copy mapper XML
Write-Host "Copying mapper files..." -ForegroundColor Cyan
$mapperSrcDir = Join-Path $srcModuleDir "mapper"
$mapperDstDir = Join-Path $backendRoot "sa-admin\src\main\resources\mapper\business\$moduleName"
New-Item -ItemType Directory -Path $mapperDstDir -Force | Out-Null
if (Test-Path $mapperSrcDir) {
    Copy-Item "$mapperSrcDir\*.xml" $mapperDstDir -Force
    Write-Host "  OK mapper files" -ForegroundColor Green
}

# Backend: SQL
Write-Host "Copying SQL file..." -ForegroundColor Cyan
$sqlDir = Join-Path $srcModuleDir "sql"
$sqlDstDir = Join-Path $backendModuleRoot "sql"
if (Test-Path $sqlDir) {
    New-Item -ItemType Directory -Path $sqlDstDir -Force | Out-Null
    Copy-Item "$sqlDir\*.sql" $sqlDstDir -Force
    Get-ChildItem $sqlDir -Filter "*.sql" | ForEach-Object {
        $sqlPath = Join-Path $sqlDstDir $_.Name
        Write-Host "  OK SQL: $sqlPath" -ForegroundColor Green
    }
}

# Frontend: js files
Write-Host "Copying frontend files..." -ForegroundColor Cyan
$jsDir = Join-Path $tempDir "js\$moduleName"
if (Test-Path $jsDir) {
    # Copy api
    $apiDst = Join-Path $frontendRoot "src\api\business\$moduleName"
    New-Item -ItemType Directory -Path $apiDst -Force | Out-Null
    Copy-Item "$jsDir\$moduleName-api.js" "$apiDst\$moduleName-api.js" -Force
    Write-Host "  OK api" -ForegroundColor Green
    
    # Copy const
    $constDst = Join-Path $frontendRoot "src\constants\business\$moduleName"
    New-Item -ItemType Directory -Path $constDst -Force | Out-Null
    Copy-Item "$jsDir\$moduleName-const.js" "$constDst\$moduleName-const.js" -Force
    Write-Host "  OK const" -ForegroundColor Green
    
    # Auto add const import to index.js
    $indexJsPath = Join-Path $frontendRoot "src\constants\index.js"
    $constVarName = "${moduleName}Const"
    
    if (Test-Path $indexJsPath) {
        # Use .NET to read/write preserving encoding
        $content = [System.IO.File]::ReadAllText($indexJsPath)
        $modified = $false
        
        # Add import if not exists
        if ($content -notmatch "import.*$constVarName") {
            $importLine = "import $constVarName from './business/$moduleName/$moduleName-const';"
            $content = $content -replace "(import dictConst from.*?;)", "`$1`n$importLine"
            $modified = $true
            Write-Host "  OK added const import" -ForegroundColor Green
        }
        
        # Add export spread if not exists
        if ($content -notmatch "\.\.\.$constVarName") {
            $exportLine = "  ...${constVarName},"
            $content = $content -replace "(  \.\.\.dictConst,)", "`$1`n$exportLine"
            $modified = $true
            Write-Host "  OK added const export" -ForegroundColor Green
        }
        
        if ($modified) {
            [System.IO.File]::WriteAllText($indexJsPath, $content)
        }
    }
    
    # Copy vue files
    $viewDst = Join-Path $frontendRoot "src\views\business\$moduleName"
    New-Item -ItemType Directory -Path $viewDst -Force | Out-Null
    Copy-Item "$jsDir\$moduleName-list.vue" "$viewDst\$moduleName-list.vue" -Force
    Copy-Item "$jsDir\$moduleName-form.vue" "$viewDst\$moduleName-form.vue" -Force
    Write-Host "  OK views" -ForegroundColor Green
    
    # Auto add tableId to table-id-const.js
    $tableIdConstPath = Join-Path $frontendRoot "src\constants\support\table-id-const.js"
    if (Test-Path $tableIdConstPath) {
        # Use .NET to read/write preserving encoding
        $content = [System.IO.File]::ReadAllText($tableIdConstPath)
        $moduleUpper = $moduleName.ToUpper()
        
        if ($content -notmatch "${moduleUpper}:") {
            # Extract current max ID in ERP
            $matches = [regex]::Matches($content, "businessERPInitTableId \+ (\d+)")
            $maxId = 0
            foreach ($match in $matches) {
                $id = [int]$match.Groups[1].Value
                if ($id -gt $maxId) { $maxId = $id }
            }
            $nextId = $maxId + 1
            
            # Find ERP closing brace and add before it
            $content = $content -replace "(    ERP: \{[^}]+)(    \},)", "`$1      ${moduleUpper}: businessERPInitTableId + $nextId, //$moduleName`n`$2"
            [System.IO.File]::WriteAllText($tableIdConstPath, $content)
            Write-Host "  OK added tableId to table-id-const.js (ID: $nextId)" -ForegroundColor Green
        }
    }
}

Remove-Item $tempDir -Recurse -Force

# Clean up empty directories in backend module
Write-Host "Cleaning up empty directories..." -ForegroundColor Cyan
$backendModuleRoot = Join-Path $backendRoot "sa-admin\src\main\java\$backendPackage\sa\admin\module\business\$moduleName"
@("config", "mapper") | ForEach-Object {
    $emptyDir = Join-Path $backendModuleRoot $_
    if ((Test-Path $emptyDir) -and @(Get-ChildItem $emptyDir -Recurse).Count -eq 0) {
        Remove-Item $emptyDir -Force
        Write-Host "  Removed empty dir: $_" -ForegroundColor Green
    }
}
Write-Host ""
Write-Host "Done! Next steps:" -ForegroundColor Green
Write-Host "1. Execute SQL: $sqlDstDir/*.sql" -ForegroundColor Yellow
Write-Host "2. Restart backend/frontend" -ForegroundColor Yellow
