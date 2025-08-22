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

### Selección Interactiva de Modelo

Al ejecutar el script por primera vez o al construir desde cero, se te presentará un menú para seleccionar el modelo:

```
==== Selección de Modelo por Defecto ====

Modelos recomendados:
[1] tinyllama    - Modelo pequeño y rápido (recomendado para pruebas)
[2] llama2       - Modelo equilibrado
[3] codellama    - Especializado en código
[4] mistral      - Modelo general de buena calidad
[5] orca-mini    - Modelo compacto pero potente
[6] qwen2:1.5b   - Modelo ligero multiidioma
[7] gemma:2b     - Modelo compacto de Google

También puedes escribir el nombre de cualquier otro modelo disponible.

Selecciona un modelo (1-7 o escribe el nombre):
```

Ejemplos de modelos personalizados que puedes escribir:
- `deepseek-r1:1.5b`
- `phi3:mini`
- `nous-hermes2:10.7b-llama3-q4_0`
- `codeqwen:7b`

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

## Selección de Modelos

### Modelos Preconfigurados

El sistema incluye opciones rápidas para los siguientes modelos:

1. **tinyllama** - Ideal para pruebas rápidas y sistemas con recursos limitados
2. **llama2** - Modelo equilibrado para uso general
3. **codellama** - Optimizado para tareas de programación y código
4. **mistral** - Excelente calidad general y razonamiento
5. **orca-mini** - Compacto pero con buen rendimiento
6. **qwen2:1.5b** - Soporte multiidioma con tamaño reducido
7. **gemma:2b** - Modelo eficiente desarrollado por Google

### Modelos Personalizados

También puedes especificar cualquier modelo disponible en el registro de Ollama escribiendo su nombre completo. Ejemplos populares:

- **deepseek-r1:1.5b** - Modelo de razonamiento avanzado
- **phi3:mini** - Modelo compacto de Microsoft
- **nous-hermes2** - Variantes especializadas en conversación
- **codeqwen:7b** - Especializado en código con mayor capacidad
- **yi:6b** - Modelo multiidioma de alta calidad

### Cambio de Modelo Durante el Chat

Una vez iniciado el chat, puedes cambiar de modelo escribiendo:
- `cambiar modelo`
- `change model`

## Notas

- El servicio usa el puerto 11434 por defecto
- Los modelos y datos se persisten en el volumen 'ollama_data'
- La primera ejecución puede tardar varios minutos mientras descarga el modelo
- En Windows, asegúrate de que Docker Desktop esté en ejecución antes de iniciar el script
- Si usas Git Bash en Windows, puedes usar también el script run.sh

## Solución de Problemas

### Problemas de Selección de Modelo

**Error: "accepts 1 arg(s), received 0"**
- Este error ocurría en versiones anteriores cuando no se especificaba correctamente el modelo
- **Solución**: Ejecuta `clean.bat`/`clean.sh` y luego `run.bat`/`run.sh` para reconstruir con la versión actualizada

**El modelo seleccionado no se está utilizando**
- Verifica que hayas seleccionado "Limpiar todo y empezar desde cero" cuando el sistema detecte contenedores existentes
- Si usas recursos existentes, el modelo no se actualiza; necesitas reconstruir

**Modelo personalizado no encontrado**
- Verifica que el nombre del modelo sea exacto (ej: `deepseek-r1:1.5b` no `deepseek-r1`)
- Consulta los modelos disponibles en: https://ollama.com/library

### Problemas Generales

#### Windows
- Si el script no funciona, asegúrate de que Docker Desktop esté en ejecución
- Si curl no está disponible, puedes instalarlo desde la Microsoft Store
- Si tienes problemas con los permisos, ejecuta el script como administrador

#### Linux/MacOS
- Si el script no tiene permisos de ejecución, usa: `chmod +x run.sh`
- Si Docker no está en ejecución: `sudo systemctl start docker`

### Recursos del Sistema

**Modelos grandes y memoria**
- Los modelos como `llama2` requieren al menos 8GB de RAM
- Para sistemas con poca memoria, usa `tinyllama` o `qwen2:1.5b`
- El sistema está configurado con límite de 8GB de memoria para el contenedor

**Tiempo de descarga**
- La primera descarga de un modelo puede tardar varios minutos
- Los modelos se almacenan en el volumen `ollama_data` y se reutilizan
- Para ver el progreso: `docker-compose logs -f ollama`
