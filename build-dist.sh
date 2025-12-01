#!/bin/bash
#
# Build distribution package for ESP32 Starter OSS
#
# Usage:
#   ./build-dist.sh [version]
#
# Examples:
#   ./build-dist.sh 1.0.0
#   ./build-dist.sh

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'

# Determine version
VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo -e "${YELLOW}No version specified, attempting to detect from git tag...${NC}"
    
    if git describe --exact-match --tags HEAD 2>/dev/null; then
        GIT_TAG=$(git describe --exact-match --tags HEAD 2>/dev/null)
        VERSION="${GIT_TAG#v}"
        echo -e "${GREEN}Detected version from git tag: $VERSION${NC}"
    fi
    
    if [ -z "$VERSION" ]; then
        VERSION="dev"
        echo -e "${YELLOW}Using default version: $VERSION${NC}"
    fi
fi

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="esp32-starter-oss"
DIST_DIR="$PROJECT_ROOT/dist"
TEMP_DIR="$PROJECT_ROOT/temp-dist-$(date +%s)"
STAGING_DIR="$TEMP_DIR/$PACKAGE_NAME-v$VERSION"
ZIP_FILENAME="$PACKAGE_NAME-v$VERSION.zip"
ZIP_FILEPATH="$DIST_DIR/$ZIP_FILENAME"

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}ESP32 Starter OSS - Build Distribution${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${WHITE}Version: $VERSION${NC}"
echo -e "${WHITE}Package: $ZIP_FILENAME${NC}"
echo ""

# Create directories
echo -e "${CYAN}[1/6] Creating directories...${NC}"
mkdir -p "$DIST_DIR"
mkdir -p "$STAGING_DIR"
echo -e "${GRAY}      Created: $STAGING_DIR${NC}"

# Copy essential files
echo -e "${CYAN}[2/6] Copying project files...${NC}"

ROOT_FILES=(
    "docker-compose.yml"
    "Dockerfile"
    "LICENSE"
    "sdkconfig.defaults"
    ".env.example"
)

for file in "${ROOT_FILES[@]}"; do
    src_path="$PROJECT_ROOT/$file"
    if [ -f "$src_path" ]; then
        cp "$src_path" "$STAGING_DIR/"
        echo -e "${GRAY}      * $file${NC}"
    else
        echo -e "${YELLOW}      x $file (not found, skipping)${NC}"
    fi
done

# Copy CMakeLists.txt as .example
if [ -f "$PROJECT_ROOT/CMakeLists.txt" ]; then
    cp "$PROJECT_ROOT/CMakeLists.txt" "$STAGING_DIR/CMakeLists.txt.example"
    echo -e "${GRAY}      * CMakeLists.txt -> CMakeLists.txt.example${NC}"
fi

# Copy README-DIST.md and rename to README.md
if [ -f "$PROJECT_ROOT/README-DIST.md" ]; then
    cp "$PROJECT_ROOT/README-DIST.md" "$STAGING_DIR/README.md"
    echo -e "${GRAY}      * README-DIST.md -> README.md${NC}"
else
    echo -e "${RED}      x README-DIST.md (not found)${NC}"
    echo "ERROR: README-DIST.md is required for distribution package"
    exit 1
fi

# Copy scripts directory
echo -e "${CYAN}[3/6] Copying scripts directory...${NC}"
if [ -d "$PROJECT_ROOT/scripts" ]; then
    cp -r "$PROJECT_ROOT/scripts" "$STAGING_DIR/"
    echo -e "${GRAY}      * scripts/${NC}"
else
    echo -e "${YELLOW}      x scripts/ (not found, skipping)${NC}"
fi

# Copy main directory
echo -e "${CYAN}[4/6] Copying main directory...${NC}"
if [ -d "$PROJECT_ROOT/main" ]; then
    mkdir -p "$STAGING_DIR/main"
    
    if [ -f "$PROJECT_ROOT/main/.gitkeep" ]; then
        cp "$PROJECT_ROOT/main/.gitkeep" "$STAGING_DIR/main/"
        echo -e "${GRAY}      * main/.gitkeep${NC}"
    fi
    
    if [ -f "$PROJECT_ROOT/main/CMakeLists.txt" ]; then
        cp "$PROJECT_ROOT/main/CMakeLists.txt" "$STAGING_DIR/main/CMakeLists.txt.example"
        echo -e "${GRAY}      * main/CMakeLists.txt -> main/CMakeLists.txt.example${NC}"
    fi
    
    if [ -f "$PROJECT_ROOT/main/main.c" ]; then
        cp "$PROJECT_ROOT/main/main.c" "$STAGING_DIR/main/main.c.example"
        echo -e "${GRAY}      * main/main.c -> main/main.c.example${NC}"
    fi
else
    echo -e "${YELLOW}      x main/ (not found, creating empty directory)${NC}"
    mkdir -p "$STAGING_DIR/main"
fi

# Create ZIP archive
echo -e "${CYAN}[5/6] Creating ZIP archive...${NC}"
if [ -f "$ZIP_FILEPATH" ]; then
    rm "$ZIP_FILEPATH"
    echo -e "${GRAY}      Removed existing: $ZIP_FILENAME${NC}"
fi

(cd "$TEMP_DIR" && zip -r "$ZIP_FILEPATH" "$PACKAGE_NAME-v$VERSION" -q)
echo -e "${GRAY}      * Created: $ZIP_FILENAME${NC}"

FILE_SIZE=$(du -h "$ZIP_FILEPATH" | cut -f1)

# Cleanup
echo -e "${CYAN}[6/6] Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"
echo -e "${GRAY}      * Removed: $TEMP_DIR${NC}"

# Success message
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}* Distribution package created successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${WHITE}Package: $ZIP_FILENAME${NC}"
echo -e "${WHITE}Size:    $FILE_SIZE${NC}"
echo -e "${WHITE}Path:    $ZIP_FILEPATH${NC}"
echo ""
