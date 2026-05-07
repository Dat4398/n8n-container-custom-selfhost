# ─────────────────────────────────────────────────────────────
#  PostgreSQL 16 — Custom Image
#  Adds: performance tuning + init SQL + pg_stat_statements
# ─────────────────────────────────────────────────────────────

FROM postgres:16-alpine

LABEL maintainer="your-team" \
      description="n8n PostgreSQL — tuned for 4 GB VPS"

# ── Install extra extensions (optional) ──────────────────────
# RUN apk add --no-cache postgresql16-contrib

# ── Copy init scripts (run once on first start, in alpha order) ─
COPY init/ /docker-entrypoint-initdb.d/

# ── Bake in a performance-tuned postgresql.conf snippet ───────
#    Values sized for 512 MB RAM budget on a 4 GB VPS.
#    These are appended via a conf.d file so the base config is untouched.
RUN mkdir -p /etc/postgresql/conf.d
COPY tuning.conf /etc/postgresql/conf.d/99-tuning.conf

# Tell Postgres to include conf.d
RUN echo "include_dir = '/etc/postgresql/conf.d'" >> /usr/share/postgresql/postgresql.conf.sample

EXPOSE 5432