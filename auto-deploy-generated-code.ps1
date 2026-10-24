param(
    [Parameter(Mandatory=$true)]
    [string]$zipPath,
    [string]$backendRoot = "G:\ai-projects\smart-admin\smart-admin-api-java17-springboot3",
    [string]$frontendRoot = "G:\ai-projects\smart-admin\smart-admin-web-javascript"
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

# Backend: copy to sa-admin/src/main/java/net/lab1024/sa/admin/module/business/{moduleName}
Write-Host "Copying backend files..." -ForegroundColor Cyan
$backendModuleRoot = Join-Path $backendRoot "sa-admin\src\main\java\net\lab1024\sa\admin\module\business\$moduleName"
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
Write-Host "SQL file location:" -ForegroundColor Cyan
$sqlDir = Join-Path $srcModuleDir "sql"
if (Test-Path $sqlDir) {
    Get-ChildItem $sqlDir -Filter "*.sql" | ForEach-Object {
        Write-Host "  $($_.FullName)" -ForegroundColor Yellow
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
    $importLine = "export * from './business/$moduleName/$moduleName-const';"
    if ((Test-Path $indexJsPath) -and !((Get-Content $indexJsPath) -match $importLine)) {
        Add-Content -Path $indexJsPath -Value $importLine
        Write-Host "  OK auto-added const import to index.js" -ForegroundColor Green
    }
    
    # Copy vue files
    $viewDst = Join-Path $frontendRoot "src\views\business\$moduleName"
    New-Item -ItemType Directory -Path $viewDst -Force | Out-Null
    Copy-Item "$jsDir\$moduleName-list.vue" "$viewDst\$moduleName-list.vue" -Force
    Copy-Item "$jsDir\$moduleName-form.vue" "$viewDst\$moduleName-form.vue" -Force
    Write-Host "  OK views" -ForegroundColor Green
}

Remove-Item $tempDir -Recurse -Force

# Clean up empty directories in backend module
Write-Host "Cleaning up empty directories..." -ForegroundColor Cyan
$backendModuleRoot = Join-Path $backendRoot "sa-admin\src\main\java\net\lab1024\sa\admin\module\business\$moduleName"
@("config", "mapper") | ForEach-Object {
    $emptyDir = Join-Path $backendModuleRoot $_
    if ((Test-Path $emptyDir) -and @(Get-ChildItem $emptyDir -Recurse).Count -eq 0) {
        Remove-Item $emptyDir -Force
        Write-Host "  Removed empty dir: $_" -ForegroundColor Green
    }
}
Write-Host ""
Write-Host "Done! Next steps:" -ForegroundColor Green
Write-Host "1. Execute SQL file (see path above)" -ForegroundColor Yellow
Write-Host "2. Restart backend/frontend" -ForegroundColor Yellow
