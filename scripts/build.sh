#!/bin/bash
# Build the ESP32 project using Docker

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building ESP32 project in Docker...${NC}"

# Parse optional target argument
TARGET=""
if [ -n "$1" ]; then
    TARGET="$1"
    echo -e "${GREEN}Building target: ${TARGET}${NC}"
fi

# Run build command in Docker container
docker compose run --rm esp-idf idf.py build $TARGET

echo -e "${GREEN}Build completed!${NC}"

