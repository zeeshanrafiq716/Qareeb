# Qareeb Postgres backup — run on host with pg_dump in PATH or via Docker.
param(
  [string]$DatabaseUrl = $env:DATABASE_URL,
  [string]$OutDir = ".\backups"
)

if (-not $DatabaseUrl) {
  Write-Error "Set DATABASE_URL or pass -DatabaseUrl"
  exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$file = Join-Path $OutDir "qareeb-$stamp.sql.gz"

Write-Host "Backing up to $file"

# Docker Postgres (compose service name postgres)
if ($DatabaseUrl -match "@postgres:") {
  docker compose exec -T postgres pg_dump -U postgres -d qareeb | gzip > $file
} else {
  pg_dump $DatabaseUrl | gzip > $file
}

Write-Host "Done. Verify restore on a staging DB before relying on this file."
