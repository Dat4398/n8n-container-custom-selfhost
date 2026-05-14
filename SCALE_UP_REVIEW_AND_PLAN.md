# Scale-Up System Review and Planning

## Scope
This review is based on the current repository configuration for n8n, PostgreSQL, Redis, and worker scaling via Docker Compose.

## Current State Review

### Strengths
- The stack is already separated into core services (`n8n`, `postgres`, `redis`) and worker processes (`n8n_worker`) with a clear scaling command.
- There is an explicit build/deploy script path (`build.sh` and `build.sh --deploy`), which is useful for repeatable VPS deployments.
- Redis and PostgreSQL have dedicated Dockerfiles/config paths, which provides a foundation for performance tuning.

### Gaps and Risks
- Worker scaling is currently manual (`--scale n8n_worker=5`) and not tied to measurable load metrics.
- No defined capacity baseline (jobs/minute, queue depth thresholds, CPU/memory limits).
- No documented SLOs or incident triggers for when to scale out/in.
- No visible observability stack in this repo (metrics/dashboard/alerts).
- Potential bottleneck risk on single-instance PostgreSQL/Redis if worker count grows aggressively.

## Scale-Up Plan

## Phase 1 — Baseline and Guardrails (Week 1)
1. Define SLO targets:
   - Workflow success rate
   - P95 execution latency
   - Queue wait time
2. Add resource limits/reservations per service in `docker-compose.yml`.
3. Add healthchecks and restart policy validation for all core services.
4. Establish starting worker count from baseline load tests.

**Deliverables**
- SLO document
- Compose resource profile
- Baseline load report (throughput vs worker count)

## Phase 2 — Observability and Alerting (Week 2)
1. Instrument host + container metrics (CPU, memory, disk, network).
2. Track queue depth and workflow execution outcomes over time.
3. Create alerts for:
   - Queue depth sustained above threshold
   - Worker crash loops
   - Database connection saturation
   - Redis memory pressure

**Deliverables**
- Dashboard(s)
- Alert rules with thresholds
- Runbook for on-call response

## Phase 3 — Controlled Horizontal Scaling (Week 3)
1. Define scaling policy (example):
   - Scale up +2 workers when queue depth > X for Y minutes and CPU headroom > Z%
   - Scale down -1 worker when queue depth < A for B minutes
2. Automate scaling with your orchestrator/automation layer (if staying on Compose, schedule/operator script with safeguards).
3. Add max worker cap based on PostgreSQL and Redis tested limits.

**Deliverables**
- Scaling policy spec
- Automation script/service
- Capacity guardrail matrix (workers vs DB/Redis limits)

## Phase 4 — Resilience and Cost Efficiency (Week 4)
1. Backpressure strategy for spikes (rate limiting, queue prioritization).
2. Failure drills (kill worker, restart Redis/Postgres replica strategy if applicable).
3. Tune for cost/performance:
   - Right-size worker resources
   - Separate high/low priority workflows
   - Optionally isolate noisy workloads

**Deliverables**
- Failure test report
- Optimized worker profile
- Monthly cost/performance review template

## Suggested Immediate Actions
1. Add explicit resource constraints in Compose for `n8n`, `n8n_worker`, `postgres`, `redis`.
2. Run a controlled load test at worker counts 1, 3, 5, 8 to identify bottlenecks.
3. Set provisional scaling thresholds from test data before enabling automation.
4. Document rollback procedure for rapid downscale if DB/Redis saturation is detected.

## Definition of Done for Scale-Up Readiness
- SLOs are defined and monitored.
- Alerts exist for queue, worker health, DB saturation, and Redis pressure.
- Scaling actions are automated and reversible.
- Load-test evidence confirms stable operation at target peak throughput.
