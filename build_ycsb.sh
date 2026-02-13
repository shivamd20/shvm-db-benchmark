#!/bin/bash
# Build script for YCSB shvmdb binding
# This ensures the binding and dependencies are built before running benchmarks

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
YCSB_DIR="$SCRIPT_DIR/ycsb"

echo "=================================================="
echo "Building YCSB DynamoDB Binding"
echo "=================================================="

# Build dynamodb binding
echo "Building dynamodb binding..."
cd "$YCSB_DIR"
mvn -pl dynamodb -am -B -DskipTests -Dcheckstyle.skip=true clean package
echo "✓ DynamoDB binding built successfully"


# Ensure core dependencies are available
echo "Ensuring core dependencies are available..."
cd "$YCSB_DIR"
if [ ! -d "core/target/dependency" ] || [ -z "$(ls -A core/target/dependency 2>/dev/null)" ]; then
    echo "Downloading core dependencies..."
    mvn -B -DskipTests dependency:copy-dependencies -f core/pom.xml
    echo "✓ Core dependencies downloaded"
else
    echo "✓ Core dependencies already present"
fi

echo "=================================================="
echo "Build Complete!"
echo "=================================================="
echo ""
echo "You can now run benchmarks with:"
echo "  ./run_benchmark.sh -w workloada_shvmdb -o load"
echo ""
