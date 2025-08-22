#!/bin/bash

# Colores para los mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para seleccionar modelo
select_model() {
    echo
    echo -e "${YELLOW}==== Selección de Modelo por Defecto ====${NC}"
    echo
    echo "Modelos recomendados:"
    echo "[1] tinyllama    - Modelo pequeño y rápido (recomendado para pruebas)"
    echo "[2] llama2       - Modelo equilibrado"
    echo "[3] codellama    - Especializado en código"  
    echo "[4] mistral      - Modelo general de buena calidad"
    echo "[5] orca-mini    - Modelo compacto pero potente"
    echo "[6] qwen2:1.5b   - Modelo ligero multiidioma"
    echo "[7] gemma:2b     - Modelo compacto de Google"
    echo
    echo "También puedes escribir el nombre de cualquier otro modelo disponible."
    echo
    
    while true; do
        read -p "Selecciona un modelo (1-7 o escribe el nombre): " choice
        case $choice in
            1) SELECTED_MODEL="tinyllama"; break;;
            2) SELECTED_MODEL="llama2"; break;;
            3) SELECTED_MODEL="codellama"; break;;
            4) SELECTED_MODEL="mistral"; break;;
            5) SELECTED_MODEL="orca-mini"; break;;
            6) SELECTED_MODEL="qwen2:1.5b"; break;;
            7) SELECTED_MODEL="gemma:2b"; break;;
            *) 
                if [[ -n "$choice" ]]; then
                    SELECTED_MODEL="$choice"
                    break
                else
                    echo "Por favor, selecciona una opción válida."
                fi;;
        esac
    done
    echo -e "${GREEN}✅ Modelo seleccionado: $SELECTED_MODEL${NC}"
    echo
}

echo -e "${BLUE}=== Iniciando Ollama Chat ===${NC}"
echo

echo -e "${YELLOW}Verificando recursos Docker existentes...${NC}"

# Verificar contenedores existentes
CONTAINERS_EXIST=$(docker ps -a --filter "name=ollama" --format "{{.Names}}" 2>/dev/null | wc -l)

# Verificar imágenes existentes
IMAGES_EXIST=$(docker images --filter "reference=ollama-project*" --format "{{.Repository}}" 2>/dev/null | wc -l)

# Verificar volumen existente
VOLUME_EXISTS=$(docker volume ls --filter "name=ollama_data" --format "{{.Name}}" 2>/dev/null | wc -l)

# Verificar red existente
NETWORK_EXISTS=$(docker network ls --filter "name=ollama-network" --format "{{.Name}}" 2>/dev/null | wc -l)

echo
if [ $CONTAINERS_EXIST -gt 0 ]; then echo -e "${GREEN}✅ Contenedores existentes encontrados${NC}"; fi
if [ $IMAGES_EXIST -gt 0 ]; then echo -e "${GREEN}✅ Imágenes del proyecto encontradas${NC}"; fi
if [ $VOLUME_EXISTS -gt 0 ]; then echo -e "${GREEN}✅ Volumen ollama_data encontrado${NC}"; fi
if [ $NETWORK_EXISTS -gt 0 ]; then echo -e "${GREEN}✅ Red ollama-network encontrada${NC}"; fi

if [ $CONTAINERS_EXIST -gt 0 ]; then
    echo
    echo -e "${YELLOW}Se encontraron recursos existentes del proyecto.${NC}"
    echo
    echo "Opciones:"
    echo "[1] Limpiar todo y empezar desde cero (recomendado para actualizaciones)"
    echo "[2] Usar recursos existentes (más rápido si no hay cambios)"
    echo "[3] Salir sin hacer nada"
    echo
    read -p "Selecciona una opción (1, 2, o 3): " choice
    
    case $choice in
        1)
            echo
            echo -e "${GREEN}Limpiando ambiente anterior...${NC}"
            docker-compose down -v
            echo -e "${GREEN}Eliminando imágenes específicas del proyecto...${NC}"
            docker rmi ollama-project-python-client 2>/dev/null
            docker rmi ollama-project-ollama 2>/dev/null
            build_fresh=true
            ;;
        2)
            echo
            echo -e "${GREEN}Usando recursos existentes...${NC}"
            build_fresh=false
            ;;
        3)
            echo
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Usando recursos existentes por defecto..."
            build_fresh=false
            ;;
    esac
else
    echo
    echo -e "${GREEN}No se encontraron recursos existentes. Iniciando instalación limpia...${NC}"
    build_fresh=true
fi

if [ "$build_fresh" = true ]; then
    select_model
    echo -e "${GREEN}Construyendo contenedores con modelo: $SELECTED_MODEL...${NC}"
    export OLLAMA_DEFAULT_MODEL="$SELECTED_MODEL"
    docker-compose build --no-cache --build-arg OLLAMA_DEFAULT_MODEL="$SELECTED_MODEL"
fi

# Verificar si los servicios ya están ejecutándose
if [ "$build_fresh" = false ]; then
    SERVICE_RUNNING=$(docker-compose ps ollama | grep "Up" | wc -l)
    if [ $SERVICE_RUNNING -eq 0 ]; then
        echo
        echo -e "${GREEN}Los servicios no están ejecutándose. Iniciándolos...${NC}"
        docker-compose up -d ollama
    else
        echo
        echo -e "${GREEN}✅ Los servicios ya están ejecutándose!${NC}"
    fi
else
    # Iniciar el servicio Ollama en segundo plano
    echo -e "${GREEN}Iniciando servicio Ollama...${NC}"
    docker-compose up -d ollama
fi

# Esperar a que el servicio Ollama esté listo
echo -e "${GREEN}Esperando a que el servicio esté listo...${NC}"
while ! curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Esperando..."
    sleep 5
done

# Iniciar el cliente Python en modo interactivo
echo -e "${BLUE}¡Servicio listo! Iniciando chat...${NC}"
docker-compose run --rm python-client 