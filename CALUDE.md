# CLAUDE.md

# Project Context

This project represents Phase 4 of the FIAP Pós-Tech Tech Challenge.

The main platform is called ToggleMaster and already contains a complete cloud-native architecture built during previous phases.

The existing architecture already includes:

- Containerized microservices
- Kubernetes
- Terraform
- GitOps
- ArgoCD
- GitHub Actions
- Docker-based deployments
- Horizontal Pod Autoscaler (HPA)
- Automated CI/CD pipelines

The purpose of this phase is to implement full observability, distributed tracing, centralized monitoring, intelligent alerting, and self-healing automation.

---

# Existing Services

The current microservices include:

- auth-service
- evaluation-service
- analytics-service
- flag-service
- targeting-service

Additional infrastructure directories include:

- terraform
- gitops

---

# Main Objective

Implement a modern observability and incident response stack using:

- OpenTelemetry Collector
- Prometheus
- Loki
- Grafana
- Datadog or New Relic
- PagerDuty or OpsGenie
- ChatOps integrations
- Self-healing automation

Everything must remain fully compatible with:

- Kubernetes
- GitOps
- Terraform
- Existing CI/CD pipelines

---

# Critical Rules

## Never break the existing architecture

Before making any changes:

- analyze the current structure
- preserve compatibility
- avoid unnecessary refactoring
- maintain existing pipelines
- preserve deployment flow

---

# Infrastructure Rules

All infrastructure must remain:

- declarative
- reproducible
- versioned
- automated

Never rely on manual cloud configuration.

Infrastructure changes must be implemented using Terraform whenever possible.

---

# Kubernetes Standards

All solutions must follow cloud-native best practices.

Mandatory requirements:

- readinessProbe
- livenessProbe
- resource requests/limits
- stdout/stderr logging
- ConfigMaps and Secrets
- HPA compatibility

Avoid anti-patterns and tightly coupled deployments.

---

# GitOps Rules

All Kubernetes resources must be delivered through:

- Helm Charts
or
- GitOps manifests

Never apply resources manually.

ArgoCD must remain the source of truth.

---

# Observability Stack

## Main Components

### Prometheus

Responsible for:

- infrastructure metrics
- Kubernetes metrics
- application metrics

### Loki

Responsible for:

- centralized logging
- container log aggregation
- log querying

### Grafana

Responsible for:

- dashboards
- visualization
- alerting

### OpenTelemetry Collector

Acts as the central telemetry pipeline.

Expected flow:

Microservices
→ OpenTelemetry Collector
→ Prometheus
→ Loki
→ Datadog/New Relic

---

# OpenTelemetry Requirements

All services must provide:

- traces
- metrics
- correlated logs
- trace_id
- span_id

Prefer OTLP whenever possible.

Use OpenTelemetry official libraries.

Prefer auto-instrumentation when applicable.

---

# Logging Standards

All logs must:

- be structured
- use JSON format
- include timestamps
- include severity levels
- include service names
- include trace_id correlation

Never expose:

- secrets
- tokens
- credentials
- sensitive internal data

---

# APM Requirements

The final solution must support:

- Distributed Tracing
- Service Map visualization
- latency analysis
- error analysis
- throughput analysis

The APM platform must clearly display communication between all microservices.

---

# Alerting Rules

Alerts must be intelligent and actionable.

Avoid alert fatigue.

Focus on:

- service availability
- HTTP 5xx errors
- latency spikes
- crash loops
- failed deployments
- resource exhaustion

---

# Incident Management

Supported integrations:

- PagerDuty
- OpsGenie

Critical alerts must:

- create incidents automatically
- provide enough troubleshooting context
- integrate with ChatOps

---

# ChatOps

Supported integrations:

- Slack
- Discord
- Microsoft Teams

Notifications should include:

- affected service
- namespace
- cluster
- timestamp
- error summary
- automated action executed

---

# Self-Healing

Self-healing automation is mandatory.

Accepted examples:

- rollout restart
- pod restart
- automatic scaling
- runbook execution
- GitHub Actions triggered via webhook
- Lambda/serverless remediation

All automations must be:

- safe
- auditable
- observable
- idempotent

---

# Terraform Rules

Always:

- reuse existing modules
- preserve current patterns
- avoid duplication

Never:

- manually create cloud resources
- break existing state management

---

# GitHub Actions

Pipelines must remain compatible.

Any new automation should:

- provide clear logs
- fail correctly
- validate manifests
- validate Terraform
- avoid hardcoded values

---

# Code Generation Rules

Always:

- analyze the current project structure first
- reuse existing patterns
- maintain compatibility
- generate complete implementations
- explain architectural impacts
- explain technical risks

Never:

- assume nonexistent infrastructure
- remove existing functionality
- introduce unnecessary complexity

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

The final solution must demonstrate:

- end-to-end observability
- distributed tracing
- centralized logging
- real-time metrics
- intelligent alerting
- incident management
- automated self-healing
- modern cloud-native architecture

Everything must be reproducible entirely through code.