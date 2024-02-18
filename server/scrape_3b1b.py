import json
import re
from service import *
from tqdm import tqdm

from youtube_transcript_api import YouTubeTranscriptApi

# yt video ids for 3b1b Linear Algebra series
ids = [
    "fNk_zzaMoSs",
    "k7RM-ot2NWY",
    "kYB8IZa5AuE",
    "XkY2DOUCWMU",
    "rHLEWRxRGiM",
    "Ip3X9LOh2dk",
    "uQhTuRlWMxw",
    "v8VSDg_WQlA",
    "LyGKycYT2v0",
    "eu6i7WJeinw",
    "BaM7OCEm3G0",
    "jBsC34PxzoM",
    "P2LTAUO1TdA",
    "PFDu9oVAE-g",
    "e50Bj7jn9IQ",
    "TgKwz5Ikpc8"
]
yt_transcripts = list(map(YouTubeTranscriptApi.get_transcript, tqdm(ids)))

pairs = []
for i,(id, t) in enumerate(tqdm(list(zip(ids, yt_transcripts)))):
    url = f"https://www.youtube.com/embed/{ids[i]}"
    subtitles = Subtitles(t)
    
    prompt = Prompts.transcript_to_bullets(subtitles.text)
    completion = Together.chat(prompt)
    # read as kinda-yaml ignoring ':'
    bullet_points = list(filter(None, completion.replace('```', '').split('\n- ')))
    
    print(bullet_points)
    
    pair = MultiKey(keys=bullet_points, value=subtitles.text, embeds=OpenAI.embed(bullet_points), path=url, unit=id, source='3b1b')
    
    Chroma.add(**pair.chroma)
    pairs += [pair]
    
query = OpenAI.embed('What is Cramer\'s rule?')
k = Chroma.query(query_embeddings=query, n_results=5, where={"source": "3b1b"})
print(k['metadatas'])  

with open('content/3b1b_linealg_summaries.json', 'w') as f:
    json.dump(pairs, f, cls=DataclassJSONEncoder)