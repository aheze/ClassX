import os
import re
import openai
import requests
from dotenv import load_dotenv
import dataclasses
import json
import time
from typing import Union, List, Literal
import chromadb
from itertools import chain
from pydantic import BaseModel

load_dotenv()

class Together:
    endpoint = 'https://api.together.xyz/v1/chat/completions'
    
    @classmethod
    def chat(cls, prompt, return_all=False, **kwargs):

        res = requests.post(cls.endpoint, json={
            **{"model": "mistralai/Mixtral-8x7B-Instruct-v0.1",
            "max_tokens": 512,
            "prompt": prompt,
            "temperature": 0.7,
            "top_p": 0.7,
            "top_k": 50,
            "repetition_penalty": 1,
            "stop": [
                "[/INST]",
                "</s>"
            ],
            "repetitive_penalty": 1,
            "update_at": "2024-02-17T23:59:53.847Z"}, **kwargs
        }, headers={
            "Authorization": f"Bearer {os.environ['TOGETHER_KEY']}",
        })
        
        if return_all:
            return res.json()
        
        return res.json()['choices'][0]['message']['content']
    
    
class OpenAI:
    client = openai.OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))
    
    @classmethod
    def embed(cls, text: Union[str, List[str]], return_all=False):
        response = cls.client.embeddings.create(
        input=text,
        model="text-embedding-3-small"
    )
        if return_all:
            return response
        return [x.embedding for x in response.data]
    
class Chroma:
    client = chromadb.PersistentClient(path="content/vectordb")
    collection = client.get_or_create_collection("classx", metadata={"hnsw:space": "cosine"})
    
    @classmethod
    def ping(cls):
        return cls.client.heartbeat()
    
    @classmethod
    def add(cls, *args, **kwargs):
        return cls.collection.add(*args, **kwargs)
    
    @classmethod
    def query(cls, *args, **kwargs):
        return cls.collection.query(*args, **kwargs)

@dataclasses.dataclass
class MultiKey:
    """many keys to one value in vectordb. better retrieval for long docs."""
    keys: List[str]
    value: str
    embeds: List[float] = None
    unit: str = None
    path: str = None
    source: Literal['mit', '3b1b'] = 'mit'
    
    def __dict__(self):
        return {k: self.value for k in self.keys}
    
    @property
    def chroma(self):
        """convert to chroma.add syntax"""
        
        ids = [f"{self.unit}_{i}" for i in range(len(self.keys))]
        
        return {
            "documents": [self.value] * len(self.keys),
            "embeddings": self.embeds,
            "metadatas": [{"path": self.path, "bullet": k, "unit": self.unit, "source": self.source} for k in self.keys],
            "ids": ids
        }
        
        
@dataclasses.dataclass
class Subtitles:
    # dict is type {text: str, start: float, duration: float}
    s: List[dict]
    
    def __str__(self):
        """timestamped subtitles: [start -> start + duration] text"""
        stamp = lambda sec: time.strftime('%M:%S', time.gmtime(sec))
        return "\n".join([f"[{stamp(x['start'])}->{stamp(x['start'] + x['duration'])}] {x['text']}" for x in self.s])
    
    @property
    def text(self):
        return " ".join([x['text'] for x in self.s])
        
@dataclasses.dataclass
class SearchResult:
    """vectordb search result to rerank."""
    id: str
    distance: float
    metadata: dict
    document: str = None
    
    def __getitem__(self, key):
        return getattr(self, key)

    @classmethod
    def set(self, results, by='id'):
        """dedup results by id key, when sorted."""
        
        ids = set()
        filtered_results = []
        for r in results:
            if r[by] not in ids:
                ids.add(r[by])
                filtered_results += [r]
                
        return filtered_results
    
class DataclassJSONEncoder(json.JSONEncoder):
    def default(self, o):
        if dataclasses.is_dataclass(o):
            return dataclasses.asdict(o)
        return super().default(o)
    
    
def grep_unit(mit_fp):
    """get unit code from mit ocw filename, MIT18_06SCF11_Ses1.1sum.pdf -> 1.1"""
    if (match := re.search(r"MIT18_06SCF11_Ses(\d+\.\d+)sum\.pdf", mit_fp)):
        return match.group(1)
    return "0.0"

def flatten_2d(l):
    return list(chain(*l))


class Prompts:
    @staticmethod
    def transcript_to_bullets(pages: str, n = 10):
        return f"""
[INST] You are a world-class teaching assistant for a college math (linear algebra) class. Distill (don't summarize) a lecture transcript into {n} distinct bullet points of very dense shorthand (fragments, semicolons, no filler words). 

Rules: 
1. Do not summarize; retain depth of content as the transcript.
2. Max 10 words, 1 line per bullet.

Format in a yaml list:
```yaml
- ith point
```

Transcript
===
{pages}
===
[/INST]

```yaml
    """.strip()
    
    @staticmethod
    def bullets_to_recitation(bullets: str):
        return f"""
[INST] You are a world-class math professor teaching a linear algebra college class. Today, you're discussing the units below.

{bullets}

Teach me in 3 ascending levels of difficulty with LaTeX, Markdown, examples, and analogies. Speak concisely, lively, reverently in the style of Richard Feynman. 

Rules:
1. No inline LaTeX ($A$), only block LaTeX ($$ A $$).

[/INST]
""".strip()

# Swift structs from Vision Pro for I/O

class Visualization(BaseModel):
    id: str
    visualizationType: Literal['latex', 'url', 'bullet']
    mainBody: str 
    
class ServerResponse(BaseModel):
    id: str
    uploadNumber: int
    visualizations: List[Visualization] = None

class WhisperUpload(BaseModel):
    id: str
    uploadNumber: int
    segments: List[str]