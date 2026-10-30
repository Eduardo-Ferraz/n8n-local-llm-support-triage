#!/usr/bin/env bash
# Imports the workflow into n8n and runs it once from the command line.
# Needs Docker and an OpenAI-compatible server (LM Studio by default, port 1234) with the model loaded.
set -euo pipefail
cd "$(dirname "$0")"

# Git Bash on Windows would rewrite /workflow into a Windows path.
export MSYS_NO_PATHCONV=1

# Only used for this check: the workflow reads its own URL from the Config node.
LLM_URL="${LLM_URL:-http://localhost:1234/v1}"
if ! curl -sf "$LLM_URL/models" > /dev/null; then
  echo "No OpenAI-compatible server at $LLM_URL. Start LM Studio's server and load the model first." >&2
  exit 1
fi

mkdir -p data/output
docker compose run --rm n8n import:workflow --input=/workflow/support-triage.json
docker compose run --rm n8n execute --id=SupportTriage001

echo
echo "Report:  data/output/triage-report.csv"
echo "Summary: data/output/summary.json"
