# Observability Demo Runbook — transcript-pipeline × MLflow

**What this demonstrates:** a real multi-agent build (Tyler's `transcript-pipeline`) running under
MLflow, so the room sees the agent loop *and* the governance record it leaves behind —
**which agent ran, what it touched, what it cost.** This is governance layer 2 made visible.

**Where it sits in the agenda:**
- **1:08 — Delegation + the dial:** run the pipeline live; the room watches the subagent fan-out in the terminal.
- **1:18 — Understand what you built:** open MLflow, read the trace tree. The comprehension + governance close.

**Base build:** run on the synthetic transcript, **extraction-only** (no Notion/Airtable routing).
Fully local, no external writes, repeatable, no real CRM data on stage.

> **✓ Content validated (rehearsed 2026-06-29):** all 6 subagents ran clean in batch mode (no
> pausing) on `demo-discovery-call.txt` → 12 entities, 5 action items (dates resolved), 5/5 relationship
> read, 4 content signals, 16 profile additions. **Total spend ≈ 149,400 tokens** across the 6 agents
> (preprocess 22.0k · entities 23.8k · actions 24.5k · relationships 22.4k · knowledge 24.2k ·
> profile-delta 32.4k) — that's the ballpark "what it cost" number the MLflow trace will show.
> Sample outputs live in `demo/extractions/` and double as the fallback if a live subagent
> misbehaves.

**► CHOSEN FOR THIS WORKSHOP: Variant B (fan-out).** Variant A is kept below as a faithfulness
footnote / fallback if a subagent misbehaves live.

**Two ways to run it (they produce different traces):**

- **Variant A — faithful (your real pipeline).** Dispatch `transcript-pipeline` as-is. It has tools
  `Read, Write, Bash, Glob, Grep` and **no Task tool**, so it does all five extraction stages *inline,
  itself*. Trace = ONE subagent span with a long series of LLM turns + Write calls (one artifact per
  stage). 100% your production build. Honest, simple, still a clean "what it touched + what it cost"
  story — but NOT a multi-agent fan-out.
- **Variant B — fan-out (a thin demo orchestrator over your existing extractor agents).** Dispatch
  your standalone agents — `transcript-preprocessor` → `entity / action / relationship / knowledge`
  → `transcript-profile-delta` — as *separate* subagents. Trace = a real **fan-out tree**: six sibling
  subagent spans under the session root, each with its own token + cost. Visually the strongest
  "which agent ran / delegation" payoff — but it's a demo wiring, not your production pipeline.

**Verified against MLflow primary docs (2026):** the Claude Code integration captures *"subagent
invocations with full nested trace"* with per-span token counts + cost — so Variant B's separate
subagents each render as their own span subtree. Variant A stays a single subagent subtree.
Source: mlflow.org/docs/latest/genai/tracing/integrations/listing/claude_code/

---

## Part 1 — One-time setup (TESTED 2026-07-10 — every command verified on this machine)

Two terminals, both in `C:\Users\Tyler\Desktop\claude-code-workshop`. Two machine-specific facts from the
rehearsal: **`mlflow` isn't on PATH here → use `python -m mlflow`**, and **port 5000 was already taken →
we use 5001.** (Extractor subagents are global in `~/.claude/agents`, available from any folder.)

**1. Install MLflow** (installed 3.14.0 cleanly):
```
pip install "mlflow>=3.4"
```

**2. Start the tracking server** (Terminal A — leave it running):
```
python -m mlflow server --host 127.0.0.1 --port 5001 --backend-store-uri "sqlite:///C:/Users/Tyler/Desktop/claude-code-workshop/demo/mlflow.db"
```
UI at http://127.0.0.1:5001. The sqlite store keeps rehearsal traces on disk as a fallback.

**3. Instrument Claude Code — NON-destructively** (Terminal B):
```
python -m mlflow autolog claude -d "C:/Users/Tyler/Desktop/claude-code-workshop" -u "http://127.0.0.1:5001" -n "Workshop Demo" --local -y
python -m mlflow autolog claude -d "C:/Users/Tyler/Desktop/claude-code-workshop" --status   # confirm it's wired
```
This installs the `mlflow-tracing` plugin and writes config into `.claude/settings.local.json` (marketplace
+ plugin + env vars). Never touches shared settings. Remove later with `... autolog claude --disable`.

**4. ⚠️ CREATE THE EXPERIMENT — skip this and the demo dies silently.**
`mlflow autolog claude` writes `MLFLOW_EXPERIMENT_ID=1` but does **not** create the experiment. The plugin
then fails every trace export with `404 No Experiment with id=1 exists` — and the UI just stays **empty**
with no obvious cause. Create it once (it takes ID 1, matching what the setup wrote):
```
python -c "import mlflow; mlflow.set_tracking_uri('http://127.0.0.1:5001'); print(mlflow.get_experiment_by_name('Workshop Demo') or mlflow.create_experiment('Workshop Demo'))"
```

**5. Rehearse in an INTERACTIVE session (verified path):**
- The plugin fires on a **`Stop` hook** — a trace ships each time Claude finishes responding in an
  **interactive** `claude` session. **Headless `claude -p` does NOT fire it** — don't rehearse that way.
- Run `claude` in this folder, run the demo (Part 2), let it finish, then open the UI.
- Verify from the CLI:
  `python -c "import mlflow; mlflow.set_tracking_uri('http://127.0.0.1:5001'); print(len(mlflow.search_traces(locations=['1'], return_type='list')))"`
- **Fallback:** the captured trace persists in `demo/mlflow.db`; screenshot the trace tree during rehearsal.

---

## Part 2 — The live run (what Tyler types, what the room watches)

In `claude`, from the workshop folder:

**Variant A (faithful):**
```
Run the transcript-pipeline subagent on demo/demo-discovery-call.txt.
Output to demo/extractions/. This is a DEMO: extraction only —
do NOT route to Notion or Airtable, do NOT touch the CRM. Just run the pipeline stages.
```

**Variant B (fan-out):**
```
On demo/demo-discovery-call.txt, dispatch these as SEPARATE subagents in order,
writing all outputs to demo/extractions/: transcript-preprocessor first, then
transcript-entity-extractor, transcript-action-extractor, transcript-relationship-extractor,
and transcript-knowledge-extractor on the cleaned transcript, then transcript-profile-delta.
DEMO: extraction only, no Notion/Airtable, no CRM writes.
```

The room watches, in the terminal: the orchestrator dispatches the pipeline, which fans out to the
extractors (preprocess → entities, actions, relationships, knowledge → profile-delta). **This is the
delegation moment** — nested loops, live. Narrate it: *"nobody coded this sequence; the model is
deciding which subagent to run next."*

Then **exit the session** (traces flush on session end — this is expected, lean into it):
> *"The agent's done. Now let's look at what it actually did — the receipts."*

---

## Part 3 — Read the trace (the money shot)

http://localhost:5000 → **Workshop Demo** experiment → **Traces** tab → click the trace.

Left panel = the **span tree**.

**Variant A (faithful) reads roughly** — one subagent, stages inline:
```
▸ Claude Code session (root)                    ~NN,NNN tok
  ▸ Subagent: transcript-pipeline               ~NN,NNN tok   $X.XX
      ▸ LLM turn (Stage 1 preprocess) · Tool: Write cleaned_transcript.json
      ▸ LLM turn (Stage 2 entities)   · Tool: Write entities_extracted.json
      ▸ LLM turn (Stage 2 actions)    · Tool: Write actions_extracted.json
      ▸ LLM turn (Stage 2 relationships / knowledge) · Tool: Write ...
      ▸ LLM turn (Stage 3 profile delta) · Tool: Write profile_delta.json
      ▸ LLM turn (Stage 4 briefing)   · Tool: Write session_briefing.md
```

**Variant B (fan-out) reads roughly** — six sibling subagents under the root:
```
▸ Claude Code session (root)                    ~NN,NNN tok
  ▸ Subagent: transcript-preprocessor           tok   $
  ▸ Subagent: transcript-entity-extractor       tok   $
  ▸ Subagent: transcript-action-extractor       tok   $
  ▸ Subagent: transcript-relationship-extractor tok   $
  ▸ Subagent: transcript-knowledge-extractor    tok   $
  ▸ Subagent: transcript-profile-delta          tok   $
```

**Point at three things, in order — they ARE your three governance questions:**
1. **Which agent ran** → the span tree / subagent names.
2. **What it touched** → click a Tool span → Inputs/Outputs tab (the file it read, the text it wrote).
3. **What it cost** → the per-span and per-trace **token + cost** columns; the experiment **Overview**
   tab shows aggregated cost + time trends.

**Say this line:** *"You cannot govern what you cannot trace. This is the trace."*

---

## Part 4 — Honesty caveats (state these aloud — it models the discipline)

- **Cost is computed for LLM spans only.** Tool/file/bash spans show no dollar cost yet. Don't claim
  per-tool cost.
- **No cache-token breakdown column.** The UI shows input/output/total tokens, not cache read/write.
- This traces the **interactive Claude Code CLI**. A *different* mechanism, `mlflow.anthropic.autolog()`
  (MLflow ≥ 3.5), traces Python agents on the Anthropic/Agent SDK — don't conflate them if asked.

---

## Part 5 — Live-demo risks & mitigations (ranked)

1. **Traces appear only after the session ends.** Scripted into the flow (run → exit → inspect). Never
   promise real-time streaming for Track A.
2. **Port mismatch = empty Traces tab.** The agent's tracking URI and the server port must match. Have
   `--port 5001` ready.
3. **Wrong cwd = nothing captured.** Tracing only fires when `claude` runs in the instrumented dir
   (the workshop folder). Confirm `pwd` and `mlflow autolog claude --status` on stage.
4. **`MLFLOW_CLAUDE_TRACING_ENABLED=false`** kill-switch env var must NOT be set on the demo box.
5. **First-run latency.** Pre-warm `mlflow server` and pre-fire one trace before the room is watching.
6. **Debug artifact** if traces don't show: `.claude/mlflow/claude_tracing.log`.

**Fallback:** if live capture fails, open the rehearsal trace from the sqlite store (still in the same
UI) and walk the screenshots. Nobody can tell the difference.

---

## Appendix — teardown
```
mlflow autolog claude --disable      # removes the hooks from settings.local.json
```
Delete `demo/mlflow.db` and `demo/extractions/` to reset for a clean re-rehearsal.
