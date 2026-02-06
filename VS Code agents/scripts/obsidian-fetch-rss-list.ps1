# Fetch a list of RSS/Atom feeds and output JSONL items (title, url, published, author)
param(
  [Parameter(Mandatory=$true)][string]$FeedListPath,
  [Parameter(Mandatory=$true)][string]$OutputJsonl,
  [int]$MaxPerFeed = 30,
  # Use a realistic browser UA to reduce 403/404 from some hosts
  [string]$UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.0.0',
  [string]$ResolvedFeedsOut
)
$ErrorActionPreference = 'Stop'
try {
  # Ensure modern TLS support for servers that reject legacy protocols
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}
if (-not (Test-Path -LiteralPath $FeedListPath)) { throw "Feed list not found: $FeedListPath" }

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputJsonl) | Out-Null
if (Test-Path -LiteralPath $OutputJsonl) { Remove-Item -LiteralPath $OutputJsonl -Force }
if ($ResolvedFeedsOut) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ResolvedFeedsOut) | Out-Null
  if (Test-Path -LiteralPath $ResolvedFeedsOut) { Remove-Item -LiteralPath $ResolvedFeedsOut -Force }
}

$feeds = Get-Content -LiteralPath $FeedListPath | Where-Object { $_ -and -not $_.StartsWith('#') }

# Helpers
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

# Namespace-agnostic child text by local-name (helps with default xmlns)
function Get-ChildTextLocal($node, [string]$localName){
  try {
    $n = $node.SelectSingleNode("*[local-name()='$localName']")
    if ($n) { return Get-NodeText $n }
    return ''
  } catch { return '' }
}

function Invoke-FetchWithRetry([string]$url, [string]$userAgent, [int]$retries = 2, [int]$timeoutSec = 60){
  $attempt = 0
  $lastErr = $null
  $headers = @{ 'User-Agent' = $userAgent; 'Accept' = 'application/rss+xml, application/atom+xml, application/xml, application/feed+json, text/xml;q=0.9, */*;q=0.1' }
  while ($attempt -le $retries) {
    try {
      return Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing -TimeoutSec $timeoutSec -MaximumRedirection 5 -ErrorAction Stop
    } catch {
      $lastErr = $_
      Start-Sleep -Seconds ([Math]::Min(10, 2 * ($attempt + 1)))
      $attempt++
    }
  }
  # As a last resort, try curl.exe which can succeed where IWR fails (TLS/SNI quirks)
  try {
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
      $accept = 'application/rss+xml, application/atom+xml, application/xml, application/feed+json, text/xml;q=0.9, */*;q=0.1'
      $body = & $curl.Path -sL -A $userAgent -H "Accept: $accept" --max-redirs 5 --connect-timeout 30 --retry 2 --retry-delay 2 --retry-all-errors --insecure "$url"
      if ($LASTEXITCODE -eq 0 -and $body) {
        return [PSCustomObject]@{ Content = [string]$body; Headers = @{} }
      }
    }
  } catch {}
  throw $lastErr
}

# Resolve relative URLs against a base
function Get-AbsoluteUrl([string]$baseUrl, [string]$href){
  if (-not $href) { return $null }
  try {
    $base = [System.Uri]$baseUrl
    $abs = New-Object System.Uri($base, $href)
    return $abs.AbsoluteUri
  } catch { return $href }
}

# Try to discover a feed URL from an HTML page using <link rel="alternate"> tags
function Find-FeedUrl([string]$pageHtml, [string]$baseUrl){
  if (-not $pageHtml) { return $null }
  # Host-specific heuristics first
  if ($baseUrl -match '^https?://www\.npr\.org/podcasts/(\d+)/') {
    $nprId = $Matches[1]
    return "https://feeds.npr.org/$nprId/podcast.xml"
  }
  if ($baseUrl -match '^https?://www\.wnycstudios\.org/podcasts/radiolab') {
    return 'https://feeds.wnyc.org/radiolab'
  }
  # Find all <link ... rel="alternate" ...> tags
  $linkTagPattern = '(?is)<link\b[^>]*?rel\s*=\s*(?:"|'')alternate(?:"|'')[^>]*>'
  $attrPattern = '(?is)(\w+)\s*=\s*(["''])(.*?)\2'
  $linkMatches = [System.Text.RegularExpressions.Regex]::Matches($pageHtml, $linkTagPattern)
  $candidates = @()
  foreach ($m in $linkMatches) {
    $tag = $m.Value
    $attrs = [System.Text.RegularExpressions.Regex]::Matches($tag, $attrPattern)
    $attrMap = @{}
    foreach ($a in $attrs) { $attrMap[$a.Groups[1].Value.ToLower()] = $a.Groups[3].Value }
    $rel = $attrMap['rel']
    $type = ($attrMap['type'] | ForEach-Object { $_.ToLower() })
    $href = $attrMap['href']
    if ($rel -and $rel -match '(?i)alternate' -and $href) {
      $isFeedType = ($type -match 'rss|atom|xml|json')
      if ($isFeedType) {
        $abs = Get-AbsoluteUrl -baseUrl $baseUrl -href $href
        if ($abs) { $candidates += @{ href = $abs; type = $type } }
      }
    }
  }
  # Prefer RSS/Atom over JSON, but accept JSON Feed if present
  $pref = $candidates | Where-Object { $_.type -match 'rss|atom|xml' } | Select-Object -First 1
  if (-not $pref) { $pref = $candidates | Where-Object { $_.type -match 'json' } | Select-Object -First 1 }
  if ($pref) { return $pref.href }
  # Generic absolute URL scan for likely feeds anywhere in HTML
  $patterns = @(
    'https?://feeds\.npr\.org/\d+/podcast\.xml',
    'https?://feeds\.wnyc\.org/[A-Za-z0-9\-_/]+',
    'https?://rss\.art19\.com/[A-Za-z0-9\-_/]+',
    'https?://feeds\.megaphone\.fm/[A-Za-z0-9\-_/]+',
    'https?://[^"''\s>]+\.(?:rss|xml)(?:\?[^"''\s>]*)?'
  )
  foreach ($pat in $patterns) {
    $m2 = [System.Text.RegularExpressions.Regex]::Match($pageHtml, $pat)
    if ($m2.Success) { return $m2.Value }
  }
  # Heuristic fallbacks
  $fallbacks = @('feed', 'rss', 'rss.xml', 'feed.xml', 'index.xml', 'podcast.xml', 'podcast.rss')
  foreach ($f in $fallbacks) {
    try {
      $base = [System.Uri]$baseUrl
      $candidate = (New-Object System.Uri($base, $f)).AbsoluteUri
      return $candidate
    } catch { continue }
  }
  return $null
}

# Attempt to parse JSON Feed and emit items
function Write-JsonFeedItems($jsonText, [string]$outputPath, [int]$maxPerFeed){
  try {
    $feed = $jsonText | ConvertFrom-Json -ErrorAction Stop
  } catch { return $false }
  if (-not $feed) { return $false }
  # JSON Feed spec: https://jsonfeed.org/version/1
  if (-not $feed.items) { return $false }
  $count = 0
  foreach ($item in $feed.items) {
    if ($count -ge $maxPerFeed) { break }
    $title = [string]$item.title
    $link = if ($item.url) { [string]$item.url } elseif ($item.external_url) { [string]$item.external_url } else { '' }
    $published = if ($item.date_published) { [string]$item.date_published } else { '' }
    $author = ''
    if ($item.author -and $item.author.name) { $author = [string]$item.author.name }
    if (-not $title -or -not $link) { continue }
    $obj = @{ title = $title; url = $link; published = $published; author = $author }
    ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $outputPath -Append -Encoding UTF8
    $count++
  }
  return $count -gt 0
}
$resolvedMap = @{}
foreach ($u in $feeds) {
  $url = $u.Trim()
  if (-not $url) { continue }
  try {
  $res = Invoke-FetchWithRetry -url $url -userAgent $UserAgent -retries 2 -timeoutSec 60
    $contentType = ''
    if ($res.Headers -and $res.Headers['Content-Type']) { $contentType = [string]$res.Headers['Content-Type'] }
  $body = if ($res.Content) { [string]$res.Content } else { '' }
    $parsed = $false
    # Try XML first
    try { [xml]$xml = $body } catch { $xml = $null }
  $finalFeedUrl = $null
    if ($xml -and $xml.feed) {
      # Atom
      $entries = @($xml.feed.entry)
      $count = 0
      foreach ($e in $entries) {
        if ($count -ge $MaxPerFeed) { break }
        $title = Get-NodeText $e.title
        $link = ($e.link | Where-Object { $_.rel -eq 'alternate' } | Select-Object -First 1).href
        if (-not $link) { $link = $e.link.href }
        $published = if ($e.published) { [string]$e.published } elseif ($e.updated) { [string]$e.updated } else { '' }
        $author = if ($e.author.name) { Get-NodeText $e.author.name } else { '' }
        if (-not $title -or -not $link) { continue }
        $obj = @{ title = $title; url = $link; published = $published; author = $author }
        ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
        $count++
      }
      $parsed = $true
      $finalFeedUrl = $url
    } elseif ($xml -and $xml.rss -and $xml.rss.channel) {
      # RSS 2.0
      $items = @($xml.rss.channel.item)
      $count = 0
      foreach ($it in $items) {
        if ($count -ge $MaxPerFeed) { break }
        $title = Get-NodeText $it.title
        $link = Get-NodeText $it.link
        if (-not $link) {
          # Fallbacks: guid (permaLink), enclosure url
          try {
            $guidNode = $it.guid
            if ($guidNode -and $guidNode.isPermaLink -and [string]::IsNullOrWhiteSpace($link)) { $link = Get-NodeText $guidNode }
          } catch {}
          try {
            $enclosure = $it.enclosure
            if ($enclosure -and $enclosure.url -and [string]::IsNullOrWhiteSpace($link)) { $link = [string]$enclosure.url }
          } catch {}
        }
        $pubDate = [string]$it.pubDate
        $author = if ($it.'dc:creator') { Get-NodeText $it.'dc:creator' } elseif ($it.author) { Get-NodeText $it.author } else { '' }
        if (-not $title -or -not $link) { continue }
        $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
        ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
        $count++
      }
      $parsed = $true
      $finalFeedUrl = $url
    } elseif ($xml -and $xml.DocumentElement -and $xml.DocumentElement.LocalName -eq 'rss') {
      # Namespaced RSS (default xmlns) where $xml.rss might be null
      $count = 0
      try { $nodes = $xml.SelectNodes("//*[local-name()='item']") } catch { $nodes = @() }
      foreach ($it in $nodes) {
        if ($count -ge $MaxPerFeed) { break }
        $title = Get-ChildTextLocal $it 'title'
        $link = Get-ChildTextLocal $it 'link'
        if (-not $link) { $link = Get-ChildTextLocal $it 'guid' }
        if (-not $link) {
          try { $enc = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($enc -and $enc.Attributes['url']) { $link = [string]$enc.Attributes['url'].Value } } catch {}
        }
        $pubDate = Get-ChildTextLocal $it 'pubDate'
        if (-not $pubDate) { $pubDate = Get-ChildTextLocal $it 'date' }
        $author = Get-ChildTextLocal $it 'creator'
        if (-not $author) { $author = Get-ChildTextLocal $it 'author' }
        if (-not $title -or -not $link) { continue }
        $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
        ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
        $count++
      }
      if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $url }
    } elseif ($xml -and $xml.DocumentElement -and $xml.DocumentElement.LocalName -eq 'RDF') {
      # RSS 1.0 (RDF) / namespace-heavy feeds
      try { $nodes = $xml.SelectNodes("//*[local-name()='item']") } catch { $nodes = @() }
      $count = 0
      foreach ($it in $nodes) {
        if ($count -ge $MaxPerFeed) { break }
        $title = ''
        $link = ''
        $pubDate = ''
        $author = ''
        try { $n = $it.SelectSingleNode("*[local-name()='title']"); if ($n) { $title = Get-NodeText $n } } catch {}
        try { $n = $it.SelectSingleNode("*[local-name()='link']"); if ($n) { $link = Get-NodeText $n } } catch {}
        if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='guid']"); if ($n) { $link = Get-NodeText $n } } catch {} }
        if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($n -and $n.Attributes['url']) { $link = [string]$n.Attributes['url'].Value } } catch {} }
        try { $n = $it.SelectSingleNode("*[local-name()='pubDate']|*[local-name()='date']"); if ($n) { $pubDate = Get-NodeText $n } } catch {}
        try { $n = $it.SelectSingleNode("*[local-name()='creator']|*[local-name()='author']"); if ($n) { $author = Get-NodeText $n } } catch {}
        if (-not $title -or -not $link) { continue }
        $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
        ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
        $count++
      }
      if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $url }
    }

    if (-not $parsed) {
  # Try JSON Feed directly based on content-type or content
  if ($contentType -match 'json' -or ($body -and ([string]$body).TrimStart().StartsWith('{'))) {
        $parsed = Write-JsonFeedItems -jsonText $body -outputPath $OutputJsonl -maxPerFeed $MaxPerFeed
      }
  if (-not $parsed) {
        # Try auto-discovery from HTML
  $discovered = Find-FeedUrl -pageHtml $body -baseUrl $url
        if ($discovered -and $discovered -ne $url) {
          try {
            $res2 = Invoke-FetchWithRetry -url $discovered -userAgent $UserAgent -retries 2 -timeoutSec 60
            $body2 = if ($res2.Content) { [string]$res2.Content } else { '' }
            $contentType2 = ''
            if ($res2.Headers -and $res2.Headers['Content-Type']) { $contentType2 = [string]$res2.Headers['Content-Type'] }
            # XML?
            try { [xml]$xml2 = $body2 } catch { $xml2 = $null }
            if ($xml2 -and $xml2.feed) {
              $entries = @($xml2.feed.entry)
              $count = 0
              foreach ($e in $entries) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-NodeText $e.title
                $link = ($e.link | Where-Object { $_.rel -eq 'alternate' } | Select-Object -First 1).href
                if (-not $link) { $link = $e.link.href }
                $published = if ($e.published) { [string]$e.published } elseif ($e.updated) { [string]$e.updated } else { '' }
                $author = if ($e.author.name) { Get-NodeText $e.author.name } else { '' }
                if (-not $title -or -not $link) { continue }
                $obj = @{ title = $title; url = $link; published = $published; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $parsed = $true
              $finalFeedUrl = $discovered
            } elseif ($xml2 -and $xml2.rss -and $xml2.rss.channel) {
              $items = @($xml2.rss.channel.item)
              $count = 0
              foreach ($it in $items) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-NodeText $it.title
                $link = Get-NodeText $it.link
                $pubDate = [string]$it.pubDate
                $author = if ($it.'dc:creator') { Get-NodeText $it.'dc:creator' } elseif ($it.author) { Get-NodeText $it.author } else { '' }
                if (-not $title -or -not $link) { continue }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $parsed = $true
              $finalFeedUrl = $discovered
            } elseif ($xml2 -and $xml2.DocumentElement -and $xml2.DocumentElement.LocalName -eq 'rss') {
              $count = 0
              try { $nodes2 = $xml2.SelectNodes("//*[local-name()='item']") } catch { $nodes2 = @() }
              foreach ($it in $nodes2) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-ChildTextLocal $it 'title'
                $link = Get-ChildTextLocal $it 'link'
                if (-not $link) { $link = Get-ChildTextLocal $it 'guid' }
                if (-not $link) { try { $enc = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($enc -and $enc.Attributes['url']) { $link = [string]$enc.Attributes['url'].Value } } catch {} }
                $pubDate = Get-ChildTextLocal $it 'pubDate'
                if (-not $pubDate) { $pubDate = Get-ChildTextLocal $it 'date' }
                $author = Get-ChildTextLocal $it 'creator'
                if (-not $author) { $author = Get-ChildTextLocal $it 'author' }
                if (-not $title -or -not $link) { continue }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $discovered }
            } elseif ($xml2 -and $xml2.DocumentElement -and $xml2.DocumentElement.LocalName -eq 'RDF') {
              try { $nodes2 = $xml2.SelectNodes("//*[local-name()='item']") } catch { $nodes2 = @() }
              $count = 0
              foreach ($it in $nodes2) {
                if ($count -ge $MaxPerFeed) { break }
                $title = ''
                $link = ''
                $pubDate = ''
                $author = ''
                try { $n = $it.SelectSingleNode("*[local-name()='title']"); if ($n) { $title = Get-NodeText $n } } catch {}
                try { $n = $it.SelectSingleNode("*[local-name()='link']"); if ($n) { $link = Get-NodeText $n } } catch {}
                if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='guid']"); if ($n) { $link = Get-NodeText $n } } catch {} }
                if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($n -and $n.Attributes['url']) { $link = [string]$n.Attributes['url'].Value } } catch {} }
                try { $n = $it.SelectSingleNode("*[local-name()='pubDate']|*[local-name()='date']"); if ($n) { $pubDate = Get-NodeText $n } } catch {}
                try { $n = $it.SelectSingleNode("*[local-name()='creator']|*[local-name()='author']"); if ($n) { $author = Get-NodeText $n } } catch {}
                if (-not $title -or -not $link) { continue }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $discovered }
            } else {
              # Maybe JSON Feed
              if ($contentType2 -match 'json' -or ($body2 -and ([string]$body2).TrimStart().StartsWith('{'))) {
                $parsed = Write-JsonFeedItems -jsonText $body2 -outputPath $OutputJsonl -maxPerFeed $MaxPerFeed
                if ($parsed) { $finalFeedUrl = $discovered }
              }
            }
          } catch {
            Write-Host ("FAILED after discovery: {0} :: {1}" -f $discovered, $_.Exception.Message)
          }
        }
      }
      # Final attempt: refetch with curl explicitly and re-parse (some hosts behave differently)
      if (-not $parsed) {
        try {
          $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
          if ($curl) {
            $accept = 'application/rss+xml, application/atom+xml, application/xml, application/feed+json, text/xml;q=0.9, */*;q=0.1'
            $bodyC = & $curl.Path -sL -A $UserAgent -H "Accept: $accept" --max-redirs 5 --connect-timeout 30 --retry 2 --retry-delay 2 --retry-all-errors --insecure "$url"
            if ($LASTEXITCODE -eq 0 -and $bodyC) {
              try { [xml]$xmlC = [string]$bodyC } catch { $xmlC = $null }
              if ($xmlC -and $xmlC.feed) {
                $count = 0
                foreach ($e in @($xmlC.feed.entry)) {
                  if ($count -ge $MaxPerFeed) { break }
                  $title = Get-NodeText $e.title
                  $link = ($e.link | Where-Object { $_.rel -eq 'alternate' } | Select-Object -First 1).href
                  if (-not $link) { $link = $e.link.href }
                  $published = if ($e.published) { [string]$e.published } elseif ($e.updated) { [string]$e.updated } else { '' }
                  $author = if ($e.author.name) { Get-NodeText $e.author.name } else { '' }
                  if (-not $title -or -not $link) { continue }
                  $obj = @{ title = $title; url = $link; published = $published; author = $author }
                  ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                  $count++
                }
                if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $url }
              } elseif ($xmlC -and $xmlC.rss -and $xmlC.rss.channel) {
                $count = 0
                foreach ($it in @($xmlC.rss.channel.item)) {
                  if ($count -ge $MaxPerFeed) { break }
                  $title = Get-NodeText $it.title
                  $link = Get-NodeText $it.link
                  if (-not $title -or -not $link) { continue }
                  $pubDate = [string]$it.pubDate
                  $author = if ($it.'dc:creator') { Get-NodeText $it.'dc:creator' } elseif ($it.author) { Get-NodeText $it.author } else { '' }
                  $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                  ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                  $count++
                }
                if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $url }
              } elseif ($xmlC -and $xmlC.DocumentElement) {
                $root = $xmlC.DocumentElement.LocalName
                if ($root -eq 'rss' -or $root -eq 'RDF') {
                  $count = 0
                  try { $nodesC = $xmlC.SelectNodes("//*[local-name()='item']") } catch { $nodesC = @() }
                  foreach ($it in $nodesC) {
                    if ($count -ge $MaxPerFeed) { break }
                    $title = Get-ChildTextLocal $it 'title'
                    $link = Get-ChildTextLocal $it 'link'
                    if (-not $link) { $link = Get-ChildTextLocal $it 'guid' }
                    if (-not $link) { try { $enc = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($enc -and $enc.Attributes['url']) { $link = [string]$enc.Attributes['url'].Value } } catch {} }
                    $pubDate = Get-ChildTextLocal $it 'pubDate'; if (-not $pubDate) { $pubDate = Get-ChildTextLocal $it 'date' }
                    $author = Get-ChildTextLocal $it 'creator'; if (-not $author) { $author = Get-ChildTextLocal $it 'author' }
                    if (-not $title -or -not $link) { continue }
                    $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                    ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                    $count++
                  }
                  if ($count -gt 0) { $parsed = $true; $finalFeedUrl = $url }
                }
              }
            }
          } catch {}
        }
      }
    }

    if (-not $parsed) {
      Write-Host ("Unrecognized feed format: {0}" -f $url)
      $resolvedMap[$url] = ''
    } else {
      if (-not $finalFeedUrl) { $finalFeedUrl = $url }
      $resolvedMap[$url] = $finalFeedUrl
    }
  } catch {
    $errMsg = $_.Exception.Message
    $handled = $false
    # If it's a 404 and URL ends with /rss, try parent page discovery once
    if ($url -match '/rss/?$') {
      try {
        $parentUrl = $url -replace '/rss/?$','/'
        $res3 = Invoke-FetchWithRetry -url $parentUrl -userAgent $UserAgent -retries 1 -timeoutSec 45
  $body3 = if ($res3.Content) { [string]$res3.Content } else { '' }
  $disc = Find-FeedUrl -pageHtml $body3 -baseUrl $parentUrl
        if ($disc) {
          try {
            $res4 = Invoke-FetchWithRetry -url $disc -userAgent $UserAgent -retries 1 -timeoutSec 60
            $body4 = if ($res4.Content) { [string]$res4.Content } else { '' }
            # Try XML then JSON as before
            try { [xml]$xml4 = $body4 } catch { $xml4 = $null }
            if ($xml4 -and $xml4.feed) {
              $count = 0
              foreach ($e in @($xml4.feed.entry)) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-NodeText $e.title
                $link = ($e.link | Where-Object { $_.rel -eq 'alternate' } | Select-Object -First 1).href
                if (-not $link) { $link = $e.link.href }
                if (-not $title -or -not $link) { continue }
                $published = if ($e.published) { [string]$e.published } elseif ($e.updated) { [string]$e.updated } else { '' }
                $author = if ($e.author.name) { Get-NodeText $e.author.name } else { '' }
                $obj = @{ title = $title; url = $link; published = $published; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } elseif ($xml4 -and $xml4.rss -and $xml4.rss.channel) {
              $count = 0
              foreach ($it in @($xml4.rss.channel.item)) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-NodeText $it.title
                $link = Get-NodeText $it.link
                if (-not $title -or -not $link) { continue }
                $pubDate = [string]$it.pubDate
                $author = if ($it.'dc:creator') { Get-NodeText $it.'dc:creator' } elseif ($it.author) { Get-NodeText $it.author } else { '' }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } elseif ($xml4 -and $xml4.DocumentElement -and $xml4.DocumentElement.LocalName -eq 'rss') {
              $count = 0
              try { $nodes4 = $xml4.SelectNodes("//*[local-name()='item']") } catch { $nodes4 = @() }
              foreach ($it in $nodes4) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-ChildTextLocal $it 'title'
                $link = Get-ChildTextLocal $it 'link'
                if (-not $link) { $link = Get-ChildTextLocal $it 'guid' }
                if (-not $link) { try { $enc = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($enc -and $enc.Attributes['url']) { $link = [string]$enc.Attributes['url'].Value } } catch {} }
                $pubDate = Get-ChildTextLocal $it 'pubDate'
                if (-not $pubDate) { $pubDate = Get-ChildTextLocal $it 'date' }
                $author = Get-ChildTextLocal $it 'creator'
                if (-not $author) { $author = Get-ChildTextLocal $it 'author' }
                if (-not $title -or -not $link) { continue }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } elseif ($xml4 -and $xml4.DocumentElement -and $xml4.DocumentElement.LocalName -eq 'RDF') {
              try { $nodes4 = $xml4.SelectNodes("//*[local-name()='item']") } catch { $nodes4 = @() }
              $count = 0
              foreach ($it in $nodes4) {
                if ($count -ge $MaxPerFeed) { break }
                $title = ''
                $link = ''
                $pubDate = ''
                $author = ''
                try { $n = $it.SelectSingleNode("*[local-name()='title']"); if ($n) { $title = Get-NodeText $n } } catch {}
                try { $n = $it.SelectSingleNode("*[local-name()='link']"); if ($n) { $link = Get-NodeText $n } } catch {}
                if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='guid']"); if ($n) { $link = Get-NodeText $n } } catch {} }
                if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($n -and $n.Attributes['url']) { $link = [string]$n.Attributes['url'].Value } } catch {} }
                try { $n = $it.SelectSingleNode("*[local-name()='pubDate']|*[local-name()='date']"); if ($n) { $pubDate = Get-NodeText $n } } catch {}
                try { $n = $it.SelectSingleNode("*[local-name()='creator']|*[local-name()='author']"); if ($n) { $author = Get-NodeText $n } } catch {}
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } else {
              # JSON Feed fallback
              $handled = Write-JsonFeedItems -jsonText $body4 -outputPath $OutputJsonl -maxPerFeed $MaxPerFeed
            }
          } catch {}
        }
      } catch {}
    }
    # Art19 heuristic: rss.art19.com/<slug> -> https://art19.com/shows/<slug>
    if (-not $handled -and $url -match '^https?://rss\.art19\.com/([^/?#]+)') {
      $slug = $Matches[1]
      $showUrl = "https://art19.com/shows/$slug"
      try {
        $res5 = Invoke-FetchWithRetry -url $showUrl -userAgent $UserAgent -retries 1 -timeoutSec 45
        $disc2 = Find-FeedUrl -pageHtml $res5.Content -baseUrl $showUrl
        if ($disc2) {
          try {
            $res6 = Invoke-FetchWithRetry -url $disc2 -userAgent $UserAgent -retries 1 -timeoutSec 60
            $body6 = if ($res6.Content) { [string]$res6.Content } else { '' }
            try { [xml]$xml6 = $body6 } catch { $xml6 = $null }
            if ($xml6 -and $xml6.feed) {
              $count = 0
              foreach ($e in @($xml6.feed.entry)) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-NodeText $e.title
                $link = ($e.link | Where-Object { $_.rel -eq 'alternate' } | Select-Object -First 1).href
                if (-not $link) { $link = $e.link.href }
                if (-not $title -or -not $link) { continue }
                $published = if ($e.published) { [string]$e.published } elseif ($e.updated) { [string]$e.updated } else { '' }
                $author = if ($e.author.name) { Get-NodeText $e.author.name } else { '' }
                $obj = @{ title = $title; url = $link; published = $published; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } elseif ($xml6 -and $xml6.rss -and $xml6.rss.channel) {
              $count = 0
              foreach ($it in @($xml6.rss.channel.item)) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-NodeText $it.title
                $link = Get-NodeText $it.link
                if (-not $title -or -not $link) { continue }
                $pubDate = [string]$it.pubDate
                $author = if ($it.'dc:creator') { Get-NodeText $it.'dc:creator' } elseif ($it.author) { Get-NodeText $it.author } else { '' }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } elseif ($xml6 -and $xml6.DocumentElement -and $xml6.DocumentElement.LocalName -eq 'rss') {
              $count = 0
              try { $nodes6 = $xml6.SelectNodes("//*[local-name()='item']") } catch { $nodes6 = @() }
              foreach ($it in $nodes6) {
                if ($count -ge $MaxPerFeed) { break }
                $title = Get-ChildTextLocal $it 'title'
                $link = Get-ChildTextLocal $it 'link'
                if (-not $link) { $link = Get-ChildTextLocal $it 'guid' }
                if (-not $link) { try { $enc = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($enc -and $enc.Attributes['url']) { $link = [string]$enc.Attributes['url'].Value } } catch {} }
                $pubDate = Get-ChildTextLocal $it 'pubDate'
                if (-not $pubDate) { $pubDate = Get-ChildTextLocal $it 'date' }
                $author = Get-ChildTextLocal $it 'creator'
                if (-not $author) { $author = Get-ChildTextLocal $it 'author' }
                if (-not $title -or -not $link) { continue }
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } elseif ($xml6 -and $xml6.DocumentElement -and $xml6.DocumentElement.LocalName -eq 'RDF') {
              try { $nodes6 = $xml6.SelectNodes("//*[local-name()='item']") } catch { $nodes6 = @() }
              $count = 0
              foreach ($it in $nodes6) {
                if ($count -ge $MaxPerFeed) { break }
                $title = ''
                $link = ''
                $pubDate = ''
                $author = ''
                try { $n = $it.SelectSingleNode("*[local-name()='title']"); if ($n) { $title = Get-NodeText $n } } catch {}
                try { $n = $it.SelectSingleNode("*[local-name()='link']"); if ($n) { $link = Get-NodeText $n } } catch {}
                if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='guid']"); if ($n) { $link = Get-NodeText $n } } catch {} }
                if (-not $link) { try { $n = $it.SelectSingleNode("*[local-name()='enclosure']"); if ($n -and $n.Attributes['url']) { $link = [string]$n.Attributes['url'].Value } } catch {} }
                try { $n = $it.SelectSingleNode("*[local-name()='pubDate']|*[local-name()='date']"); if ($n) { $pubDate = Get-NodeText $n } } catch {}
                try { $n = $it.SelectSingleNode("*[local-name()='creator']|*[local-name()='author']"); if ($n) { $author = Get-NodeText $n } } catch {}
                $obj = @{ title = $title; url = $link; published = $pubDate; author = $author }
                ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $OutputJsonl -Append -Encoding UTF8
                $count++
              }
              $handled = $count -gt 0
            } else {
              $handled = Write-JsonFeedItems -jsonText $body6 -outputPath $OutputJsonl -maxPerFeed $MaxPerFeed
            }
          } catch {}
        }
      } catch {}
    }
    if (-not $handled) {
      Write-Host ("FAILED: {0} :: {1}" -f $url, $errMsg)
    }
  }
}

# Optionally output a mapping of original to resolved feed URLs
if ($ResolvedFeedsOut) {
  try {
    ($resolvedMap | ConvertTo-Json -Depth 4) | Out-File -FilePath $ResolvedFeedsOut -Encoding UTF8 -Force
  } catch {}
}

