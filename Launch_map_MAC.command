#!/bin/bash
# Launches the Node.js map server (server.js). If Node isn't already
# available (bundled locally or on the system), this downloads a portable,
# no-install Node runtime into a local "node_runtime" folder next to this
# script - one time only. Every run after that skips the download and just
# uses what's already there.

PORT=8000
NODE_VERSION="20.18.1"   # pinned LTS version for reliability

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

LOCAL_NODE_DIR="$DIR/node_runtime"
LOCAL_NODE_BIN="$LOCAL_NODE_DIR/bin/node"

NODE_CMD=""

# 1) Already downloaded locally? Use it, skip everything else.
if [[ -x "$LOCAL_NODE_BIN" ]]; then
    NODE_CMD="$LOCAL_NODE_BIN"
    echo "Using previously downloaded Node runtime."

# 2) System-wide Node already installed? Use that instead of downloading.
elif command -v node >/dev/null 2>&1; then
    NODE_CMD="node"
    echo "Using system-installed Node.js."

# 3) Neither found - download a portable copy, one time only.
else
    echo "Node.js not found. Downloading a portable copy (one-time setup)..."

    ARCH="$(uname -m)"
    if [[ "$ARCH" == "arm64" ]]; then
        NODE_ARCH="arm64"
    else
        NODE_ARCH="x64"
    fi

    NODE_TARBALL="node-v${NODE_VERSION}-darwin-${NODE_ARCH}"
    DOWNLOAD_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TARBALL}.tar.gz"

    echo "Downloading from: $DOWNLOAD_URL"
    curl -L -o "$DIR/node.tar.gz" "$DOWNLOAD_URL"

    if [[ $? -ne 0 ]]; then
        echo "ERROR: Download failed. Check your internet connection and try again."
        read -p "Press Enter to close..."
        exit 1
    fi

    echo "Extracting..."
    mkdir -p "$LOCAL_NODE_DIR"
    tar -xzf "$DIR/node.tar.gz" -C "$LOCAL_NODE_DIR" --strip-components=1
    rm -f "$DIR/node.tar.gz"

    if [[ -x "$LOCAL_NODE_BIN" ]]; then
        NODE_CMD="$LOCAL_NODE_BIN"
        echo "Node.js installed locally - done. Future runs will skip this step."
    else
        echo "ERROR: Something went wrong extracting Node.js."
        read -p "Press Enter to close..."
        exit 1
    fi
fi

echo "Starting local server..."
PORT="$PORT" "$NODE_CMD" server.js &
SERVER_PID=$!

sleep 2

echo "Opening map in browser..."
CACHEBUST="$(date +%s)"
open "http://localhost:$PORT/index_long.html?nocache=$CACHEBUST"

echo ""
echo "Server is running. Close this window (or press Ctrl+C) to stop the map server."
wait $SERVER_PID
