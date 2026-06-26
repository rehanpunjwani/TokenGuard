# RecallPy — Agent instructions

## Entrypoints

| Entry | Invocation |
|---|---|
| CLI | `recall-py <command>` or `python -m recall_py <command>` |
| CLI module | `recall_py.cli:main` (Typer app) |
| HTTP API | `recall-py serve` — FastAPI at `127.0.0.1:8766` |
| MCP server | `recall-py mcp-stdio` — stdio transport (spawned by IDE, never run manually) |
| Package root | `src/recall_py/` (setuptools `packages.find` with `where = ["src"]`) |

## Key commands

```bash
pip install -e ".[dev]"   # dev install
pytest                    # all tests (asyncio_mode = auto)
recall-py onboard        # first-time setup (config, DB migration, Ollama check)
recall-py onboard -y --skip-pull  # non-interactive (CI)
recall-py doctor         # check DB path, migrations, Ollama reachability
recall-py metrics        # show token savings
recall-py migrate        # apply SQLite migrations only
bash scripts/docker-up.sh          # docker compose up --build -d + model pulls
SKIP_MODEL_PULL=1 bash scripts/docker-up.sh  # skip model pulls
```

## Config loading order

1. `src/recall_py/config/default.yaml` (shipped, bundled via `package-data`)
2. `~/.config/recall-py/config.yaml` (XDG, only when `RECALL_PY_CONFIG` unset)
3. `RECALL_PY_CONFIG` env var → YAML file path
4. `--config` CLI flag
5. Env overlays: `RECALL_PY_OLLAMA_BASE_URL`, `RECALL_PY_DB_PATH`, `RECALL_PY_API_LISTEN_HOST`, `RECALL_PY_API_LISTEN_PORT`

Each layer deep-merges into the previous.

## Required Ollama models (default config)

- `nomic-embed-text` (embedding)
- `llama3.2` (local chat)

## Architecture

- **SQLite** in `~/.local/share/recall-py/recall-py.db` — schema v3 with tables: `threads`, `messages`, `chunks`, `proxy_cache`, `usage_events`. Migrations are imperative (see `store/db.py`), run automatically on first connection.
- **Embeddings** stored as float32 blobs; cosine similarity computed in-process in `retrieve.py`.
- **Chunking** at `1200` chars with `150` char overlap (configurable via `limits`).

## MCP tools (Cursor / Claude Code)

Cursor project config at `.cursor/mcp.json` auto-launches via `scripts/mcp-stdio.sh`.

Always follow the `recall-py.mdc` rule: call `recall_py_handle_query` before answering any user question. Then `recall_py_ingest_turn(role=assistant, ...)` after replying. If local draft is weak, call `recall_py_escalate_pack` and use your main model.

Cursor hooks (`.cursor/hooks.json`) auto-ingest when enabled in Cursor Settings → Hooks. Hook scripts must be `chmod +x`.

## Docker

- `docker-compose.yml`: ollama service + recall-py service (HTTP API `recall-py serve` only, no MCP inside container)
- Entrypoint (`scripts/docker-entrypoint.sh`) waits for Ollama health before starting.
- Env vars for container overrides: `RECALL_PY_OLLAMA_BASE_URL`, `RECALL_PY_DB_PATH`, `RECALL_PY_API_LISTEN_HOST`.

## Testing

- `pytest` runs all tests — no extra flags needed.
- `pytest-asyncio` with `asyncio_mode = auto` (async tests run automatically).
- Test database is `tmp_path`-scoped (no external DB needed).
- Settings env tests use `monkeypatch` — no real Ollama required for unit tests.
