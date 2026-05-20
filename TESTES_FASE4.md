# Roteiro de Testes - Tech Challenge Fase 4

Este roteiro cobre as evidencias pedidas na atividade: IaC, GitOps, metricas, logs, OpenTelemetry, APM, alertas, incidentes, ChatOps e self-healing.

## 1. Pre-check antes da gravacao

Confirme que o contexto do EKS esta apontando para o cluster correto:

```bash
kubectl config current-context
kubectl get nodes
```

Valide o estado geral do cluster:

```bash
kubectl get pods -A
kubectl get hpa -n techchallenge
kubectl get svc -n techchallenge
kubectl get svc -n observability
```

Valide o ArgoCD:

```bash
kubectl get applications -n argocd
```

Resultado esperado:

```text
auth-service, evaluation-service, flag-service, targeting-service, observability e metrics-server: Synced Healthy
```

Se algum app aparecer como `OutOfSync`, abra o ArgoCD, clique no app e use `Sync`. Para a demonstracao, o ideal e iniciar com tudo `Synced Healthy`.

Valide Terraform:

```bash
cd terraform
terraform fmt -check -recursive
terraform validate
terraform plan
cd ..
```

## 2. URLs de acesso

ArgoCD:

```text
http://a5b425c9e38004161a47628049c89c3d-1298102489.us-east-1.elb.amazonaws.com
```

Usuario:

```text
admin
```

Senha:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Grafana:

```text
http://acd6efb641c5c4039a766a28d1076264-1579902366.us-east-1.elb.amazonaws.com:3000
```

Credenciais do Grafana:

```text
usuario: admin
senha: changeme-observability
```

Prometheus:

```text
http://a739b20aa07a4486981f95fa62220510-904874822.us-east-1.elb.amazonaws.com:9090
```

Alertmanager:

```text
http://a18bf750e09a8467395b21ef497a3c9c-348930763.us-east-1.elb.amazonaws.com:9093
```

Loki API:

```text
http://a7552b9cacfd741b594728933dda889d-250327884.us-east-1.elb.amazonaws.com:3100
```

Observacao: o Loki retorna `404 page not found` na raiz. Isso e normal. Teste pelos endpoints:

```text
/ready
/loki/api/v1/labels
```

New Relic:

```text
https://one.newrelic.com
```

PagerDuty:

```text
https://app.pagerduty.com/incidents
```

Discord:

```text
Canal configurado no webhook de ChatOps.
```

## 3. Evidencia de GitOps e Kubernetes

No video, mostre:

1. ArgoCD com todos os apps.
2. App `observability` sincronizado.
3. App `metrics-server` sincronizado.
4. Apps dos microsservicos saudaveis.

Comandos uteis:

```bash
kubectl get applications -n argocd
kubectl get pods -n techchallenge
kubectl get pods -n observability
kubectl get hpa -n techchallenge
```

Resultado esperado:

```text
Todos os pods principais em Running.
HPAs exibindo metricas de CPU.
ArgoCD mostrando Synced/Healthy.
```

## 4. Teste de Prometheus

Acesse o Prometheus e rode as queries:

```promql
up{namespace="techchallenge"}
```

Esperado: targets dos microsservicos com valor `1`.

```promql
sum by(service) (rate(http_requests_total{namespace="techchallenge"}[5m]))
```

Esperado: taxa de requisicoes por servico.

```promql
sum(kube_pod_status_phase{exported_namespace="techchallenge",phase="Running"})
```

Esperado: quantidade de pods rodando.

```promql
sum(kube_horizontalpodautoscaler_status_desired_replicas{exported_namespace="techchallenge"})
```

Esperado: replicas desejadas pelos HPAs.

```promql
sum(increase(kube_pod_container_status_restarts_total{exported_namespace="techchallenge"}[15m])) or vector(0)
```

Esperado: `0` se nao houve restart recente.

## 5. Teste de Loki e logs centralizados

Primeiro valide a API:

```bash
curl http://a7552b9cacfd741b594728933dda889d-250327884.us-east-1.elb.amazonaws.com:3100/ready
curl http://a7552b9cacfd741b594728933dda889d-250327884.us-east-1.elb.amazonaws.com:3100/loki/api/v1/labels
```

Esperado:

```text
ready
labels como namespace, pod, service, container e stream
```

No Grafana:

1. Abra `Explore`.
2. Selecione datasource `Loki`.
3. Rode:

```logql
{namespace="techchallenge"}
```

Por servico:

```logql
{namespace="techchallenge", service="evaluation-service"}
```

O que mostrar no video:

```text
Logs JSON dos microsservicos.
Labels de namespace, pod e service.
Logs em tempo real apos chamadas de teste.
```

## 6. Teste do dashboard Grafana

Abra:

```text
Dashboards > ToggleMaster > ToggleMaster Observability Overview
```

Paineis esperados:

```text
Services Up: valor positivo, normalmente 10.
Pods Running: valor positivo, normalmente 10.
Restarts 15m: 0 em estado saudavel.
HPA Desired Replicas: valor positivo, normalmente 10.
Request Rate by Service: linhas por servico apos gerar trafego.
HTTP 5xx by Service: vazio em estado saudavel, aparece quando houver falha.
CPU Usage by Pod: series por pod.
Memory Usage by Pod: series por pod.
Application Logs - Real Time: logs vindos do Loki.
```

Se algum painel ficar vazio, gere trafego com o passo seguinte e aguarde 30 a 60 segundos.

## 7. Gerar trafego real nos microsservicos

Abra port-forwards para os servicos internos:

```bash
kubectl port-forward -n techchallenge svc/flag-service 8002:8002
kubectl port-forward -n techchallenge svc/targeting-service 8003:8003
kubectl port-forward -n techchallenge svc/evaluation-service 8004:8004
```

Em outro terminal, carregue a chave interna:

```bash
export API_KEY=$(kubectl get secret -n techchallenge evaluation-service-secret -o jsonpath='{.data.SERVICE_API_KEY}' | base64 -d)
export FLAG_NAME="enable-demo-$(date +%s)"
```

Crie uma flag:

```bash
curl -X POST http://localhost:8002/flags \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$FLAG_NAME\",\"description\":\"Demo FIAP\",\"is_enabled\":true}"
```

Crie uma regra:

```bash
curl -X POST http://localhost:8003/rules \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"flag_name\":\"$FLAG_NAME\",\"is_enabled\":true,\"rules\":{\"type\":\"PERCENTAGE\",\"value\":50}}"
```

Gere avaliacoes:

```bash
for i in $(seq 1 50); do
  curl "http://localhost:8004/evaluate?user_id=user-$i&flag_name=$FLAG_NAME"
  echo
done
```

Depois mostre:

```text
Grafana: Request Rate by Service aumentando.
Loki: logs do evaluation-service, flag-service e targeting-service.
Prometheus: metricas http_requests_total.
New Relic: traces e service map.
```

## 8. Teste de OpenTelemetry e New Relic

Valide o OTel Collector:

```bash
kubectl logs -n observability deploy/otel-collector --tail=100
```

Procure por mensagens de exportacao de traces e metricas. Nao deve haver erro de autenticacao do New Relic.

No New Relic:

1. Abra `https://one.newrelic.com`.
2. Va em APM ou Services.
3. Procure pelos servicos:

```text
auth-service
evaluation-service
flag-service
targeting-service
analytics-service
```

4. Abra `Service Map`.
5. Gere trafego pelo passo 7.
6. Abra um trace do `evaluation-service`.

O que mostrar:

```text
Trace distribuido iniciado no evaluation-service.
Chamadas para flag-service e targeting-service.
Mapa de dependencia entre microsservicos.
Latencia, throughput e eventuais erros.
```

## 9. Teste de alertas

No Prometheus, abra `Alerts`.

Alertas configurados:

```text
TechChallengeTargetDown
TechChallengePodRestarting
TechChallengeHighErrorRate
TechChallengeAuthHigh5xx
```

No Alertmanager, abra:

```text
http://a18bf750e09a8467395b21ef497a3c9c-348930763.us-east-1.elb.amazonaws.com:9093
```

Estado saudavel esperado:

```text
Sem alertas firing.
```

## 10. Prova real: incidente, PagerDuty, Discord e self-healing

Existem duas formas de demonstrar.

### Opcao A - Teste controlado e seguro da cadeia completa

Esta opcao dispara um alerta sintetico no Alertmanager. Ela prova PagerDuty, Discord e self-healing sem quebrar de verdade a aplicacao.

Execute:

```bash
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

curl -X POST http://a18bf750e09a8467395b21ef497a3c9c-348930763.us-east-1.elb.amazonaws.com:9093/api/v2/alerts \
  -H "Content-Type: application/json" \
  -d "[
    {
      \"labels\": {
        \"alertname\": \"TechChallengeAuthHigh5xx\",
        \"severity\": \"critical\",
        \"service\": \"auth-service\",
        \"namespace\": \"techchallenge\",
        \"self_heal\": \"true\"
      },
      \"annotations\": {
        \"summary\": \"Teste FIAP: auth-service com 5xx acima de 5%\",
        \"description\": \"Alerta sintetico para demonstrar PagerDuty, Discord e self-healing.\",
        \"remediation\": \"rollout restart deployment/auth-service\",
        \"remediation_deployment\": \"auth-service\"
      },
      \"startsAt\": \"$NOW\"
    }
  ]"
```

Mostre:

```bash
kubectl rollout status deployment/auth-service -n techchallenge
kubectl logs -n observability deploy/self-healing-webhook --tail=50
kubectl logs -n observability deploy/chatops-discord-webhook --tail=50
```

No video:

```text
Alertmanager com alerta firing.
PagerDuty com incidente aberto.
Discord com notificacao.
Logs do self-healing mostrando rollout restart.
Pods do auth-service reiniciando/renovando ReplicaSet.
```

Resolva o alerta sintetico:

```bash
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

curl -X POST http://a18bf750e09a8467395b21ef497a3c9c-348930763.us-east-1.elb.amazonaws.com:9093/api/v2/alerts \
  -H "Content-Type: application/json" \
  -d "[
    {
      \"labels\": {
        \"alertname\": \"TechChallengeAuthHigh5xx\",
        \"severity\": \"critical\",
        \"service\": \"auth-service\",
        \"namespace\": \"techchallenge\",
        \"self_heal\": \"true\"
      },
      \"annotations\": {
        \"summary\": \"Teste FIAP resolvido\"
      },
      \"startsAt\": \"$NOW\",
      \"endsAt\": \"$NOW\"
    }
  ]"
```

### Opcao B - Falha real controlada no auth-service

Esta opcao causa uma falha real alterando temporariamente a conexao de banco do `auth-service`. Use apenas durante a demonstracao.

Cause a falha:

```bash
kubectl set env deployment/auth-service -n techchallenge DATABASE_URL='postgres://invalid:invalid@invalid:5432/auth_db'
```

Acompanhe:

```bash
kubectl get pods -n techchallenge -w
```

Em outro terminal:

```bash
kubectl get pods -n techchallenge
kubectl describe pod -n techchallenge -l app.kubernetes.io/name=auth-service
```

Aguarde alguns minutos e mostre:

```text
Pod do auth-service reiniciando ou indisponivel.
Prometheus Alerts com TechChallengeTargetDown ou TechChallengePodRestarting.
Alertmanager recebendo alerta.
PagerDuty abrindo incidente.
Discord recebendo notificacao.
CronJob/self-healing tentando acao corretiva quando detectar CrashLoopBackOff.
```

Recupere pelo GitOps:

```bash
kubectl annotate application auth-service -n argocd argocd.argoproj.io/refresh=hard --overwrite
```

Se o ArgoCD nao reverter imediatamente, entre no ArgoCD e clique em `Sync` no `auth-service`.

Confirme recuperacao:

```bash
kubectl rollout status deployment/auth-service -n techchallenge
kubectl get pods -n techchallenge
kubectl get application auth-service -n argocd
```

## 11. Checklist do video

Use esta ordem para a gravacao:

1. Mostrar Terraform com `terraform validate` e explicar que EKS/ArgoCD/secrets de integracao sao IaC.
2. Mostrar ArgoCD com apps GitOps.
3. Mostrar pods dos microsservicos e observabilidade.
4. Mostrar HPA funcionando.
5. Abrir Grafana e mostrar dashboard customizado.
6. Abrir Prometheus e executar queries.
7. Abrir Grafana Explore com Loki e buscar logs.
8. Gerar trafego pelo `evaluation-service`.
9. Abrir New Relic e mostrar Service Map/Trace.
10. Abrir Alertmanager.
11. Disparar incidente controlado.
12. Mostrar PagerDuty.
13. Mostrar Discord.
14. Mostrar logs do self-healing.
15. Mostrar pods recuperados e ArgoCD ainda saudavel.

## 12. Evidencias que devem aparecer no relatorio

Inclua prints ou trechos de terminal para:

```text
ArgoCD Synced/Healthy
kubectl get pods -A
kubectl get hpa -n techchallenge
Grafana dashboard
Prometheus queries
Loki logs no Grafana Explore
OTel Collector rodando
New Relic Service Map
New Relic Trace distribuido
Alertmanager Firing
PagerDuty incident
Discord notification
Self-healing logs
Aplicacao recuperada
```

## 13. Observacoes importantes

Os endpoints de Grafana, Prometheus, Alertmanager e Loki estao expostos por `LoadBalancer` para facilitar a demonstracao. Depois da avaliacao, recomenda-se voltar Prometheus, Alertmanager e Loki para `ClusterIP` ou proteger via Ingress com autenticacao e restricao de IP.

O Loki nao possui UI propria na raiz. A validacao principal de logs deve ser feita pelo Grafana Explore.

O teste sintetico da Opcao A e o mais seguro para provar a cadeia completa. A Opcao B e mais fiel ao enunciado por causar falha real, mas pode deixar o servico temporariamente indisponivel ate o ArgoCD corrigir.
