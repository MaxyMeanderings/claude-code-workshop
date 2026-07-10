# Agent Demo Spec — "Workflow vs Agent: the definition, made visible"

**The move:** run the *same task two ways* — a fixed pipeline vs a model-driven agent — and put their
**MLflow traces side by side.** The structural difference between the two traces *is* the definition of
an agent. You stop asserting "control-of-path is what makes it an agent" and start **showing** it.

This is the 1:08 "Delegation + the dial" block, upgraded, and it feeds the 1:18 "understand what you
built" close. It reuses the observability demo already built and validated.

---

## 0. The definition it embodies (2026-current)

> An agent is a system where an **LLM-driven loop — not fixed code — decides the next action** to
> pursue a delegated objective, **using tools against an environment**, through the loop
> **gather → act → verify → repeat**, with **autonomy bounded** at a chosen point on a continuum (and a
> bounded *capability surface*), **governed by observability** — the trajectory, not just the output.

The 2026 research confirms this is where the whole field landed (Anthropic: an agent is *"LLMs
autonomously using tools in a loop,"* 2025-09-29; Google ADK ships it as literal classes — **LLM Agents
vs Workflow Agents**). Two things the 2026 canon *adds* to the definition — bake both into the demo:
1. **`verify` is an explicit loop stage** (the net-new beat). — Anthropic harness post, 2025-11-26.
2. **Capability-surface** dimension on the autonomy continuum: the risk isn't only "how much autonomy"
   but "which dangerous capabilities co-occur" (the lethal trifecta). — Willison, 2025-06-16.

---

## 1. The two runs

### Run A — The Workflow (baseline; already built)
The fixed 6-stage extractor fan-out (`demo/DEMO-RUNBOOK.md`, Variant B). The path is
**predefined by me** — preprocess → 4 extractors → profile-delta, same order every time.
- **Trace:** identical shape every run, ~149,400 tokens, tidy and predictable.
- **Say:** *"I coded this path. In Google's own vocabulary this is a **Workflow Agent** — a deterministic
  controller. It's cheap, predictable, and governable. Most business processes should be exactly this."*
  (This lands your **T4** — most orgs need the workflow, not the agent.)

### Run B — The Agent (control-of-path; new)
**One** agent, same transcript, given a goal + tools (`Read`, `Grep`, `Write`) + a **bounded** write
action, told: *"Triage this call — decide what matters, do it, verify your work, stage the follow-ups.
You choose the steps."* The **model decides the path**.
- **Trace:** a *different* shape — the model's chosen steps, a `verify` loop, possibly a retry.
- **Say:** *"Nobody coded this sequence. The model chose what to look at, in what order, and when it was
  done. That's an agent."*

### The payoff — the contrast
Open both traces in MLflow. Workflow = 6 fixed sibling spans, same every run. Agent = variable spans in
a model-chosen order with a verify beat. **"The difference between these two traces is the definition.
And observability is how you can see it."**

---

## 2. The five definitional elements, each pinned to a live moment

| Element | Where it shows | 2026 sharpening (say this) |
|---|---|---|
| **Control-of-path** | Agent trace ≠ workflow trace | *The* differentiator; ADK makes it two code classes |
| **Tools / environment** | Agent reaches for `Grep` the workflow never used | Tools = "a contract between deterministic systems and non-deterministic agents" |
| **The loop** | Point at the agent's `gather → act → verify → repeat` spans | `verify` is the **net-new 2026 beat**; the SDK *owns* the loop now — you don't hand-roll `while stop_reason=='tool_use'` |
| **Bounded autonomy** | The permission gate on the staged write | The dial is now real knobs: `max_turns`, **`max_budget_usd`**, effort levels, 6 permission modes, PreToolUse hooks |
| **Observability = trajectory** | Both traces; tokens + cost per span | MLflow 3 rides the **OpenTelemetry GenAI semantic conventions** — vendor-neutral, name it |

---

## 3. 2026 best-practice callouts to weave in (each earns its place, with source)

Pick per time budget. **Minimum viable (5 beats):** loop + verify + observability + evals + security.

1. **The loop is named and the framework owns it.** Contrast hand-rolled `while` vs SDK `query()`.
   — Anthropic, *Building agents with the Claude Agent SDK*, 2025-09-29.
2. **Verify / self-correction is the top real-world failure fix.** Show the agent nearly mark itself
   "done," then its verify pass catch a miss. — Anthropic harness, 2025-11-26.
3. **Observability = trajectory, not output.** The agent's trace is the object of study.
   — MLflow 3 (OTel-native); OpenTelemetry AI Agent Observability, 2025.
4. **Evals + error analysis is the #1 predictor of progress** (Ng). Optional live beat: read the agent's
   trace → a 10-example mini-eval on "did it catch the real commitments?" → fix only the failing step.
   Evaluate the *trajectory*, not just the final answer. — Ng, *The Batch* #323, 2025-10-15.
5. **Security — the lethal trifecta, honestly.** The transcript is **untrusted content**; the write
   action is the **exfiltration surface**. Bounding/staging the write (not a prompt filter) is the
   *architectural* mitigation. State plainly: **prompt injection is not solved.**
   — Willison, 2025-06-16 & 06-13.
6. **Context engineering, if you want depth.** The agent uses **just-in-time retrieval** — it reads the
   transcript on demand rather than everything being stuffed in up front. — Anthropic, 2025-09-29.
7. **Simplicity / single-agent-first.** The whole A-vs-B contrast *is* this lesson: the workflow is the
   default; you **earn** the agent only when the path can't be predetermined. — every lab.

---

## 4. Runnable — exact steps

**Prereq:** MLflow instrumented per `DEMO-RUNBOOK.md` Part 1 (`mlflow autolog claude --local`, server on
:5000). Both runs get traced; you view them after the session flushes.

**Run A (workflow):** the Variant B dispatch from the runbook (the 6 extractor subagents).

**Run B (agent):** one prompt to a single agent, tools `Read, Grep, Write, Bash, Glob`:
```
You are a call-triage agent. There is NO fixed pipeline — decide the steps yourself from what THIS
call contains. Transcript: demo/demo-discovery-call.txt
- Decide what matters, extract/act accordingly, write outputs to demo/agent-run/.
- VERIFY your own output before finishing (re-read; check you didn't miss or invent anything).
- DEMO ONLY: anything that would touch a real system (CRM/Notion/Airtable/send), STAGE to a file
  marked "REQUIRES HUMAN APPROVAL" instead of doing it.
Report your trajectory (the steps you chose + why), what verify caught, and what you gated.
```

**The bound to show:** the staged "REQUIRES HUMAN APPROVAL" file *is* bounded autonomy — the agent chose
the action but was not allowed to execute it. Then show the dial: default (asks) vs `--dangerously-skip-
permissions` (doesn't), and mention `max_turns` / `max_budget_usd` as the hard stops.

---

## 5. Honesty caveats (say these — they model the discipline)

- **Prompt injection is not solved.** Vendor "95% catch rate" guardrails are a failing grade in security.
  The real defense is architectural + human-in-the-loop.
- **OTel GenAI semconv is still "in Development"** (mid-2026), and **message content is off by default**
  in many instrumentations — an empty trace is usually a config flag, not a bug.
- **"More agents / more tools" is hype.** Start single-agent, earn the second. Cost/latency/compounding-
  error are real; the workflow often wins.

---

## 6. Actual agent trajectory (validated 2026 run on `demo-discovery-call.txt`)

This is real output, not hypothetical. The agent (16 tool calls, ~69k tokens) chose a path **no fixed
pipeline would take**, and it earned its cost by catching three things extraction cannot.

**The path it chose (control-of-path):**
1. Read the transcript, then **immediately searched the repo for the promised case study** — because
   "send it *today*" only matters if the asset exists. No pipeline does this.
2. Cross-checked the existing fixed-pipeline `extractions/` as a *check*, not as truth.
3. **Re-derived the dates itself** instead of trusting a hardcoded anchor.
4. Built an action register (5 commitments).
5. Staged every external action as approval-gated.
6. Drafted a scoping brief grounded strictly in what was said.
7. Self-verified against the raw transcript.
It **deliberately skipped** full profile-delta extraction and refused to invent a price — *matching
effort to what the call warranted.* That selective skipping is the agent move.

**What its `verify` stage caught — the payoff:**
- ⭐ **The most urgent commitment has no deliverable.** The case study promised "today" (and Priya's
  precondition) **doesn't exist anywhere in the repo.** *"Extraction pipelines never surface this because
  extraction ≠ fulfillment."* This is the single best slide in the whole workshop: the agent, by
  choosing to **act on the environment**, found a real gap a workflow is structurally blind to.
- **Caught a frozen assumption.** The fixed pipeline hardcoded the Friday date and marked it
  "no verification needed"; the agent flagged it as ambiguous and gated the calendar hold. (Partly an
  artifact of differing date context between the two runs — so lead the demo with the case-study catch,
  which is airtight — but the *structural* point holds: **the workflow freezes an assumption; the agent
  re-checks it.**)
- **Refused to fabricate.** "Fixed price" with no price quoted → marked `[NOT STATED]`, no invention.

**Bounded autonomy, demonstrated:** all five outside-world actions (send case study, calendar hold, loop
Priya, CRM upsert, generate proposal) were **staged as payloads, zero executed** — three with blockers
surfaced *now* instead of at the deadline.

**The line for the stage:** *"Same transcript. The workflow extracted it perfectly and moved on. The
agent asked a question the workflow can't — 'does the thing Tyler promised actually exist?' — and the
answer was no. That's not the model being smarter. That's control-of-path plus a tool against the
environment. That's the definition, doing work."*

**The honest T4 balance (say it):** the agent did *more* and caught *more* — but at ~69k tokens for one
call, a variable path, and less predictability. For high-volume, well-defined extraction, the **workflow
is the right call**. The agent earns its cost exactly where the task is open-ended, needs judgment, or
must touch the environment. **Extraction is a workflow; fulfillment/triage is an agent task** — and this
run proved the line. Outputs: `demo/agent-run/` (6 files).
