---
name: Twilio dispatch SMS blocked by 30044
description: Dispatch pre-call SMS (5 segments) always fails with error 30044 on trial account. Short SMS (form/payment links, 1 segment) deliver fine. Fix requires Twilio upgrade or shortening the message.
type: project
---

Dispatch pre-call SMS in WF8 fails 100% of the time with Twilio error 30044 (spam/content filter).

**Evidence (2026-03-16 investigation):**
- All 3 dispatch SMS attempts: FAILED (error 30044, 5 segments each)
- All form link SMS: DELIVERED (1 segment)
- All payment link SMS: DELIVERED (1 segment)
- Same sender (+12282252906), same recipient (+61493571124, verified), same trial account
- Root cause: message length (5 segments) + content pattern (GPS coords, phone number in body) triggers spam filter on trial account

**Why:** Twilio trial accounts apply aggressive content filtering. Multi-segment messages with phone numbers and coordinates in the body get flagged.

**How to apply:** When Twilio is upgraded to a paid account, re-test the dispatch SMS. If it still fails, shorten the message to 1-2 segments (rego, category, suburb, driver phone only — voice agent provides full details during call). The n8n workflow (WF8) is working correctly — the SMS node executes, Twilio accepts and queues the message, then silently drops it.

**Test phone override still active:** WF8 "Prepare First Dispatch" node has `provider_phone: '+61493571124'` hardcoded. Remove before production.
