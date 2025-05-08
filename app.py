"""API FastAPI de ejemplo para demostración de CI/CD."""

import logging
import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Configurar logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Crear la aplicación FastAPI
app = FastAPI(
    title="Hola Mundo API",
    description="API de ejemplo para CI/CD con FastAPI",
    version="0.1.0",
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    """Endpoint principal que devuelve un mensaje de hola mundo."""
    logger.info("Procesando solicitud al endpoint raíz")
    return {"message": "Hola Mundo desde FastAPI!"}


@app.get("/health")
async def health_check():
    """Endpoint para verificación de salud de la aplicación."""
    logger.info("Verificación de salud solicitada")
    return {"status": "healthy"}


# Manejar el puerto dinámico en entornos como Cloud Run
if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 9819))
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=False)
