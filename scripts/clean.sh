#!/bin/bash
# Clean build artifacts using Docker

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Cleaning build artifacts...${NC}"

# Run fullclean command in Docker container
docker compose run --rm esp-idf idf.py fullclean

echo -e "${GREEN}Clean completed!${NC}"

