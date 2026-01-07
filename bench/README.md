# Ether Benchmark Suite

Comprehensive performance tracking for the Ether IDE.

## 📊 Benchmark Types

### 1. **Performance Benchmarks** (Automated)
Tracks throughput and latency over time.

```bash
# Run automated benchmark
iex -S mix
> Ether.Benchmark.run()

# Set new baseline
> Ether.Benchmark.set_baseline()
```

### 2. **Microbenchmarks** (NIF Operations)
Measures individual function performance.

```bash
mix run bench/nif_microbench.exs
```

**Tests:**
- Context create/destroy overhead
- Binary encoding/decoding speed
- Scan and search operations

### 3. **Load Testing** (Concurrency)
Tests system under concurrent load.

```bash
mix run bench/load_test.exs
```

**Scenarios:**
- Concurrent scans (10, 50, 100 parallel)
- Concurrent searches
- Mixed workloads
- Sustained load (30 seconds)
- Spike scenarios

### 4. **Memory Profiling**
Detects memory leaks and tracks allocation patterns.

```bash
mix run bench/memory_bench.exs
```

**Metrics:**
- Memory before/after operations
- Leak detection over sustained operations
- Context lifecycle memory usage

### 5. **Web Vitals**
Measures frontend performance metrics.

```bash
# Backend metrics (TTFB, FCP proxy, TTI)
mix run bench/web_vitals.exs

# Frontend metrics (LCP, FID, CLS)
# Open app in browser and check console
```

### 6. **Regression Detection** (CI)
Automatically runs on every PR.

- Compares against baseline
- Posts results as PR comment
- Fails if regression >10%

## 📁 Files

| File | Purpose |
|------|----------|
| `index.html` | Interactive dashboard |
| `data.js` | Latest benchmark data (auto-generated) |
| `history.json` | Historical results (last 100 runs) |
| `baseline.json` | Performance baseline for regression detection |
| `ci_results.json` | CI-friendly output (auto-generated) |
| `nif_microbench.exs` | NIF operation benchmarks |
| `load_test.exs` | Concurrency and stress tests |
| `memory_bench.exs` | Memory profiling |
| `web_vitals.exs` | Web performance metrics |
| `scanner_bench.exs` | Quick manual comparison |

## 🌐 Dashboard

Open `index.html` in your browser to see:
- Latest performance stats
- Historical trends (line chart)
- Performance comparison (bar chart)

## 🚀 CI Integration

Benchmarks run automatically on every PR via GitHub Actions.

**Workflow:** `.github/workflows/benchmark.yml`

**Output:**
- PR comment with results
- Fails if regression detected (>10% slower)
- Exports results to `bench/ci_results.json`

## 📈 Regression Detection

### Set Baseline
```bash
iex -S mix
> Ether.Benchmark.set_baseline()
```

### Check Against Baseline
```bash
> Ether.Benchmark.run()
# Automatically compares against baseline
# Warns if >10% slower
```

### Thresholds
- **Regression**: >10% slower than baseline
- **Improvement**: >10% faster than baseline
- **OK**: Within ±10% of baseline

## 🎯 Performance Targets

| Metric | Target | Current |
|--------|--------|----------|
| Scanner Throughput | >10,000 files/sec | ~12,000 |
| Search Throughput | >8,000 matches/sec | ~8,500 |
| FCP (First Chunk) | <5ms | ~0.28ms |
| Memory Leak | <1MB growth | ✅ None |
| TTFB | <100ms | - |
| LCP | <2.5s | - |

## 🌐 Hosting on GitHub Pages

To make the dashboard publicly accessible:

1. Push to GitHub
2. Go to Settings → Pages
3. Source: Deploy from branch `main`
4. Directory: `/bench`
5. Visit: `https://el0368.github.io/Ether/`

