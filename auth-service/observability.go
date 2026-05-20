package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
	"go.opentelemetry.io/otel/trace"
)

var (
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total de requisicoes HTTP processadas pelo servico.",
		},
		[]string{"service", "method", "path", "status"},
	)
	httpRequestDurationSeconds = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Duracao das requisicoes HTTP em segundos.",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"service", "method", "path", "status"},
	)
)

func init() {
	prometheus.MustRegister(httpRequestsTotal, httpRequestDurationSeconds)
}

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
		"service":   getenv("OTEL_SERVICE_NAME", getenv("APP_NAME", "auth-service")),
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
		recorder := &statusRecorder{ResponseWriter: w, statusCode: http.StatusOK}
		next.ServeHTTP(recorder, r)
		status := strconv.Itoa(recorder.statusCode)
		service := getenv("OTEL_SERVICE_NAME", getenv("APP_NAME", "auth-service"))
		httpRequestsTotal.WithLabelValues(service, r.Method, r.URL.Path, status).Inc()
		httpRequestDurationSeconds.WithLabelValues(service, r.Method, r.URL.Path, status).Observe(time.Since(start).Seconds())
		logJSONContext(r.Context(), "INFO", "http_request", map[string]any{
			"method":      r.Method,
			"path":        r.URL.Path,
			"status":      recorder.statusCode,
			"duration_ms": time.Since(start).Milliseconds(),
		})
	})
}

type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.statusCode = code
	r.ResponseWriter.WriteHeader(code)
}

func getenv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}
