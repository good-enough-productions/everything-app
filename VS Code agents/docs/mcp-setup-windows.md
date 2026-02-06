# MCP setup on Windows (PowerShell)

This guide installs Astral's uv (required by several MCP servers using `uvx`) and suggests a curated MCP starter pack for VS Code Agent Mode.

## 1) Install uv on Windows

Recommended methods (pick one):

- WinGet (simple, managed):
```powershell
winget install --id=astral-sh.uv -e
```
- Scoop (if you use Scoop):
```powershell
scoop install main/uv
```
- PyPI via pipx (isolated):
```powershell
pipx install uv
```

Notes:
- After install, ensure `uv` and `uvx` are on PATH. Restart VS Code/terminal if needed.
- To upgrade later: `uv self update` (works if installed via standalone/winget); or use your package manager's upgrade command.

Verify install:
```powershell
uv --version
uvx --version
```

Optional: PowerShell completion (in PowerShell profile):
```powershell
# Autocomplete for uv
$profilePath = $PROFILE
"uv generate-shell-completion powershell | Invoke-Expression" | Out-File -FilePath $profilePath -Append
# Autocomplete for uvx
"uvx --generate-shell-completion powershell | Invoke-Expression" | Out-File -FilePath $profilePath -Append
```

## 2) Install MCP servers (curated starter pack)

You can install MCP servers directly from the VS Code page (deep links) or via commands. These choices complement dev workflows and our chat modes.

- MarkItDown (file to Markdown conversions) — requires `uvx`:
  - VS Code link: code URL on the list
  - Manual:
    ```powershell
    uvx markitdown-mcp
    ```
- Playwright (browser automation for testing/data extraction):
  - VS Code link: code URL on the list
  - Manual:
    ```powershell
    npx @playwright/mcp@latest
    ```
- GitHub (repo/issues/PRs access):
  - VS Code link: code URL on the list
- Hugging Face (models/datasets/spaces):
  - VS Code link: code URL on the list
- Context7 (framework docs Q&A):
  - VS Code link: code URL on the list

For data work (optional):
- DuckDB:
  ```powershell
  uvx mcp-server-duckdb --db-path "C:\\path\\to\\data.duckdb"
  ```

Notes:
- The VS Code page provides clickable install links that pre-fill settings. Open: https://code.visualstudio.com/mcp
- Some servers need API tokens (Hugging Face, GitHub, etc.). VS Code will prompt for them during setup.

## 3) Use MCP tools in Agent Mode

- Open Copilot Chat in Agent mode and ensure the selected mode has tools that map to installed MCP servers.
- Our `chatmode-expert` focuses on building modes; add MCP tools to your specific modes when needed (e.g., `markitdown`, `duckdb`, etc.).

## 4) Add tools to your mode

Example adding MarkItDown and DuckDB to a mode front matter:
```yaml
tools:
  - codebase
  - file
  - selection
  - markitdown
  - duckdb
```
Instruction body example:
- Use `#markitdown` to convert PDFs or images to Markdown before summarizing.
- Use `#duckdb` to run SQL queries; ask for a `.du c k d b` path if missing.

## Troubleshooting
- If `uvx` isn’t found, restart the shell. Confirm PATH has the `uv` install location.
- If an MCP server tool isn’t visible, reopen VS Code, ensure the server is running/installed, or reinstall via the VS Code link.
- PowerShell execution policy may block profiles; use `Get-ExecutionPolicy` and, if needed, run a non-restrictive policy for your user.

See also: PowerShell on Windows — Common Gotchas: `docs/powershell-windows-gotchas.md` (avoiding Test-Path prompts, quoting rules, output directories).
