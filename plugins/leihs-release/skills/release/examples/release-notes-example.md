# Release Notes Example: Leihs 7.12.0-RC.1

This is an example of properly formatted release notes following the Leihs conventions.

## Final Formatted Notes

```markdown
**Borrow module now supports French (Switzerland) translation.**

---

### admin
- feat: time-range filter for audits-changes

### borrow
- feat: french (switzerland) translation support
- fix: calendar year instead of week-based year

### database
- fix: null constraint for images.filename

### deploy
- chore: upgrade python and ansible
- chore: enable db-backup service

### legacy
- fix: reservations popup positioning

### zhdk-inventory
- fix: inventory hosts
```

## Formatting Rules Applied

### Removed
- "inventory" and "integration-tests" sections (entirely removed)
- All "chore" items from non-deploy repos
- All dependency updates (npm audit fix, update db, update shared-clj, etc.)
- All "Support mise" and "Update database" commits
- All refactor commits

### Kept
- Only "feat:" and "fix:" prefixed items
- Deploy repo chores (infrastructure changes)
- All lowercase formatting
- Proper prefixes on all items

### Added
- Highlight section at top (prose format, bolded)
- Mentioned repo name in highlight
- Horizontal rule separator after highlight

## Original vs Formatted

**Before:** ~150 items across 12 sections with many chores
**After:** ~10 items across 6 sections, focused on user-facing changes

**Highlight criteria:**
- Notable user-facing features
- Significant improvements
- Major fixes
- New capabilities
