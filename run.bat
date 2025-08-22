@echo off
setlocal enabledelayedexpansion
echo === Iniciando Ollama Chat ===
echo.

echo Verificando recursos Docker existentes...

rem Verificar contenedores existentes
docker ps -a --filter "name=ollama" --format "table {{.Names}}\t{{.Status}}" > temp_containers.txt 2>nul
set CONTAINERS_EXIST=0
for /f "skip=1" %%i in (temp_containers.txt) do set CONTAINERS_EXIST=1
if exist temp_containers.txt del temp_containers.txt

rem Verificar imágenes existentes
docker images --filter "reference=ollama-project*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" > temp_images.txt 2>nul
set IMAGES_EXIST=0
for /f "skip=1" %%i in (temp_images.txt) do set IMAGES_EXIST=1
if exist temp_images.txt del temp_images.txt

rem Verificar volumen existente
docker volume ls --filter "name=ollama_data" --format "table {{.Name}}" > temp_volumes.txt 2>nul
set VOLUME_EXISTS=0
for /f "skip=1" %%i in (temp_volumes.txt) do set VOLUME_EXISTS=1
if exist temp_volumes.txt del temp_volumes.txt

rem Verificar red existente
docker network ls --filter "name=ollama-network" --format "table {{.Name}}" > temp_networks.txt 2>nul
set NETWORK_EXISTS=0
for /f "skip=1" %%i in (temp_networks.txt) do set NETWORK_EXISTS=1
if exist temp_networks.txt del temp_networks.txt

echo.
if %CONTAINERS_EXIST%==1 echo ✅ Contenedores existentes encontrados
if %IMAGES_EXIST%==1 echo ✅ Imágenes del proyecto encontradas
if %VOLUME_EXISTS%==1 echo ✅ Volumen ollama_data encontrado
if %NETWORK_EXISTS%==1 echo ✅ Red ollama-network encontrada

if %CONTAINERS_EXIST%==1 (
    echo.
    echo Se encontraron recursos existentes del proyecto.
    echo.
    echo Opciones:
    echo [1] Limpiar todo y empezar desde cero ^(recomendado para actualizaciones^)
    echo [2] Usar recursos existentes ^(más rápido si no hay cambios^)
    echo [3] Salir sin hacer nada
    echo.
    set /p choice="Selecciona una opción (1, 2, o 3): "
    
    if "!choice!"=="1" (
        echo.
        echo Limpiando ambiente anterior...
        docker-compose down -v
        echo Eliminando imágenes específicas del proyecto...
        docker rmi ollama-project-python-client 2>nul
        docker rmi ollama-project-ollama 2>nul
        goto build_fresh
    )
    if "!choice!"=="2" (
        echo.
        echo Usando recursos existentes...
        goto check_running
    )
    if "!choice!"=="3" (
        echo.
        echo Saliendo...
        exit /b 0
    )
    echo Opción no válida. Usando recursos existentes por defecto...
    goto check_running
) else (
    echo.
    echo No se encontraron recursos existentes. Iniciando instalación limpia...
    goto build_fresh
)

:build_fresh

call :select_model
echo Construyendo contenedores con modelo: !SELECTED_MODEL!...
set OLLAMA_DEFAULT_MODEL=!SELECTED_MODEL!
docker-compose build --no-cache --build-arg OLLAMA_DEFAULT_MODEL=!SELECTED_MODEL!

:start_services
echo Iniciando servicio Ollama...
docker-compose up -d ollama
goto service_ready

:check_running
rem Verificar si los servicios ya están ejecutándose
docker-compose ps ollama | findstr "Up" > nul 2>&1
if errorlevel 1 (
    echo.
    echo Los servicios no están ejecutándose. Iniciándolos...
    docker-compose up -d ollama
) else (
    echo.
    echo ✅ Los servicios ya están ejecutándose!
)

:service_ready

echo.
echo Preparando el servicio Ollama...
echo [Esto puede tomar varios minutos en la primera ejecución]
echo.
echo Progreso:
echo - Iniciando servicio
echo - Descargando modelo
echo - Configurando ambiente
echo.
echo Mostrando logs en tiempo real:
echo ----------------------------------------

rem Mostrar logs en segundo plano
start cmd /c "docker-compose logs -f ollama"

:check_service
echo.
echo Verificando servicio...
curl -s http://localhost:11434/api/tags > nul 2>&1
if errorlevel 1 (
    echo [Esperando que el servicio esté listo...]
    timeout /t 5 /nobreak > nul
    goto check_service
)

echo.
echo ✅ Servicio listo! Iniciando chat...
echo ----------------------------------------
docker-compose run --rm --service-ports python-client

goto :eof

:select_model
echo.
echo ==== Selección de Modelo por Defecto ====
echo.
echo Modelos recomendados:
echo [1] tinyllama    - Modelo pequeño y rápido ^(recomendado para pruebas^)
echo [2] llama2       - Modelo equilibrado
echo [3] codellama    - Especializado en código
echo [4] mistral      - Modelo general de buena calidad
echo [5] orca-mini    - Modelo compacto pero potente
echo [6] qwen2:1.5b   - Modelo ligero multiidioma
echo [7] gemma:2b     - Modelo compacto de Google
echo.
echo También puedes escribir el nombre de cualquier otro modelo disponible.
echo.

:model_loop
set /p choice="Selecciona un modelo (1-7 o escribe el nombre): "

if "!choice!"=="1" set SELECTED_MODEL=tinyllama && goto model_selected
if "!choice!"=="2" set SELECTED_MODEL=llama2 && goto model_selected
if "!choice!"=="3" set SELECTED_MODEL=codellama && goto model_selected
if "!choice!"=="4" set SELECTED_MODEL=mistral && goto model_selected
if "!choice!"=="5" set SELECTED_MODEL=orca-mini && goto model_selected
if "!choice!"=="6" set SELECTED_MODEL=qwen2:1.5b && goto model_selected
if "!choice!"=="7" set SELECTED_MODEL=gemma:2b && goto model_selected

if not "!choice!"=="" (
    set SELECTED_MODEL=!choice!
    goto model_selected
)

echo Por favor, selecciona una opción válida.
goto model_loop

:model_selected
echo ✅ Modelo seleccionado: !SELECTED_MODEL!
echo.
goto :eof

:error
echo.
echo ❌ Ocurrió un error al iniciar el servicio
echo Por favor, verifica que Docker Desktop esté en ejecución
exit /b 1