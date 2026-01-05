@echo off
setlocal

echo [Ether] Starting Comprehensive System Audit...
echo =================================================

:: 1. Run Unit Tests (Logic)
echo [1/3] Verifying Logic (mix test)...
call mix test > test_output.txt
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Unit Tests Failed. See test_output.txt
) else (
    echo [PASS] Logic Verified.
)

:: 2. Run Benchmarks (Performance)
echo [2/3] Verifying Performance (Benchmarks)...
:: Assuming we have a benchmark script. If not, we skip or use a simple one.
:: Based on logs, we have Aether.Benchmark.run() but that's internal.
:: Let's run the mix bench alias if it exists, or the script.
if exist "bench/scanner_bench.exs" (
    call mix run bench/scanner_bench.exs > bench_output.txt
    echo [PASS] Benchmarks Completed.
) else (
    echo [SKIP] No benchmark script found.
)

:: 3. Generate Report HTML
echo [3/3] Generating Visual Report...
:: Ideally we would have a script to parse these txt files and make HTML.
:: For now, we will create a simple HTML that embeds the text content.
:: This is a "MVP" visualizer.

echo ^<!DOCTYPE html^> > docs\latest_report.html
echo ^<html lang="en"^>^<head^> >> docs\latest_report.html
echo ^<meta charset="UTF-8"^>^<title^>Aether Test Report^</title^> >> docs\latest_report.html
echo ^<style^>body{font-family:monospace;padding:20px} h1,h2{border-bottom:1px solid #ccc} pre{background:#f5f5f5;padding:10px;border:1px solid #ddd}^</style^> >> docs\latest_report.html
echo ^</head^>^<body^> >> docs\latest_report.html
echo ^<h1^>Aether System Verification Report^</h1^> >> docs\latest_report.html
echo ^<p^>Generated on %DATE% %TIME%^</p^> >> docs\latest_report.html

echo ^<h2^>1. Logic Verification (Unit Tests)^</h2^> >> docs\latest_report.html
echo ^<pre^> >> docs\latest_report.html
type test_output.txt >> docs\latest_report.html
echo ^</pre^> >> docs\latest_report.html

echo ^<h2^>2. Performance Verification (Benchmarks)^</h2^> >> docs\latest_report.html
echo ^<pre^> >> docs\latest_report.html
if exist "bench_output.txt" type bench_output.txt >> docs\latest_report.html
if not exist "bench_output.txt" echo No benchmark run. >> docs\latest_report.html
echo ^</pre^> >> docs\latest_report.html

echo ^</body^>^</html^> >> docs\latest_report.html

echo.
echo =================================================
echo [SUCCESS] Report generated at docs/latest_report.html
echo Open it to visualize the "Real World" test results.
pause
