# Resultado da Fase 4 - Observabilidade e Resposta a Incidentes

Este documento resume o que ficou implementado no repositorio para atender aos requisitos tecnicos da Fase 4 e o que ainda depende de configuracao externa.

## 1. Monitoramento opensource no Kubernetes

Automatizado via GitOps/ArgoCD:

- Prometheus em `gitops/apps/observability/prometheus.yaml`
- Loki em `gitops/apps/observability/loki.yaml`
- Promtail em `gitops/apps/observability/promtail.yaml`
- Grafana em `gitops/apps/observability/grafana.yaml`
- kube-state-metrics em `gitops/apps/observability/kube-state-metrics.yaml`
- metrics-server via Helm/ArgoCD em `gitops/argocd/app-metrics-server.yaml`

O `metrics-server` foi adicionado para que os HPAs funcionem apos a recriacao da infraestrutura.

## 2. Dashboard Grafana

O dashboard `ToggleMaster Observability Overview` e provisionado automaticamente no Grafana.

Paineis incluidos:

- servicos disponiveis
- pods em execucao
- restarts recentes
- replicas desejadas pelos HPAs
- taxa de requisicoes por microsservico
- erros HTTP 5xx por microsservico
- CPU por pod
- memoria por pod
- logs em tempo real via Loki

## 3. OpenTelemetry

O OTel Collector esta provisionado em `gitops/apps/observability/otel-collector.yaml`.

Fluxo implementado:

```text
Microsservicos -> OTLP HTTP -> OTel Collector -> Prometheus / New Relic / logs do Collector
Pods -> Promtail -> Loki
Prometheus -> Alertmanager
```

Os microsservicos possuem variaveis `OTEL_*` nos manifests Kubernetes e instrumentacao nos codigos Go/Python.

## 4. Instrumentacao e metricas HTTP

Implementado:

- Python services com `prometheus-flask-exporter`
- Go services com OpenTelemetry HTTP e metricas Prometheus customizadas
- metricas `http_requests_total`
- metricas `http_request_duration_seconds`
- logs JSON com `trace_id` e `span_id`

Servicos Go atualizados:

- `auth-service`
- `evaluation-service`

## 5. APM comercial

Escolha preparada: New Relic.

O OTel Collector possui exporter `otlphttp/newrelic` e usa a Secret `external-apm-secret`, gerenciada pelo Terraform.

O que falta fazer manualmente:

- criar conta New Relic
- informar `TF_VAR_new_relic_license_key` antes do `terraform apply`
- gerar trafego e validar traces, service map, latencia, erros e throughput no New Relic

Nao consigo criar a conta nem obter a license key por voce.

## 6. Alertas inteligentes

Prometheus possui regras para:

- alvo indisponivel
- pods reiniciando
- taxa geral de HTTP 5xx
- taxa de HTTP 5xx do `auth-service` acima de 5%

A regra especifica `TechChallengeAuthHigh5xx` possui label `self_heal="true"` e anotacao de remediacao.

## 7. Incident management

Alertmanager esta preparado para:

- PagerDuty
- ChatOps via webhook

O que falta fazer manualmente:

- criar conta PagerDuty
- obter `pagerduty_routing_key`
- obter webhook do Discord
- informar `TF_VAR_pagerduty_routing_key` e `TF_VAR_discord_webhook_url` antes do `terraform apply`

Nao consigo criar essas contas nem gerar as chaves por voce.

## 8. ChatOps

Alertmanager envia notificacoes para o adaptador interno `chatops-discord-webhook`, que formata o payload e repassa para o Discord.

Campos esperados no alerta:

- servico afetado
- namespace
- severidade
- resumo
- descricao
- acao de remediacao

Para ativar, informe `TF_VAR_discord_webhook_url` antes do `terraform apply`.

## 9. Self-healing

Foram implementados dois mecanismos:

- CronJob `crashloop-self-healing`: verifica pods em `CrashLoopBackOff` e executa rollout restart do Deployment correspondente.
- Webhook `self-healing-webhook`: recebe alerta do Alertmanager e executa restart do Deployment definido na anotacao `remediation_deployment`.

Exemplo implementado:

```text
TechChallengeAuthHigh5xx -> Alertmanager -> self-healing-webhook -> rollout restart deployment/auth-service
```

## 10. Validacao apos recriar a infraestrutura

```bash
kubectl get applications -n argocd
kubectl get pods -n techchallenge
kubectl get pods -n observability
kubectl get hpa -n techchallenge
kubectl top pods -n techchallenge
```

Grafana:

```bash
kubectl port-forward -n observability svc/grafana 3000:3000
```

Prometheus:

```bash
kubectl port-forward -n observability svc/prometheus 9090:9090
```

Alertmanager:

```bash
kubectl port-forward -n observability svc/alertmanager 9093:9093
```

Logs:

```bash
kubectl logs -n observability deploy/otel-collector
kubectl logs -n observability deploy/self-healing-webhook
kubectl logs -n observability cronjob/crashloop-self-healing
```

## 11. Variaveis sensiveis para automacao

Para recriar a infraestrutura ja com New Relic, PagerDuty e Discord configurados, exporte as variaveis abaixo antes do `terraform apply`:

```bash
export TF_VAR_new_relic_license_key="<NEW_RELIC_LICENSE_KEY>"
export TF_VAR_pagerduty_routing_key="<PAGERDUTY_EVENTS_API_V2_ROUTING_KEY>"
export TF_VAR_discord_webhook_url="<DISCORD_WEBHOOK_URL>"
```

Esses valores nao devem ser commitados no Git.

## 12. Limitacoes conhecidas

- Chaves reais de New Relic, PagerDuty e Discord nao podem ser geradas automaticamente.
- Secrets de integracao externa ficam no Terraform como variaveis sensiveis; para producao, avaliar AWS Secrets Manager, External Secrets, SOPS ou Sealed Secrets.
- O exporter New Relic so ficara funcional quando `NEW_RELIC_LICENSE_KEY` for preenchida.
- O service map no APM depende de trafego real entre os microsservicos.
