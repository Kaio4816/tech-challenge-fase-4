# ---------- Stage 1: build ----------
FROM golang:1.23-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git ca-certificates tzdata

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o evaluation-service .

# ---------- Stage 2: runtime ----------
FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/evaluation-service /app/evaluation-service

USER appuser

EXPOSE 8004

ENTRYPOINT ["/app/evaluation-service"]
