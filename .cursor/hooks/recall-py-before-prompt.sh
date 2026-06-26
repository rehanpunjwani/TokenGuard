#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if command -v recall-py >/dev/null 2>&1; then
  exec recall-py hook before-prompt
fi
for py in python3.12 python3; do
  if command -v "$py" >/dev/null 2>&1 && "$py" -c "import recall_py" 2>/dev/null; then
    exec "$py" -m recall_py hook before-prompt
  fi
done
if [[ -x "$ROOT/.venv/bin/recall-py" ]]; then
  exec "$ROOT/.venv/bin/recall-py" hook before-prompt
fi
echo '{"agent_message":"RecallPy hook failed: install recall-py (pip install -e .)"}' >&1
exit 0
