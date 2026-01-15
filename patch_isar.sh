#!/bin/bash

# Script to patch isar_flutter_libs for Android API 36 compatibility

ISAR_BUILD_FILE="$HOME/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/android/build.gradle"
ISAR_MANIFEST_FILE="$HOME/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/android/src/main/AndroidManifest.xml"

echo "Patching isar_flutter_libs for Android API 36..."

# Patch build.gradle
if [ -f "$ISAR_BUILD_FILE" ]; then
    if grep -q "namespace" "$ISAR_BUILD_FILE"; then
        echo "✓ Namespace already exists in build.gradle"
    else
        sed -i.bak '/android {/a\
    namespace = "io.isar.isar_flutter_libs"
' "$ISAR_BUILD_FILE"
        echo "✓ Added namespace to build.gradle"
    fi
else
    echo "✗ Error: build.gradle not found"
    exit 1
fi

# Patch AndroidManifest.xml
if [ -f "$ISAR_MANIFEST_FILE" ]; then
    if grep -q 'package=' "$ISAR_MANIFEST_FILE"; then
        sed -i.bak 's/package="[^"]*"//g' "$ISAR_MANIFEST_FILE"
        echo "✓ Removed package attribute from AndroidManifest.xml"
    else
        echo "✓ Package attribute already removed from AndroidManifest.xml"
    fi
else
    echo "✗ Error: AndroidManifest.xml not found"
    exit 1
fi

echo "✓ Patch completed successfully!"
