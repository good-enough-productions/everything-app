# Remove malformed feed imports and tidy Feeds folder
$ErrorActionPreference = 'Stop'
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
$feedsDir = Join-Path -Path $vault -ChildPath 'Feeds'
if (-not (Test-Path -LiteralPath $feedsDir)) { Write-Host 'Feeds folder not found'; exit 0 }

$deleted = 0
# Delete files named System.Xml.XmlElement.md
Get-ChildItem -LiteralPath $feedsDir -Recurse -File -Filter 'System.Xml.XmlElement.md' -ErrorAction SilentlyContinue | ForEach-Object {
  Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
  $deleted++
}

# Delete files whose frontmatter title equals 'System.Xml.XmlElement'
$mds = Get-ChildItem -LiteralPath $feedsDir -Recurse -File -Filter *.md -ErrorAction SilentlyContinue
foreach ($f in $mds) {
  try {
    $first = Get-Content -LiteralPath $f.FullName -TotalCount 30 -ErrorAction SilentlyContinue
    if ($first -and $first[0].Trim() -eq '---') {
      $titleLine = $first | Where-Object { $_ -match '^title\s*:' } | Select-Object -First 1
      if ($titleLine) {
        $val = ($titleLine -replace '^title\s*:\s*','').Trim().Trim('"').Trim("'")
        if ($val -eq 'System.Xml.XmlElement') {
          Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue
          $deleted++
        }
      }
    }
  } catch {}
}

Write-Host ("Deleted malformed feed notes: {0}" -f $deleted)
