@echo off
echo === Limpiando Ollama Project ===

echo.
echo 1. Deteniendo contenedores...
docker-compose down -v

echo.
echo 2. Limpiando imágenes no utilizadas...
docker system prune -f

echo.
echo 3. Eliminando volumen de datos...
docker volume rm ollama_data

echo.
echo 4. Verificando contenedores activos...
docker ps -a | findstr "ollama"

echo.
echo === Limpieza completada ===
echo [Puedes volver a iniciar el servicio con run.bat] 