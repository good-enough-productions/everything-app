# Import new items from a JSONL export or API into the vault as Markdown notes
param(
  [Parameter(Mandatory=$true)][string]$InputPath,
  [string]$DestFolder = 'Feeds'
)
$ErrorActionPreference = 'Stop'
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
if (-not (Test-Path -LiteralPath $vault)) { throw "Vault not found: $vault" }

if (-not (Test-Path -LiteralPath $InputPath)) { throw "Input not found: $InputPath" }
$destRoot = Join-Path -Path $vault -ChildPath $DestFolder
New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

# Supports JSON Lines with fields: title, url, published (yyyy-MM-dd or ISO), author, summary, content (optional)
$items = Get-Content -LiteralPath $InputPath
foreach ($line in $items) {
  if (-not $line.Trim()) { continue }
  try {
    $obj = $line | ConvertFrom-Json
    $title = [string]$obj.title
        if ($title -match '^System\.Xml\.XmlElement' -or [string]::IsNullOrWhiteSpace($title)) {
          if ($obj.url) {
            try {
              $u = [Uri]$obj.url
              $title = ($u.Segments[-1] -replace '-' ,' ' -replace '_' ,' ')
            } catch { $title = "Imported Item " + (Get-Random) }
          } else { $title = "Imported Item " + (Get-Random) }
        }
    $url = [string]$obj.url
    $pub = if ($obj.published) { (Get-Date $obj.published).ToString('yyyy-MM-dd') } else { (Get-Date).ToString('yyyy-MM-dd') }
    $author = [string]$obj.author
    $summary = [string]$obj.summary
    $content = [string]$obj.content

    # safe filename
        $fileName = ($title -replace '[\\/:*?"<>|]',' ').Trim()
    if (-not $fileName) { $fileName = (Get-Random) }
    $year = $pub.Substring(0,4)
    $month = $pub.Substring(5,2)
    $folder = Join-Path -Path $destRoot -ChildPath (Join-Path -Path $year -ChildPath $month)
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    $path = Join-Path -Path $folder -ChildPath ("$fileName.md")

    $safeTitle = $title -replace "'", "''"
    $lines = @()
    $lines += '---'
    $lines += "title: '$safeTitle'"
    if ($author) { $lines += ("author: '" + ($author -replace "'", "''") + "'") }
    if ($url) { $lines += ("source: '" + ($url -replace "'", "''") + "'") }
    $lines += ("published: $pub")
    $lines += 'tags: [feeds]'
    $lines += '---'
    $lines += ''
    $lines += "# $title"
    if ($summary) { $lines += ''; $lines += '## Summary'; $lines += $summary }
    if ($content) { $lines += ''; $lines += '## Content'; $lines += $content }
    $lines += ''
    $lines += '## See also'
    $lines += '- [[Topics/Feeds]]'

    Set-Content -LiteralPath $path -Value $lines -Encoding UTF8
    Write-Host ("Imported: {0}" -f $path)
  } catch {
    Write-Host ("FAILED: {0}" -f $_.Exception.Message)
  }
}
