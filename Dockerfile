FROM neuml/txtai-cpu:latest

# Set working directory
WORKDIR /app

# Install necessary system packages (curl, unzip, git for Bun install)
# Assume base image has apt and needed basics, just ensure these helpers
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
ENV PATH="/root/.bun/bin:${PATH}"

# Install Bun dependencies first
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# ---> MODIFIED: Install required Python dependencies <---
# kb-mcp-server and its deps might not be in the base image or discoverable
# huggingface_hub is needed for model downloads
RUN pip install sentence-transformers huggingface_hub kb-mcp-server

# Copy the rest of the application code
COPY . .

# Set up environment
RUN bun setup:env

# Build knowledge base (if not already built)
RUN if [ ! -f kb.tar.gz ]; then bun run kb:use-samples && bun run kb:package; fi

# Expose the default port
EXPOSE 3000

# Command to run the application
CMD ["bun", "start"]
