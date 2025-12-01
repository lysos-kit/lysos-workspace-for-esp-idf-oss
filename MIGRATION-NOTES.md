# Distribution Structure Migration Notes

## Changes Made

This document describes the restructuring of the ESP32 Starter distribution package to separate the Docker/tooling configuration from the user's ESP-IDF project files.

## New Structure

### Before (Old Structure)

```
tools/esp32-starter/
├── docker-compose.yml
├── Dockerfile
├── main/
│   ├── CMakeLists.txt.example
│   └── main.c.example
├── CMakeLists.txt.example
└── ...
```

In this structure, the ESP-IDF project files were mixed with the Docker configuration.

### After (New Structure)

```
esp32-starter/
├── docker-compose.yml         # Docker configuration
├── Dockerfile                 # Container definition
├── scripts/                   # Helper scripts
├── .env.example               # Environment template
├── README.md                  # Main documentation
└── project-root-folder/       # USER'S ESP-IDF PROJECT
    ├── main/
    │   ├── CMakeLists.txt.example
    │   └── main.c.example
    ├── CMakeLists.txt.example
    └── README.md
```

## Benefits

1. **Clear Separation**: Docker/tooling configuration is separate from project code
2. **Easy Project Management**: Users can easily replace `project-root-folder` with their own project
3. **Better Organization**: Clearer distinction between infrastructure and application code
4. **Flexible**: Users can symlink their existing project or copy it into place

## Files Modified

### 1. docker-compose.yml

- Changed volume mount from `.:/workspace` to `./project-root-folder:/workspace`
- Added extension fields (`x-defaults`) for reusable configuration values

### 2. build-dist.ps1 (PowerShell)

- Changed `$StagingDir` to point to temp root instead of `tools/esp32-starter`
- Added `$ProjectRootFolder` variable
- Updated all file copy operations to place project files in `project-root-folder/`
- Added automatic creation of `project-root-folder/README.md`

### 3. build-dist.sh (Bash)

- Changed `STAGING_DIR` to point to temp root
- Added `PROJECT_ROOT_FOLDER` variable
- Updated all file copy operations to place project files in `project-root-folder/`
- Added automatic creation of `project-root-folder/README.md`

### 4. README-DIST.md

- Updated Quick Start instructions to reflect new workflow
- Updated Project Structure section
- Added "About project-root-folder" section
- Added "Using Your Own ESP-IDF Project" advanced usage section

### 5. .gitignore

- Added `project-root-folder/` to ignore list (distribution-only, not in source)

## User Workflow Changes

### Old Workflow

```bash
unzip esp32-starter-oss-v*.zip
cd tools/esp32-starter
cp CMakeLists.txt.example CMakeLists.txt
# ... edit files directly in this directory
docker compose up -d
```

### New Workflow

```bash
unzip esp32-starter-oss-v*.zip
cd esp32-starter-oss-v*
cd project-root-folder
cp CMakeLists.txt.example CMakeLists.txt
# ... edit files in project-root-folder
cd ..
docker compose up -d
```

## Advanced Usage

Users can now easily:

1. **Replace with existing project:**

   ```bash
   rm -rf project-root-folder
   cp -r /path/to/existing/project project-root-folder
   ```

2. **Use symlink:**

   ```bash
   rm -rf project-root-folder
   ln -s /path/to/existing/project project-root-folder
   ```

3. **Keep multiple projects:**
   ```bash
   mv project-root-folder project-1
   cp -r /path/to/project-2 project-root-folder
   # Edit docker-compose.yml to switch between them
   ```

## Testing

To test the new distribution:

1. Build the distribution:

   ```powershell
   # Windows
   .\build-dist.ps1

   # Linux/Mac
   ./build-dist.sh
   ```

2. Extract and test:

   ```bash
   cd dist
   unzip esp32-starter-oss-vdev.zip
   cd esp32-starter-oss-vdev
   ls -la  # Should show project-root-folder/
   ```

3. Verify structure:
   ```bash
   cd project-root-folder
   ls -la  # Should show main/, CMakeLists.txt.example, etc.
   ```

## Migration for Existing Users

Existing users upgrading from the old structure need to:

1. Extract the new distribution
2. Copy their project files into `project-root-folder/`:

   ```bash
   # Backup old structure
   cp -r tools/esp32-starter/main /tmp/my-project-main
   cp tools/esp32-starter/CMakeLists.txt /tmp/my-project-cmake

   # Set up new structure
   cd new-esp32-starter/project-root-folder
   rm main/*  # Remove examples
   cp -r /tmp/my-project-main/* main/
   cp /tmp/my-project-cmake CMakeLists.txt
   ```

## Compatibility

- The Docker container behavior is unchanged
- All `idf.py` commands work the same way
- Helper scripts (`run.ps1`, `run.sh`) work without modification
- USB passthrough configuration is unchanged
- Environment variables (`.env`) work the same way

## Date

December 1, 2025
