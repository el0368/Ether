# Preparation Plan: Native Search Readiness

Before we touch the core logic to add "Native Content Search," we will implement a stability shield to ensure the current Scanner remains flawless.

## 1. Regression Shielding
We will expand `test/ether/native/streaming_test.exs` to include:
- **Unicode Stress**: Filenames with complex emojis and non-standard characters.
- **Deep Nesting**: Paths exceeding 260 characters (Windows MAX_PATH tests).
- **Concurrency Pressure**: Running multiple scans simultaneously to test the Zig thread pool.

## 2. ADR-017: Native Resource Handles (Level 6)
We will transition from "One-off" scans to "Persistent Handles."
- Instead of starting from scratch every time, Elixir will hold a `ResourceHandle` to the Zig Scanner.
- This allows for **Incremental Scanning** and **Context Persistence**.

## 3. The "Pure Logic" Split
We will modify `scanner_safe.zig` to separate the **Filesystem Crawler** (which we already have) from the **Content Searcher** (which we are adding).
- This ensures that a bug in the "Searcher" cannot cause a crash in the "Crawler."

## Verification Plan
1. **Pre-Flight**: Run existing tests (100% pass).
2. **Stress Test**: Run the new expanded native test suite.
3. **Drafting**: Finalize the architectural ADR-017 for user review.
