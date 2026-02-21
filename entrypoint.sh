#!/bin/bash
set -e

SERVER_DIR="/server"
PLUGINS_DIR="$SERVER_DIR/plugins"
MC_VERSION="${MC_VERSION:-1.21.4}"

mkdir -p "$PLUGINS_DIR"
cd "$SERVER_DIR"

# ── Paper ────────────────────────────────────────────────────────────────────
if [ ! -f "$SERVER_DIR/server.jar" ]; then
    echo "==> Fetching latest Paper build for $MC_VERSION..."
    BUILD=$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds" \
        | jq -r '.builds | map(select(.channel=="default")) | last | .build')
    echo "==> Downloading Paper build $BUILD..."
    curl -fsSL -o "$SERVER_DIR/server.jar" \
        "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${BUILD}/downloads/paper-${MC_VERSION}-${BUILD}.jar"
fi

# ── EULA ─────────────────────────────────────────────────────────────────────
if [ ! -f "$SERVER_DIR/eula.txt" ]; then
    echo "eula=true" > "$SERVER_DIR/eula.txt"
fi

# ── Seed plugins from image into volume ──────────────────────────────────────
for jar in /plugins-staging/*.jar; do
    fname=$(basename "$jar")
    if [ ! -f "$PLUGINS_DIR/$fname" ]; then
        echo "==> Installing plugin: $fname"
        cp "$jar" "$PLUGINS_DIR/$fname"
    fi
done

# ── Launch ───────────────────────────────────────────────────────────────────
echo "==> Starting Paper server..."
exec java \
    -Xms${MEMORY_MIN:-1G} \
    -Xmx${MEMORY_MAX:-4G} \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -jar "$SERVER_DIR/server.jar" --nogui
