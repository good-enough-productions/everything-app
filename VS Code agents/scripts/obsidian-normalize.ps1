# Reads obsidian.config.json for the vault path, cleans Articles, normalizes metadata, and creates topic hubs
$ErrorActionPreference = 'Stop'

# Resolve vault path from config
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
if (-not (Test-Path -LiteralPath $vault)) { throw "Vault not found: $vault" }

$articles = Join-Path -Path $vault -ChildPath 'Articles'
if (-not (Test-Path $articles)) { throw "Articles folder not found: $articles" }

Write-Host "Vault: $vault"
Write-Host "Articles: $articles"

# 0) Delete leftover triage folder at vault root (if exists)
$triageRoot = Join-Path -Path $vault -ChildPath '_triage'
if (Test-Path $triageRoot) {
  Remove-Item -LiteralPath $triageRoot -Recurse -Force
  Write-Host "Deleted triage folder: $triageRoot"
}

# 1) Remove zero-byte files and tiny markdown (<200B) inside Articles
$zeros = Get-ChildItem $articles -Recurse -File | Where-Object { $_.Length -eq 0 }
$zeros | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Host ("Deleted zero-byte files: {0}" -f $zeros.Count)

$tinymd = Get-ChildItem $articles -Recurse -File -Filter *.md | Where-Object { $_.Length -lt 200 }
$tinymd | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Host ("Deleted tiny md files: {0}" -f $tinymd.Count)

# 2) Normalize metadata across all md notes in Articles
$mds = Get-ChildItem -Path $articles -Recurse -File -Filter *.md
$addedFront = 0; $addedH1 = 0
foreach ($f in $mds) {
  try {
    $lines = Get-Content -LiteralPath $f.FullName -ErrorAction SilentlyContinue
    if ($null -eq $lines) { continue }
    $hasFront = ($lines.Count -gt 0 -and $lines[0].Trim() -eq '---')
    $title = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $title = ($title -replace '[_-]+',' ') -replace '\s+',' '
    $title = $title.Trim()

    if (-not $hasFront) {
      $created = $f.CreationTime.ToString('yyyy-MM-dd')
      $modified = $f.LastWriteTime.ToString('yyyy-MM-dd')
      # Sanitize title for YAML: escape single quotes for YAML single-quoted scalars
      $safeTitle = $title -replace "'", "''"
      $yaml = @()
      $yaml += '---'
      $yaml += "title: '$safeTitle'"
      $yaml += 'tags: [articles]'
      $yaml += ('created: {0}' -f $created)
      $yaml += ('modified: {0}' -f $modified)
      $yaml += '---'
      $yaml += ''
      $hasH1 = ($lines | Where-Object { $_ -match '^#\s' } | Measure-Object).Count
      if ($hasH1 -eq 0) { $yaml += ("# $title"); $yaml += '' }
      $new = @($yaml) + $lines
      Set-Content -LiteralPath $f.FullName -Value $new -Encoding UTF8
      $addedFront++
    } else {
      # Ensure H1 exists after frontmatter
      $dashIdxs = @()
      for ($i=0; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $dashIdxs += $i } }
      if ($dashIdxs.Count -ge 2) {
        $end = $dashIdxs[1]
        $after = @()
        if ($end -lt ($lines.Count - 1)) { $after = $lines[($end+1)..($lines.Count-1)] }
        $hasH1After = ($after | Where-Object { $_ -match '^#\s' } | Measure-Object).Count
        if ($hasH1After -eq 0) {
          $before = $lines[0..$end]
          $new = @($before) + '' + ("# $title") + '' + $after
          Set-Content -LiteralPath $f.FullName -Value $new -Encoding UTF8
          $addedH1++
        }
      }
    }
  } catch {
    Write-Host ("FAILED: {0} :: {1}" -f $f.FullName, $_.Exception.Message)
  }
}
Write-Host ("Frontmatter added: {0}; H1 inserted: {1}" -f $addedFront, $addedH1)

# 3) Create topic hub notes to seed Graph View
$topics = Join-Path -Path $vault -ChildPath 'Topics'
New-Item -ItemType Directory -Force -Path $topics | Out-Null

$rssPath = Join-Path -Path $topics -ChildPath 'RSS.md'
$rssContent = @(
  '---',
  'title: "RSS"',
  'tags: [topic, rss]',
  '---',
  '',
  '# RSS',
  '',
  'Quick links:',
  '- [[Podcasts/Syntax FM/926-RSS-Is-NOT-Dead|Syntax FM 926 — RSS Is NOT Dead]]',
  '',
  'Related notes:',
  '- Add links to your RSS-related articles here'
)
Set-Content -LiteralPath $rssPath -Value $rssContent -Encoding UTF8

$obsPath = Join-Path -Path $topics -ChildPath 'Obsidian.md'
$obsContent = @(
  '---',
  'title: "Obsidian"',
  'tags: [topic, obsidian]',
  '---',
  '',
  '# Obsidian',
  '',
  'Starter hub for Obsidian-related notes.',
  '',
  'Related notes:',
  '- Add links to your Obsidian-related articles here'
)
Set-Content -LiteralPath $obsPath -Value $obsContent -Encoding UTF8

# 4) Post-operation stats
$all = Get-ChildItem -Path $articles -Recurse -File
$md = $all | Where-Object { $_.Extension -ieq '.md' }
$missingFront = 0
foreach ($f in $md) { try { $first = Get-Content -LiteralPath $f.FullName -TotalCount 1 -ErrorAction SilentlyContinue; if ($first -ne '---') { $missingFront++ } } catch {} }
$missingH1 = 0
foreach ($f in $md) { try { if (-not (Select-String -LiteralPath $f.FullName -Pattern '^#\s' -SimpleMatch -Quiet)) { $missingH1++ } } catch {} }
Write-Host ("POST: Files={0} MD={1} MissingFront={2} MissingH1={3}" -f $all.Count, $md.Count, $missingFront, $missingH1)
