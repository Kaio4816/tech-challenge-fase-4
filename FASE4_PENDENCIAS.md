# Pendencias e Validacao da Fase 4

Este arquivo lista o que ainda precisa ser validado ou finalizado para fechar a entrega da Fase 4 do Tech Challenge.

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

### 1. Corrigir repoURL do ArgoCD

Validar se os manifests em `gitops/argocd` ainda apontam para:

```text
tech-challenge-fase-3
```

Se sim, alterar para:

```text
tech-challenge-fase-4
```

### 2. Configurar Datadog ou New Relic

O OpenTelemetry Collector esta preparado, mas ainda falta escolher e configurar uma plataforma externa:

- Criar Secret com API key ou license key
- Adicionar exporter no pipeline do Collector
- Validar traces no APM externo
- Demonstrar service map, latencia, erros e throughput

### 3. Configurar PagerDuty ou OpsGenie

O Alertmanager esta estruturado, mas ainda precisa de chave real:

- `pagerduty_routing_key`
- ou `opsgenie_api_key`

Tambem e necessario testar um alerta real.

### 4. Configurar ChatOps

Definir e configurar um webhook real, por exemplo:

- Slack
- Microsoft Teams
- Discord
- Google Chat

### 5. Melhorar dashboards Grafana

O dashboard inicial existe, mas para apresentacao recomenda-se adicionar paineis para:

- CPU e memoria por servico
- Restarts de pods
- Logs por servico
- Latencia
- Taxa de erro
- Status dos HPAs
- Estado da stack de observabilidade
- Fluxo SQS/analytics, se possivel

### 6. Validar metricas HTTP reais

Algumas regras de alerta dependem de metricas HTTP. E necessario validar no Prometheus quais metricas reais estao sendo expostas pelos servicos Python e Go.

Se os nomes forem diferentes, ajustar as regras de alerta.

### 7. Adicionar backend visual de traces

Hoje os traces podem chegar ao OpenTelemetry Collector, mas ainda falta uma visualizacao dedicada.

Opcoes:

- Enviar traces para Datadog
- Enviar traces para New Relic
- Adicionar Grafana Tempo para demonstracao local
- Adicionar Jaeger para demonstracao local

### 8. Ajustar Terraform

Pontos tecnicos recomendados:

- DynamoDB usa chave `id`, mas o `analytics-service` grava `event_id`
- Redis Security Group precisa liberar porta `6379`
- RDS libera trafego demais; ideal restringir para TCP `5432`
- Remover variaveis Terraform nao usadas
- Evitar versionar senhas em `terraform.tfvars`

### 9. Externalizar Secrets Kubernetes

Hoje existem secrets sensiveis em YAML.

Boas praticas recomendadas:

- AWS Secrets Manager
- External Secrets Operator
- SOPS
- Sealed Secrets

Caso nao seja implementado, documentar essa limitacao na apresentacao.

### 10. Teste ponta a ponta

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
Trace aparecer no APM
Alerta disparar
Self-healing registrar acao
```

## Prioridade Recomendada

1. Corrigir `repoURL` do ArgoCD para o repositorio da Fase 4
2. Validar Prometheus, Loki e Grafana em runtime
3. Configurar Datadog ou New Relic
4. Configurar PagerDuty ou OpsGenie
5. Configurar ChatOps
6. Ajustar pontos criticos do Terraform
7. Executar teste ponta a ponta
