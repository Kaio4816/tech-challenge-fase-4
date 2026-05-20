FROM golang:1.21-alpine AS builder

WORKDIR /src

RUN apk add --no-cache ca-certificates git

COPY . .

RUN sed -i '/github.com\/jackc\/pgx\/v4\/stdlib/d' go.mod && \
    go mod tidy

RUN sed -i '/"crypto\/sha256"/d' handlers.go && \
    sed -i '/"encoding\/hex"/d' handlers.go && \
    sed -i '/"fmt"/d' key.go && \
    sed -i '/"fmt"/d' main.go && \
    sed -i '/"github.com\/jackc\/pgx\/v4\/stdlib"/d' main.go

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/auth-service .

FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates && \
    addgroup -S app && adduser -S app -G app

COPY --from=builder /out/auth-service /app/auth-service

USER app

EXPOSE 8001

ENTRYPOINT ["/app/auth-service"]