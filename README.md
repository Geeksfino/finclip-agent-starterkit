# finclip-agent

[中文文档](./README.zh-CN.md)

This project provides tools to set up and configure a CxAgent with kb-mcp-server integration for knowledge base access.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/finclip-agent.git
cd finclip-agent

# Run the setup script (installs all dependencies)
bun start
```

## Manual Setup

If you prefer to run each step manually:

1. Set up dependencies:
   ```bash
   bun run setup
   ```

2. Download required models:
   ```bash
   bun run download-models
   ```

3. Generate configuration:
   ```bash
   bun run generate-config
   ```

## Configuration

After setup, you'll need to:

1. Edit `.agent.env` with your API key and other settings
2. Place your knowledge base embeddings at `./finclip.tar.gz` or update the path in `conf/preproc-mcp.json`
3. Optionally create a `brain.md` file to customize your agent's behavior

## Knowledge Base Management

### Interactive Mode

The finclip-agent includes an interactive script for managing your knowledge base:

```bash
# Start the interactive knowledge base management tool
bun run kb:interactive
```

This tool guides you through the process of building, exporting, and searching your knowledge base with a simple menu interface. It also offers to update your MCP configuration automatically after building or exporting the knowledge base.

### Direct Commands

If you prefer direct access to the knowledge base tools, you can use these commands:

```bash
# Build the knowledge base from documents in the content directory
bun run kb:build

# Build with debug output
bun run kb:build:debug

# Search the knowledge base interactively
bun run kb:search

# Search with graph-based retrieval
bun run kb:search:graph

# Export the knowledge base for distribution
bun run kb:package
```

These commands use the configuration in `kb.yml`. After packaging the knowledge base, the `finclip.tar.gz` file will be created, which is used by the MCP server.

## Running the Agent

```bash
# Start the agent
bunx @finogeek/cxagent
```

## Embedding the Chat Widget

Create an HTML file with the following content:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Finclip Agent Chat</title>
</head>
<body>
  <h1>Finclip Agent Chat</h1>
  
  <script 
    src="./node_modules/@finogeek/cxagent/web/dist/finclip-chat.js" 
    data-finclip-chat 
    data-api-url="http://localhost:5678" 
    data-streaming-url="http://localhost:5679"
  ></script>
</body>
</html>
```

Open this HTML file in your browser to interact with the agent.

## Project Structure

- `setup.sh`: Installs Bun, checks Python, installs uv, and sets up the environment
- `download-models.js`: Downloads required models from Hugging Face based on kb.yml
- `generate-config.js`: Generates the MCP configuration for kb-mcp-server
- `index.js`: Main script that runs all setup steps in sequence

## Requirements

- [Bun](https://bun.sh/) runtime (v1.0.0 or higher)
- Python 3.9+ with pip
- Internet connection for downloading models

## Troubleshooting

### Common Issues

1. **Model download fails**:
   - Check your internet connection
   - Ensure you have enough disk space
   - Try running `bun run download-models` again

2. **Configuration generation fails**:
   - Make sure kb-mcp-server is installed correctly
   - Check that the virtual environment is activated

3. **Agent doesn't start**:
   - Verify your API key in `.agent.env`
   - Check that the embeddings file exists at the specified path

## Advanced Configuration

For advanced configuration options, refer to:
- [CxAgent Documentation](https://github.com/Geeksfino/cxagent)
- [kb-mcp-server Documentation](https://github.com/Geeksfino/kb-mcp-server)
