#!/bin/bash
# Open an interactive shell in the ESP-IDF Docker container

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Opening interactive shell in ESP-IDF container...${NC}"
echo -e "${GREEN}You can now run idf.py commands directly.${NC}"
echo -e "${GREEN}Type 'exit' to leave the container shell.${NC}"
echo ""

# Open interactive shell in Docker container
docker compose run --rm esp-idf /bin/bash

echo -e "${GREEN}Shell session ended.${NC}"

