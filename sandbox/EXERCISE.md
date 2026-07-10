# EXERCISE — Build a workflow and an agent in Claude Code

You'll build **both**, run **both** on the same little project in `project/`, and watch them disagree.

The project has three features — **auth, export, search**. `project/TODO.md` says what the team *thinks*
is done. **One of those claims is wrong.** Your workflow won't notice. Your agent will.

> Stuck anywhere? Finished versions are in `solution/`. Peek, then keep going.

---

## Part 1 — Build the WORKFLOW *(you script the path)* — ~7 min

A **workflow** follows fixed steps that *you* write. In Claude Code, a **slash command** is the simplest
way to encode one.

1. Open `.claude/commands/status-report.md`. Steps 1–2 are written for you.
2. Find the `>>> FILL THIS IN >>>` block. Write the **rule** a workflow uses to decide each feature's
   status. A workflow doesn't investigate — it follows a rule. The obvious one here:
   *report each feature's status **exactly as stated in TODO.md.***
3. Delete the `>>>` lines. Save.

✅ You just built a workflow.

## Part 2 — Build the AGENT *(it decides the path)* — ~10 min

An **agent** is given a **goal** and its own **tools**, and *it* decides the steps. In Claude Code, a
**subagent** is a file in `.claude/agents/`.

1. Open `.claude/agents/status-reporter.md`. The goal and tools are already set.
2. Find the `>>> FILL THIS IN >>>` block. Write the **one rule** that makes this an agent, not a workflow:
   before it calls anything "done," it must **check the actual code in `project/src/`** — not trust
   TODO.md. If the code is a stub or raises `NotImplementedError`, the feature is **not** done.
3. Delete the `>>>` lines. Save.

✅ You just built an agent. The whole difference from the workflow is **one instruction: verify against
reality.**

## Part 3 — RUN both on the same project — ~10 min

Start Claude Code in this folder: `claude`

**Run the workflow:**
```
/status-report
```
Look at what it says about **export**. It reports **DONE** — because it trusted TODO.md. (It even *read*
`export.py`, but its rule says take the status from TODO.md, so it reports the claim anyway. That's a
workflow: it follows its script.)

**Run the agent:**
```
> Use the status-reporter subagent to report on the project in project/
```
Watch it work: it reads TODO.md, then **opens the code to check.** It reports that **export is NOT done**
— TODO.md claims it, but `export.py` is a stub.

### 🔑 The aha
Same project. Same TODO. The **workflow repeated a claim; the agent checked reality and caught the lie.**
Nobody told the agent to open `export.py` — it *decided* to, because its goal was accuracy. That decision
is **control-of-path**, and it is the entire difference between a workflow and an agent.

## Part 4 — Work the dial *(bounded autonomy)* — ~5 min

When the agent wrote `status-report.md`, did Claude Code ask first? That prompt is the **bound** — the
agent chose the action, but *you* approved it. Move the dial:

| Setting | What happens | Autonomy |
|---|---|---|
| `claude --permission-mode plan` | agent says what it *would* do, then stops | most human control |
| default | asks before it writes / runs | balanced |
| `claude --dangerously-skip-permissions` | never asks | fully unsupervised — only when you trust the task |

Same agent, three levels of autonomy. **You** set that dial per task.

---

## What you built
- A **workflow** — a fixed path you scripted. Predictable and cheap, but blind past its script.
- An **agent** — a goal + tools + **control-of-path**, verifying against reality.
- And you moved the **autonomy dial**.

**Most real tasks want the workflow.** You reach for the agent when the path can't be predetermined —
like when someone needs to know whether the thing that was *claimed* done is *actually* done.
