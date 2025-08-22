#!/bin/bash

echo "=== Limpiando Ollama Project ==="

echo -e "\n1. Deteniendo contenedores..."
docker-compose down -v

echo -e "\n2. Limpiando imágenes no utilizadas..."
docker system prune -f

echo -e "\n3. Eliminando volumen de datos..."
docker volume rm ollama_data

echo -e "\n4. Verificando contenedores activos..."
docker ps -a | grep ollama

echo -e "\n=== Limpieza completada ==="
echo "[Puedes volver a iniciar el servicio con ./run.sh]" 