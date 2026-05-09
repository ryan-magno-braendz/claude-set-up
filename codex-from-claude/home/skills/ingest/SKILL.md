---
name: ingest
description: Ingest a source into the knowledge base — extracts entities, concepts, cross-references. Usage: /ingest .raw/file.md or /ingest https://url
allowed-tools: Read Write Edit Glob Grep Bash WebFetch
---

# Ingest: Process Sources Into the Knowledge Base

Read the source. Extract knowledge. Cross-reference everything. A single source typically touches 5-15 knowledge pages.

**Vault path:** `/Users/gabrielmagno/Documents/Obsidian-Vault/`
**Knowledge base:** `04-knowledge/` (concepts, entities, sources, comparisons, decisions, learnings)
**Raw sources:** `.raw/`
**Schemas:** Read CLAUDE.md sections 8 (entities), 9 (sources), 10 (comparisons), 12 (ingest operation)

---

## Usage

```
/ingest .raw/filename.md          # ingest a file from .raw/
/ingest https://example.com/...   # ingest a URL
/ingest .raw/articles/            # batch ingest all files in a folder
/ingest force .raw/filename.md    # re-ingest even if already processed
```

---

## Delta Tracking

Before ingesting, check `.raw/.manifest.json` to avoid reprocessing unchanged sources.

**Before ingesting a file:**
1. Compute hash: `md5 -q [file]` (macOS) or `md5sum [file] | cut -d' ' -f1`
2. Check if the path exists in `.raw/.manifest.json` with the same hash
3. If hash matches → skip. Report: "Already ingested (unchanged). Use `force` to re-ingest."
4. If missing or hash differs → proceed

**After ingesting:**
Record `{hash, ingested_at, pages_created, pages_updated}` in `.raw/.manifest.json`

---

## URL Ingestion

When the argument starts with `https://`:

1. Fetch the page using WebFetch
2. If `defuddle` is available (`which defuddle 2>/dev/null`), run it to strip ads/nav/clutter (saves 40-60% tokens)
3. Derive slug from URL path (last segment, lowercased, hyphens)
4. Save to `.raw/articles/[slug]-[YYYY-MM-DD].md` with frontmatter: `source_url`, `fetched`
5. Proceed with single source ingest

---

## Single Source Ingest

1. **Read** the source completely. Do not skim.
2. **Discuss** key takeaways with Ryan. Ask: "What should I emphasize?" Skip if Ryan says "just ingest it."
3. **Create** source summary in `04-knowledge/sources/YYYY-MM-DD-slug.md` using source schema (CLAUDE.md §9). Include `key_claims`, `confidence`, `source_type`, `author`, `url`.
4. **Create or update** entity pages in `04-knowledge/entities/` for every person, org, product, tool mentioned. Use entity schema (CLAUDE.md §8). Check existing entities first — update, don't duplicate.
5. **Create or update** concept pages in `04-knowledge/concepts/` for significant ideas. Check existing concepts first.
6. **Cross-reference** — link new pages to existing ones. Check for bidirectional links. Every mention of an existing entity or concept should be a `[[wikilink]]`.
7. **Check for contradictions.** If new info conflicts with existing pages:
   ```markdown
   > [!contradiction] Conflict with [[New Source]]
   > [[Existing Page]] claims X. [[New Source]] says Y.
   > Needs resolution. Check dates, context, and primary sources.
   ```
   Add the callout on BOTH pages. Never silently overwrite old claims.
8. **Flag gaps** where claims need more evidence:
   ```markdown
   > [!gap] This needs more evidence.
   > Only one source supports this claim.
   ```
9. **Update** `00-dashboard/hot-cache.md` with this ingest's context.
10. **Prompt Ryan** if any decisions or learnings should be captured.

---

## Batch Ingest

When given a folder or multiple files:

1. List all files to process. Confirm with Ryan.
2. Process each source following single ingest flow. Defer cross-referencing until step 3.
3. After all sources: cross-reference pass. Look for connections between newly ingested sources.
4. Update hot cache once at the end (not per-source).
5. Report: "Processed N sources. Created X pages, updated Y pages. Key connections: ..."

For 10+ sources, check in with Ryan after every 5.

---

## Writing Quality

All content must be **explanatory and descriptive**. This is Ryan's long-term memory:
- Source summaries: explain what the source covers and why it matters, not just a title
- Entity pages: explain who/what this is, Ryan's relationship to it, and connections
- Concept pages: explain the concept so future Ryan can recall it without rereading the source
- Key claims: state them as standalone facts, not "the article says..."

---

## What NOT to Do

- Never modify files in `.raw/` — they are immutable source documents
- Never create duplicates — always check existing pages via Glob/Grep first
- Never skip the hot cache update
- Never write terse, context-free content
- Never quote `.raw/` verbatim — always paraphrase into Ryan's own understanding
