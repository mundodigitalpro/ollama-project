import requests
import time
import sys
from typing import Optional, Dict, Any, List
from requests.exceptions import RequestException
import logging
import json

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class OllamaAPI:
    def __init__(self, base_url: str = "http://localhost:11434", max_retries: int = 5):
        self.base_url = base_url.rstrip('/')
        self.max_retries = max_retries
        self.current_model = None
        
    def get_available_models(self) -> List[str]:
        """Get list of available models"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=5)
            if response.status_code == 200:
                return [m['name'] for m in response.json().get('models', [])]
        except Exception as e:
            logger.error(f"Error getting models: {str(e)}")
        return []

    def select_model(self) -> bool:
        """Let user select a model from available ones or download a new one"""
        models = self.get_available_models()
        
        print("\nModelos disponibles:")
        if models:
            for i, model in enumerate(models, 1):
                print(f"{i}. {model}")
        else:
            print("No hay modelos instalados")
        
        print("\nOpciones:")
        print("- Escribe un número para seleccionar un modelo existente")
        print("- Escribe el nombre de un nuevo modelo para descargarlo")
        print("- Ejemplos de modelos: llama2, codellama, mistral, tinyllama, orca-mini")
        
        while True:
            try:
                choice = input("\nSelecciona o escribe un modelo: ").strip().lower()
                
                # Si el usuario introduce un número
                if choice.isdigit() and models and 1 <= int(choice) <= len(models):
                    self.current_model = models[int(choice)-1]
                    print(f"✅ Modelo seleccionado: {self.current_model}")
                    return True
                    
                # Si el usuario introduce el nombre de un modelo
                else:
                    if choice in models:
                        self.current_model = choice
                        print(f"✅ Modelo seleccionado: {self.current_model}")
                        return True
                    else:
                        confirm = input(f"¿Quieres descargar el modelo '{choice}'? (s/n): ").lower()
                        if confirm in ['s', 'si', 'sí', 'y', 'yes']:
                            print(f"\n⏳ Descargando modelo {choice}...")
                            try:
                                response = requests.post(
                                    f"{self.base_url}/api/pull",
                                    json={"name": choice},
                                    stream=True,
                                    timeout=3600  # Aumentamos el timeout a 1 hora
                                )
                                response.raise_for_status()
                                
                                # Mostrar progreso de descarga
                                last_status = ""
                                for line in response.iter_lines():
                                    if line:
                                        try:
                                            status = requests.utils.json.loads(line)
                                            if 'status' in status and status['status'] != last_status:
                                                print(f"Status: {status['status']}")
                                                last_status = status['status']
                                            if 'completed' in status:
                                                print(f"\rProgreso: {status.get('completed', 0)}%", end='', flush=True)
                                            if status.get('status') == "success":
                                                print("\n✅ Descarga completada!")
                                                break
                                        except json.JSONDecodeError:
                                            continue
                                
                                # Verificar que el modelo se descargó correctamente
                                new_models = self.get_available_models()
                                if choice in new_models:
                                    self.current_model = choice
                                    print(f"✅ Modelo {choice} descargado y seleccionado")
                                    return True
                                else:
                                    print("❌ Error: El modelo no aparece en la lista después de la descarga")
                                    
                            except requests.exceptions.RequestException as e:
                                print(f"\n❌ Error al descargar el modelo: {str(e)}")
                                if "connection" in str(e).lower():
                                    print("  Sugerencia: Verifica tu conexión a internet")
                                elif "timeout" in str(e).lower():
                                    print("  Sugerencia: La descarga está tardando demasiado, intenta de nuevo")
                                retry = input("\n¿Quieres intentar con otro modelo? (s/n): ").lower()
                                if retry not in ['s', 'si', 'sí', 'y', 'yes']:
                                    return False
                        else:
                            retry = input("¿Quieres intentar con otro modelo? (s/n): ").lower()
                            if retry not in ['s', 'si', 'sí', 'y', 'yes']:
                                return False
                            
            except ValueError:
                print("❌ Por favor, introduce un número válido o el nombre del modelo.")
                
        return False

    def wait_for_service(self, timeout: int = 120) -> bool:
        """Wait for Ollama service to be ready"""
        logger.info("Checking if Ollama service is available...")
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                response = requests.get(f"{self.base_url}/api/tags", timeout=5)
                if response.status_code == 200:
                    models = response.json().get('models', [])
                    if models:
                        logger.info(f"Available models: {[m['name'] for m in models]}")
                        return True
                    logger.warning("No models available yet...")
            except requests.exceptions.RequestException as e:
                logger.error(f"Error connecting to Ollama: {str(e)}")
            logger.info("Waiting for Ollama service to be ready...")
            time.sleep(5)
        logger.error("Error: Ollama service is not available")
        return False

    def chat_with_model(self, prompt: str, model: str = None) -> Optional[Dict[str, Any]]:
        """
        Send a chat message to the Ollama API with retry logic
        Returns the full response dictionary or None if there's an error
        """
        if model is None:
            model = self.current_model
            
        if model is None:
            logger.error("No model selected")
            return None

        url = f"{self.base_url}/api/generate"
        data = {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.7,
                "top_p": 0.9
            }
        }
        
        for attempt in range(self.max_retries):
            try:
                logger.info("Enviando pregunta al modelo...")
                response = requests.post(url, json=data, timeout=30)
                response.raise_for_status()
                return response.json()
            except requests.exceptions.Timeout:
                logger.error(f"Intento {attempt + 1}/{self.max_retries}: Tiempo de espera agotado")
            except requests.exceptions.RequestException as e:
                logger.error(f"Intento {attempt + 1}/{self.max_retries}: Error: {str(e)}")
                if hasattr(e, 'response') and e.response is not None:
                    error_msg = e.response.text
                    logger.error(f"Contenido de la respuesta: {error_msg}")
                    if "rate limit exceeded" in error_msg.lower():
                        wait_time = 60
                        logger.warning(f"Límite de tasa excedido. Esperando {wait_time} segundos...")
                        time.sleep(wait_time)
                        continue
            except ValueError as e:
                logger.error(f"Error al procesar la respuesta: {str(e)}")
                return None
                
            if attempt < self.max_retries - 1:
                wait_time = min(2 ** attempt, 30)
                logger.info(f"Reintentando en {wait_time} segundos...")
                time.sleep(wait_time)
            
        logger.error("No se pudo obtener respuesta después de todos los intentos")
        return None

def main():
    print("\n=== Chat con Ollama ===")
    print("Escribe 'salir' para terminar")
    print("Escribe 'cambiar modelo' para seleccionar otro modelo")
    print("Iniciando servicio...\n")
    
    ollama = OllamaAPI(base_url="http://localhost:11434", max_retries=10)
    
    if not ollama.wait_for_service(timeout=300):
        print("❌ No se pudo conectar al servicio de Ollama")
        sys.exit(1)
    
    if not ollama.select_model():
        print("❌ No se pudo seleccionar un modelo")
        sys.exit(1)
    
    print("✅ Servicio listo para chatear!\n")
    
    while True:
        try:
            prompt = input(">>> ")
            
            if prompt.lower() in ['salir', 'exit', 'quit']:
                print("\n👋 ¡Hasta luego!")
                break
                
            if prompt.lower() == 'cambiar modelo':
                if ollama.select_model():
                    print("✅ Continúa el chat con el nuevo modelo")
                continue
            
            if not prompt.strip():
                continue
            
            print("\n⏳ Procesando respuesta...\n")
            response = ollama.chat_with_model(prompt)
            
            if response:
                print("🤖:", response.get('response', 'No hay contenido en la respuesta'))
            else:
                print("❌ Error: No se pudo obtener respuesta de Ollama")
                
        except KeyboardInterrupt:
            print("\n\n👋 ¡Hasta luego!")
            break
        except Exception as e:
            print(f"\n❌ Error inesperado: {str(e)}")
            continue

if __name__ == "__main__":
    main()
