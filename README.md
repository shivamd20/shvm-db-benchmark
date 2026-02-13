# YCSB ShvmDB Benchmark Setup

This repository contains a custom YCSB binding for benchmarking **shvm-db**, a DynamoDB-compatible database built on Cloudflare Durable Objects.

## Architecture

### Standalone ShvmDB Module

The `ycsb/shvmdb` module is a **standalone Maven project** that:
- Depends on **upstream YCSB 0.17.0** from Maven Central (not local builds)
- Contains only the ShvmDB-specific binding code
- Can be built independently without building the entire YCSB project
- Avoids dependency conflicts from other YCSB bindings (mongodb, cassandra, etc.)

### Benefits

✅ **Fast builds** - Only builds what you need (~2 seconds)  
✅ **No broken dependencies** - Doesn't touch unrelated modules  
✅ **Uses stable YCSB** - Pinned to official 0.17.0 release  
✅ **CI/CD ready** - Simple, focused GitHub Actions workflow  

## Quick Start

### 1. Build the ShvmDB Binding

```bash
./build_ycsb.sh
```

This script:
- Builds the shvmdb binding module
- Downloads required YCSB core dependencies
- Prepares everything for benchmarking

### 2. Start Your ShvmDB Server

Make sure your shvm-db server is running (default: `http://localhost:8787`)

### 3. Run Benchmarks

```bash
# Load phase (insert initial data)
./run_benchmark.sh -w workloada_shvmdb -o load

# Run phase (execute workload)
./run_benchmark.sh -w workloada_shvmdb -o run

# Multiple workloads
./run_benchmark.sh -w workloada_shvmdb,workloadb_shvmdb -o run

# Custom endpoint
./run_benchmark.sh -w workloada_shvmdb -o load -e https://your-db.workers.dev
```

## Available Workloads

Located in `workloads/`:

- **workloada_shvmdb** - Update Heavy (50% read, 50% update)
- **workloadb_shvmdb** - Read Heavy (95% read, 5% update)
- **workloadc_shvmdb** - Read Only (100% read)
- **workload_write_only** - Write Only (100% insert)

## Results

Benchmark results are stored in `results/run_XXXX/` with auto-incrementing run IDs.

### Latest Results (Run 0001)

| Workload | Throughput | Read p90 | Update p90 |
|----------|------------|----------|------------|
| Read Heavy (95% Read) | 372 ops/sec | 16.2 ms | 20.1 ms |
| Write Heavy (95% Update) | 381 ops/sec | 15.0 ms | 17.7 ms |

Each result file contains:
- Throughput (ops/sec)
- Latency percentiles (p50, p90, p95, p99, p99.9)
- Operation counts and statistics

## Development

### Modifying the ShvmDB Binding

1. Edit code in `ycsb/shvmdb/src/main/java/site/ycsb/db/shvmdb/`
2. Rebuild: `./build_ycsb.sh`
3. Test: `./run_benchmark.sh -w workloada_shvmdb -o load`

### CI/CD

The GitHub Actions workflow (`.github/workflows/build-and-publish.yml`) automatically:
- Builds the shvmdb binding on every push
- Publishes to GitHub Packages
- Uses comprehensive caching for fast builds

### Project Structure

```
shvm-db-benchmark/
├── ycsb/
│   ├── shvmdb/                    # Standalone ShvmDB binding
│   │   ├── pom.xml                # Depends on YCSB 0.17.0 from Maven Central
│   │   └── src/
│   ├── core/                      # YCSB core (for local dev only)
│   └── bin/                       # YCSB runner scripts
├── workloads/                     # Benchmark workload definitions
├── results/                       # Benchmark results (auto-generated)
├── build_ycsb.sh                  # Build script
└── run_benchmark.sh               # Benchmark runner
```

## Troubleshooting

### "Cannot connect to ShvmDB"
- Ensure your shvm-db server is running
- Check the endpoint URL (default: `http://localhost:8787`)
- Verify the server is accessible: `curl http://localhost:8787`

### "Build failed"
- Ensure Maven is installed: `mvn --version`
- Ensure Java 11+ is installed: `java --version`
- Try cleaning: `cd ycsb/shvmdb && mvn clean`

### "Missing dependencies"
- Run `./build_ycsb.sh` to rebuild everything
- Check `ycsb/core/target/dependency/` exists
- Check `ycsb/shvmdb/target/dependency/` exists

## Technical Details

### Maven Coordinates

**ShvmDB Binding:**
```xml
<groupId>in.shvm.ycsb</groupId>
<artifactId>shvmdb-binding</artifactId>
<version>0.18.0-shivam-SNAPSHOT</version>
```

**Upstream YCSB Core:**
```xml
<groupId>site.ycsb</groupId>
<artifactId>core</artifactId>
<version>0.17.0</version>
```

### How It Works

1. **Build Time**: The shvmdb module downloads YCSB 0.17.0 from Maven Central
2. **Runtime**: The `ycsb.sh` script detects it's a source checkout and loads:
   - Core JARs from `core/target/`
   - Core dependencies from `core/target/dependency/`
   - Binding JAR from `shvmdb/target/`
   - Binding dependencies from `shvmdb/target/dependency/`

This hybrid approach gives you:
- Stable, tested YCSB core (0.17.0)
- Custom ShvmDB binding (your code)
- No need to build 50+ unrelated modules
