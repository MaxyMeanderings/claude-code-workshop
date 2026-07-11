#!/usr/bin/env bash
# One-command MLflow observability setup for the "Workflows vs Agents" workshop demo.
# Installs MLflow, starts a local tracking server, instruments Claude Code, and creates the
# experiment. Run from anywhere: `bash scripts/setup-mlflow.sh` (Windows: use Git Bash).
#
# Verified 2026-07 against MLflow 3.14. Requires Python 3.10+, the Claude Code CLI, and curl.
set -euo pipefail

# Windows consoles default to cp1252; `mlflow autolog claude` prints a U+2713 check and dies with
# UnicodeEncodeError without this. Harmless (a no-op) on macOS/Linux. Keep it before any python call.
export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

# `pip` is often not on PATH even when `python` is (esp. Windows/py launcher). Call pip via the module.
PY="${PYTHON:-python}"

PORT="${MLFLOW_PORT:-5001}"                       # 5000 is often taken; override with MLFLOW_PORT=xxxx
URI="http://127.0.0.1:${PORT}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_NATIVE="$(cygpath -m "$ROOT" 2>/dev/null || echo "$ROOT")"   # native path on Windows; no-op elsewhere
cd "$ROOT"

echo "==> Installing MLflow (>=3.4)"
"$PY" -m pip install "mlflow>=3.4"

echo "==> Starting the tracking server on ${URI}  (background; logs -> mlflow-server.log)"
"$PY" -m mlflow server --host 127.0.0.1 --port "${PORT}" \
  --backend-store-uri "sqlite:///demo/mlflow.db" > mlflow-server.log 2>&1 &
echo "    server pid: $!"

echo "==> Waiting for the server..."
for _ in $(seq 1 30); do
  if curl -s -o /dev/null "${URI}"; then echo "    up."; break; fi
  sleep 1
done

echo "==> Instrumenting Claude Code (installs the mlflow-tracing plugin, writes .claude/settings.local.json)"
"$PY" -m mlflow autolog claude -d "${ROOT_NATIVE}" -u "${URI}" -n "Workshop Demo" --local -y

echo "==> Creating the experiment"
# REQUIRED: 'mlflow autolog claude' sets MLFLOW_EXPERIMENT_ID=1 but does NOT create the experiment.
# Without this, every trace export fails with '404 No Experiment with id=1' and the UI stays empty.
"$PY" - <<PYEOF
import mlflow
mlflow.set_tracking_uri("${URI}")
e = mlflow.get_experiment_by_name("Workshop Demo")
print("experiment id:", e.experiment_id if e else mlflow.create_experiment("Workshop Demo"))
PYEOF

"$PY" -m mlflow autolog claude -d "${ROOT_NATIVE}" --status

cat <<EOF

MLflow tracing is set up.
  UI:         ${URI}
  Run it:     start 'claude' in this folder, run the demo, and finish the turn.
  Important:  traces ship when an INTERACTIVE 'claude' session finishes a turn.
              Headless 'claude -p' does NOT trigger tracing.
  Teardown:   python -m mlflow autolog claude -d "${ROOT_NATIVE}" --disable   (then stop the server)
EOF
