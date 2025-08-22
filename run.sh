#!/bin/bash

# Colores para los mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Iniciando Ollama Chat ===${NC}"

# Detener contenedores previos
echo -e "${GREEN}Limpiando ambiente anterior...${NC}"
docker-compose down -v

# Construir las imágenes
echo -e "${GREEN}Construyendo contenedores...${NC}"
docker-compose build --no-cache

# Iniciar el servicio Ollama en segundo plano
echo -e "${GREEN}Iniciando servicio Ollama...${NC}"
docker-compose up -d ollama

# Esperar a que el servicio Ollama esté listo
echo -e "${GREEN}Esperando a que el servicio esté listo...${NC}"
while ! curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Esperando..."
    sleep 5
done

# Iniciar el cliente Python en modo interactivo
echo -e "${BLUE}¡Servicio listo! Iniciando chat...${NC}"
docker-compose run --rm python-client 