---
name: lint
description: 'Run vault health check — orphan pages, dead links, stale blockers, frontmatter gaps, cross-reference gaps. Usage: /lint or /lint quick'
allowed-tools: Read Glob Grep
---

# Lint: Vault Health Check

Scan the entire vault for structural and content issues. Report findings. Ask before auto-fixing.

**Vault path:** `/Users/gabrielmagno/Documents/Obsidian-Vault/`

---

## Usage

```
/lint                    # full vault health check
/lint knowledge          # only scan 04-knowledge/
/lint tasks              # only scan 03-tasks/
/lint quick              # frontmatter gaps + dead links only (fast)
```

---

## Full Lint Checks (run in order)

### 1. Orphan Pages
Knowledge pages (`04-knowledge/`) with no inbound wikilinks from anywhere in the vault.
- Scan all `.md` files for `[[page-name]]` references
- Pages with zero inbound links are orphans
- Report: page name, type, when created

### 2. Dead Links
Wikilinks `[[page-name]]` that point to non-existent pages anywhere in the vault.
- Scan all `.md` files for `[[...]]` patterns
- Check if target file exists
- Report: source file, broken link, suggested fix (create stub or remove link)

### 3. Stale Blockers
Tasks in `03-tasks/` with `status: blocked` and no update (`updated` field) in 7+ days.
- Read frontmatter of all task files
- Calculate days since `updated`
- Report: task ID, title, blocker, days stale

### 4. Missing Pages
Concepts or entities mentioned in text across multiple pages but lacking their own dedicated page.
- Scan for capitalized terms or technical terms that appear 3+ times across different files
- Check if a corresponding page exists in `04-knowledge/`
- Report: term, files that mention it, suggested type (concept/entity)

### 5. Frontmatter Gaps
Pages missing required frontmatter fields per their schema:
- Tasks (`03-tasks/`): id, title, client, project, status, priority, created, updated
- Entities (`04-knowledge/entities/`): type, entity_type, status, projects
- Concepts (`04-knowledge/concepts/`): type, complexity, domain, status
- Sources (`04-knowledge/sources/`): type, source_type, confidence, key_claims
- Comparisons (`04-knowledge/comparisons/`): type, subjects, dimensions, verdict
- Decisions (`04-knowledge/decisions/`): id, status, project
- Learnings (`04-knowledge/learnings/`): id, type, project

### 6. Empty Sections
Headings (`##`, `###`) with no content underneath them (just the next heading or end of file).
- Scan knowledge pages and project files
- Report: file, empty heading

### 7. Stale Knowledge
Knowledge pages with `status: seed` that haven't been updated in 30+ days.
- Read frontmatter `status` and `updated` fields
- Calculate staleness
- Report: page, type, days since update

### 8. Cross-Reference Gaps
Entity or concept names mentioned in text but not linked with wikilinks.
- Build a list of all entity and concept page names
- Scan all vault `.md` files for plain-text mentions (not already wikilinked)
- Report: file, unlinked mention, suggested link

---

## Report Format

Output findings directly to Ryan in chat, organized by category:

```
## Vault Lint Report — YYYY-MM-DD

### Summary
- Pages scanned: N
- Issues found: N
- By severity: X critical, Y warning, Z info

### Orphan Pages (N)
- page-name.md — no inbound links. Suggest: link from [[Related Page]]

### Dead Links (N)
- [[Missing Page]] in source-file.md — create stub or remove

### Stale Blockers (N)
- TASK-NNNN: "title" — blocked N days, blocker: "..."

### Frontmatter Gaps (N)
- file.md — missing: status, tags

### Stale Seeds (N)
- concept-name.md — seed for N days, needs development
```

---

## Auto-Fix Rules

**Safe to auto-fix (do it):**
- Adding missing `updated` dates from file modification time
- Adding missing `status: seed` to knowledge pages without status

**Ask before fixing:**
- Creating stub pages for dead links
- Adding wikilinks for unlinked mentions
- Deleting orphan pages (might be intentionally standalone)
- Resolving contradictions (requires judgment)
