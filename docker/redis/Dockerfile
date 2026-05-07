
# ─────────────────────────────────────────────────────────────
#  Redis 7 — Custom Image
#  Bakes in redis.conf so no runtime --command flags are needed
# ─────────────────────────────────────────────────────────────

FROM redis:7-alpine

LABEL maintainer="your-team" \
      description="n8n Redis queue — 256 MB cap, LRU eviction"

# Copy tuned config into the image
COPY redis.conf /usr/local/etc/redis/redis.conf

# Use the config file; password is injected at runtime via
# the REDIS_PASSWORD environment variable substituted by entrypoint
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]

EXPOSE 6379