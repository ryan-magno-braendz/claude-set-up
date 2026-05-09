---
name: sync-vault
description: End-of-session vault sync — scans the conversation for decisions, learnings, entities, concepts, task updates, and log entries, then persists everything to the vault in one pass. Run before ending a session. Usage: /sync-vault
allowed-tools: Read Write Edit Glob Grep Bash
---

# Sync Vault: End-of-Session Knowledge Persistence

Scan the entire conversation. Find everything worth persisting. Write it all to the vault in one pass. This is the "flush to disk" operation for your second brain.

**Vault path:** `/Users/gabrielmagno/Documents/Obsidian-Vault/`

---

## Usage

```
/sync-vault              # full scan and persist
```

Run this before ending any session where meaningful work happened.

---

## What to Scan For

Review the entire conversation and check each category. Skip categories with nothing to persist.

### 1. Decisions Made
Any technical or architectural choice where two or more real options existed.
- **Create:** `04-knowledge/decisions/YYYY-MM-DD-slug.md` per CLAUDE.md §6
- **Or update:** existing decision if it was revisited

### 2. Learnings Discovered
Errors debugged (>30 min), unexpected wins, category-level insights.
- **Create:** `04-knowledge/learnings/YYYY-MM-DD-slug.md` per CLAUDE.md §7

### 3. New Entities Encountered
People, organizations, tools, services, or products mentioned for the first time.
- **Create:** `04-knowledge/entities/slug.md` per CLAUDE.md §8
- **Or update:** existing entity with new context, connections, or project links

### 4. New Concepts Learned
Technical concepts, patterns, or methodologies discussed in depth.
- **Create:** `04-knowledge/concepts/slug.md`
- **Or update:** existing concept with new information

### 5. Comparisons Analyzed
Side-by-side evaluations of alternatives.
- **Create:** `04-knowledge/comparisons/YYYY-MM-DD-slug.md` per CLAUDE.md §10

### 6. Sources Referenced
Articles, docs, or URLs that were read and discussed.
- **Create:** `04-knowledge/sources/YYYY-MM-DD-slug.md` per CLAUDE.md §9

### 7. Task Updates
Any task that was worked on, completed, or had its status changed.
- **Update:** `03-tasks/TASK-NNNN-*.md` — update `status`, `updated` date, append to `## Notes`
- **If completed:** set `status: done`, populate `completed` date

### 8. Daily Log Entries
Work done on any client during this session.
- **Append:** to `<client-path>/log.md` — reverse chronological, today's date heading, 3-7 bullets

### 9. Contradictions with Existing Knowledge
Anything discussed that conflicts with what's already in the vault.
- **Add:** `> [!contradiction]` callouts on both the existing page and new content

---

## Workflow

1. **Scan** — Review the full conversation. For each of the 9 categories above, list what needs to be persisted. Present the list to Ryan:

```
## Session Sync Summary

### Will create:
- Decision: "Chose X over Y for Z" → 04-knowledge/decisions/YYYY-MM-DD-slug.md
- Learning: "Discovered that A causes B" → 04-knowledge/learnings/YYYY-MM-DD-slug.md
- Entity: "New Tool Name" → 04-knowledge/entities/slug.md

### Will update:
- TASK-0005: status → done, add completion notes
- braendz/log.md: append today's entries
- Entity: azure-ai-search.md — add new project link

### Will skip:
- No new comparisons
- No new sources

Proceed?
```

2. **Confirm** — Wait for Ryan to approve or adjust.

3. **Execute** — Create and update all files. For each:
   - Check for duplicates before creating (Glob/Grep)
   - Follow the relevant schema from CLAUDE.md
   - Use next available ID for decisions (DEC-NNNN) and learnings (LEARN-NNNN)
   - Cross-reference new pages with existing ones (bidirectional wikilinks)
   - Write explanatory, descriptive content — not terse summaries

4. **Update hot cache** — Overwrite `00-dashboard/hot-cache.md` with updated context.

5. **Report** — Confirm what was persisted:

```
## Sync Complete

Created: 3 files
Updated: 4 files
Hot cache: refreshed

New:
- 04-knowledge/decisions/2026-04-24-chose-unified-index.md
- 04-knowledge/learnings/2026-04-24-beider-morse-replace-bug.md
- 04-knowledge/entities/new-tool.md

Updated:
- 03-tasks/TASK-0005 (status: done)
- 01-fulltime/braendz/log.md (appended 2026-04-24)
- 04-knowledge/entities/azure-ai-search.md (added project link)
- 00-dashboard/hot-cache.md (refreshed)
```

---

## Writing Quality

All persisted content must be **explanatory and descriptive**:
- Decisions: full context, alternatives, consequences — not just "chose X"
- Learnings: symptom, root cause, fix, prevention — not just "fixed bug"
- Entities: who/what, role, connections, experience notes — not just a name
- Log entries: what was done AND why it matters — not just "worked on X"
- Task notes: what was tried, what worked, what didn't, next move

---

## What NOT to Persist

- Mechanical back-and-forth (clarification questions, typo corrections)
- Information already in the vault (check first, update if needed)
- Temporary debugging steps with no lasting insight
- Setup/configuration steps already documented
- Conversation about vault system itself (meta-operations)
