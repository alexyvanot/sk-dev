#!/bin/bash

# Variables
PAPER_API="https://api.papermc.io/v2/projects/paper"
DOWNLOAD_DIR="./"
SERVER_JAR="paper.jar"
PLUGINS_DIR="$DOWNLOAD_DIR/plugins"

# Get latest PaperMC version
LATEST_VERSION=$(curl -s "$PAPER_API" | grep -o '"versions":\[[^]]*' | sed 's/.*\[\(.*\)/\1/' | awk -F, '{gsub(/"/,"",$NF); print $NF}')
echo "Latest PaperMC version: $LATEST_VERSION"

# Get latest PaperMC build
BUILD_API="$PAPER_API/versions/$LATEST_VERSION"
LATEST_BUILD=$(curl -s "$BUILD_API" | grep -o '"builds":\[[^]]*' | sed 's/.*\[\(.*\)/\1/' | awk -F, '{print $NF}')
echo "Latest build: $LATEST_BUILD"

# Download latest PaperMC jar
JAR_URL="$PAPER_API/versions/$LATEST_VERSION/builds/$LATEST_BUILD/downloads/paper-$LATEST_VERSION-$LATEST_BUILD.jar"
echo "Downloading $JAR_URL ..."
curl -o "$DOWNLOAD_DIR/$SERVER_JAR.new" "$JAR_URL"

# Replace old PaperMC jar
if [ -f "$DOWNLOAD_DIR/$SERVER_JAR" ]; then
    mv "$DOWNLOAD_DIR/$SERVER_JAR" "$DOWNLOAD_DIR/$SERVER_JAR.bak"
fi
mv "$DOWNLOAD_DIR/$SERVER_JAR.new" "$DOWNLOAD_DIR/$SERVER_JAR"

echo "PaperMC updated to version $LATEST_VERSION build $LATEST_BUILD."

# Ensure eula.txt exists with eula=true
EULA_FILE="$DOWNLOAD_DIR/eula.txt"
if [ ! -f "$EULA_FILE" ]; then
    echo "eula=true" > "$EULA_FILE"
    echo "Created eula.txt with eula=true."
fi

# Ensure plugins directory exists
if [ ! -d "$PLUGINS_DIR" ]; then
    mkdir -p "$PLUGINS_DIR"
    echo "Created plugins directory."
fi

# Get/Update latest Skript release info from GitHub
SKRIPT_API="https://api.github.com/repos/SkriptLang/Skript/releases/latest"
SKRIPT_JAR_URL=$(curl -s "$SKRIPT_API" | grep 'browser_download_url.*Skript-.*\.jar' | head -n1 | sed 's/.*"\(https[^"]*Skript-[^"]*\.jar\)".*/\1/')

if [ -z "$SKRIPT_JAR_URL" ]; then
    echo "Could not find Skript plugin jar in latest release."
    exit 1
fi

# If Skript jar does exist, back it up
if [ -f "$PLUGINS_DIR/skript.jar" ]; then
    mv "$PLUGINS_DIR/skript.jar" "$PLUGINS_DIR/skript.jar.bak"
    echo "Backed up existing skript.jar."
fi

# Download latest Skript jar and rename to skript.jar
echo "Downloading Skript plugin: $SKRIPT_JAR_URL ..."
curl -L -o "$PLUGINS_DIR/skript.jar" "$SKRIPT_JAR_URL"

