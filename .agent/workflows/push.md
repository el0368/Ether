---
description: how to commit and push changes to GitHub
---

## Push to GitHub

// turbo-all

1. **Record work history first** (see `/record-work`):
   - Update `docs/DEVLOG.md` with session summary
   - Update `docs/WALKTHROUGH.md` if major feature

2. Stage all changes:
   ```cmd
   git add .
   ```

3. Commit with a descriptive message:
   ```cmd
   git commit -m "feat: description of changes"
   ```

4. Push to remote:
   ```cmd
   git push
   ```

## Commit Message Format

Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `refactor:` - Code change that neither fixes a bug nor adds a feature
- `chore:` - Build process or auxiliary tool changes
- `test:` - Adding or fixing tests
