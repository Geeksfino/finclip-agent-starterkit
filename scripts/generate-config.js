#!/usr/bin/env bun

import fs from 'fs';
import path from 'path';
import { spawn } from 'child_process';

console.log('🔧 Generating MCP configuration...');

// Get the project directory
const projectDir = process.cwd();
const confDir = path.join(projectDir, 'conf');
const embeddingsPath = path.join(projectDir, 'kb.tar.gz');

// Ensure conf directory exists
if (!fs.existsSync(confDir)) {
  fs.mkdirSync(confDir, { recursive: true });
}

// Find the path to kb-mcp-server in the virtual environment
const findKbMcpServerPath = () => {
  return new Promise((resolve, reject) => {
    // ---> MODIFIED: Determine paths and script based on IN_DOCKER <---
    const isInDocker = process.env.IN_DOCKER === 'true';
    const pythonPath = isInDocker ? 'python3' : path.join(projectDir, '.venv', 'bin', 'python');
    console.log(`ℹ️ Using Python path for finding kb-mcp-server: ${pythonPath}`);

    const pythonScriptDocker = `
import sys
import shutil
path = shutil.which('kb-mcp-server')
if path:
    print(path)
else:
    print("ERROR: kb-mcp-server not found in PATH")
    sys.exit(1)
    `;

    const pythonScriptLocal = `
import os
import sys
# sys.executable should be /app/.venv/bin/python
bin_dir = os.path.dirname(sys.executable)
kb_mcp_server_path = os.path.join(bin_dir, 'kb-mcp-server')
if os.path.exists(kb_mcp_server_path):
    print(kb_mcp_server_path)
else:
    print(f"ERROR: kb-mcp-server not found in {bin_dir}")
    sys.exit(1)
    `;

    const pythonScript = isInDocker ? pythonScriptDocker : pythonScriptLocal;

    // ---> MODIFIED: Renamed 'process' variable to 'pyProcess' to avoid shadowing global <---
    const pyProcess = spawn(pythonPath, [
      '-c',
      pythonScript
    ]);

    let output = '';
    pyProcess.stdout.on('data', (data) => {
      output += data.toString();
    });

    pyProcess.stderr.on('data', (data) => {
      console.error(data.toString().trim());
    });

    pyProcess.on('close', (code) => {
      if (code === 0 && !output.includes('ERROR')) {
        resolve(output.trim());
      } else {
        reject(new Error('Failed to find kb-mcp-server path'));
      }
    });
  });
};

// Generate the configuration file
async function generateConfig() {
  try {
    // Get the path to kb-mcp-server
    const kbMcpServerPath = await findKbMcpServerPath();
    console.log(`📍 Found kb-mcp-server at: ${kbMcpServerPath}`);
    
    // Check if embeddings file exists
    if (!fs.existsSync(embeddingsPath)) {
      console.warn(`⚠️ Warning: Embeddings file not found at ${embeddingsPath}`);
      console.warn('⚠️ You will need to provide the correct embeddings file later');
    } else {
      console.log(`📍 Using embeddings file: ${embeddingsPath}`);
    }
    
    // Create the configuration object
    const config = {
      "mcpServers": {
        "finclip-rag-server": {
          "command": kbMcpServerPath,
          "args": [
            "--embeddings",
            embeddingsPath,
            "--enable-causal-boost"
          ],
          "cwd": projectDir
        }
      }
    };
    
    // Write the configuration to file
    const configPath = path.join(confDir, 'preproc-mcp.json');
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    
    console.log(`✅ Configuration generated at: ${configPath}`);

    console.log('Configuration generation complete.');
    
  } catch (error) {
    console.error('❌ Error generating configuration:', error.message);
    process.exit(1);
  }
}

generateConfig();
