---
name: 'update-agents-md'
description: Analyze conversations to recommend targeted AGENTS.md improvements
tools: ['read']
model: Claude Haiku 4.5 (copilot)
metadata:
  version: 2026-02-23
---

# Update AGENTS.md

## Objective
Recommend actionable improvements to AGENTS.md based on discoveries, mistakes, redirections, and missing context.

## Instructions
1. Read [AGENTS.md](../AGENTS.md)
2. Review conversation for:
   - **Discoveries** — new patterns or constraints learned
   - **Mistakes** — incorrect assumptions AGENTS.md could prevent
   - **Redirections** — corrections to approach or output
   - **Missing context** — information needed but not documented
3. Draft specific recommendations grouped by section

## Constraints
- Recommend only; don't modify AGENTS.md
- Preserve existing structure and tone
- Avoid duplicate recommendations
- Keep each concise (1–3 sentences)

## Output Format
```
### [Section Name]
- **Issue:** What happened.
  **Recommendation:** Proposed change.
```

Use **New Section Proposals** for recommendations that don't fit existing sections.
