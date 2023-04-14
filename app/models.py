from typing import List, Tuple
from pydantic import BaseModel


class DataPoint(BaseModel):
    id: int
    body: str
    title: str = ""


class ModelConf(BaseModel):
    n_clusters: int
    max_iter: int = 300
    random_state: int = 42
    min_df: float = 0.05
    max_df: float = 0.95
    ngram_range: Tuple[int, int] = (1, 2)


class RequestBody(BaseModel):
    """
    Request body for /cluster endpoint
    """

    data: List[DataPoint]
    model_conf: ModelConf


class ClusterResponse(BaseModel):
    """
    Response model for /cluster endpoint
    """

    model_conf: ModelConf
    clusters: List[Tuple[int, int]]
