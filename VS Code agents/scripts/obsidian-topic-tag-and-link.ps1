# Tag Articles with topic tags and add consolidated See also wikilinks
$ErrorActionPreference = 'Stop'

# Resolve vault path robustly (avoid Join-Path prompts by always supplying Path and ChildPath)
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
if (-not (Test-Path -LiteralPath $vault)) { throw "Vault not found: $vault" }

$articlesDir = Join-Path -Path $vault -ChildPath 'Articles'
$topicsDir = Join-Path -Path $vault -ChildPath 'Topics'
New-Item -ItemType Directory -Force -Path $topicsDir | Out-Null

# Topic definitions: Name, Tag, Regex patterns (case-insensitive)
$topics = @(
  @{ Name='RSS';        Tag='topic/rss';        Patterns=@('rss') },
  @{ Name='Obsidian';   Tag='topic/obsidian';   Patterns=@('obsidian') },
  @{ Name='AI';         Tag='topic/ai';         Patterns=@('\bai\b','\bA\.I\.\b','gpt','claude','llm','openai','anthropic','gemini','llama','langchain','rag','vector(\s|-)db','embedding') },
  @{ Name='Productivity'; Tag='topic/productivity'; Patterns=@('productivity','focus','adhd','pomodoro','time blocking','deep work') },
  @{ Name='Business';   Tag='topic/business';   Patterns=@('business','engagement plan','business plan','revenue','pricing','market(\s|-)fit','gtm','churn','mrr') },
  @{ Name='Planning';   Tag='topic/planning';   Patterns=@('planning','weekly planning','quarterly planning','roadmap','plan') },
  @{ Name='Web Development'; Tag='topic/web-dev'; Patterns=@('web development','frontend','front-end','back-end','backend','javascript','typescript','react','next(\.js)?','node(\.js)?','css','html','webpack','vite','astro','svelte(kit)?','vue(\.js)?','angular','remix','bun','deno','tailwind','postcss') },
  @{ Name='Product Management'; Tag='topic/product-management'; Patterns=@('product management','\bpm\b','product manager','roadmap','prioritization','user research','discovery','prd','okrs?') },
  @{ Name='Health'; Tag='topic/health'; Patterns=@('health','fitness','exercise','sleep','nutrition','workout','steps','hrv','recovery') },
  @{ Name='Software Engineering'; Tag='topic/engineering'; Patterns=@('software engineering','architecture','design patterns?','refactor(ing)?','testing','unit test(s)?','integration test(s)?','tdd','ci/cd','observability','monitoring','logging') },
  @{ Name='Data'; Tag='topic/data'; Patterns=@('data','sql','postgres(ql)?','mysql','mongodb','warehouse','etl','analytics','pandas','numpy','spark') }
)

function New-TopicHub([string]$name,[string]$tag){
  $path = Join-Path -Path $topicsDir -ChildPath ("$name.md")
  if (-not (Test-Path $path)){
    $content = @(
      '---',
      "title: '$name'",
      "tags: [topic, $tag]",
      '---','',
      "# $name",'',
      'Related notes:',
      '- Add links here'
    )
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
  }
}

foreach($t in $topics){ New-TopicHub -name $t.Name -tag $t.Tag }

# Helpers
function Test-ContainsAnyPattern([string]$text, [string[]]$patterns){
  if (-not $text) { return $false }
  foreach($p in $patterns){ if ($text -match $p){ return $true } }
  return $false
}

function Set-TagsInFrontmatter([string]$raw,[string[]]$tagsToAdd){
  # Works with normalized frontmatter (starts with ---). Adds or merges tags as a bracketed list.
  $lines = $raw -split "`r?`n"
  if ($lines.Length -eq 0 -or $lines[0] -ne '---'){ return $raw }
  # find end of frontmatter (second ---)
  $end = $null
  for ($i = 1; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -eq '---') { $end = $i; break }
  }
  if ($null -eq $end) { return $raw }
  # locate tags line within frontmatter
  $tagsIdx = $null
  for ($j = 1; $j -lt $end; $j++) {
    if ($lines[$j] -match '^\s*tags\s*:') { $tagsIdx = $j; break }
  }
  # parse existing tags
  $existing = @()
  if ($null -ne $tagsIdx) {
    $val = ($lines[$tagsIdx] -replace '^\s*tags\s*:\s*','').Trim()
    if ($val.StartsWith('[') -and $val.EndsWith(']')) {
      $inner = $val.TrimStart('[').TrimEnd(']')
      if ($inner.Trim()) { $existing = ($inner -split ',').ForEach({ $_.Trim() }) }
    } elseif ($val) {
      $existing = ($val -split '\s+').ForEach({ $_.Trim() })
    }
  }
  # merge tags
  foreach ($t in $tagsToAdd) { if (-not ($existing -contains $t)) { $existing += $t } }
  $tagsLine = 'tags: [' + ($existing -join ', ') + ']'
  if ($null -ne $tagsIdx) {
    $lines[$tagsIdx] = $tagsLine
  } else {
    # insert after first line of frontmatter
    $pre = $lines[0]
    $rest = $lines[1..($lines.Length-1)]
    $lines = @($pre, $tagsLine) + $rest
  }
  return ($lines -join "`r`n")
}

function Add-SeeAlso([string]$raw,[string[]]$topicNames){
  if ($topicNames.Count -eq 0){ return $raw }
  $links = $topicNames | Sort-Object -Unique | ForEach-Object { "- [[Topics/$($_)]]" }
  # Use multiline regex so we detect an existing header anywhere in the doc
  if ($raw -match '(?m)^##\s+See also\b'){ # header exists
    # Append missing links if not present
    foreach($lnk in $links){ if ($raw -notmatch [regex]::Escape($lnk)) { $raw += "`r`n$lnk" } }
    return $raw
  } else {
    return ($raw.TrimEnd() + "`r`n`r`n## See also`r`n" + ($links -join "`r`n") + "`r`n")
  }
}

$mds = Get-ChildItem -Path $articlesDir -Recurse -File -Filter *.md
$tagged=0; $linked=0
# per-topic match counters
$topicMatchCounts = @{}
foreach($t in $topics){ $topicMatchCounts[$t.Name] = 0 }
# sample lists
$filesTagged = New-Object System.Collections.Generic.List[string]
$filesLinked = New-Object System.Collections.Generic.List[string]
foreach($f in $mds){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
  if (-not $raw){ continue }
  $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $text = ($name + ' ' + $raw).ToLower()
  $matchedTopics = @()
  foreach($t in $topics){ if (Test-ContainsAnyPattern -text $text -patterns $t.Patterns){ $matchedTopics += $t } }
  $matchedTopics = $matchedTopics | Select-Object -Unique
  if ($matchedTopics.Count -eq 0){ continue }

  # Add tags
  $tagsToAdd = $matchedTopics.ForEach({ $_.Tag })
  $updated = Set-TagsInFrontmatter -raw $raw -tagsToAdd $tagsToAdd
  if ($updated -ne $raw){ $tagged++ }

  # Add see also links
  $topicNames = $matchedTopics.ForEach({ $_.Name })
  $updated2 = Add-SeeAlso -raw $updated -topicNames $topicNames
  if ($updated2 -ne $updated){ $linked++ }

  # increment per-topic counts
  foreach($mt in $matchedTopics){ $topicMatchCounts[$mt.Name]++ }

  if ($updated -ne $raw -and $filesTagged.Count -lt 10) { $filesTagged.Add($f.FullName) }
  if ($updated2 -ne $updated -and $filesLinked.Count -lt 10) { $filesLinked.Add($f.FullName) }

  if ($updated2 -ne $raw){ Set-Content -LiteralPath $f.FullName -Value $updated2 -Encoding UTF8 }
}

# Write a report into the vault
$reportsDir = Join-Path -Path $vault -ChildPath 'Reports'
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null
$date = Get-Date -Format 'yyyy-MM-dd'
$reportPath = Join-Path -Path $reportsDir -ChildPath ("tagging-report-" + $date + ".md")
$report = @()
$report += '---'
$report += "title: 'Tagging Report ' + $date"
$report += 'tags: [report, obsidian]'
$report += "created: $date"
$report += '---'
$report += ''
$report += '# Tagging Report'
$report += ''
$report += ("Files updated (tags): {0}" -f $tagged)
$report += ("Files updated (links): {0}" -f $linked)
$report += ''
$report += '## Matches by Topic'
foreach($k in ($topicMatchCounts.Keys | Sort-Object)){
  $report += ("- {0}: {1}" -f $k, $topicMatchCounts[$k])
}
$report += ''
if ($filesTagged.Count -gt 0){
  $report += '## Sample files updated (tags)'
  foreach($p in $filesTagged){ $report += ("- " + $p) }
  $report += ''
}
if ($filesLinked.Count -gt 0){
  $report += '## Sample files updated (links)'
  foreach($p in $filesLinked){ $report += ("- " + $p) }
  $report += ''
}
Set-Content -LiteralPath $reportPath -Value $report -Encoding UTF8

Write-Host ("Tagging complete. Files updated (tags): {0} | Files updated (links): {1} | Report: {2}" -f $tagged,$linked,$reportPath)
