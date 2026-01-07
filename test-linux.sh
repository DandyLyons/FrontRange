#!/bin/bash
# Test FrontRange on Linux using Docker
# This script runs swift build and swift test inside an Ubuntu container with Swift 6.2

set -e

echo "🐧 Testing FrontRange on Linux (Swift 6.2 / Ubuntu)"
echo "=================================================="

# Use official Swift 6.2 Docker image
SWIFT_IMAGE="swift:6.2"

echo "📦 Pulling Swift Docker image: $SWIFT_IMAGE"
docker pull "$SWIFT_IMAGE"

echo ""
echo "🔨 Building on Linux..."
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  "$SWIFT_IMAGE" \
  swift build

echo ""
echo "✅ Build successful!"
echo ""
echo "🧪 Running tests on Linux..."
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  "$SWIFT_IMAGE" \
  swift test

echo ""
echo "✅ All tests passed on Linux!"
