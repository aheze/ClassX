from glob import glob
from pypdf import PdfReader
import json
import re
from service import *
from tqdm import tqdm

pairs = []
for i,f in enumerate(tqdm(glob('content/18.06/static_resources/*sum.pdf'))):
    reader = PdfReader(f)
    url = f"https://ocw.mit.edu/courses/18-06sc-linear-algebra-fall-2011/{f.split('/')[-1]}"
    number_of_pages = len(reader.pages)
    pages = "\n\n".join([page.extract_text() for page in reader.pages])

    prompt = Prompts.transcript_to_bullets(pages)
    completion = Together.chat(prompt)
    # read as kinda-yaml ignoring ':'
    bullet_points = list(filter(None, completion.replace('```', '').split('\n- ')))
    
    pair = MultiKey(keys=bullet_points, value=pages, embeds=OpenAI.embed(bullet_points), path=url, unit=grep_unit(f))
    
    Chroma.add(**pair.chroma)
    pairs += [pair]
    
query = OpenAI.embed('Markov matrices')
k = Chroma.query(query_embeddings=query, n_results=5)
print(k['metadatas'])  

with open('content/18.06_summaries.json', 'w') as f:
    json.dump(pairs, f, cls=DataclassJSONEncoder)