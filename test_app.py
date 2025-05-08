"""Tests para la API FastAPI de ejemplo."""

from fastapi.testclient import TestClient

from app import app

client = TestClient(app)


def test_read_root():
    """Prueba el endpoint raíz '/'."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hola Mundo desde FastAPI!"}


def test_health_check():
    """Prueba el endpoint de health check."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
