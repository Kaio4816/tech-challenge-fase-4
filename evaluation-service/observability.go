package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
	"go.opentelemetry.io/otel/trace"
)

func initTracer(ctx context.Context, serviceName string) (func(context.Context) error, error) {
	exporter, err := otlptracehttp.New(ctx)
	if err != nil {
		return nil, err
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(semconv.ServiceName(serviceName)),
		resource.WithFromEnv(),
		resource.WithTelemetrySDK(),
	)
	if err != nil {
		return nil, err
	}

	provider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(provider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))
	return provider.Shutdown, nil
}

func logJSON(level, message string, fields map[string]any) {
	logJSONContext(context.Background(), level, message, fields)
}

func logJSONContext(ctx context.Context, level, message string, fields map[string]any) {
	payload := map[string]any{
		"timestamp": time.Now().UTC().Format(time.RFC3339Nano),
		"level":     level,
		"service":   getenv("OTEL_SERVICE_NAME", getenv("APP_NAME", "evaluation-service")),
		"message":   message,
		"trace_id":  "",
		"span_id":   "",
	}
	span := trace.SpanFromContext(ctx)
	if span.SpanContext().IsValid() {
		payload["trace_id"] = span.SpanContext().TraceID().String()
		payload["span_id"] = span.SpanContext().SpanID().String()
	}
	for k, v := range fields {
		payload[k] = v
	}
	bytes, err := json.Marshal(payload)
	if err != nil {
		log.Printf(`{"level":"error","message":"failed to marshal log","error":"%s"}`, err.Error())
		return
	}
	log.Println(string(bytes))
}

func accessLogMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		logJSONContext(r.Context(), "INFO", "http_request", map[string]any{
			"method":      r.Method,
			"path":        r.URL.Path,
			"duration_ms": time.Since(start).Milliseconds(),
		})
	})
}

func getenv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}
