param(
  [Parameter(Mandatory=$true)][string]$FeedUrl,
  [Parameter(Mandatory=$true)][string]$OutputJsonl,
  [int]$MaxItems = 10,
  [string]$UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.0.0'
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputJsonl) | Out-Null
if (Test-Path -LiteralPath $OutputJsonl) { Remove-Item -LiteralPath $OutputJsonl -Force }

function Get-NodeText($node){
  if ($null -eq $node) { return '' }
  try {
    if ($node -is [string]) { return [string]$node }
    if ($node.PSObject.Properties.Name -contains '#text') { return [string]$node.'#text' }
    if ($node.PSObject.Properties.Name -contains '#cdata-section') { return [string]$node.'#cdata-section' }
    if ($node.InnerText) { return [string]$node.InnerText }
    return [string]$node
  } catch { return '' }
}
function Get-ChildTextLocal($node, [string]$localName){
  try {
    $n = $node.SelectSingleNode("*[local-name()='$localName']")
    if ($n) { return Get-NodeText $n }
    return ''
  } catch { return '' }
}

function Get-Body([string]$url){
  try {
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
      $accept = 'application/rss+xml, application/atom+xml, application/xml, text/xml;q=0.9, */*;q=0.1'
      $body = & $curl.Path -sL -A $UserAgent -H "Accept: $accept" --max-redirs 5 --connect-timeout 30 --retry 2 --retry-delay 2 --retry-all-errors --insecure "$url"
      if ($LASTEXITCODE -eq 0 -and $body) { return [string]$body }
    }
  } catch {}
  try {
    $headers = @{ 'User-Agent' = $UserAgent; 'Accept' = 'application/rss+xml, application/atom+xml, application/xml, text/xml;q=0.9, */*;q=0.1' }
    $res = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing -TimeoutSec 60 -MaximumRedirection 5 -ErrorAction Stop
    if ($res -and $res.Content) { return [string]$res.Content }
  } catch {}
  throw "Failed to fetch: $url"
}

$body = Get-Body $FeedUrl
try { [xml]$xml = $body } catch { $xml = $null }
$wrote = $false

if ($xml -and $xml.feed) {
  $i = 0
  foreach ($e in @($xml.feed.entry)) {
    if ($i -ge $MaxItems) { break }
    $title = Get-NodeText $e.title
    $link = ($e.link | Where-Object { $_.rel -eq 'alternate' } | Select-Object -First 1).href
    if (-not $link) { $link = $e.link.href }
    $pub = if ($e.published) { [string]$e.published } elseif ($e.updated) { [string]$e.updated } else { '' }
    $author = if ($e.author.name) { Get-NodeText $e.author.name } else { '' }
    if (-not $title -or -not $link) { continue }
    @{ title=$title; url=$link; published=$pub; author=$author } | ConvertTo-Json -Compress | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
    $i++
  }
  $wrote = $i -gt 0
} elseif ($xml -and $xml.rss -and $xml.rss.channel) {
  $i = 0
  foreach ($it in @($xml.rss.channel.item)) {
    if ($i -ge $MaxItems) { break }
    $title = Get-NodeText $it.title
    $link = Get-NodeText $it.link
    if (-not $link) {
      try { $guid = $it.guid; if ($guid -and $guid.isPermaLink) { $link = Get-NodeText $guid } } catch {}
      try { $enc = $it.enclosure; if ($enc -and $enc.url) { $link = [string]$enc.url } } catch {}
    }
    $pub = [string]$it.pubDate
    $author = if ($it.'dc:creator') { Get-NodeText $it.'dc:creator' } elseif ($it.author) { Get-NodeText $it.author } else { '' }
    if (-not $title -or -not $link) { continue }
    @{ title=$title; url=$link; published=$pub; author=$author } | ConvertTo-Json -Compress | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
    $i++
  }
  $wrote = $i -gt 0
} elseif ($xml -and $xml.DocumentElement) {
  $root = $xml.DocumentElement.LocalName
  if ($root -eq 'rss' -or $root -eq 'RDF') {
    $i = 0
    try { $nodes = $xml.SelectNodes("//*[local-name()='item']") } catch { $nodes = @() }
    foreach ($it in $nodes) {
      if ($i -ge $MaxItems) { break }
      $title = Get-ChildTextLocal $it 'title'
      $link = Get-ChildTextLocal $it 'link'
      if (-not $link) { $link = Get-ChildTextLocal $it 'guid' }
      if (-not $link) { try { $enc = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($enc -and $enc.Attributes['url']) { $link = [string]$enc.Attributes['url'].Value } } catch {} }
      $pub = Get-ChildTextLocal $it 'pubDate'; if (-not $pub) { $pub = Get-ChildTextLocal $it 'date' }
      $author = Get-ChildTextLocal $it 'creator'; if (-not $author) { $author = Get-ChildTextLocal $it 'author' }
      if (-not $title -or -not $link) { continue }
      @{ title=$title; url=$link; published=$pub; author=$author } | ConvertTo-Json -Compress | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
      $i++
    }
    $wrote = $i -gt 0
  }
}

if (-not $wrote) { Write-Host ("Unrecognized or empty feed: {0}" -f $FeedUrl) }
