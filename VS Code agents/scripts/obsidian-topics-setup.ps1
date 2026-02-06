# Create Topic hubs and add wikilinks from Articles based on filename keywords
$ErrorActionPreference = 'Stop'

# Resolve vault path from config robustly
$rootDir = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path -Path $rootDir -ChildPath 'obsidian.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$vault = $config.vaultPath
if ([string]::IsNullOrWhiteSpace($vault)) { throw "vaultPath missing in config: $configPath" }
if (-not (Test-Path -LiteralPath $vault)) { throw "Vault not found: $vault" }

$topicsDir = Join-Path -Path $vault -ChildPath 'Topics'
$articlesDir = Join-Path -Path $vault -ChildPath 'Articles'
New-Item -ItemType Directory -Force -Path $topicsDir | Out-Null

function Ensure-TopicFile {
  param([string]$name, [string]$tag)
  $path = Join-Path -Path $topicsDir -ChildPath ("$name.md")
  if (-not (Test-Path $path)) {
    $content = @(
      '---',
      "title: '$name'",
      "tags: [topic, $tag]",
      '---',
      '',
      "# $name",
      '',
      'Related notes:',
      '- Add links here'
    )
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
  }
}

# Ensure hub notes
Ensure-TopicFile -name 'RSS' -tag 'rss'
Ensure-TopicFile -name 'Obsidian' -tag 'obsidian'
Ensure-TopicFile -name 'AI' -tag 'ai'
Ensure-TopicFile -name 'Productivity' -tag 'productivity'
Ensure-TopicFile -name 'Business' -tag 'business'
Ensure-TopicFile -name 'Planning' -tag 'planning'
Ensure-TopicFile -name 'Software Engineering' -tag 'engineering'
Ensure-TopicFile -name 'Data' -tag 'data'
Ensure-TopicFile -name 'Feeds' -tag 'feeds'

# Create a simple Article template
$templatesDir = Join-Path -Path $vault -ChildPath 'Templates'
New-Item -ItemType Directory -Force -Path $templatesDir | Out-Null

# Article template
$articleT = @(
  '---',
  "title: 'Your Title'",
  'tags: [articles]',
  "created: $(Get-Date -Format yyyy-MM-dd)",
  '---',
  '',
  '# Your Title',
  '',
  '## Summary',
  '- ',
  '',
  '## Key ideas',
  '- ',
  '',
  '## Quotes',
  '> ',
  '',
  '## Links/References',
  '- '
)
Set-Content -LiteralPath (Join-Path -Path $templatesDir -ChildPath 'Article.md') -Value $articleT -Encoding UTF8

# Podcast template
$podcastT = @(
  '---',
  "title: 'Episode Title'",
  "date: $(Get-Date -Format yyyy-MM-dd)",
  "show: 'Show Name'",
  'episode: 0',
  "source: 'https://example.com'",
  "audio: ''",
  'tags: [podcast]','---','',
  '# Episode Title','',
  '## Description','',
  '## Complete Show Notes','',
  '### Technologies/Tools','- ', '',
  '### Discussion Points','- ', '',
  '### Links/Resources','- ', '',
  '## Transcript',''
)
Set-Content -LiteralPath (Join-Path -Path $templatesDir -ChildPath 'Podcast.md') -Value $podcastT -Encoding UTF8

# Meeting template
$meetingT = @(
  '---',
  "title: 'Meeting: Subject'",
  "date: $(Get-Date -Format yyyy-MM-dd)",
  "attendees: ['you']",
  'tags: [meeting]','---','',
  '# Meeting: Subject','',
  '## Agenda','- ', '',
  '## Decisions','- [ ] ', '',
  '## Action Items','- [ ] ', '',
  '## Notes','- '
)
Set-Content -LiteralPath (Join-Path -Path $templatesDir -ChildPath 'Meeting.md') -Value $meetingT -Encoding UTF8

# Build topic rules (case-insensitive)
$rules = @(
  @{ Topic = 'RSS';        Patterns = @('rss') },
  @{ Topic = 'Obsidian';   Patterns = @('obsidian') },
  @{ Topic = 'AI';         Patterns = @(' ai ', 'ai_', '_ai', 'gpt', 'claude', 'llm', 'openai', 'anthropic', 'gemini') },
  @{ Topic = 'Productivity'; Patterns = @('productivity', 'focus', 'adhd') },
  @{ Topic = 'Business';   Patterns = @('business', 'engagement plan', 'business plan') },
  @{ Topic = 'Planning';   Patterns = @('planning', 'weekly planning', 'plan ') }
)

# Helper: check if a file already contains a wikilink to a topic
function Test-TopicLink {
  param([string]$filePath, [string]$topic)
  try {
    $text = Get-Content -LiteralPath $filePath -Raw -ErrorAction SilentlyContinue
    return ($text -match "\[\[Topics/$topic\]\]" -or $text -match "\[\[Topics/$topic\\|" )
  } catch { return $false }
}

# Append links to matching notes
$linkedCount = 0
$mds = Get-ChildItem $articlesDir -Recurse -File -Filter *.md
foreach ($f in $mds) {
  $name = ' ' + ([System.IO.Path]::GetFileNameWithoutExtension($f.Name)).ToLower() + ' '
  $toLink = @()
  foreach ($rule in $rules) {
    foreach ($pat in $rule.Patterns) {
      if ($name -like "*$(($pat).ToLower())*") { $toLink += $rule.Topic; break }
    }
  }
  $toLink = $toLink | Select-Object -Unique
  if ($toLink.Count -gt 0) {
    foreach ($topic in $toLink) {
  if (-not (Test-TopicLink -filePath $f.FullName -topic $topic)) {
        Add-Content -LiteralPath $f.FullName -Value "`n## See also`n- [[Topics/$topic]]" -Encoding UTF8
        $linkedCount++
      }
    }
  }
}

Write-Host ("Topic hubs ensured. Notes linked: {0}" -f $linkedCount)
