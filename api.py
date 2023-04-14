from http import HTTPStatus
from typing import Dict
from collections import Counter

from fastapi import FastAPI

from app.models import ClusterResponse, RequestBody
from app.cluster import cluster_data
from app.metrics import instrument_app
from app.utils import create_logger

logger = create_logger("clustering-service")

app = FastAPI(title="Clustering Service")
instrument_app(app, "ml", "clustering")


@app.get("/status", status_code=HTTPStatus.OK)
async def service_status() -> Dict:
    """Health check"""
    return {"message": HTTPStatus.OK.phrase}


@app.post("/cluster", status_code=HTTPStatus.OK)
async def cluster(data: RequestBody) -> ClusterResponse:
    """
    Get clustering results for the data sent in the body.
    """
    logger.info(
        f"Clustering {len(data.data)} data points, into {data.model_conf.n_clusters} clusters"
    )
    logger.info(f"Model configuration: {data.model_conf}")
    clusters = cluster_data(data.data, data.model_conf)
    logger.info(f"Cluster sizes: {Counter([x[1] for x in clusters])}")
    return {"model_conf": data.model_conf, "clusters": clusters}
