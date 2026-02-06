# Custom Chat Mode: Chat Mode Expert

This workspace contains a ready-to-use custom chat mode that is an expert in designing and wiring new custom chat modes (including MCP-aware tool selection).

## Files
- `.github/chatmodes/chatmode-expert.chatmode.md` — the mode definition for building chat modes.
- `.github/chatmodes/researcher.chatmode.md` — research assistant with MCP tools (markitdown, context7, etc.).
- `.github/chatmodes/prototyper.chatmode.md` — requirements clarification and rapid prototype development.
- `.vscode/tasks.json` — tasks to open all modes quickly.
- `keybindings-example.json` — copy these to your user keybindings.json for instant mode switching.

## How to use
1. Open this folder in VS Code.
2. In Copilot Chat, pick `chatmode-expert`, `researcher`, or `prototyper` from the mode picker.
3. Or run tasks: Ctrl+Shift+P → "Tasks: Run Task" → "Open Chat Mode: [name]".
4. Optional: Copy keybindings from `keybindings-example.json` to your user settings for Ctrl+Alt+M (expert), Ctrl+Alt+R (researcher), and Ctrl+Alt+P (prototyper).

## Optional: keyboard shortcuts
Copy the contents of `keybindings-example.json` to your user `keybindings.json` (Ctrl+Shift+P → "Preferences: Open Keyboard Shortcuts (JSON)"):

- Ctrl+Alt+M: Open chatmode-expert
- Ctrl+Alt+R: Open researcher  
- Ctrl+Alt+P: Open prototyper

## Notes
- The mode lists common tools (`codebase`, `file`, `selection`, `fetch_webpage`, `github_repo`, `get_terminal_last_command`, `get_terminal_selection`). Tools resolve if provided by Copilot or installed extensions; unknown tools are ignored.
- To add MCP tools from extensions, include their tool names under `tools:` and instruct the agent when to use them.

## MCP on Windows
- `docs/mcp-setup-windows.md` — installing uv and curated MCP servers with Windows-friendly steps
- `docs/mcp-troubleshooting.md` — why some MCP servers don't show up in VS Code's "Configure Tools"
- `docs/powershell-windows-gotchas.md` — avoid Test-Path Path[0] prompts, quoting pitfalls, and safe path handling
