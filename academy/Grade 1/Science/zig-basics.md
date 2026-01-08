# Zig Academy: The Native Content Engine

## 🎯 Goal
Leverage Zig's raw performance to manage, index, and package educational content at a scale and speed impossible with standard web technologies.

## 🚀 Native Academy Features

### 1. Curriculum Mapper (High-Speed Scanner)
Adapt the current `scanner_safe.zig` to understand the curriculum hierarchy.
- **Function:** Instantly crawl `/academy/subjects` to generate a live map of Grades, Topics, and Lessons.
- **Performance:** Handle 1,000,000+ exercises with <100ms startup time.
- [ ] **Test:** Scan a simulated 100k lesson directory.

### 2. Metadata Indexing (Binary Slabs)
Instead of Elixir parsing JSON thousands of times, Zig performs native metadata extraction.
- **Logic:** Parse `metadata.json` files in the background.
- **Output:** Generate a compact binary "Topic Index" for the Svelte frontend.
- [ ] **Test:** Compare Zig JSON extraction speed vs Elixir `Jason`.

### 3. Content Bundler
Package multiple Markdown/JSON files into a single binary "Lesson Blob" for the student portal.
- **Strategy:** Use Zero-Copy binary packing to minimize memory overhead during transmission.
- **Benefit:** Students receive a single, efficient package containing the whole lesson (text, images, interactive logic).
- [ ] **Test:** Verify bundle integrity via checksums.

### 4. Curriculum Diffing
Support for identifying changes between curriculum versions (Git integration).
- **Function:** Fast native diffing of content to show authors what changed between "Revision A" and "Revision B".

---

## 🛠️ Implementation Phasing

### Phase 1: Content Hierarchy
- Modify scanner to recognize `lesson_` and `quiz_` file patterns.
- Implement specialized metadata extraction for "Grade" and "Subject" tags.

### Phase 2: Search Intelligence
- Implement native sub-string search inside lesson text at >1GB/s.
- Allow authors to "Find every lesson mentioning 'Pythagoras' across all grades."

### Phase 3: Binary Distribution
- Finalize the `AetherAcademyProtocol` for bundling content for the student portal.
