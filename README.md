# shvm-db Benchmark

This repository contains the YCSB benchmark setup for [shvm-db](https://github.com/shivamd20/shvm-db).

## Architecture
- **shvm-db**: Running locally on Cloudflare Workers (via `wrangler dev` on port 8787).
- **YCSB**: Java benchmark client.
- **Binding**: Custom `shvmdb` binding (`site.ycsb.db.shvmdb.ShvmDBClient`) that talks to shvm-db via HTTP (DynamoDB-compatible JSON).

## Prerequisites
1.  **Java 11+** installed (`java -version`).
2.  **Maven** installed (`mvn -v`).
3.  **shvm-db** running locally:
    ```bash
    cd /path/to/shvm-db
    npm start
    ```

## Setup & Build
The YCSB source and bindings are included in the `ycsb/` directory.

To report/rebuild the binding:
```bash
cd ycsb
mvn -pl site.ycsb:shvmdb-binding -am clean package -DskipTests
# Ensure dependencies are copied for the runner script
mvn dependency:copy-dependencies -pl core
```

## Running the Benchmark
A convenience script `run_benchmark.sh` is provided to run the full suite (Workloads A, B, C, and Write-Only):

```bash
./run_benchmark.sh
```

This script will:
1.  **Load** data (Workload A load phase).
2.  **Run Workload A** (Update Heavy: 50/50).
3.  **Run Workload B** (Read Heavy: 95/5).
4.  **Run Workload C** (Read Only: 100/0).
5.  **Run Write-Only** (Insert 100%).

Results are saved to `results/` directory with timestamps.

## Workloads
Configuration files are in `workloads/`:
- `workloada_shvmdb`: Update Heavy
- `workloadb_shvmdb`: Read Heavy
- `workloadc_shvmdb`: Read Only
- `workload_write_only`: Stress test writes

## Current Results (Summary)
See `results/summary.md` for the latest run.

| Workload | Throughput (ops/sec) | Read Latency (p99) | Update Latency (p99) |
|---|---|---|---|
| Workload A | ~835 | ~16 ms | ~18 ms |
| Workload B | ~830 | ~23 ms | ~27 ms |
| Workload C | ~670 | ~28 ms | N/A |
| Write Only | ~550 | N/A | ~35 ms |

*Note: Benchmarks run against local `miniflare` instance.*
