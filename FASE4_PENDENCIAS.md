# Pendencias e Validacao da Fase 4

Este arquivo lista os itens de validacao e as pendencias externas restantes para fechar a entrega da Fase 4 do Tech Challenge.

O resultado consolidado da implementacao esta em `FASE4_RESULTADO.md`.

## Validacao Inicial

### 1. ArgoCD e GitOps

Validar se todas as aplicacoes estao sincronizadas e saudaveis:

```bash
kubectl get applications -n argocd
kubectl get applications -n argocd -o wide
```

Aplicacoes esperadas:

- auth-service
- flag-service
- targeting-service
- evaluation-service
- analytics-service
- observability
- metrics-server

Importante: confirmar se os manifests do ArgoCD apontam para o repositorio da Fase 4.

### 2. Pods, Services e HPA

```bash
kubectl get pods -n techchallenge
kubectl get svc -n techchallenge
kubectl get hpa -n techchallenge

kubectl get pods -n observability
kubectl get svc -n observability
```

Validar:

- Todos os pods em `Running`
- Nenhum pod em `CrashLoopBackOff`
- HPAs criados para os microsservicos
- Stack de observabilidade criada no namespace `observability`

### 3. Health Checks

Validar os endpoints `/health` dos servicos:

```bash
kubectl port-forward -n techchallenge svc/auth-service 8001:8001
curl http://localhost:8001/health
```

Repetir para:

- flag-service: `8002/health`
- targeting-service: `8003/health`
- evaluation-service: `8004/health`
- analytics-service: `8005/health`

### 4. Prometheus

```bash
kubectl port-forward -n observability svc/prometheus 9090:9090
```

Acessar:

```text
http://localhost:9090
```

Queries uteis:

```promql
up
up{namespace="techchallenge"}
up{namespace="observability"}
```

Tambem validar em:

```text
Status -> Targets
```

### 5. Grafana e Loki

```bash
kubectl port-forward -n observability svc/grafana 3000:3000
```

Acessar:

```text
http://localhost:3000
```

Validar logs no Loki com:

```logql
{namespace="techchallenge"}
```

### 6. OpenTelemetry Collector

Gerar trafego na aplicacao e validar logs do Collector:

```bash
kubectl logs -n observability deploy/otel-collector
```

Exemplo de trafego:

```bash
curl "http://<evaluation-url>/evaluate?user_id=test-1&flag_name=enable-new-dashboard"
```

### 7. Alertmanager

```bash
kubectl port-forward -n observability svc/alertmanager 9093:9093
```

Acessar:

```text
http://localhost:9093
```

Validar se as regras aparecem no Prometheus em:

```text
Alerts
```

### 8. Self-Healing

```bash
kubectl get cronjob -n observability
kubectl get jobs -n observability
kubectl logs -n observability job/<job-name>
```

Validar se o CronJob registra a varredura de pods em `CrashLoopBackOff`.

## O Que Ainda Falta

### 1. Configurar chaves reais de APM, incidentes e ChatOps

O repositorio esta preparado para New Relic, PagerDuty e ChatOps, mas os valores reais devem ser informados como variaveis sensiveis do Terraform:

- `TF_VAR_new_relic_license_key`
- `TF_VAR_pagerduty_routing_key`
- `TF_VAR_discord_webhook_url`

Esses valores dependem de contas externas e nao podem ser gerados automaticamente.

### 2. Validar New Relic

Depois de preencher `NEW_RELIC_LICENSE_KEY`, gerar trafego e validar:

- traces distribuidos
- service map
- latencia
- erros
- throughput

### 3. Testar alerta real e incidente

Depois de preencher PagerDuty e Discord:

- disparar `TechChallengeAuthHigh5xx`
- confirmar abertura de incidente
- confirmar mensagem no canal ChatOps
- confirmar log no `self-healing-webhook`

### 4. Externalizar Secrets Kubernetes

Hoje existem secrets sensiveis em YAML.

Boas praticas recomendadas:

- AWS Secrets Manager
- External Secrets Operator
- SOPS
- Sealed Secrets

Caso nao seja implementado, documentar essa limitacao na apresentacao.

### 5. Revisar secrets/versionamento Terraform

Evitar versionar:

- senhas reais
- `terraform.tfvars`
- estados Terraform
- chaves de integracao

### 6. Teste ponta a ponta

Executar e demonstrar o fluxo completo:

```text
Criar API key
Criar flag
Criar targeting rule
Avaliar flag
Gerar evento no SQS
Analytics consumir evento
DynamoDB receber evento
Logs aparecerem no Loki
Metricas aparecerem no Prometheus
Trace aparecer no New Relic
Alerta disparar
Self-healing registrar acao
```
