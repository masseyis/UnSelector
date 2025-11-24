#!/bin/bash

# Build script for UnSelector Renoise Tool
# Creates com.penchi.UnSelector.xrnx package

# Remove old package if it exists
if [ -f "com.penchi.UnSelector.xrnx" ]; then
    echo "Removing old com.penchi.UnSelector.xrnx..."
    rm com.penchi.UnSelector.xrnx
fi

# Create the .xrnx package (which is just a zip file)
echo "Building com.penchi.UnSelector.xrnx..."
zip -q com.penchi.UnSelector.xrnx \
    main.lua \
    manifest.xml \
    cover.png \
    thumbnail.png \
    README.md

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "✓ Successfully built com.penchi.UnSelector.xrnx"
    echo "  Package size: $(du -h com.penchi.UnSelector.xrnx | cut -f1)"
    echo ""
    echo "Files included:"
    unzip -l com.penchi.UnSelector.xrnx
else
    echo "✗ Build failed"
    exit 1
fi
