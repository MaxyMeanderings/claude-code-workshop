# Claude Code Workshop — Workflows vs Agents (+ MLflow Observability)

Working folder for the **IEEE × Claude** workshop. Open in VS Code to see every file at once.

## Map
| Path | What it is |
|---|---|
| `WORKSHOP-OUTLINE.md` | The plan — **Define → Build → Run → Observe** (source of truth) |
| `.claude/agents/call-triage.md` | **The demo AGENT** — a goal + tools + control-of-path (a real file) |
| `.claude/commands/extract-fanout.md` | **The demo WORKFLOW** — the fixed extractor fan-out (a real file) |
| `.claude/agents/transcript-*.md` | The **6 extractor agents** the workflow dispatches — vendored in, fully self-contained |
| `demo/DEMO-RUNBOOK.md` | MLflow setup + how to run + read the two traces |
| `demo/AGENT-DEMO-SPEC.md` | Workflow-vs-agent demo, validated (§6 = the real agent trajectory) |
| `demo/demo-discovery-call.txt` | Synthetic transcript both runs operate on |
| `demo/extractions/` | Run A (workflow) output |
| `demo/agent-run/` | Run B (agent) output |
| `sandbox/` | **Student hands-on** — they clone this (`SETUP.md` → `EXERCISE.md`) |

## Run the demo (from this folder)
```
claude
```
- **Workflow:** `/extract-fanout demo/demo-discovery-call.txt`  → fixed 6-subagent fan-out
- **Agent:** `> Use the call-triage agent on demo/demo-discovery-call.txt`  → chooses its own path

Same transcript, two control models. For observability, set up MLflow in one command —
`bash scripts/setup-mlflow.sh` (or follow `demo/DEMO-RUNBOOK.md` step by step) — then compare the two
traces. The difference *is* the definition.

## The one-line definition this whole folder demonstrates
> An **agent** is an LLM-driven loop that **decides its own next action** (not fixed code) to pursue a
> goal, using tools against an environment, with **bounded autonomy**, observed as a trajectory.
> A **workflow** is the same building blocks on a path **you** predetermined.
