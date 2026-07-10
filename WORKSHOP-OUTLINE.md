# Workshop — Workflows vs Agents in Claude Code (with MLflow Observability)

**IEEE × Claude Community · 90 min · hands-on**
**Audience:** young, technical (CS/engineering students) — code-literate, assume **new to Claude Code**.

## Thesis
Everything is built and run **in Claude Code**. Students define the workflow-vs-agent line, build one of
each in Claude Code, run them, and instrument them with **MLflow** so they can read **cost, performance,
and governance** straight off the trace.

## Learning objectives — what they leave able to do
1. **Define** — articulate *workflow vs agent* (control-of-path) and choose the right one for a task.
2. **Build** — build both a **workflow** and an **agent** in Claude Code.
3. **Run** — run them in Claude Code and work the **autonomy dial** (permissions, turn/budget caps).
4. **Observe** — instrument with MLflow and read **cost / performance / governance** off the trace, with
   the best-practice levers for each.

---

## The arc: DEFINE → BUILD → RUN → OBSERVE

### 1 · DEFINE — workflow vs agent *(~12 min, talk + 1 live loop)*
- **The definition:** an agent is where an **LLM-driven loop — not fixed code — decides the next action**,
  using **tools against an environment**, through **gather → act → verify → repeat**, with **bounded
  autonomy**, governed by **observability**.
- **In Claude Code terms:** a **workflow** = *you* code the path (a skill/command/Workflow-tool script that
  runs fixed steps); an **agent** = a subagent or the main loop that **decides its own path**.
- The field agrees: Google's ADK ships this as two classes — **LLM Agents vs Workflow Agents**.
- **Honest anchor:** most business processes should be **workflows** — cheaper, predictable, governable.
  You *earn* the agent when the path can't be predetermined.

### 2 · BUILD in Claude Code — the primitives *(~25 min, hands-on — the core)*
The Claude Code building blocks, taught from zero:
| Primitive | What it is | Role |
|---|---|---|
| `CLAUDE.md` | project memory / instructions | the **context** an agent works inside |
| Skills (`.claude/skills/*/SKILL.md`) | discoverable capabilities (progressive disclosure) | reusable competence |
| Subagents (`.claude/agents/*.md`) | delegated agents with their own tools + context | **delegation / control-of-path** |
| Tools + **permission modes** | what it can *do*, and what it must ask first | the **bound** |
| Slash commands / the **Workflow tool** | fixed orchestration ("the plan moves into code") | how you build a **workflow** |

- **Build a WORKFLOW:** a skill/command (or the Workflow tool) that runs **fixed steps in a fixed order**.
- **Build an AGENT:** a subagent given a **goal + tools**, free to **choose its path**.
- **Student hands-on = `sandbox/` (built + validated).** Each student fills a scaffolded workflow
  (`/status-report`) and agent (`status-reporter`), then runs both on a tiny project where `TODO.md`
  claims a feature is done that is actually a stub. The workflow repeats the claim; the agent verifies
  the code and catches it. Can't-stall `solution/` fallback + pre-flight `SETUP.md` included. See
  `sandbox/EXERCISE.md`.
- **2026 best practice while building:** context engineering (smallest high-signal token set), tool design
  (few, consolidated, well-documented — "more tools ≠ better"), progressive-disclosure skills.

### 3 · RUN in Claude Code — the loop + the dial *(~15 min, hands-on)*
- Run the **workflow** (fixed path) and the **agent** (chooses path) on the **same input**.
- Watch the loop live in the terminal: **gather → act → verify → repeat** — narrate that the *model* chose
  the next step (control-of-path) and that **`verify` is the net-new 2026 stage**.
- **The dial (bounded autonomy):** permission modes (`default → plan → acceptEdits → auto → bypass`),
  `max_turns`, `max_budget_usd`, effort levels, PreToolUse hooks, staging/approval gates.
- **The validated contrast** (see `AGENT-DEMO-SPEC.md`): the workflow extracts the call perfectly and
  moves on; the agent chooses to check the environment and catches the promised case study **doesn't
  exist** — *extraction ≠ fulfillment.* Same input, different trajectory, and you can see why.

### 4 · OBSERVE with MLflow — cost / performance / governance *(~28 min, Tyler-driven demo + best-practice teaching)*
> **Setup reality:** don't ask 30 student laptops to stand up MLflow live (setup-hell). **You demo** the
> trace on a rehearsed capture; students get the runbook to reproduce it as take-home. Optional live
> instrument for the fast ones.

- **Instrument (in Claude Code):** the `mlflow-tracing` plugin or `mlflow autolog claude --local`; server on
  `:5000`; traces flush on session end (→ "watch it work, then open the receipts"). MLflow 3 rides the
  **OpenTelemetry GenAI semantic conventions** — vendor-neutral, name it.
- **The trace = the trajectory, not just the output.** Open the span tree. Then read the three off it:

| Lens | Read from the trace | Best-practice levers |
|---|---|---|
| **COST** | tokens + `$` per span; trace total; workflow (~149k, flat) vs agent (~69k/call, variable) | context engineering · deferred tools/ToolSearch (~85% tool-def savings) · code-execution-with-MCP (98.7%) · effort control · `max_budget_usd` · model choice |
| **PERFORMANCE** | latency per span · # tool-calling steps · time-to-done · where it stalled/retried | tool design · `verify` stage reduces rework · subagent isolation/parallelism · Opus 4.8 fewer steps · **evaluate the trajectory** (evals = "biggest predictor of progress" — Ng) |
| **GOVERNANCE** | *which* agent ran · *what* it touched (every tool I/O) · *what* it cost = audit record | permission modes · PreToolUse hooks (block dangerous calls) · approval-gating/staging · lethal-trifecta capability-surface · human-in-the-loop |

- **Governance framing:** this trace is **layer 2** of the 3-layer model (org policy / observability /
  in-agent enforcement). *"You cannot govern what you cannot trace. This is the trace."*

### 5 · CLOSE *(~10 min)*
- **Understand what you built** — each student inspects their own run/trace.
- **Where next:** MCP, multi-agent orchestration, long-running harnesses, evals.

---

## Honesty beats (say these — they model the discipline)
- **Prompt injection is not solved.** Defense is architectural (break the lethal trifecta) + human-in-loop,
  not a 95%-catch-rate filter.
- **"More agents / more tools" is hype.** Start single-agent, earn the second.
- **The agent isn't universally better.** It did more *and* cost more; **extraction is a workflow,
  fulfillment is an agent task.**
- **Observability standards are still moving.** OTel GenAI semconv is "in Development"; trace **content is
  off by default** in many setups (empty trace = config flag, not a bug).

## Scope guardrails
- **In:** Claude Code as the harness — build + run there; MLflow for observability.
- **Out (name, don't teach):** the Python Agent SDK / OpenAI / Google SDKs (mention only as "the field
  converged"), MCP-server building, deep multi-agent orchestration.

## Assets (all under this folder)
- `WORKSHOP-OUTLINE.md` — this file (source of truth)
- `sandbox/` — **student hands-on** (validated): `SETUP.md` (pre-flight), `EXERCISE.md` (build+run a
  workflow and an agent), scaffolds in `.claude/`, `solution/` fallback, `project/` (the trap repo)
- Definition brief — the stress-tested workflow-vs-agent definition
- `demo/DEMO-RUNBOOK.md` — MLflow setup + the two runs
- `demo/AGENT-DEMO-SPEC.md` — the workflow-vs-agent demo, validated (§6 = real trajectory)
- `demo/demo-discovery-call.txt` · `demo/extractions/` (workflow output) · `demo/agent-run/` (agent output)
