from typing import List, Tuple
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.pipeline import Pipeline
from app.models import DataPoint, ModelConf


def cluster_data(data: List[DataPoint], model_conf: ModelConf) -> List[Tuple[int, int]]:
    """Prepare and cluster data"""
    in_data = [f"{elem.body} {elem.title}" for elem in data]
    ids = [elem.id for elem in data]
    vectorizer = TfidfVectorizer(
        min_df=model_conf.min_df,
        max_df=model_conf.max_df,
        ngram_range=model_conf.ngram_range,
    )
    km = KMeans(
        n_clusters=model_conf.n_clusters,
        init="k-means++",
        n_init=10,
        max_iter=model_conf.max_iter,
        random_state=model_conf.random_state,
    )
    pipeline = Pipeline([("vect", vectorizer), ("kmeans", km)])
    pipeline.fit(in_data)
    clusters = pipeline["kmeans"].labels_.tolist()
    out = list(zip(ids, clusters))
    return out
