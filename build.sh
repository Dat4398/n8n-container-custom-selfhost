#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  build.sh — Build, tag, and (optionally) push all images
#  Usage:
#    ./build.sh            # build only
#    ./build.sh --push     # build + push to registry
#    ./build.sh --deploy   # build + deploy stack
#    ./build.sh --push --deploy
# ─────────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ────────────────────────────────────────────────────
REGISTRY="${REGISTRY:-}"            # e.g. registry.yoursite.com/n8n
N8N_VERSION="${N8N_VERSION:-latest}"
TAG="${TAG:-$(date +%Y%m%d)}"

IMAGES=(
  "n8n-custom:${N8N_VERSION}     ./docker/n8n"
  "n8n-postgres:16               ./docker/postgres"
  "n8n-redis:7                   ./docker/redis"
)

DO_PUSH=false
DO_DEPLOY=false

for arg in "$@"; do
  case $arg in
    --push)   DO_PUSH=true ;;
    --deploy) DO_DEPLOY=true ;;
    *) echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

# ── Helper ────────────────────────────────────────────────────
log() { echo -e "\033[1;36m▶ $*\033[0m"; }
ok()  { echo -e "\033[1;32m✔ $*\033[0m"; }
err() { echo -e "\033[1;31m✘ $*\033[0m" >&2; exit 1; }

# ── Pre-flight ────────────────────────────────────────────────
command -v docker &>/dev/null || err "docker not found"
[ -f .env ] || { log "No .env found — copying from .env.example"; cp .env.example .env; }

# ── Build ─────────────────────────────────────────────────────
log "Building all images  (N8N_VERSION=${N8N_VERSION}  TAG=${TAG})"

docker compose build \
  --build-arg N8N_VERSION="${N8N_VERSION}" \
  --parallel \
  --progress=plain

ok "All images built successfully"

# ── Tag with date ─────────────────────────────────────────────
log "Tagging images with :${TAG}"
docker tag "n8n-custom:${N8N_VERSION}"  "n8n-custom:${TAG}"
docker tag "n8n-postgres:16"            "n8n-postgres:${TAG}"
docker tag "n8n-redis:7"               "n8n-redis:${TAG}"

# ── Push ──────────────────────────────────────────────────────
if $DO_PUSH; then
  [ -n "${REGISTRY}" ] || err "--push requires REGISTRY env var  (e.g. REGISTRY=registry.example.com/n8n ./build.sh --push)"
  log "Pushing to ${REGISTRY}"
  for entry in "${IMAGES[@]}"; do
    local_image=$(echo "$entry" | awk '{print $1}')
    remote="${REGISTRY}/${local_image}"
    docker tag  "$local_image" "$remote"
    docker push "$remote"
    ok "Pushed: $remote"
  done
fi

# ── Deploy ────────────────────────────────────────────────────
if $DO_DEPLOY; then
  log "Deploying stack..."
  docker compose up -d --remove-orphans
  docker compose up -d --scale n8n_worker=5
  ok "Stack is up → http://localhost:5678"
  docker compose ps
fi

ok "Done! 🚀"