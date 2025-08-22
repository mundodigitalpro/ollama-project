@echo off
echo === Limpiando Ollama Project ===

echo.
echo 1. Deteniendo contenedores...
docker-compose down -v

echo.
echo 2. Eliminando imágenes específicas del proyecto...
docker rmi ollama-project-python-client 2>nul
docker rmi ollama-project-ollama 2>nul

echo.
echo 3. Limpiando imágenes no utilizadas...
docker system prune -f

echo.
echo 4. Eliminando volumen de datos...
docker volume rm ollama_data 2>nul

echo.
echo 5. Verificando contenedores activos...
docker ps -a | findstr "ollama"

echo.
echo === Limpieza completada ===
echo [Puedes volver a iniciar el servicio con run.bat] 