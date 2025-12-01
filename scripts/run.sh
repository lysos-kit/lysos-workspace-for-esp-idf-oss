#!/bin/bash
# =============================================================================
# Generic Command Runner for ESP-IDF Docker Container
# =============================================================================
# This script provides a convenient wrapper to run any ESP-IDF command inside
# the Docker container without having to type the full docker compose command.
#
# Usage:
#   ./run.sh <command> [arguments...]
#
# Common ESP-IDF Tools:
#   - idf.py         : Main build system
#   - esptool.py     : Flash and chip communication
#   - espcoredump.py : Core dump analysis
#   - espsecure.py   : Security features
#   - espefuse.py    : eFuse management
#   - parttool.py    : Partition table operations
#   - monitor.py     : Serial monitor
#
# Examples:
#   ./run.sh idf.py build
#   ./run.sh idf.py flash monitor
#   ./run.sh esptool.py --version
#   ./run.sh esptool.py chip_id
#   ./run.sh espcoredump.py info_corefile coredump.bin
#   ./run.sh espsecure.py --help
#   ./run.sh espefuse.py summary
#   ./run.sh python --version
#   ./run.sh ls -la
# =============================================================================

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo ""
    echo -e "${RED}ERROR: No command provided${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./run.sh <command> [arguments...]${NC}"
    echo ""
    echo -e "${CYAN}Common ESP-IDF Tools:${NC}"
    echo -e "${WHITE}  idf.py         - Main build system${NC}"
    echo -e "${WHITE}  esptool.py     - Flash and chip communication${NC}"
    echo -e "${WHITE}  espcoredump.py - Core dump analysis${NC}"
    echo -e "${WHITE}  espsecure.py   - Security features${NC}"
    echo -e "${WHITE}  espefuse.py    - eFuse management${NC}"
    echo -e "${WHITE}  parttool.py    - Partition table operations${NC}"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo -e "${WHITE}  ./run.sh idf.py build${NC}"
    echo -e "${WHITE}  ./run.sh idf.py flash monitor${NC}"
    echo -e "${WHITE}  ./run.sh esptool.py --version${NC}"
    echo -e "${WHITE}  ./run.sh esptool.py chip_id${NC}"
    echo -e "${WHITE}  ./run.sh espcoredump.py info_corefile coredump.bin${NC}"
    echo -e "${WHITE}  ./run.sh espefuse.py summary${NC}"
    echo -e "${WHITE}  ./run.sh python --version${NC}"
    echo ""
    exit 1
fi

# Get all arguments as the command to run
COMMAND="$@"

echo ""
echo -e "${CYAN}Running: ${COMMAND}${NC}"
echo ""

# Change to parent directory (where docker-compose.yml is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Execute command inside the Docker container
# Using bash -i -c ensures the ESP-IDF environment is loaded
docker compose exec esp-idf bash -i -c "$COMMAND"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Command completed successfully${NC}"
else
    echo -e "${RED}Command failed with exit code: ${EXIT_CODE}${NC}"
fi
echo ""

exit $EXIT_CODE
