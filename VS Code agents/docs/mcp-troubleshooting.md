# Installing MCP Servers in VS Code

The MCP servers need to be installed through VS Code's MCP system to appear in the "Configure Tools" dialog.

## Method 1: Use VS Code's MCP install links (recommended)

Visit: https://code.visualstudio.com/mcp

Look for these servers and click their "Install" buttons:

- **MarkItDown**: Convert PDFs, Word docs, images to Markdown
- **ImageSorcery**: Local image processing with computer vision
- **GitHub**: Access repositories and issues  
- **Hugging Face**: Access models and datasets
- **Context7**: Get framework documentation (should already be installed)
- **Playwright**: Browser automation (should already be installed)

## Method 2: Manual VS Code command

If the web links don't work, try these in VS Code Command Palette (Ctrl+Shift+P):

1. `MCP: Configure Server...`
2. Add server manually:
   - **Name**: markitdown
   - **Command**: uvx
   - **Args**: ["markitdown-mcp"]

For ImageSorcery:
   - **Name**: imagesorcery  
   - **Command**: uvx
   - **Args**: ["imagesorcery-mcp"]

## Method 3: Check VS Code settings

Go to Settings → Extensions → GitHub Copilot → MCP Servers to see what's configured.

## Why this happens:

- `uvx markitdown-mcp` works from terminal but VS Code needs the server registered in its MCP configuration
- The "Configure Tools" dialog only shows servers that VS Code knows about through its MCP registry
- Installing via the VS Code MCP page automatically handles the registration
