# finclip-agent-starterkit

<p align="right">
  <a href="README.md">English</a> |
  <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/Geeksfino/finclip-agent-starterkit/stargazers"><img src="https://img.shields.io/github/stars/Geeksfino/finclip-agent-starterkit.svg" alt="GitHub stars"></a>
  <a href="https://github.com/Geeksfino/finclip-agent-starterkit/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Geeksfino/finclip-agent-starterkit.svg" alt="license"></a>
  <a href="https://github.com/Geeksfino/finclip-agent-starterkit/issues"><img src="https://img.shields.io/github/issues/Geeksfino/finclip-agent-starterkit.svg" alt="GitHub issues"></a>
  <a href="https://bun.sh"><img src="https://img.shields.io/badge/powered%20by-Bun-orange.svg" alt="Powered by Bun"></a>
  <a href="https://github.com/Geeksfino/finclip-agent"><img src="https://img.shields.io/badge/based%20on-finclip--agent-blue.svg" alt="Based on finclip-agent"></a>
</p>

This project is a starter kit for building knowledge base-powered chatbots using FinClip and finclip-agent. It provides all the necessary setup and configuration tools to quickly deploy an agent with custom knowledge. The frontend chat interface can be embedded as a floating window on websites, and the backend is an Agent based on [finclip-agent](https://github.com/Geeksfino/finclip-agent).

**Important**: When creating your own agent, make sure to follow the strict YAML format requirements for the `brain.md` file as specified in the [finclip-agent documentation](https://github.com/Geeksfino/finclip-agent#agent-brain). The file must only contain the top-level fields: `name`, `role`, `goal`, and `capabilities`. Any other structure will prevent the agent from starting correctly.

## Getting Started

**Important**: This project uses [Bun](https://bun.sh/) instead of Node.js/npm as the JavaScript runtime and package manager.

### Environment Preparation

Before you begin, prepare your environment by running the setup script:

```bash
# Download the setup script
curl -fsSL https://raw.githubusercontent.com/Geeksfino/finclip-agent-starterkit/main/scripts/setup.sh -o setup.sh

# Make it executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

This script will:
- Install Bun (if not already installed)
- Check for Python (you'll need Python 3.9+ installed)
- Install uv (Python package manager)
- Set up a Python virtual environment
- Install necessary dependencies

**Note**: The setup script will check if Python is installed, but it will not install Python for you. If Python is not found, the script will exit with an error message.

### Prerequisites

- A Unix-like environment (macOS, Linux, or WSL on Windows)
- [Python](https://www.python.org/) 3.9 or higher installed on your system

## Quick Start

After preparing your environment with the setup script, follow these steps:

```bash
# Clone the repository
git clone https://github.com/Geeksfino/finclip-agent-starterkit.git
cd finclip-agent-starterkit

# Run the environment setup script
# This will download models and generate configuration files
bun setup:env

# Copy sample files to the contents directory (optional)
bun run kb:use-samples

# Build the knowledge base (creates kb.tar.gz)
bun run kb:package

# Configure your API key in .agent.env (REQUIRED)
# Edit the .agent.env file and add your LLM API key

# Start the agent
bun start

# Verify the agent is working with the inspector UI
bun start --inspect
```

## Environment Setup

### Automatic Setup

The easiest way to set up your environment is to run:

```bash
bun setup:env
```

This script will:
1. Check for and install Bun if not already available
2. Verify Python is installed (you'll need to install Python manually if it's not found)
3. Install all necessary dependencies
4. Create a Python virtual environment
5. Install kb-mcp-server
6. Download required models
7. Generate configuration files

### Manual Setup

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

1. Edit `.agent.env` with your API key and other settings (REQUIRED)
   ```
   # Example .agent.env configuration
   LLM_API_KEY=your_api_key_here        # Replace with your actual API key
   LLM_PROVIDER_URL=https://api.openai.com/v1
   LLM_MODEL=gpt-4o                    # Or another model of your choice
   LLM_STREAM_MODE=true
   ```
2. Optionally edit `brain.md` to customize your agent's behavior

> **Note**: The `conf/preproc-mcp.json` file contains paths specific to your local environment and is automatically generated by the setup process. It should not be manually edited or committed to version control.

## Sample Knowledge Base Content

This starter kit comes with sample markdown files in the `knowledge-samples` directory covering topics like data science, machine learning, neural networks, and NLP. This allows you to quickly build a working knowledge base for testing before adding your own content.

### Using the Sample Files

To use the provided sample files:

```bash
# Copy the sample files to the contents directory
bun run kb:use-samples

# Build the knowledge base (creates kb.tar.gz)
bun run kb:package
```

### Building the Knowledge Base

1. After copying the sample files to the `contents` directory, they will be used when you run the knowledge base build commands
2. To generate the knowledge base, run `bun run kb:package`
3. The knowledge base will be built according to the settings in `kb.yml` in the root directory
4. Once built, you can test the knowledge base by running `bun run kb:search "your search query"` to search for information

### Customizing with Your Own Content

When you're ready to customize the chatbot with your own knowledge:

1. Place your own markdown, PDF, or other supported documents in the `contents` directory
2. Adjust the settings in `kb.yml` if needed (e.g., chunking strategy, embedding model)
3. Rebuild the knowledge base with `bun run kb:package`

The quality of knowledge base retrieval and generation depends on the configuration in `kb.yml`, including source file formats, data chunking strategies (e.g., by line, by paragraph), chunk overlap, retriever type, and choice of embedding models. The generation process requires some computation time; refer to the [kb-mcp-server](https://github.com/Geeksfino/kb-mcp-server) documentation for details.

## Verifying the Agent

To quickly verify that the agent is working correctly, you can use the inspector UI:

```bash
# Using the start script
bun start --inspect
# point browser to http://localhost:5173

# or with a custom port
bun start --inspect --inspect-port 3000
# point browser to http://localhost:3000

# Alternatively, you can use the cxagent command directly
bunx @finogeek/cxagent --inspect
# or
bunx @finogeek/cxagent --inspect --inspect-port 3000
```

This will open a web interface where you can see the agent's configuration, test its functionality, and ensure everything is set up correctly.

## Running with Docker (Pre-built Image)

This project automatically builds a Docker image and pushes it to the GitHub Container Registry (GHCR) on pushes to the main branch. You can pull and run this pre-built image.

**Prerequisites:**

1.  **Docker:** Ensure Docker Desktop or Docker Engine is installed and running.
2.  **`.agent.env` File:** Create a file named `.agent.env` in the directory where you will run the `docker run` command. Populate it with necessary environment variables:
    ```dotenv
    # Example .agent.env
    LLM_PROVIDER=openai # Or your chosen provider
    LLM_API_KEY=sk-your_openai_api_key # Replace with your actual key
    AGENT_HOST=0.0.0.0
    AGENT_HTTP_PORT=8080 # Port for API requests
    AGENT_STREAM_PORT=8081 # Port for streaming responses
    # Add other required variables for your LLM provider
    ```
3.  **Knowledge Base (`kb.tar.gz`):** You need a knowledge base archive file (e.g., `kb.tar.gz`). If you don't have one, you can generate it from the sample files by running `bun run kb:use-samples && bun run kb:package` locally in the project first.

**Steps:**

1.  **Log in to GitHub Container Registry:**
    *   Generate a GitHub Personal Access Token (PAT) with the `read:packages` scope. Go to GitHub > Settings > Developer settings > Personal access tokens.
    *   Log in using your terminal:
        ```bash
        docker login ghcr.io -u YOUR_GITHUB_USERNAME -p YOUR_PAT
        ```
        (Replace `YOUR_GITHUB_USERNAME` and `YOUR_PAT`)

2.  **Run the Docker Container:**
    ```bash
    docker run \
      -it \
      --rm \
      --name finclip-agent \
      --env-file .agent.env \
      -p <HOST_HTTP_PORT>:<AGENT_HTTP_PORT> \
      -p <HOST_STREAM_PORT>:<AGENT_STREAM_PORT> \
      -v "/path/to/your/kb.tar.gz":/app/kb.tar.gz \
      ghcr.io/geeksfino/finclip-agent:latest
    ```

    **Replace the placeholders:**
    *   `<HOST_HTTP_PORT>:<AGENT_HTTP_PORT>`: Map a port on your host machine to the `AGENT_HTTP_PORT` defined in your `.agent.env` (e.g., `-p 8080:8080`).
    *   `<HOST_STREAM_PORT>:<AGENT_STREAM_PORT>`: Map a port for the streaming connection, matching `AGENT_STREAM_PORT` (e.g., `-p 8081:8081`).
    *   `"/path/to/your/kb.tar.gz"`: The **absolute path** to your local `kb.tar.gz` file.

3.  **Test the Agent:**
    Once the container is running, you can interact with it using `curl` or other API tools pointed at `http://localhost:<HOST_HTTP_PORT>`. Remember to use the `/createSession` endpoint for the first message and `/chat` for subsequent messages (see [API Usage](#api-usage) section).

#### Running in Debug Mode (`--inspect`)

To run the container with the Node.js/Bun inspector enabled for debugging:

1.  **Expose the Debug Port:** Add `-p 9229:9229` to the `docker run` command.
2.  **Override the Command:** Append the command override to the `docker run` command to include the `--inspect` flag.

```bash
docker run \
  -it \
  --rm \
  --name finclip-agent-debug \
  --env-file .agent.env \
  -p <HOST_HTTP_PORT>:<AGENT_HTTP_PORT> \
  -p <HOST_STREAM_PORT>:<AGENT_STREAM_PORT> \
  -p 9229:9229 \
  -v "/path/to/your/kb.tar.gz":/app/kb.tar.gz \
  ghcr.io/geeksfino/finclip-agent:latest \
  bun --inspect=0.0.0.0:9229 run start 
```

*   Replace ports and paths as described in the standard run command.
*   You can then attach a Node.js debugger (e.g., from VS Code or Chrome DevTools) to `localhost:9229`.

## Building Docker Image Locally
{{ ... }}
