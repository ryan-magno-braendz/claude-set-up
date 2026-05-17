---
name: vault_second_brain
description: Obsidian Vault expanded to full second brain — entities, sources, comparisons, hot cache, hooks, ingest, lint, CSS callouts, cross-project knowledge layer
type: project
originSessionId: f60a42bf-c8ba-4871-a855-bcb72f65f2de
---
Ryan's Obsidian Vault at `/Users/gabrielmagno/Documents/Obsidian-Vault/` was expanded from a work tracker to a full second brain on 2026-04-23.

**Why:** Ryan wants the vault to be where he dumps everything instead of keeping it all in his head. When he works on a project that uses a technology he's used before, the vault should surface those connections automatically. Knowledge compounds across engagements.

**What was added:**
- `04-knowledge/entities/` — people, orgs, tools, services (entity_type: person|organization|tool|service|product)
- `04-knowledge/sources/` — articles, papers, docs studied (with confidence: high|medium|low)
- `04-knowledge/comparisons/` — side-by-side analyses with subjects, dimensions, verdict
- Knowledge status lifecycle: seed → developing → mature → evergreen
- `00-dashboard/hot-cache.md` — 500-word context cache, auto-loaded via hooks
- Hooks: SessionStart (read hot cache), PostCompact (restore after compaction), Stop (prompt update)
- CSS callouts: `[!contradiction]`, `[!gap]`, `[!key-insight]`, `[!stale]`
- Vault colors CSS snippet for color-coded folders
- Ingest operation (section 12 of CLAUDE.md) — source → entities + concepts + cross-refs
- Vault lint (section 13) — 8-category health check
- New Bases dashboards: knowledge.base, entities.base, sources.base, comparisons.base
- Enhanced existing dashboards with formulas: age_days, days_until_due, urgency, blocked_days, stale_alert
- Templates: entity.md, source.md, comparison.md added to 06-meta/templates/

**How to apply:** The vault's CLAUDE.md (now 19 sections) is the authoritative reference. Cross-project access uses Rule 5 in global CLAUDE.md. Hot cache is the cheapest way to restore context (~500 tokens).

**Source of patterns:** Adapted from claude-obsidian plugin (cloned to `.raw/claude-obsidian/`), based on Andrej Karpathy's LLM Wiki pattern.
