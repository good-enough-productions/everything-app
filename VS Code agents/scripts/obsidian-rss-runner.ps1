# Chain: fetch RSS list -> import to vault -> tag/link -> regenerate topics index
param(
  [string]$FeedListPath = 'C:\Users\dschm\OneDrive\Desktop\Everything App\VS Code agents\feeds.txt',
  [string]$WorkDir = 'C:\Users\dschm\OneDrive\Desktop\Everything App\VS Code agents\.work',
  [int]$MaxPerFeed = 20
)
$ErrorActionPreference = 'Stop'
$script:Null = New-Item -ItemType Directory -Force -Path $WorkDir -ErrorAction SilentlyContinue
$jsonl = Join-Path -Path $WorkDir -ChildPath 'feeds.jsonl'

# Fetch
$fetcher = Join-Path -Path $PSScriptRoot -ChildPath 'obsidian-fetch-rss-list.ps1'
if ([string]::IsNullOrWhiteSpace($FeedListPath) -or -not (Test-Path -LiteralPath $FeedListPath)) {
  throw "Feed list not found: $FeedListPath"
}
& $fetcher -FeedListPath $FeedListPath -OutputJsonl $jsonl -MaxPerFeed $MaxPerFeed

# Import
$importer = Join-Path -Path $PSScriptRoot -ChildPath 'obsidian-rss-import.ps1'
& $importer -InputPath $jsonl -DestFolder 'Feeds'

# Tag/link
$tagger = Join-Path -Path $PSScriptRoot -ChildPath 'obsidian-topic-tag-and-link.ps1'
& $tagger

# Rebuild topics index
$indexer = Join-Path -Path $PSScriptRoot -ChildPath 'obsidian-generate-topics-index.ps1'
& $indexer

Write-Host 'RSS workflow complete.'
