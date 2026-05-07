# ─────────────────────────────────────────────────────────────
#  n8n — Custom Image
#  Base  : n8nio/n8n:latest  (Node 20 / Alpine)
#  Adds  : custom local nodes  +  optional npm community nodes
# ─────────────────────────────────────────────────────────────

ARG N8N_VERSION=latest
FROM n8nio/n8n:${N8N_VERSION}

# Switch to root to install packages
USER root

# ── System deps (uncomment if your nodes need native binaries) ─
# RUN apk add --no-cache python3 make g++ git

# ── Install community nodes from npm registry ─────────────────
#    Add/remove packages as needed; keep versions pinned for reproducibility
# RUN cd /usr/local/lib/node_modules/n8n \
#  && npm install --production \
#       n8n-nodes-evolution-api@1.0.0 \
#       n8n-nodes-puppeteer@1.3.0 \
#  && npm cache clean --force

# ── Copy local custom nodes into the image ────────────────────
#    Each sub-folder must be a valid npm package (has package.json)
COPY --chown=node:node custom-nodes/ /home/node/custom-nodes/

# Install dependencies for every local node package
RUN set -eux; \
    for dir in /home/node/custom-nodes/*/; do \
      if [ -f "${dir}package.json" ]; then \
        echo "▶ Installing deps for: ${dir}"; \
        cd "$dir" && npm install --omit=dev --no-audit --no-fund; \
      fi; \
    done; \
    cd /home/node

# ── Drop back to the unprivileged user ────────────────────────
USER node

# Tell n8n where to find custom nodes at runtime
ENV N8N_CUSTOM_EXTENSIONS="/home/node/custom-nodes"

WORKDIR /home/node

# Inherit CMD / ENTRYPOINT from base image