# Ether Benchmark Dashboard

Interactive performance tracking for the Ether IDE native scanner.

## 📊 View Dashboard

Open `index.html` in your browser to see:
- **Latest Performance**: Current Elixir vs Zig NIF throughput
- **Historical Trends**: Line chart showing performance over time
- **Comparison View**: Bar chart of recent benchmark runs
- **Statistics**: Performance gain, total runs, last updated

## 🚀 Running Benchmarks

### Automated Benchmark (Recommended)
```bash
# Runs 500 iterations and saves to history.json
iex -S mix
> Ether.Benchmark.run()
```

### Manual Benchmark
```bash
# Quick comparison (1000 iterations)
mix run bench/scanner_bench.exs
```

### FCP Benchmark
```bash
# Latency test (100 iterations)
mix run benchmark_fcp.exs
```

## 📁 Files

- `index.html` - Interactive dashboard (open in browser)
- `data.js` - Latest benchmark data (auto-generated)
- `history.json` - Historical results (last 100 runs)
- `scanner_bench.exs` - Manual benchmark script

## 🌐 Hosting on GitHub Pages

To make the dashboard publicly accessible:

1. Push to GitHub
2. Go to Settings → Pages
3. Source: Deploy from branch `main`
4. Directory: `/bench`
5. Visit: `https://el0368.github.io/Ether/`

## 📈 Data Format

```json
[
  {
    "timestamp": "2026-01-07T12:00:00Z",
    "elixir_ops_sec": 408.12,
    "zig_ops_sec": 11876.48
  }
]
```
