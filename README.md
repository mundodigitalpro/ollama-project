# Ollama Docker Project

Este proyecto configura un entorno Docker para ejecutar LLMs usando Ollama, con una interfaz de chat interactiva.

## Prerrequisitos

- Docker Desktop (Windows) o Docker Engine (Linux/MacOS)
- Docker Compose
- curl (incluido en Windows 10/11 por defecto)

## Inicio Rápido

### En Windows:
1. Ejecutar el script:
   ```batch
   run.bat
   ```

### En Linux/MacOS:
1. Dar permisos de ejecución al script:
   ```bash
   chmod +x run.sh
   ```

2. Ejecutar el script:
   ```bash
   ./run.sh
   ```

## Uso

- Escribe tus preguntas y presiona Enter
- Escribe 'salir' (o 'exit' o 'quit') para terminar
- Escribe 'cambiar modelo' para seleccionar otro modelo

## Limpieza

Después de usar el servicio, puedes limpiar todo el entorno:

### En Windows:
```batch
clean.bat
```

### En Linux/MacOS:
```bash
./clean.sh
```

Esto eliminará:
- Contenedores detenidos
- Imágenes no utilizadas
- Volúmenes de datos
- Redes no utilizadas

## Modelos Disponibles

El proyecto usa por defecto el modelo 'orca-mini'. Otros modelos disponibles:
- llama2
- mistral
- codellama

## Notas

- El servicio usa el puerto 11434 por defecto
- Los modelos y datos se persisten en el volumen 'ollama_data'
- La primera ejecución puede tardar varios minutos mientras descarga el modelo
- En Windows, asegúrate de que Docker Desktop esté en ejecución antes de iniciar el script
- Si usas Git Bash en Windows, puedes usar también el script run.sh

## Solución de Problemas

### Windows
- Si el script no funciona, asegúrate de que Docker Desktop esté en ejecución
- Si curl no está disponible, puedes instalarlo desde la Microsoft Store
- Si tienes problemas con los permisos, ejecuta el script como administrador

### Linux/MacOS
- Si el script no tiene permisos de ejecución, usa: chmod +x run.sh
- Si Docker no está en ejecución: sudo systemctl start docker

## Modelos

Puedes:
- Seleccionar un modelo ya descargado
- Descargar un nuevo modelo escribiendo su nombre

Algunos modelos disponibles:
- llama2
- codellama
- mistral
- tinyllama
- orca-mini
