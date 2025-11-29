#!/bin/bash
# Open ESP-IDF menuconfig in Docker

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Opening ESP-IDF menuconfig...${NC}"

# Run menuconfig in Docker container with interactive terminal
docker compose run --rm esp-idf idf.py menuconfig

echo -e "${GREEN}Configuration saved.${NC}"

