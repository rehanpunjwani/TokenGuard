#!/usr/bin/env bash
set -euo pipefail

echo "RecallPy Setup Verification"
echo "=============================="
echo ""

# Check if recall-py is installed
if ! command -v recall-py &> /dev/null; then
    echo "❌ recall-py command not found. Install with: python3 -m pip install recall-py"
    echo "   (or from a clone: python3 -m pip install -e .)"
    exit 1
fi
echo "✓ recall-py installed"

# Check Ollama
if curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    echo "✓ Ollama reachable at http://127.0.0.1:11434"
else
    echo "❌ Ollama not reachable at http://127.0.0.1:11434"
    echo "   Start with: ollama serve  OR  (from your clone) bash scripts/docker-up.sh"
    exit 1
fi

# Check models
MODELS=$(curl -s http://127.0.0.1:11434/api/tags | grep -o '"name":"[^"]*"' | cut -d'"' -f4 || echo "")
EMBED_OK=false
CHAT_OK=false

if echo "$MODELS" | grep -q "nomic-embed-text"; then
    EMBED_OK=true
    echo "✓ nomic-embed-text model found"
else
    echo "❌ nomic-embed-text model not found. Run: ollama pull nomic-embed-text"
fi

if echo "$MODELS" | grep -q "llama3.2"; then
    CHAT_OK=true
    echo "✓ llama3.2 model found"
else
    echo "❌ llama3.2 model not found. Run: ollama pull llama3.2"
fi

# Run recall-py doctor
echo ""
echo "Running recall-py doctor..."
if recall-py doctor > /dev/null 2>&1; then
    echo "✓ recall-py doctor passed"
else
    echo "⚠️  recall-py doctor reported issues"
    recall-py doctor
fi

echo ""
if $EMBED_OK && $CHAT_OK; then
    echo "✅ Setup verified! You can now configure RecallPy in your IDE's MCP settings."
    echo ""
    echo "Next step: Run 'recall-py onboard' to see the MCP configuration snippet."
else
    echo "⚠️  Some models are missing. Pull them with:"
    echo "   ollama pull nomic-embed-text"
    echo "   ollama pull llama3.2"
fi
