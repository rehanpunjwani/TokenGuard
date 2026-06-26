#!/usr/bin/env bash
# Portable MCP launcher for Cursor/Claude: repo .venv first, then PATH, then python -m.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -x "$ROOT/.venv/bin/recall-py" ]]; then
  exec "$ROOT/.venv/bin/recall-py" mcp-stdio "$@"
fi

if command -v recall-py >/dev/null 2>&1; then
  exec recall-py mcp-stdio "$@"
fi

for py in python3.12 python3; do
  if command -v "$py" >/dev/null 2>&1 && "$py" -c "import recall_py" 2>/dev/null; then
    exec "$py" -m recall_py mcp-stdio "$@"
  fi
done

echo "RecallPy MCP: could not start. From repo root run: python3 -m pip install -e ." >&2
exit 1
