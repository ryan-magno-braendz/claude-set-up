---
name: Amazon listing quality reference
description: Sven-approved GD GOOD.designs listing as quality benchmark for Amazon DE content generation
type: project
originSessionId: 74755e23-4689-45fe-a00a-76ff00e4cfe2
---
Sven approved the GD GOOD.designs Heart Ring listing (ASIN: B0GVTH7F3P) as the quality standard for generated listings on 2026-04-23.

**Why:** Previous AI output had bad capitalization, nonsensical text, and ugly bullet formatting. Sven specifically said "the text doesn't make sense" and "the capitalization is incorrect."

**How to apply:** Use this listing's style as the benchmark when evaluating or improving the Amazon listing generation workflow. Key style elements:
- Bullets: 1-word CAPS headline, colon, then short natural prose (120-180 chars, not 250)
- Description: Flowing prose telling a product story, no bullet lists
- Capitalization: Standard German Rechtschreibung (nouns capitalized, adjectives lowercase)
- Tone: Professional, concise, native-sounding German

This reference is now embedded directly in the n8n workflow prompts (Bullets 1-5 and Description nodes) as REFERENZBEISPIEL sections.
