FROM ollama/ollama:latest

EXPOSE 11434

# Argument para el modelo por defecto
ARG OLLAMA_DEFAULT_MODEL=tinyllama

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl procps && \
    rm -rf /var/lib/apt/lists/*

# Set environment variable from build arg
ENV MODEL_NAME=${OLLAMA_DEFAULT_MODEL:-tinyllama}

# Create a startup script
COPY <<'EOF' /start.sh
#!/bin/bash

MAX_RETRIES=5
RETRY_DELAY=60

# Obtener modelo de la variable de entorno
MODEL_NAME="${MODEL_NAME:-tinyllama}"

echo "Starting Ollama service..."
ollama serve &
OLLAMA_PID=$!

# Function to check if ollama is running
check_ollama() {
    if ! kill -0 $OLLAMA_PID 2>/dev/null; then
        echo "Ollama process died unexpectedly"
        exit 1
    fi
}

# Wait for service to be ready
echo "Waiting for Ollama service to be ready..."
for i in {1..60}; do
    if curl -s http://localhost:11434/api/tags >/dev/null; then
        echo "Ollama service is ready"
        break
    fi
    check_ollama
    sleep 2
done

# Pull the model
for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $i/$MAX_RETRIES: Pulling $MODEL_NAME model..."
    if timeout 300 ollama pull $MODEL_NAME; then
        echo "Model pulled successfully"
        break
    else
        check_ollama
        if [ $i -lt $MAX_RETRIES ]; then
            echo "Failed to pull model. Waiting ${RETRY_DELAY}s before retry..."
            sleep $RETRY_DELAY
        else
            echo "Failed to pull model after $MAX_RETRIES attempts"
            exit 1
        fi
    fi
done

echo "Setup complete. Keeping service running..."
wait $OLLAMA_PID
EOF

RUN chmod +x /start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:11434/api/tags || exit 1

ENTRYPOINT ["/start.sh"]
