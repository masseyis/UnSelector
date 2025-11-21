#!/bin/bash

# Build script for AutoClearSelection Renoise Tool
# Creates com.penchi.AutoClearSelection.xrnx package

# Remove old package if it exists
if [ -f "com.penchi.AutoClearSelection.xrnx" ]; then
    echo "Removing old com.penchi.AutoClearSelection.xrnx..."
    rm com.penchi.AutoClearSelection.xrnx
fi

# Create the .xrnx package (which is just a zip file)
echo "Building com.penchi.AutoClearSelection.xrnx..."
zip -q com.penchi.AutoClearSelection.xrnx \
    main.lua \
    manifest.xml \
    cover.png \
    thumbnail.png \
    README.md

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "✓ Successfully built com.penchi.AutoClearSelection.xrnx"
    echo "  Package size: $(du -h com.penchi.AutoClearSelection.xrnx | cut -f1)"
    echo ""
    echo "Files included:"
    unzip -l com.penchi.AutoClearSelection.xrnx
else
    echo "✗ Build failed"
    exit 1
fi
