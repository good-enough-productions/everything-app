param(
  [Parameter(Mandatory=$true)][string]$Source,
  [Parameter(Mandatory=$true)][string]$VaultRelative
)
$ErrorActionPreference = 'Stop'
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
if (-not (Test-Path -LiteralPath $vault)) { throw "Vault not found: $vault" }
$destDir = Split-Path -Parent (Join-Path -Path $vault -ChildPath $VaultRelative)
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
Copy-Item -LiteralPath $Source -Destination (Join-Path -Path $vault -ChildPath $VaultRelative) -Force
Write-Host ("Copied: {0} -> {1}" -f $Source, (Join-Path -Path $vault -ChildPath $VaultRelative))
