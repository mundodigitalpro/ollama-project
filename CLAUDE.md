# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Ollama Docker Project that provides a containerized environment for running Large Language Models (LLMs) using Ollama with an interactive Python chat interface. The project consists of a Docker-composed service with an Ollama server and a Python client for chat interaction.

## Quick Start Commands

### Windows
```batch
# Start the service (builds containers, starts Ollama, downloads model)
run.bat

# Clean up all containers, images, and volumes
clean.bat
```

### Linux/MacOS
```bash
# Make scripts executable (first time only)
chmod +x run.sh clean.sh

# Start the service
./run.sh

# Clean up environment
./clean.sh
```

## Architecture

The project uses a multi-container Docker architecture:

1. **Ollama Service (`ollama`)**: 
   - Runs on port 11434
   - Uses `ollama/ollama:latest` base image
   - Automatically pulls the `tinyllama` model on startup
   - Includes health checks and retry logic
   - Persists data in `ollama_data` volume

2. **Python Client (`python-client`)**:
   - Interactive chat interface using Python 3.9
   - Located in `example.py`
   - Uses `network_mode: "host"` for communication
   - Depends on Ollama service health

## Core Components

### Python Chat Client (`example.py`)
- **OllamaAPI Class**: Main interface for Ollama communication
  - Service health checking with timeout
  - Model selection and downloading
  - Chat interaction with retry logic
  - Error handling and logging

### Key Features
- Interactive model selection from available models
- Automatic model downloading with progress display
- Robust error handling and retry mechanisms
- Support for multiple models (llama2, codellama, mistral, tinyllama, orca-mini)

### Docker Configuration
- **Main Dockerfile**: Sets up Ollama service with startup script
- **Dockerfile.client**: Python environment with dependencies
- **docker-compose.yml**: Orchestrates both services with proper networking

## Development Workflow

### Running the Application
1. Use `run.bat` (Windows) or `./run.sh` (Linux/MacOS) to start
2. The script will:
   - Clean previous environment
   - Build containers from scratch
   - Start Ollama service
   - Wait for service readiness
   - Launch interactive Python client

### Model Management
- Default model: `tinyllama` (downloaded automatically)
- Available models: llama2, codellama, mistral, orca-mini
- Models can be selected interactively or downloaded on-demand
- Type "cambiar modelo" in chat to switch models

### Cleanup
- Use `clean.bat`/`clean.sh` to remove all containers, images, and volumes
- This ensures a fresh start for the next run

## Dependencies

### Python Dependencies (`requirements.txt`)
- `requests==2.31.0`: HTTP client for API communication
- `typing-extensions==4.8.0`: Type hints support
- `python-dotenv==1.0.0`: Environment variable management

### Docker Requirements
- Docker Desktop (Windows) or Docker Engine (Linux/MacOS)
- Docker Compose
- curl (for health checks)

## Service Configuration

### Ollama Service Settings
- Memory limit: 8GB (with 4GB reserved)
- CPU limit: 4 cores
- Health check interval: 30 seconds
- Startup timeout: 120 seconds
- Port: 11434

### Network Configuration
- Uses bridge network `ollama-network`
- Python client uses host networking for communication
- Volume persistence for model data

## Troubleshooting

### Common Issues
- Ensure Docker Desktop is running before starting
- First run may take several minutes while downloading models
- If connection fails, verify port 11434 is available
- Use logs: `docker-compose logs -f ollama`

### Development Notes
- The project is primarily in Spanish (interface text, documentation)
- Logging configured at INFO level with timestamps
- Comprehensive error handling with user-friendly messages
- Supports interruption with Ctrl+C