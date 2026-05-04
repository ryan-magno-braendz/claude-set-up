---
name: save
description: Save current conversation insights as a permanent knowledge page in the vault. Usage: /save or /save "Page Title"
allowed-tools: Read Write Edit Glob Grep
---

# Save: File Conversations Into the Knowledge Base

Good answers and insights shouldn't disappear into chat history. This command takes what was just discussed and files it as a permanent knowledge page.

**Vault path:** `/Users/gabrielmagno/Documents/Obsidian-Vault/`

---

## Usage

```
/save                    # Claude determines the best note type and name
/save "Page Title"       # Save with a specific title (skips naming question)
```

---

## Note Type Decision

Determine the best type from the conversation content:

| Type | Folder | Use when |
|------|--------|---------|
| concept | `04-knowledge/concepts/` | Explaining or defining an idea, pattern, framework, or technology |
| entity | `04-knowledge/entities/` | Discussing a person, org, tool, service, or product |
| source | `04-knowledge/sources/` | Summarizing external material discussed in the session |
| comparison | `04-knowledge/comparisons/` | Analyzing alternatives or trade-offs |
| decision | `04-knowledge/decisions/` | A technical or architectural decision that was made |
| learning | `04-knowledge/learnings/` | An error debugged, a win, or a category-level insight |

If Ryan specifies a type, use it. Otherwise pick the best fit. When in doubt, use concept.

---

## Save Workflow

1. **Scan** the current conversation. Identify the most valuable content to preserve.
2. **Ask** (if no title given): "What should I call this note?" Keep the name short and descriptive.
3. **Determine** note type using the table above.
4. **Extract** all relevant content. Rewrite in declarative present tense — not "the user asked" but the actual knowledge itself.
5. **Create** the note in the correct folder with full frontmatter per the relevant schema (CLAUDE.md §6-10).
6. **Cross-reference**: identify any existing wiki pages mentioned in the conversation. Add them to `related:` in frontmatter. Add wikilinks in the body.
7. **Check for duplicates**: search existing pages before creating. If a page on this topic exists, update it instead.
8. **Update** `00-dashboard/hot-cache.md` to reflect the new addition.
9. **Confirm**: "Saved as [[page-name]] in 04-knowledge/[folder]/."

---

## Writing Style

- Declarative, present tense. Write the knowledge, not the conversation.
- **Not:** "The user asked about X and Claude explained..."
- **Yes:** "X works by doing Y. The key insight is Z."
- Explanatory and descriptive — future Ryan should understand this cold
- Link every mentioned concept, entity, or wiki page with `[[wikilinks]]`
- Cite sources where applicable: `(Source: [[page-name]])`

---

## What to Save vs Skip

**Save:**
- Non-obvious insights or synthesis
- Decisions with rationale
- Analyses that took significant effort
- Research findings
- Technical patterns worth remembering
- Comparisons that are likely to be referenced again

**Skip:**
- Mechanical Q&A with obvious answers
- Setup steps already documented elsewhere
- Temporary debugging with no lasting insight
- Anything already in the vault (update existing page instead)
