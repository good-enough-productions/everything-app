# PowerShell on Windows — Common Gotchas (and fixes)

Avoid interactive prompts and brittle one‑liners by following these patterns when running scripts and chaining commands in Windows PowerShell 5.1.

## 1) Always set ErrorActionPreference at the start

Use Stop to fail fast inside script blocks; don’t try to inject it mid-line.

```powershell
$ErrorActionPreference = 'Stop'
```

## 2) Test-Path requires a Path value

The prompt “Supply values for: Path[0]” appears when Test-Path is called with `$null` or an empty string. Prevent this:

- Ensure variables are non-empty before calling Test-Path.
- Use `-LiteralPath` for raw paths.
- Guard with `[string]::IsNullOrWhiteSpace($p)`.

Example:

```powershell
if (-not [string]::IsNullOrWhiteSpace($FeedListPath) -and (Test-Path -LiteralPath $FeedListPath)) {
  # safe to use
} else {
  throw "Feed list not found: $FeedListPath"
}
```

## 3) Join-Path with -ChildPath must be non-empty

If `-ChildPath` is empty, PowerShell can prompt unexpectedly. Ensure it’s provided:

```powershell
if (-not [string]::IsNullOrWhiteSpace($child)) {
  $full = Join-Path -Path $base -ChildPath $child
}
```

Prefer using variables you control (e.g., known filenames) over passing user-provided empty values.

## 4) Quote commands in one-liners carefully

When embedding quotes in `-Command`, prefer double-quotes for the outer string and single-quotes inside. Avoid mixing JSON or XPath quotes that break the parser.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\\path\\to\\script.ps1' -FeedListPath 'C:\\x\\feeds.txt' -OutputJsonl 'C:\\x\\out.jsonl'"
```

For XPath with quotes, build strings in variables first instead of inline literals.

## 5) Initialize working directories

Create output folders before writing files. Use `Split-Path -Parent` and `New-Item -Force`.

```powershell
$out = 'C:\\x\\tmp\\feeds.jsonl'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
```

## 6) Prefer -LiteralPath for file system operations

Prevents wildcard expansion and edge-case prompts.

```powershell
Get-Content -LiteralPath $file -ErrorAction Stop
```

## 7) Avoid reserved/automatic variables

Don’t assign to `$matches` (automatic), use `$linkMatches` etc. This prevents subtle regex bugs and analyzer warnings.

## 8) Use approved verbs for functions

Name functions like `Get-...`, `Set-...`, `Find-...` to satisfy PSScriptAnalyzer (we use `Find-FeedUrl`).

## 9) Optional: Use PowerShell 7 for better networking

Some feeds require newer TLS/HTTP stacks. If possible, run:

```powershell
powershell -Version 7 -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\obsidian-rss-runner.ps1
```

## 10) Quick checklist before running scripts

- Paths exist and are quoted
- Output folder exists
- `-ChildPath` is non-empty
- No PS7-only syntax in PS5.1 shells
- `$ErrorActionPreference = 'Stop'` set at top of script
