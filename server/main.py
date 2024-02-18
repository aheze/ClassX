from service import *
from fastapi import FastAPI
import time

app = FastAPI()

@app.post("/search")
async def search(data: WhisperUpload):
    transcript = "\n".join(data.segments)

    completion = Together.chat(Prompts.transcript_to_bullets(transcript, n=4))
    bullet_points = list(filter(None, completion.replace('```', '').split('\n- ')))

    print(bullet_points)

    queries = OpenAI.embed(bullet_points)
    k = Chroma.query(query_embeddings=queries, n_results=3)
    k = {key: flatten_2d(v) for key, v in k.items() if key and v}

    results = [SearchResult(id=a, distance=b, metadata=c) for a,b,c in zip(k['ids'], k['distances'], k['metadatas'])]
    results.sort(key=lambda x: x.distance)

    unique_results = SearchResult.set(results, by='id')
    
    topk = [x.metadata for x in unique_results[:5]]

    # take top 3 scores. could be unique, or same lecture diff bullet.
    urls = list(set([x['path'] for x in topk]))[:3]

    bullets = "\n".join(["- " + x['bullet'] for x in topk])

    print(bullets, urls)

    gen_recitation = Together.chat(Prompts.bullets_to_recitation(bullets), max_tokens=1000)

    print(gen_recitation)
    
    visuals = [
       *[Visualization(
            id=url, visualizationType="url", mainBody=url) for url in urls],
         Visualization(
            id=f"recitation_{int(time.time())}", visualizationType="latex", mainBody=gen_recitation),
         Visualization(
            id=f"bullets_{int(time.time())}", visualizationType="bullet", mainBody=bullets)
    ]
    
    return ServerResponse(visualizations=visuals, id=data.id, uploadNumber=data.uploadNumber)

@app.get('/')
async def ping():
    return "I am a teapot"

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=3000)
