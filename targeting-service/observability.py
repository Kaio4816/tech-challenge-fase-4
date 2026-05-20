import json
import logging
import os
from datetime import datetime, timezone

from opentelemetry import trace
from prometheus_flask_exporter import PrometheusMetrics


class JsonFormatter(logging.Formatter):
    def format(self, record):
        span = trace.get_current_span()
        span_context = span.get_span_context() if span else None
        payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "service": os.getenv("OTEL_SERVICE_NAME", os.getenv("APP_NAME", "targeting-service")),
            "message": record.getMessage(),
            "trace_id": "",
            "span_id": "",
        }
        if span_context and span_context.is_valid:
            payload["trace_id"] = format(span_context.trace_id, "032x")
            payload["span_id"] = format(span_context.span_id, "016x")
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        return json.dumps(payload)


def configure_observability(app):
    handler = logging.StreamHandler()
    handler.setFormatter(JsonFormatter())
    root_logger = logging.getLogger()
    root_logger.handlers = [handler]
    root_logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))

    metrics = PrometheusMetrics(app)
    metrics.info("app_info", "Application information", version=os.getenv("APP_VERSION", "unknown"))
    return metrics
