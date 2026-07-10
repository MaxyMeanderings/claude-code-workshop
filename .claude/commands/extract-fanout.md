---
description: WORKFLOW — run the fixed extraction fan-out over a call transcript (predefined path)
---

You are running a fixed **WORKFLOW**. The path is predefined: dispatch these subagents in **this exact
order**. Do not improvise, reorder, or skip — that is the whole point of a workflow.

Transcript: $ARGUMENTS   (default if none given: `demo/demo-discovery-call.txt`)
Output directory: `demo/extractions/`

1. Dispatch `transcript-preprocessor` on the transcript → `cleaned_transcript.json`.
2. Then dispatch these four on the cleaned transcript → their `*_extracted.json` files:
   `transcript-entity-extractor`, `transcript-action-extractor`,
   `transcript-relationship-extractor`, `transcript-knowledge-extractor`.
3. Then dispatch `transcript-profile-delta`, reading all four → `profile_delta.json`.

**DEMO constraints:** extraction only. Do NOT route to Notion / Airtable / any CRM. Do NOT send anything.

