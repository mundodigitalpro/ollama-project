#!/bin/bash

echo "=== Limpiando Ollama Project ==="

echo -e "\n1. Deteniendo contenedores..."
docker-compose down -v

echo -e "\n2. Eliminando imágenes específicas del proyecto..."
docker rmi ollama-project-python-client 2>/dev/null
docker rmi ollama-project-ollama 2>/dev/null

echo -e "\n3. Limpiando imágenes no utilizadas..."
docker system prune -f

echo -e "\n4. Eliminando volumen de datos..."
docker volume rm ollama_data 2>/dev/null

echo -e "\n5. Verificando contenedores activos..."
docker ps -a | grep ollama

echo -e "\n=== Limpieza completada ==="
echo "[Puedes volver a iniciar el servicio con ./run.sh]" 