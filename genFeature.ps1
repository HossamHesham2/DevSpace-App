param(
  [Parameter(Mandatory = $true)]
  [string]$FeatureName
)

$FeatureClassName = ($FeatureName -split '_|-|\s' | ForEach-Object {
    if ($_ -ne "") {
        $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower()
    }
}) -join ""

# ---------------------------------------------------------
#  Banner
# ---------------------------------------------------------
Write-Host ""
Write-Host "+------------------------------------------------+" -ForegroundColor Cyan
Write-Host "|        FLUTTER CLEAN ARCHITECTURE GENERATOR    |" -ForegroundColor Cyan
Write-Host "+------------------------------------------------+" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Feature Name  : " -NoNewline -ForegroundColor DarkGray
Write-Host "$FeatureName" -ForegroundColor Yellow
Write-Host "  Class Name    : " -NoNewline -ForegroundColor DarkGray
Write-Host "$FeatureClassName" -ForegroundColor Yellow
Write-Host ""

$folders = @(
  "lib/features/$FeatureName",

  "lib/features/$FeatureName/data",
  "lib/features/$FeatureName/data/datasources",
  "lib/features/$FeatureName/data/datasources/remote",
  "lib/features/$FeatureName/data/datasources/local",
  "lib/features/$FeatureName/data/models",
  "lib/features/$FeatureName/data/repositories",

  "lib/features/$FeatureName/domain",
  "lib/features/$FeatureName/domain/entities",
  "lib/features/$FeatureName/domain/repositories",
  "lib/features/$FeatureName/domain/usecases",

  "lib/features/$FeatureName/presentation",
  "lib/features/$FeatureName/presentation/provider",
  "lib/features/$FeatureName/presentation/pages",
  "lib/features/$FeatureName/presentation/widgets"
)

# ---------------------------------------------------------
#  Create folders
# ---------------------------------------------------------
Write-Host "> Creating folder structure..." -ForegroundColor Magenta

foreach ($folder in $folders) {
  if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
    Write-Host "   + " -NoNewline -ForegroundColor DarkGreen
    Write-Host "$folder" -ForegroundColor Gray
  }
}

Write-Host ""

$files = [ordered]@{}

$files["lib/features/$FeatureName/data/datasources/local/${FeatureName}_local_datasource.dart"] = @"
abstract class ${FeatureClassName}LocalDatasource {}

class ${FeatureClassName}LocalDatasourceImpl extends ${FeatureClassName}LocalDatasource {}
"@

$files["lib/features/$FeatureName/data/datasources/remote/${FeatureName}_remote_datasource.dart"] = @"
abstract class ${FeatureClassName}RemoteDatasource {}

class ${FeatureClassName}RemoteDatasourceImpl extends ${FeatureClassName}RemoteDatasource {}
"@

$files["lib/features/$FeatureName/data/repositories/${FeatureName}_repository_impl.dart"] = @"
import '../../domain/repositories/${FeatureName}_repository.dart';

class ${FeatureClassName}RepositoryImpl implements ${FeatureClassName}Repository {}
"@

$files["lib/features/$FeatureName/domain/entities/${FeatureName}_entity.dart"] = @"
class ${FeatureClassName}Entity {}
"@

$files["lib/features/$FeatureName/domain/repositories/${FeatureName}_repository.dart"] = @"
abstract class ${FeatureClassName}Repository {}
"@


# ---------------------------------------------------------
#  Create files
# ---------------------------------------------------------
Write-Host "> Generating Dart files..." -ForegroundColor Magenta

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$root = (Get-Location).Path

foreach ($file in $files.Keys) {

    $fullPath = Join-Path $root $file
    $dir = Split-Path $fullPath -Parent

    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($fullPath, $files[$file], $utf8NoBom)

    Write-Host "   * " -NoNewline -ForegroundColor DarkCyan
    Write-Host "$file" -ForegroundColor Gray
}

# ---------------------------------------------------------
#  Summary tree
# ---------------------------------------------------------
Write-Host ""
Write-Host "> Structure overview" -ForegroundColor Magenta
Write-Host "   lib/features/$FeatureName" -ForegroundColor White
Write-Host "   |-- data" -ForegroundColor DarkYellow
Write-Host "   |   |-- datasources (remote, local)" -ForegroundColor Gray
Write-Host "   |   |-- models" -ForegroundColor Gray
Write-Host "   |   '-- repositories" -ForegroundColor Gray
Write-Host "   |-- domain" -ForegroundColor DarkYellow
Write-Host "   |   |-- entities" -ForegroundColor Gray
Write-Host "   |   |-- repositories" -ForegroundColor Gray
Write-Host "   |   '-- usecases" -ForegroundColor Gray
Write-Host "   '-- presentation" -ForegroundColor DarkYellow
Write-Host "       |-- Provider" -ForegroundColor Gray
Write-Host "       |-- pages" -ForegroundColor Gray
Write-Host "       '-- widgets" -ForegroundColor Gray
Write-Host ""
Write-Host "+------------------------------------------------------------+" -ForegroundColor Green
Write-Host "|  Feature '$FeatureName' structure created successfully" -ForegroundColor Green
Write-Host "+------------------------------------------------------------+" -ForegroundColor Green
Write-Host ""