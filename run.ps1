# Imports the workflow into n8n and runs it once from the command line.
# Needs Docker and an OpenAI-compatible server (LM Studio by default, port 1234) with the model loaded.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# Only used for this check: the workflow reads its own URL from the Config node.
$llmUrl = if ($env:LLM_URL) { $env:LLM_URL } else { 'http://localhost:1234/v1' }
try {
    Invoke-RestMethod "$llmUrl/models" | Out-Null
} catch {
    Write-Error "No OpenAI-compatible server at $llmUrl. Start LM Studio's server and load the model first."
    exit 1
}

New-Item -ItemType Directory -Force data/output | Out-Null
docker compose run --rm n8n import:workflow --input=/workflow/support-triage.json
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
docker compose run --rm n8n execute --id=SupportTriage001
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output ''
Write-Output 'Report:  data/output/triage-report.csv'
Write-Output 'Summary: data/output/summary.json'
