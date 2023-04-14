from typing import Optional

from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator, metrics


def instrument_app(
    app: FastAPI,
    metric_namespace: str = "",
    metric_subsystem: str = "",
    excluded_handlers: Optional[list] = None,
) -> None:
    """Add Prometheus metrics to FastAPI app under /metrics endpoint"""
    instrumentator = _create_instrumentator(excluded_handlers)
    _add_metrics(instrumentator, metric_namespace, metric_subsystem)
    instrumentator.instrument(app).expose(
        app, endpoint="/metrics", include_in_schema=True
    )


def _create_instrumentator(excluded_handlers: Optional[list] = None) -> Instrumentator:
    """Create instrumentator that will handle Prometheus metrics"""
    if not excluded_handlers:
        excluded_handlers = ["/status", "/metrics"]
    instrumentator = Instrumentator(
        should_group_status_codes=False,
        should_ignore_untemplated=True,
        should_instrument_requests_inprogress=True,
        excluded_handlers=excluded_handlers,
        inprogress_name="http_requests_inprogress",
        inprogress_labels=True,
    )
    return instrumentator


def _add_metrics(
    instrumentator: Instrumentator,
    metric_namespace: str = "",
    metric_subsystem: str = "",
) -> None:
    """
    Add metrics to instumentator.
    To see available predefined metrics check:
    https://github.com/trallnag/prometheus-fastapi-instrumentator/blob/master/src/prometheus_fastapi_instrumentator/metrics.py
    To see how to implement new metrics check:
    https://github.com/trallnag/prometheus-fastapi-instrumentator#creating-new-metrics
    """
    instrumentator.add(
        metrics.request_size(
            metric_name="http_request_size_bytes",
            metric_doc="Content bytes of requests",
            metric_namespace=metric_namespace,
            metric_subsystem=metric_subsystem,
            should_include_handler=True,
            should_include_method=True,
            should_include_status=True,
        )
    )
    instrumentator.add(
        metrics.response_size(
            metric_name="http_response_size_bytes",
            metric_doc="Content bytes of responses",
            metric_namespace=metric_namespace,
            metric_subsystem=metric_subsystem,
            should_include_handler=True,
            should_include_method=True,
            should_include_status=True,
        )
    )
    instrumentator.add(
        metrics.latency(
            metric_name="http_request_duration_seconds",
            metric_doc="Duration of HTTP requests in seconds",
            metric_namespace=metric_namespace,
            metric_subsystem=metric_subsystem,
            should_include_handler=True,
            should_include_method=True,
            should_include_status=True,
        )
    )
    instrumentator.add(
        metrics.requests(
            metric_name="http_requests_total",
            metric_doc="Total number of requests by method, status and handler",
            metric_namespace=metric_namespace,
            metric_subsystem=metric_subsystem,
            should_include_handler=True,
            should_include_method=True,
            should_include_status=True,
        )
    )
