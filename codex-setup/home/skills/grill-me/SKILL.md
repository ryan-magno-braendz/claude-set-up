---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

## Phase 1: Context

If the user points to a written plan, design doc, or file — read it first.
If the user describes the idea verbally, start grilling from what they said.
If there's a relevant codebase, explore it to ground your questions in reality.

Identify the decision tree — every branch where a choice exists or an assumption
is implicit.

## Phase 2: Grill

Work through the decision tree one question at a time, starting with the most
foundational decisions (ones that other decisions depend on).

For each question:
1. Ask the question. Be specific — reference the relevant part of the plan or idea.
2. Wait for the user's answer.
3. If the answer has gaps or risks, push back with follow-ups before moving on.
4. Once resolved, state the resolved decision clearly and move to the next.
5. If the user says "I don't know yet", flag it as OPEN and continue — return
   to open items at the end.

If a question can be answered by exploring the codebase, explore it yourself
instead of asking.

### Grilling standards
- Don't accept vague answers. Push for specifics.
- Challenge assumptions — "why not X instead?"
- Surface implicit dependencies between decisions.
- When you have a recommendation, offer it — but after the user answers, not before.

## Phase 3: Summary

When all branches are resolved (or explicitly marked OPEN), produce a decision
summary:

**Resolved decisions** — numbered list of what was decided and why.
**Open items** — what still needs answers, and what's blocked by each.
**Risks surfaced** — anything that came up during grilling that deserves attention.
