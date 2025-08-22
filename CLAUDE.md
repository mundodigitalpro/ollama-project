# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Ollama Docker Project that provides a containerized environment for running Large Language Models (LLMs) using Ollama with an interactive Python chat interface. The project consists of a Docker-composed service with an Ollama server and a Python client for chat interaction.

## Quick Start Commands

### Windows
```batch
# Start the service with interactive model selection
run.bat

# Clean up all containers, images, and volumes
clean.bat
```

### Linux/MacOS
```bash
# Make scripts executable (first time only)
chmod +x run.sh clean.sh

# Start the service with interactive model selection
./run.sh

# Clean up environment
./clean.sh
```

### Interactive Model Selection

When starting the service for the first time or rebuilding containers, users are prompted to select a model:

1. **Pre-configured options (1-7)**: Quick selection of popular models
2. **Custom model names**: Users can type any model name available in Ollama registry
3. **Examples of custom models**: `deepseek-r1:1.5b`, `phi3:mini`, `codeqwen:7b`

The selected model is automatically downloaded and configured during container startup.

## Architecture

The project uses a multi-container Docker architecture:

1. **Ollama Service (`ollama`)**: 
   - Runs on port 11434
   - Uses `ollama/ollama:latest` base image
   - Automatically downloads the user-selected model on startup
   - Includes health checks and retry logic with 5 retry attempts
   - Persists data in `ollama_data` volume
   - Falls back to `tinyllama` if no model is specified

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
- **Interactive model selection at startup**: Choose from pre-configured options or specify custom models
- **Automatic model downloading**: Downloads selected model during container startup with progress display
- **Robust error handling**: 5-retry mechanism with 60-second delays for model downloads
- **Support for any Ollama model**: Pre-configured options include tinyllama, llama2, codellama, mistral, orca-mini, qwen2:1.5b, gemma:2b
- **Custom model support**: Users can specify any model from the Ollama registry (e.g., deepseek-r1:1.5b, phi3:mini)

### Docker Configuration
- **Main Dockerfile**: Sets up Ollama service with startup script
- **Dockerfile.client**: Python environment with dependencies
- **docker-compose.yml**: Orchestrates both services with proper networking

## Development Workflow

### Running the Application
1. Use `run.bat` (Windows) or `./run.sh` (Linux/MacOS) to start
2. The script will:
   - Check for existing Docker resources and offer cleanup/reuse options
   - **Prompt for model selection** (when building fresh containers)
   - Build containers with the selected model as build argument
   - Start Ollama service with automatic model download
   - Wait for service readiness with health checks
   - Launch interactive Python client

### Model Selection Process
When running fresh builds, the system presents:
- **Menu of 7 pre-configured models** with descriptions
- **Option to enter custom model names** for any Ollama registry model
- **Validation and confirmation** of the selected model
- **Automatic environment variable passing** to Docker containers

### Model Management
- **Startup selection**: Interactive model selection during container build
- **Pre-configured models**: 7 popular models with quick selection (1-7)
- **Custom models**: Support for any model in Ollama registry
- **Fallback model**: `tinyllama` used if no model specified
- **Runtime switching**: Type "cambiar modelo" in chat to switch models
- **Persistent storage**: Downloaded models stored in `ollama_data` volume

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

### Model Selection Issues
- **Error: "accepts 1 arg(s), received 0"**: Fixed in current version - run clean.bat/clean.sh and rebuild
- **Custom model not working**: Ensure exact model name from Ollama registry (e.g., `deepseek-r1:1.5b`)
- **Model selection ignored**: Choose "Clean and rebuild" option when prompted about existing resources

### Common Issues  
- Ensure Docker Desktop is running before starting
- First run may take several minutes while downloading models
- Large models (like llama2) require significant RAM and download time
- If connection fails, verify port 11434 is available
- Use logs: `docker-compose logs -f ollama`
- For custom models, verify availability at https://ollama.com/library

### Development Notes
- The project is primarily in Spanish (interface text, documentation)
- Logging configured at INFO level with timestamps
- Comprehensive error handling with user-friendly messages
- Supports interruption with Ctrl+C