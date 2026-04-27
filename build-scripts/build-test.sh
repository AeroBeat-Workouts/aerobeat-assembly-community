#!/bin/bash
# build-test.sh - Restore the assembly manifest and run the root validation path

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== AeroBeat Assembly Community validation ==="

echo "Restoring root assembly dependencies..."
godotenv addons install

echo "Importing root project..."
godot --headless --path . --import

echo "Running root GUT suite..."
godot --headless --path . --script addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gexit

echo "=== Assembly validation passed ==="
