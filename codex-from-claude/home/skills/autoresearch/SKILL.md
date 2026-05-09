---
name: autoresearch
description: Run autonomous 3-round web research on a topic, file all findings into the knowledge base. Usage: /autoresearch [topic]
allowed-tools: Read Write Edit Glob Grep Bash WebFetch WebSearch
---

# AutoResearch: Autonomous Research Loop

Take a topic, run iterative web searches, synthesize findings, and file everything into the knowledge base. Ryan gets knowledge pages, not a chat response.

**Vault path:** `/Users/gabrielmagno/Documents/Obsidian-Vault/`

---

## Usage

```
/autoresearch phonetic search algorithms for trademark matching
/autoresearch Azure AI Search vector quantization options
/autoresearch n8n vs Temporal for workflow automation
```

---

## Research Loop

```
Input: topic (from user command)

Round 1: Broad search
1. Decompose topic into 3-5 distinct search angles
2. For each angle: run 2-3 web searches (prefer Tavily, then WebSearch)
3. For top 2-3 results per angle: fetch the page content
4. Extract: key claims, entities, concepts, open questions

Round 2: Gap fill
5. Identify what's missing or contradicted from Round 1
6. Run targeted searches for each gap (max 5 queries)
7. Fetch top results for each gap

Round 3: Synthesis check (only if major gaps remain)
8. One more targeted pass on remaining contradictions
9. Otherwise: proceed to filing

Max rounds: 3. Stop when depth is reached.
```

---

## Filing Results

After research, create these pages in the vault:

### Source pages (`04-knowledge/sources/`)
One page per major reference found. Use source schema (CLAUDE.md §9):
- `source_type`, `author`, `date_published`, `url`, `confidence`, `key_claims`
- Body: summary of what the source contributes

### Concept pages (`04-knowledge/concepts/`)
One page per significant concept extracted. Check existing concepts first — update rather than duplicate. Include sections: Definition, How It Works, Why It Matters, Examples, Connections, Sources.

### Entity pages (`04-knowledge/entities/`)
One page per significant person, org, or product identified. Check existing entities first.

### Synthesis page (`04-knowledge/sources/`)
Master synthesis titled `YYYY-MM-DD-research-[topic-slug].md`:

```yaml
---
type: source
title: "Research: [Topic]"
source_type: research-synthesis
confidence: medium
key_claims: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [source, research]
status: developing
related: ["[[every page created in this session]]"]
projects: []
---
```

Sections: Overview, Key Findings, Key Entities, Key Concepts, Contradictions, Open Questions, Sources.

---

## After Filing

1. **Cross-reference** all new pages with existing knowledge. Add wikilinks in both directions.
2. **Check for contradictions** with existing vault content. Use `> [!contradiction]` callouts.
3. **Update** `00-dashboard/hot-cache.md` with the research summary.
4. **Report** to Ryan:

```
Research complete: [Topic]

Rounds: N | Searches: N | Pages created: N | Pages updated: N

Created:
  04-knowledge/sources/YYYY-MM-DD-research-topic.md (synthesis)
  04-knowledge/sources/YYYY-MM-DD-source-name.md
  04-knowledge/concepts/concept-name.md
  04-knowledge/entities/entity-name.md

Key findings:
- [Finding 1]
- [Finding 2]

Open questions:
- [Gap 1]
- [Gap 2]
```

---

## Confidence Scoring

Label every claim with confidence when filing:

- **high**: multiple independent authoritative sources agree, or official documentation
- **medium**: single good source, or sources partially agree
- **low**: speculation, opinion, single informal source, or unverified claim

Mark claims from sources older than 3 years as potentially stale using `> [!stale]`.

---

## Search Preferences

- **Prefer**: official documentation, .edu, peer-reviewed papers, established publications, GitHub repos with significant stars
- **Deprioritize**: Reddit posts, undated pages, social media, sources that don't cite their own claims
- **Always note**: source date for factual claims
- **Prefer recent**: sources from the last 2 years unless the topic is foundational

---

## Constraints

- Max search rounds: 3
- Max pages created per session: 15
- Max sources fetched per round: 5
- If constraints are hit before completion: file what you have, note skipped areas in Open Questions
- Do not fabricate from training data — if a claim can't be sourced, mark it `> [!gap]`
