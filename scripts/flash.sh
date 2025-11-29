#!/bin/bash
# Flash and monitor the ESP32 device using Docker

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Flashing ESP32 device...${NC}"

# Check if port is specified as argument
PORT=""
if [ -n "$1" ]; then
    PORT="-p $1"
    echo -e "${GREEN}Using port: $1${NC}"
else
    # Use ESPPORT from environment (loaded from .env via docker-compose)
    echo -e "${YELLOW}Using port from .env file (ESPPORT)${NC}"
fi

# Run flash and monitor command in Docker container
docker compose run --rm esp-idf idf.py $PORT flash monitor

echo -e "${GREEN}Flash and monitor session ended.${NC}"

