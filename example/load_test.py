from locust import HttpUser, task
from pathlib import Path
import json

EXAMPLE_DATA_FILE = Path(__file__).parent / "example_data.jsonl"

def get_data(data_file: str):
    with open(data_file, "r") as f:
        data = { "model_conf": { "n_clusters": 4 }, "data": [] }
        for line in f.readlines():
            data["data"].append(json.loads(line))
    return data

DATA = get_data(EXAMPLE_DATA_FILE)
# URL = "http://localhost:8090/cluster"

class ClusterUser(HttpUser):
    @task
    def cluster(self):
        self.client.post("/cluster", json=DATA)
