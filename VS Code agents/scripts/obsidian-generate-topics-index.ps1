# Generate Topics/Index.md listing all topic hubs in the vault
$ErrorActionPreference = 'Stop'

# Resolve vault path
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
if (-not (Test-Path -LiteralPath $vault)) { throw "Vault not found: $vault" }

$topicsDir = Join-Path -Path $vault -ChildPath 'Topics'
New-Item -ItemType Directory -Force -Path $topicsDir | Out-Null
$indexPath = Join-Path -Path $topicsDir -ChildPath 'Index.md'

$files = Get-ChildItem -LiteralPath $topicsDir -File -Filter *.md | Where-Object { $_.Name -ne 'Index.md' } | Sort-Object Name
$today = Get-Date -Format 'yyyy-MM-dd'

$lines = @()
$lines += '---'
$lines += "title: 'Topics Index'"
$lines += 'tags: [topic, index]'
$lines += "created: $today"
$lines += '---'
$lines += ''
$lines += '# Topics Index'
$lines += ''
foreach ($f in $files) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $lines += ("- [[Topics/$name]]")
}

Set-Content -LiteralPath $indexPath -Value $lines -Encoding UTF8
Write-Host ("Index written: {0}" -f $indexPath)
