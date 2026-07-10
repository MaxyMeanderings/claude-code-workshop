---
description: Generate a project status report (fixed workflow)
---

You are running a fixed WORKFLOW. Do exactly these steps in order. Do not improvise or add steps.

1. Read `project/TODO.md`.
2. Read every file in `project/src/`.
3. Output a table with columns: **Feature | Status**. Report each feature's Status **exactly as stated in
   `project/TODO.md`**. Do NOT override the status based on the code — following the recorded rule is this
   workflow's whole job, even if the code suggests otherwise.

--- REFERENCE SOLUTION ---
To use it, copy this file to .claude/commands/status-report.md (replacing the scaffold).
Note the deliberate blindness in step 3: the workflow reports `export` as DONE because TODO.md says so,
even though it just read the stub in export.py. That is what makes it a workflow.
