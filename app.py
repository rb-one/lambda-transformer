import json
import os
from collections.abc import Mapping, MutableMapping
from typing import Any

from sentence_transformers import SentenceTransformer, util

# Check if the environment variable ENV_NAME is set and equal to 'Docker'
# Otherwise if it's not set, we are working locally.
if os.environ.get("ENV_NAME") == "Docker":
    model_name_or_path = "model/all-MiniLM-L6-v2"
    os.environ["TRANSFORMERS_CACHE"] = "./model"
else:
    model_name_or_path = "all-MiniLM-L6-v2"


class TextSimilarityMapper:
    def __init__(self, model: str):
        self.model = SentenceTransformer(model)
        self.mapping: MutableMapping[str, Any] = {}

    def set_mapping(self, mapping: Mapping):
        self.mapping.update(mapping)

    def map(self, text: str) -> str:
        inputs = list(self.mapping.keys())
        inputs_embedded = self.model.encode(inputs)
        text_embedded = self.model.encode([text])
        similarities = util.cos_sim(text_embedded, inputs_embedded)[0]
        best_match_idx = similarities.argmax()
        if similarities[best_match_idx] < 0.5:
            return text
        return self.mapping[inputs[best_match_idx]]


def lambda_handler(event: dict, context: str):
    model = TextSimilarityMapper(model_name_or_path)
    body = json.loads(event["body"])
    model.set_mapping(body["mapping"])
    result = model.map(body["text"])
    return {"statusCode": 200, "body": json.dumps({"mapped_text": result})}
