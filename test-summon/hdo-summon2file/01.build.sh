#!/bin/bash
# Script to build the hdo-summon2file image

IMAGE_NAME="hdo-summon2file"

echo "Building Docker image $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

echo "Build complete. Current images:"
docker images | grep $IMAGE_NAME