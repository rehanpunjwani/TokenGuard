# CLI Reference

RecallPy is available as a command-line tool via `recall-py` (or `python -m recall_py`).

## Global options

| Option | Env var | Description |
|--------|---------|-------------|
| `--config`, `-c` | `RECALL_PY_CONFIG` | Path to a YAML config file |
| | `RECALL_PY_OLLAMA_BASE_URL` | Override `ollama.base_url` |
| | `RECALL_PY_DB_PATH` | Override `storage.db_path` |
| | `RECALL_PY_API_LISTEN_HOST` | Override `api.listen_host` |
| | `RECALL_PY_API_LISTEN_PORT` | Override `api.listen_port` |

## Commands

### `recall-py onboard`

First-time setup: config file, database migration, Ollama check, optional model pulls, and an MCP snippet.

```
Options:
  --config, -c PATH   Optional YAML config path
  --yes, -y           Non-interactive (use defaults)
  --skip-pull         Skip Ollama model downloads
```

### `recall-py serve`

Start the HTTP API server.

```
Options:
  --config, -c PATH   Optional YAML config path
```

Listens on `127.0.0.1:8766` by default (configurable via YAML or env vars).

Endpoints:

| Path | Method | Description |
|------|--------|-------------|
| `/health` | GET | Health check (Ollama reachability) |
| `/v1/chat/completions` | POST | OpenAI-compatible proxy (when `proxy.enabled`) |

### `recall-py mcp-stdio`

Run the MCP server on stdio (for IDE integration).

```
Options:
  --config, -c PATH   Optional YAML config path
```

### `recall-py doctor`

Check database path, schema version, and Ollama reachability.

```
Options:
  --config, -c PATH   Optional YAML config path
```

### `recall-py metrics`

Show estimated token savings and usage events.

```
Options:
  --config, -c PATH           Optional YAML config path
  --thread-id, -t TEXT        Limit to one thread (default: all)
  --json                      Output as JSON instead of a table
```

### `recall-py index`

Index README, rules, and docs into workspace RAG memory.

```
Options:
  --workspace, -w PATH    Repo root to index (default: cwd or RECALL_PY_WORKSPACE)
  --force                 Re-index unchanged files
  --config, -c PATH       Optional YAML config path
```

### `recall-py hook`

Run Cursor hook handlers (reads JSON from stdin).

```
Usage: recall-py hook before-prompt|after-response
```

### `recall-py migrate`

Apply SQLite schema migrations only.

```
Options:
  --config, -c PATH   Optional YAML config path
```
