#!/bin/bash
# Monitor the ESP32 serial output using Docker

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting serial monitor...${NC}"

# Check if port is specified as argument
PORT=""
if [ -n "$1" ]; then
    PORT="-p $1"
    echo -e "${GREEN}Using port: $1${NC}"
else
    # Use ESPPORT from environment (loaded from .env via docker-compose)
    echo -e "${YELLOW}Using port from .env file (ESPPORT)${NC}"
fi

# Run monitor command in Docker container
docker compose run --rm esp-idf idf.py $PORT monitor

echo -e "${GREEN}Monitor session ended.${NC}"

