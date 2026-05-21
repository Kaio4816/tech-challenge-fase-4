# Relatorio de Entrega - Tech Challenge Fase 4

## Identificacao

Nome: Kaio Henrique Oliveira Mendes

RM: 367900

Username: Kaio Mendes

Repositorio: [Kaio4816/tech-challenge-fase-4-final](https://github.com/Kaio4816/tech-challenge-fase-4-final/tree/main)

Video de demonstracao: [YouTube](https://youtu.be/MUIjZc-PsCA?si=jzv5DLkM0hYSrJp_)

## Visao Geral da Entrega

Este projeto implementa a Fase 4 do Tech Challenge da Pos-Tech FIAP para a plataforma ToggleMaster, adicionando uma stack completa de observabilidade, APM, alertas, gestao de incidentes, ChatOps e automacao de self-healing sobre uma arquitetura cloud-native ja existente.

A arquitetura preserva os componentes anteriores do projeto:

- microsservicos containerizados
- Kubernetes/EKS
- Terraform
- GitOps com ArgoCD
- GitHub Actions
- HPA
- pipelines CI/CD automatizados

Foram adicionados os seguintes componentes:

- OpenTelemetry Collector
- Prometheus
- Loki
- Promtail
- Grafana
- New Relic
- PagerDuty
- Discord ChatOps
- Alertmanager
- automacao de self-healing por webhook e CronJob

## Arquitetura de Observabilidade

A arquitetura implementada utiliza o OpenTelemetry Collector como ponto central de recebimento, processamento e roteamento da telemetria.

Fluxo principal:

```text
Microsservicos
  -> OpenTelemetry SDK / instrumentacao automatica
  -> OpenTelemetry Collector
  -> Prometheus
  -> Loki
  -> New Relic
  -> Grafana
  -> Alertmanager
  -> PagerDuty / Discord / Self-Healing
```

Os microsservicos enviam traces via OTLP para o OTel Collector. As metricas expostas pelos servicos e componentes do cluster sao coletadas pelo Prometheus. Os logs dos containers sao coletados pelo Promtail, enviados ao Loki e consultados pelo Grafana.

O Grafana centraliza a visualizacao operacional, incluindo saude dos servicos, pods em execucao, restarts, replicas desejadas pelo HPA, taxa de requisicoes, erros HTTP 5xx, uso de CPU, uso de memoria e logs em tempo real.

O Alertmanager recebe alertas do Prometheus e roteia incidentes criticos para PagerDuty, Discord e self-healing.

## Justificativa Tecnica

### OpenTelemetry Collector

O OpenTelemetry Collector foi escolhido como componente central porque permite padronizar a telemetria dos microsservicos e desacoplar as aplicacoes dos backends de observabilidade. Com isso, as aplicacoes enviam dados em formato aberto via OTLP, enquanto o Collector fica responsavel por processar e exportar os dados para as ferramentas adequadas.

Essa abordagem reduz acoplamento, facilita mudancas futuras de fornecedor APM e preserva uma arquitetura cloud-native compativel com Kubernetes e GitOps.

### Prometheus, Loki e Grafana

Prometheus foi utilizado para metricas por ser uma solucao open source padrao no ecossistema Kubernetes, com forte integracao com scraping, alertas e PromQL.

Loki foi escolhido para centralizacao de logs por integrar naturalmente com Grafana e Promtail, alem de trabalhar bem com labels Kubernetes como namespace, pod, container e service.

Grafana foi utilizado como camada principal de visualizacao por permitir dashboards customizados combinando metricas Prometheus e logs Loki.

### New Relic vs Datadog

Foi escolhido o New Relic como ferramenta APM comercial. A escolha foi motivada por:

- suporte a ingestao via OpenTelemetry/OTLP
- facilidade de visualizacao de traces distribuidos
- service map para demonstrar dependencias entre servicos
- disponibilidade de conta gratuita para fins academicos
- boa integracao com aplicacoes instrumentadas via OpenTelemetry

Datadog tambem atenderia tecnicamente ao requisito, mas o New Relic foi priorizado por simplificar a demonstracao de traces e service map no contexto academico do projeto.

### PagerDuty vs OpsGenie

Foi escolhido o PagerDuty como ferramenta de gerenciamento de incidentes. A escolha foi motivada por:

- integracao nativa com Alertmanager
- abertura automatica de incidentes a partir de alertas criticos
- facilidade para evidenciar o ciclo de incidente durante a demonstracao
- suporte a roteamento por integration key

OpsGenie tambem seria uma alternativa valida, mas o PagerDuty apresentou menor complexidade para integrar com o Alertmanager e demonstrar incidentes em tempo real.

### ChatOps com Discord

O Discord foi utilizado como canal de ChatOps para receber notificacoes detalhadas dos alertas. A integracao e feita por webhook, acionado pelo Alertmanager atraves de um servico intermediario `chatops-discord-webhook`.

As mensagens enviadas incluem:

- nome do alerta
- severidade
- servico afetado
- namespace
- resumo
- descricao
- acao de remediacao

### Self-Healing

A automacao de self-healing foi implementada de duas formas:

- webhook acionado pelo Alertmanager quando um alerta possui `self_heal=true`
- CronJob que verifica pods em `CrashLoopBackOff` e tenta executar `rollout restart`

No fluxo principal, o Alertmanager envia o alerta para o webhook de self-healing, que executa uma acao corretiva segura e idempotente:

```bash
kubectl rollout restart deployment/auth-service -n techchallenge
```

Essa abordagem permite demonstrar resposta automatica a incidentes sem remover o controle do GitOps. O ArgoCD continua sendo a fonte de verdade dos manifests.

## Evidencias Visuais Obrigatorias

### 1. Dashboard do Grafana

Inserir print do dashboard:

```text
Grafana > Dashboards > ToggleMaster > ToggleMaster Observability Overview
```

O print deve mostrar, preferencialmente:

- Services Up
- Pods Running
- HPA Desired Replicas
- Request Rate by Service
- HTTP 5xx by Service
- CPU Usage by Pod
- Memory Usage by Pod
- Application Logs - Real Time

Evidencia:

```text
[INSERIR PRINT DO DASHBOARD DO GRAFANA AQUI]
```

### 2. Trace Distribuido no APM

Inserir print do New Relic:

```text
New Relic > APM & Services > evaluation-service ou auth-service > Distributed tracing / Span View
```

O print deve demonstrar uma requisicao passando pelo `evaluation-service` e suas dependencias, como `flag-service` e `targeting-service`.

Evidencia:

```text
[INSERIR PRINT DO TRACE DISTRIBUIDO NO NEW RELIC AQUI]
```

### 3. Notificacao de Incidente no ChatOps

Inserir print do Discord mostrando a notificacao enviada pelo Alertmanager.

A mensagem deve conter:

- nome do alerta
- severidade critica
- servico afetado
- namespace
- descricao
- acao de remediacao

Evidencia:

```text
[INSERIR PRINT DA NOTIFICACAO NO DISCORD AQUI]
```

### 4. Log/Execucao da Automacao de Self-Healing

Inserir print do terminal com os logs do webhook de self-healing:

```bash
kubectl logs -n observability deploy/self-healing-webhook --tail=50
```

O print deve mostrar mensagem semelhante a:

```text
rollout restart triggered from alert
deployment: auth-service
```

Evidencia:

```text
[INSERIR PRINT DO LOG/EXECUCAO DO SELF-HEALING AQUI]
```

## Evidencias Tecnicas Complementares

### ArgoCD

Comando:

```bash
kubectl get applications -n argocd
```

Resultado esperado:

```text
Aplicacoes Synced e Healthy.
```

### Pods Kubernetes

Comando:

```bash
kubectl get pods -A
```

Resultado esperado:

```text
Microsservicos e stack de observabilidade em Running.
```

### HPA

Comando:

```bash
kubectl get hpa -n techchallenge
```

Resultado esperado:

```text
HPAs com metricas de CPU disponiveis.
```

### Loki

Validacao:

```bash
curl http://a7552b9cacfd741b594728933dda889d-250327884.us-east-1.elb.amazonaws.com:3100/ready
```

Resultado esperado:

```text
ready
```

Labels:

```bash
curl http://a7552b9cacfd741b594728933dda889d-250327884.us-east-1.elb.amazonaws.com:3100/loki/api/v1/labels
```

Resultado esperado:

```json
{"status":"success","data":["container","filename","namespace","pod","service","service_name","stream"]}
```

### Prometheus

Queries recomendadas:

```promql
up{namespace="techchallenge"}
```

```promql
sum by(service) (rate(http_requests_total{namespace="techchallenge"}[5m]))
```

```promql
sum(kube_pod_status_phase{exported_namespace="techchallenge",phase="Running"})
```

```promql
sum(kube_horizontalpodautoscaler_status_desired_replicas{exported_namespace="techchallenge"})
```

## Teste de Incidente

Para demonstrar o fluxo completo de incidente, foi utilizado um alerta sintetico enviado ao Alertmanager com os labels:

```text
severity="critical"
self_heal="true"
service="auth-service"
namespace="techchallenge"
```

Esse alerta aciona:

- Alertmanager
- PagerDuty
- Discord ChatOps
- self-healing webhook

O self-healing executa o restart controlado do deployment afetado:

```bash
kubectl rollout restart deployment/auth-service -n techchallenge
```

## Conclusao

A entrega implementa uma stack completa de observabilidade e resposta automatica a incidentes para a plataforma ToggleMaster, mantendo a compatibilidade com Kubernetes, Terraform, GitOps, ArgoCD e CI/CD.

A solucao permite observar metricas, logs e traces distribuidos, abrir incidentes automaticamente, notificar via ChatOps e executar uma acao automatizada de mitigacao. Toda a implementacao foi realizada como codigo, preservando a reprodutibilidade da infraestrutura e dos componentes de observabilidade.
