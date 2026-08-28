# Changesets

Add a changeset for releasable changes to skills or skill references.

Use this format:

```md
---
"custom-skills": patch
---

Short description of the user-facing or operational change.
```

Use `patch`, `minor`, or `major` according to the release impact:

- **patch**: Bug fixes, documentation updates, reference improvements
- **minor**: New skills, new references, non-breaking enhancements
- **major**: Breaking changes to skill interfaces or significant restructuring

## Examples

**Patch** - Documentation or minor improvements:
```md
---
"custom-skills": patch
---

Fix typo in azure-architecture SKILL.md
```

**Minor** - New skills or features:
```md
---
"custom-skills": minor
---

Add new kubernetes-architecture skill with best practices
```

**Major** - Breaking changes:
```md
---
"custom-skills": major
---

Restructure all Azure skills to use new reference loading protocol
```
