FROM neuml/txtai-cpu:latest

# Set working directory
WORKDIR /app

# Install system dependencies (helpers for bun/uv install)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
ENV PATH="/root/.bun/bin:${PATH}"

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# Add the uv installation path to PATH
ENV PATH="/root/.local/bin:${PATH}"

# ---> ADDED: Install missing Python packages globally using uv <---
RUN uv pip install --system huggingface_hub kb-mcp-server

# Install Bun dependencies first
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# ---> ADDED: Set IN_DOCKER flag for setup script <---
ENV IN_DOCKER=true

# ---> MODIFIED: Run setup script (will skip venv/pip due to IN_DOCKER) <---
RUN bun setup:env

# Build knowledge base (if not already built)
RUN if [ ! -f kb.tar.gz ]; then bun run kb:use-samples && bun run kb:package; fi

# Expose the default port
EXPOSE 3000

# Command to run the application
CMD ["bun", "start"]
