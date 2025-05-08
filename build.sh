#!/bin/bash

# Variables para la imagen
IMAGE_NAME="hello-world-fastapi"
PROJECT_ID="crp-dev-dig-mlcatalog"
REGION="us-central1"
REGISTRY_NAME="cicd"
SERVICE_NAME="fastapi-hello-world-service"

# Tag para la imagen (latest)
TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REGISTRY_NAME}/${IMAGE_NAME}:latest"

echo "Intentando autenticarse con gcloud..."
# Asegurarse de que la autenticación está activa
gcloud auth login --brief

# Configurar Docker para usar gcloud como credencial helper con permisos explícitos
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Verificar si el usuario tiene los permisos necesarios
echo "Verificando permisos en el repositorio..."
gcloud artifacts repositories describe $REGISTRY_NAME --location=$REGION --project=$PROJECT_ID

if [ $? -ne 0 ]; then
    echo "No se puede acceder al repositorio. Verificando si existe..."
    gcloud artifacts repositories list --location=$REGION --project=$PROJECT_ID
    echo "Si el repositorio existe, es posible que necesites solicitar permisos adicionales."
    echo "Permisos necesarios: artifactregistry.repositories.uploadArtifacts"
    exit 1
fi

echo "Construyendo la imagen Docker localmente..."
docker buildx build --platform linux/amd64 -t $TAG .

if [ $? -ne 0 ]; then
    echo "Error al construir la imagen Docker"
    exit 1
fi

echo "Intentando subir la imagen a Artifact Registry..."
docker push $TAG

if [ $? -ne 0 ]; then
    echo "Error al subir la imagen. Probablemente necesites permisos adicionales."
    echo "Solicita el rol 'Artifact Registry Writer' o el permiso específico 'artifactregistry.repositories.uploadArtifacts'"
    echo "Comando para otorgar permisos:"
    echo "gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:TU_EMAIL --role=roles/artifactregistry.writer"

    echo "¿Deseas continuar e intentar desplegar usando una imagen existente? (s/n)"
    read continuar
    if [ "$continuar" != "s" ]; then
        exit 1
    fi
fi

# Desplegar la imagen en Cloud Run (ya sea la nueva o una existente)
echo "Desplegando en Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image=$TAG \
  --region=$REGION \
  --platform=managed \
  --port=9819 \
  --cpu=4 \
  --memory=16Gi \
  --min-instances=1 \
  --max-instances=50 \
  --timeout=3600s \
  --concurrency=80 \
  --execution-environment=gen2 \
  --no-allow-unauthenticated

# Verificar si el despliegue fue exitoso
if [ $? -ne 0 ]; then
    echo "Error al desplegar la imagen en Cloud Run"
    exit 1
fi

echo "Imagen desplegada exitosamente en Cloud Run: $SERVICE_NAME"
