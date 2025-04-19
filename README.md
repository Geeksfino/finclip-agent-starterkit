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

## Running the Agent in Different Environments

Depending on your development or deployment needs, you might run the agent and its NATS dependency in various ways. Here are common configurations:

**Important:** Ensure your LLM provider details (`LLM_PROVIDER_URL`, `LLM_API_KEY`, `LLM_MODEL`) are correctly set, either in the `.agent.env` file for local runs or passed as environment variables (`-e`) for Docker runs.

### 1. Local Development (Agent + NATS Outside Docker)

*   **Description:** Run both the agent and the NATS server directly on your host machine. Ideal for initial development and debugging.
*   **Prerequisites:**
    *   NATS server running locally (e.g., `nats-server -js`).
    *   Bun installed.
    *   Dependencies installed (`bun install`).
*   **NATS Configuration:** Ensure `AGENT_NATS_URL` in `.agent.env` points to your local NATS (default is usually `nats://localhost:4222`).
*   **Command:**
    ```bash
    # Start the agent
    bun start

    # Or start with the inspector UI
    bun start --inspect
    ```

### 2. Agent in Docker, NATS Local (Outside Docker)

*   **Description:** Run the agent inside a Docker container, connecting to a NATS server running directly on the host machine.
*   **Prerequisites:**
    *   Docker installed.
    *   NATS server running locally on the host (`nats-server -js`).
    *   Agent Docker image built (`docker build -t finclip-agent-starterkit .`).
*   **NATS Configuration:** The `AGENT_NATS_URL` needs to point to the host machine from within the Docker container. Use `nats://host.docker.internal:4222` for Docker Desktop (Mac/Windows) or the host's IP address for Docker on Linux.
*   **Command:**
    ```bash
    # Replace NATS_URL if needed. Assumes .agent.env contains other variables.
    # Port mapping (-p) should match AGENT_HTTP_PORT and AGENT_STREAM_PORT in .agent.env
    # Ensure kb.tar.gz and conf/nats_conversation_handler.yml exist locally.
    docker run -it --rm \
      --name finclip-agent \
      --env-file .agent.env \
      -p 5678:5678 \
      -p 5679:5679 \
      -v "$PWD/kb.tar.gz":/app/kb.tar.gz \
      -v "$PWD/conf/nats_conversation_handler.yml":/app/conf/nats_conversation_handler.yml \
      -e AGENT_NATS_URL="nats://host.docker.internal:4222" \
      ghcr.io/geeksfino/finclip-agent:latest
    ```

### 3. Docker Compose (Agent + NATS)

*   **Description:** Use Docker Compose to manage both the agent and NATS services together in containers. Recommended for consistent development and deployment environments.
*   **Prerequisites:**
    *   Docker and Docker Compose installed.
    *   A `docker-compose.yml` file defining the `agent` and `nats` services (you might need to create this based on the provided Dockerfile).
*   **NATS Configuration:** In the `docker-compose.yml`, set the `AGENT_NATS_URL` environment variable for the agent service to point to the NATS service name (e.g., `nats://nats:4222`, assuming the NATS service is named `nats`).
*   **Command:**
    ```bash
    # In the directory with docker-compose.yml
    docker compose up
    # Or run in detached mode
    docker compose up -d
    ```

### 4. Standalone Agent Docker, NATS in Docker Network

*   **Description:** Run the agent in a Docker container and connect to a NATS server *also* running in a separate Docker container, typically within the same user-defined Docker network.
*   **Prerequisites:**
    *   Docker installed.
    *   NATS server running in a container (e.g., `docker run --name my-nats -d -p 4222:4222 nats:latest -js`).
    *   Agent Docker image built (`docker build -t finclip-agent-starterkit .`).
    *   (Optional but recommended) A user-defined Docker network (`docker network create my-network`) with both containers attached.
*   **NATS Configuration:** Set `AGENT_NATS_URL` to point to the NATS container's name or IP address within the Docker network (e.g., `nats://my-nats:4222` if the NATS container is named `my-nats`).
*   **Command:**
    ```bash
    # Replace NATS_URL if needed. Assumes .agent.env contains other variables.
    # Assumes both containers are on 'my-network'.
    # Port mapping (-p) should match AGENT_HTTP_PORT and AGENT_STREAM_PORT in .agent.env
    # Ensure kb.tar.gz and conf/nats_conversation_handler.yml exist locally.
    docker run -it --rm --network=my-network \
      --name finclip-agent \
      --env-file .agent.env \
      -p 5678:5678 \
      -p 5679:5679 \
      -v "$PWD/kb.tar.gz":/app/kb.tar.gz \
      -v "$PWD/conf/nats_conversation_handler.yml":/app/conf/nats_conversation_handler.yml \
      -e AGENT_NATS_URL="nats://my-nats:4222" \
      ghcr.io/geeksfino/finclip-agent:latest
    ```

### 5. Standalone Agent Docker, NATS Remote

*   **Description:** Run the agent in a Docker container connecting to a NATS server hosted elsewhere (e.g., a managed NATS service or another server).
*   **Prerequisites:**
    *   Docker installed.
    *   Agent Docker image built (`docker build -t finclip-agent-starterkit .`).
    *   Connection details (hostname/IP, port, credentials if any) for the remote NATS server.
*   **NATS Configuration:** Set `AGENT_NATS_URL` to the full URL of the remote NATS server (e.g., `nats://user:pass@remote.nats.server.com:4222`).
*   **Command:**
    ```bash
    # Replace NATS_URL. Assumes .agent.env contains other variables.
    # Port mapping (-p) should match AGENT_HTTP_PORT and AGENT_STREAM_PORT in .agent.env
    # Ensure kb.tar.gz and conf/nats_conversation_handler.yml exist locally.
    docker run -it --rm \
      --name finclip-agent \
      --env-file .agent.env \
      -p 5678:5678 \
      -p 5679:5679 \
      -v "$PWD/kb.tar.gz":/app/kb.tar.gz \
      -v "$PWD/conf/nats_conversation_handler.yml":/app/conf/nats_conversation_handler.yml \
      -e AGENT_NATS_URL="nats://<user>:<password>@<remote_nats_host>:<remote_nats_port>" \
      ghcr.io/geeksfino/finclip-agent:latest
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
    LLM_API_KEY=your_api_key_here        # Replace with your actual API key
    LLM_PROVIDER=openai # Or your chosen provider
    AGENT_HOST=0.0.0.0
    AGENT_HTTP_PORT=5678 # Port for API requests
    AGENT_STREAM_PORT=5679 # Port for streaming responses
    # Add other required variables for your LLM provider
    ```
3.  **Knowledge Base (`kb.tar.gz`):** You need a knowledge base archive file (e.g., `kb.tar.gz`). If you don't have one, you can generate it from the sample files by running `bun run kb:use-samples && bun run kb:package` locally in the project first.

### About NATS Integration (Optional)

The agent includes an optional NATS Conversation Handler. When enabled (via the agent's internal `nats_conversation_handler.yml` configuration), this handler publishes conversation segments (like user messages and agent responses) to a NATS subject (e.g., `conversation.segments`). This allows external services or monitoring agents to subscribe to these messages for purposes such as real-time compliance checking, logging, analytics, or triggering downstream signaling events based on conversation content. If you need to monitor agent interactions, configuring the NATS connection is necessary.

### Configuring NATS Connection (Optional)

By default, the agent expects the NATS server (if enabled in its internal configuration) to be at `nats://localhost:4222`. This works for local development but not typically inside Docker.

*   **NATS on Docker Host:** If your NATS server is running directly on the machine hosting Docker:
    ```dotenv
    AGENT_NATS_URL=nats://host.docker.internal:4222
    ```
    *Note: `host.docker.internal` resolves to the host's internal IP from within the container on Docker Desktop (Mac/Windows). For Linux, you might need to use `--add-host=host.docker.internal:host-gateway` in your `docker run` command or use the host's specific network IP.* 

*   **NATS in Another Docker Container:** If NATS is running in another container on the same Docker network (e.g., via Docker Compose):
    ```dotenv
    AGENT_NATS_URL=nats://<nats-service-name>:4222
    ```
    (Replace `<nats-service-name>` with the service name defined in your `docker-compose.yml` or the container name if on the same user-defined bridge network).

*   **Remote NATS Server:** If NATS is running on a different machine accessible over the network:
    ```dotenv
    AGENT_NATS_URL=nats://<remote-nats-ip-or-hostname>:4222
    ```

If `AGENT_NATS_URL` is *not* set in `.agent.env`, the agent will attempt to use the default (`nats://localhost:4222`), which will likely fail unless NATS is running *inside* the same container.

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
      -v "/path/to/your/conf/nats_conversation_handler.yml":/app/conf/nats_conversation_handler.yml \
      ghcr.io/geeksfino/finclip-agent:latest
    ```

    **Replace the placeholders:**
    *   `<HOST_HTTP_PORT>:<AGENT_HTTP_PORT>`: Map a port on your host machine to the `AGENT_HTTP_PORT` defined in your `.agent.env` (e.g., `-p 5678:5678`).
    *   `<HOST_STREAM_PORT>:<AGENT_STREAM_PORT>`: Map a port for the streaming connection, matching `AGENT_STREAM_PORT` (e.g., `-p 5679:5679`).
    *   `"/path/to/your/kb.tar.gz"`: The **absolute path** to your local `kb.tar.gz` file.
    *   `"/path/to/your/conf/nats_conversation_handler.yml"`: The **absolute path** to your local `nats_conversation_handler.yml` file.

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
  -v "/path/to/your/conf/nats_conversation_handler.yml":/app/conf/nats_conversation_handler.yml \
  ghcr.io/geeksfino/finclip-agent:latest \
  bun --inspect=0.0.0.0:9229 run start 
```

*   Replace ports and paths as described in the standard run command.
*   You can then attach a Node.js debugger (e.g., from VS Code or Chrome DevTools) to `localhost:9229`.

## Building Docker Image Locally
{{ ... }}
