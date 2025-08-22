@echo off
echo === Iniciando Ollama Chat ===

echo Limpiando ambiente anterior...
docker-compose down -v

echo Construyendo contenedores...
docker-compose build --no-cache

echo Iniciando servicio Ollama...
docker-compose up -d ollama

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

:error
echo.
echo ❌ Ocurrió un error al iniciar el servicio
echo Por favor, verifica que Docker Desktop esté en ejecución
exit /b 1