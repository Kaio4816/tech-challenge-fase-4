# AGENTS.md

# Project Overview

This repository contains the ToggleMaster platform developed for FIAP Pós-Tech Tech Challenge Phase 4.

The project already includes a complete cloud-native architecture created during previous phases.

Current architecture includes:

- Python microservices
- Docker containers
- Kubernetes deployments
- Terraform infrastructure
- GitOps workflows
- ArgoCD
- GitHub Actions CI/CD pipelines
- Horizontal Pod Autoscaler (HPA)

This phase focuses on implementing:

- full observability
- distributed tracing
- centralized logging
- intelligent alerting
- incident management
- self-healing automation

---

# Repository Structure

Main directories:

/auth-service
/evaluation-service
/analytics-service
/flag-service
/targeting-service

/gitops
/terraform

Infrastructure and deployment logic already exist and must be preserved.

---

# Main Objective

Implement a complete observability and incident response stack using:

- OpenTelemetry Collector
- Prometheus
- Loki
- Grafana
- Datadog or New Relic
- PagerDuty or OpsGenie
- ChatOps integrations
- Self-healing automation

Everything must remain compatible with:

- Kubernetes
- GitOps
- Terraform
- Existing CI/CD pipelines

---

# Critical Rules

## Never break the existing architecture

Before modifying anything:

- analyze the current structure
- preserve compatibility
- preserve deployment workflows
- avoid unnecessary refactoring
- reuse existing patterns

Never remove existing functionality unless explicitly requested.

---

# Technology Stack

Current technologies include:

- Python
- Docker
- Kubernetes
- Terraform
- GitHub Actions
- ArgoCD
- GitOps

---

# Python Standards

- Reuse existing project patterns
- Preserve current application structure
- Avoid unnecessary dependencies
- Keep Docker compatibility
- Prefer minimal and maintainable solutions
- Avoid hardcoded values

Logging must use stdout/stderr.

---

# Docker Standards

- Preserve existing Docker build patterns
- Keep images lightweight whenever possible
- Avoid unnecessary layers
- Maintain compatibility with Kubernetes deployments

---

# Kubernetes Standards

Mandatory requirements:

- readinessProbe
- livenessProbe
- resource requests/limits
- ConfigMaps
- Secrets
- HPA compatibility
- stdout/stderr logging

Never manually apply manifests.

All changes must remain GitOps-compatible.

---

# GitOps Rules

ArgoCD is the source of truth.

Use:

- Helm
or
- GitOps manifests

Never rely on manual Kubernetes operations.

All infrastructure and deployment changes must be committed to git.

---

# Terraform Rules

Always:

- reuse existing modules
- preserve state compatibility
- use variables and locals
- preserve current architecture

Never:

- hardcode credentials
- create manual cloud resources
- break existing Terraform workflows

---

# Observability Standards

Use OpenTelemetry as the central telemetry pipeline.

Expected flow:

Microservices
→ OpenTelemetry Collector
→ Prometheus
→ Loki
→ Datadog/New Relic

All services must expose:

- traces
- metrics
- structured logs
- trace correlation
- span correlation

Prefer OTLP whenever possible.

---

# Logging Standards

Logs must:

- use JSON
- contain timestamps
- contain service names
- contain severity levels
- contain trace_id
- contain span_id

Never expose:

- secrets
- credentials
- tokens

---

# Grafana Requirements

Dashboards should include:

- cluster resource usage
- service health
- HTTP request metrics
- latency metrics
- error rate metrics
- real-time logs
- pod status

---

# APM Requirements

The final solution must support:

- Distributed Tracing
- Service Map
- latency analysis
- error analysis
- throughput analysis

---

# Alerting Rules

Alerts must focus on real operational issues.

Avoid alert fatigue.

Focus on:

- HTTP 5xx
- service downtime
- crash loops
- latency spikes
- resource exhaustion

---

# Incident Management

Supported integrations:

- PagerDuty
- OpsGenie

Critical alerts must:

- open incidents automatically
- provide troubleshooting context
- integrate with ChatOps

---

# ChatOps

Supported platforms:

- Slack
- Discord
- Microsoft Teams

Notifications should include:

- affected service
- namespace
- cluster
- timestamp
- error summary
- remediation action executed

---

# Self-Healing

Self-healing automation is mandatory.

Accepted examples:

- rollout restart
- automatic pod restart
- GitHub Actions remediation
- webhook-triggered automation
- runbook automation

Automations must be:

- safe
- idempotent
- observable
- auditable

---

# CI/CD Rules

Pipelines must remain operational.

Any new automation should:

- provide clear logs
- fail correctly
- validate manifests
- validate Terraform
- avoid hardcoded values

---

# Code Generation Rules

Always:

- analyze the repository first
- understand the architecture before changing files
- reuse existing patterns
- explain architectural impacts
- explain operational risks
- generate complete implementations

Never:

- assume nonexistent infrastructure
- introduce unnecessary complexity
- break deployment pipelines
- remove existing functionality

---

# Priority Order

Highest priorities:

1. Stability
2. Observability
3. Automation
4. GitOps compatibility
5. Kubernetes compatibility
6. Fast troubleshooting
7. Low coupling

---

# Final Goal

The final platform must demonstrate:

- end-to-end observability
- distributed tracing
- centralized logging
- real-time metrics
- intelligent alerting
- incident management
- self-healing automation
- modern cloud-native architecture

Everything must be reproducible entirely through code.