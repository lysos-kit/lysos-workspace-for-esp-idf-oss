#!/bin/bash
#
# Build distribution package for Lysos Workspace for ESP-IDF
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
PACKAGE_NAME="lysos-workspace"
DIST_DIR="$PROJECT_ROOT/dist"
TEMP_DIR="$PROJECT_ROOT/temp-dist-$(date +%s)"
VERSIONED_FOLDER_NAME="$PACKAGE_NAME-v$VERSION"
STAGING_DIR="$TEMP_DIR/$VERSIONED_FOLDER_NAME"
PROJECT_ROOT_FOLDER="$STAGING_DIR/project-root-folder"
ZIP_FILENAME="$PACKAGE_NAME-v$VERSION.zip"
ZIP_FILEPATH="$DIST_DIR/$ZIP_FILENAME"

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Lysos Workspace - Build Distribution${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${WHITE}Version: $VERSION${NC}"
echo -e "${WHITE}Package: $ZIP_FILENAME${NC}"
echo ""

# Create directories
echo -e "${CYAN}[1/6] Creating directories...${NC}"
mkdir -p "$DIST_DIR"
mkdir -p "$STAGING_DIR"
mkdir -p "$PROJECT_ROOT_FOLDER"
echo -e "${GRAY}      Created: $STAGING_DIR${NC}"
echo -e "${GRAY}      Created: $PROJECT_ROOT_FOLDER${NC}"

# Copy essential files
echo -e "${CYAN}[2/6] Copying project files...${NC}"

ROOT_FILES=(
    "docker-compose.yml"
    "Dockerfile"
    "LICENSE"
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

# Create a placeholder README in project-root-folder
echo -e "${CYAN}[4/6] Creating project-root-folder...${NC}"
cat > "$PROJECT_ROOT_FOLDER/README.md" << 'EOF'
# Your ESP-IDF Project Goes Here

Copy your entire ESP-IDF project folder into this directory (not just the contents, the whole folder).

## Quick Start

1. Copy your project folder here:
   ```bash
   cp -r /path/to/my-esp32-project ./project-root-folder/
   ```
   
   Result structure:
   ```
   project-root-folder/
   └── my-esp32-project/  ← your project folder
       ├── main/
       ├── CMakeLists.txt
       └── ...
   ```

2. Edit .env and set PROJECT_NAME to your folder name:
   ```bash
   cd ..
   cp .env.example .env
   # Edit .env and set: PROJECT_NAME=my-esp32-project
   ```

3. Start Docker:
   ```bash
   docker compose up -d
   docker compose exec esp-idf bash
   ```

4. Inside the container, build your project:
   ```bash
   idf.py set-target esp32s3
   idf.py build
   idf.py flash monitor
   ```

See the main README.md in the parent directory for complete documentation.
EOF
echo -e "${GRAY}      * project-root-folder/README.md (placeholder)${NC}"

# Create ZIP archive
echo -e "${CYAN}[5/6] Creating ZIP archive...${NC}"
if [ -f "$ZIP_FILEPATH" ]; then
    rm "$ZIP_FILEPATH"
    echo -e "${GRAY}      Removed existing: $ZIP_FILENAME${NC}"
fi

(cd "$TEMP_DIR" && zip -r "$ZIP_FILEPATH" * -q)
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
