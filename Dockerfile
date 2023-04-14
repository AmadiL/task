FROM python:3.8-slim

WORKDIR /
RUN rm -rf /tmp/prometheus_multiproc_metrics \
    && mkdir -p /tmp/prometheus_multiproc_metrics
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus_multiproc_metrics

COPY requirements.txt requirements.txt
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install -r requirements.txt --no-cache-dir \
    && apt-get purge -y --auto-remove gcc build-essential

COPY api.py api.py
COPY app/ app/

EXPOSE 8000

ENTRYPOINT ["gunicorn", "api:app", "--workers", "2", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
