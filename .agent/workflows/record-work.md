---
description: how to record work history after completing tasks
---

## Record Work History

After completing significant work (feature, phase, bugfix), record it in the documentation.

// turbo-all

1. **Update DEVLOG.md** with session summary:
   ```
   docs/logs/DEVLOG.md
   ```
   Add date, time, what was accomplished, and any issues.

2. **Update WALKTHROUGH.md** with detailed steps:
   ```
   docs/reference/WALKTHROUGH.md
   ```
   Include:
   - Files created/modified
   - Code examples
   - API reference for new modules
   - Verification results

3. **Update task tracker** (if using artifacts):
   ```
   .gemini/antigravity/brain/[conversation-id]/task.md
   ```
   Mark completed items as [x]

4. **Commit and push**:
   ```cmd
   git add docs/
   git commit -m "docs: Update work history"
   git push
   ```

## What to Record

### For Each Session
- Start/end time
- Goals attempted
- Issues encountered
- Resolutions applied
- Commits made

### For Each Feature/Agent
- Module path
- Public API with examples
- Channel events (if applicable)
- Test coverage

### For Each Bug Fix
- Problem description
- Root cause
- Solution applied
- Prevention measures
