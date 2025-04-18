FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    build-essential \
    gcc \
    g++ \
    cmake \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
ENV PATH="/root/.bun/bin:${PATH}"

# ---> ADDED: Install uv explicitly <---
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# Add the uv installation path to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Install Bun dependencies first
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# ---> MODIFIED: Create Python virtual environment using uv <---
RUN /root/.local/bin/uv venv .venv --python python3

# ---> MODIFIED: Install Python dependencies conditionally setting ARM flags <---
# Declare TARGETPLATFORM as an argument provided by buildx
ARG TARGETPLATFORM
# Use the Python from the created venv
# Set ARM flags only if building for linux/arm64
RUN CFLAGS_FOR_ARM="$(if [ "$TARGETPLATFORM" = "linux/arm64" ]; then echo -march=armv8-a+dotprod; fi)" \
    CXXFLAGS_FOR_ARM="$(if [ "$TARGETPLATFORM" = "linux/arm64" ]; then echo -march=armv8-a+dotprod; fi)" \
    CFLAGS="$CFLAGS_FOR_ARM" CXXFLAGS="$CXXFLAGS_FOR_ARM" \
    /root/.local/bin/uv pip install -vv --no-cache-dir kb-mcp-server sentence-transformers -p /app/.venv/bin/python3

# Add the virtual environment's bin directory to the PATH (still useful)
ENV PATH="/app/.venv/bin:${PATH}"

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
