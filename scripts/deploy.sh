#!/bin/bash

set -e

echo "========================================="
echo "Starting deployment"
echo "========================================="

echo "Logging in to Amazon ECR..."

aws ecr get-login-password --region "$AWS_REGION" | \
docker login \
  --username AWS \
  --password-stdin \
  "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Pulling Docker image..."

docker pull "$IMAGE_URI"

echo "Stopping existing container..."

docker stop flask-app || true

echo "Removing existing container..."

docker rm flask-app || true

echo "Starting new container..."

docker run -d \
  --name flask-app \
  --restart unless-stopped \
  -p 5000:5000 \
  -e MONGO_URI="$MONGO_URI" \
  -e SECRET_KEY="$SECRET_KEY" \
  "$IMAGE_URI"

echo "Waiting for application to start..."

sleep 10

echo "Checking whether container is running..."

if ! docker ps --format '{{.Names}}' | grep -q '^flask-app$'; then
    echo "ERROR: flask-app container is not running."

    echo "Container logs:"
    docker logs flask-app || true

    exit 1
fi

echo "Container is running."

echo "Performing deployment health check..."

if curl --fail \
        --silent \
        --show-error \
        --max-time 10 \
        http://localhost:5000/health; then

    echo ""
    echo "========================================="
    echo "Health check PASSED"
    echo "Deployment successful"
    echo "========================================="

else

    echo ""
    echo "========================================="
    echo "Health check FAILED"
    echo "Deployment failed"
    echo "========================================="

    echo "Container logs:"
    docker logs flask-app || true

    exit 1
fi