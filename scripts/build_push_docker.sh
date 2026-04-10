#!/bin/bash
# Builds and pushes Docker images to your registry
set -e

# NOTE: Change this to your actual Docker Hub username!
DOCKER_USERNAME="fantoforever"

echo "Building Backend Image..."
cd taskapp_backend
docker build -t ${DOCKER_USERNAME}/taskapp-backend:latest .
docker push ${DOCKER_USERNAME}/taskapp-backend:latest
cd -

echo "Building Frontend Image..."
cd taskapp_frontend
docker build -t ${DOCKER_USERNAME}/taskapp-frontend:latest .
docker push ${DOCKER_USERNAME}/taskapp-frontend:latest
cd -

echo "✅ Docker Images successfully built and pushed!"
