# =========================
# STAGE 1 - BUILDER
# =========================
FROM python:3.11-slim AS builder

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

# Dependências de build 
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copia apenas requirements primeiro 
COPY requirements.txt .

# Instala dependências em um diretório isolado
RUN pip install --upgrade pip && \
    pip install --prefix=/install -r requirements.txt


# =========================
# STAGE 2 - RUNTIME
# =========================
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copia apenas as libs instaladas do builder
COPY --from=builder /install /usr/local

# Copia o código da aplicação
COPY . .

# Cria usuário não-root
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 8005

# Healthcheck 
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8005/health || exit 1

CMD ["opentelemetry-instrument", "gunicorn", "--bind", "0.0.0.0:8005", "app:app"]
