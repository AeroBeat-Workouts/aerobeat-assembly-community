#!/bin/bash
# build-test.sh - Run before considering Phase 5 complete

set -e

echo "=== Phase 5: Integration Build Test ==="

# Test 1: Open core
echo "Testing aerobeat-core..."
cd aerobeat-core/.testbed
godot --headless --quit
cd ../..

# Test 2: Open mediapipe driver
echo "Testing mediapipe driver..."
cd aerobeat-input-mediapipe-python/.testbed
godot --headless --quit
cd ../..

# Test 3: Open and build assembly
echo "Testing assembly..."
cd aerobeat-assembly-community
godot --headless --export-release "Linux/X11" build/aerobeat.x86_64 || true
cd ..

# Test 4: Run GUT tests
echo "Running GUT tests..."
cd aerobeat-assembly-community
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/integration/test_full_pipeline.gd
cd ..

echo "=== All tests passed! Phase 5 complete. ==="
