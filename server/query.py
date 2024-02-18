from service import *

# transcript = """
# What's a Markov matrix?
# Can I just write down a typical Markov matrix, say .1, .2, .7, .01, .99 0, let's say, .3, .3, .4. Okay. There's a -- a
# totally just invented Markov matrix. What makes it a Markov matrix?
# Two properties that this -- this matrix has.
# So two properties are -- one, every entry is greater equal zero.
# All entries greater than or equal to zero.
# And, of course, when I square the matrix, the entries will still be greater/equal zero.
# I'm going to be interested in the powers of this matrix.
# """

transcript = """
With determinants it's a fascinating, small topic inside linear algebra.
Used to be determinants were the big thing, and linear algebra was the little thing, but they -- those changed, that
situation changed.
Now determinants is one specific part, very neat little part.
And my goal today is to find a formula for the determinant.
It'll be a messy formula.
So that's why you didn't see it right away.
But if I'm given this n by n matrix then I use those entries to create this number, the determinant.
So there's a formula for it.
"""

completion = Together.chat(Prompts.transcript_to_bullets(transcript, n=4))
bullet_points = list(filter(None, completion.replace('```', '').split('\n- ')))

print(bullet_points)

queries = OpenAI.embed(bullet_points)
k = Chroma.query(query_embeddings=queries, n_results=3)
k = {key: flatten_2d(v) for key, v in k.items() if key and v}

results = [SearchResult(id=a, distance=b, metadata=c) for a,b,c in zip(k['ids'], k['distances'], k['metadatas'])]
results.sort(key=lambda x: x.distance)

unique_results = SearchResult.set(results, by='id')

print(unique_results)

topk = [x.metadata for x in unique_results[:20]]

# take top 3 scores. could be unique, or same lecture diff bullet.
urls = list(set([x['path'] for x in topk]))

bullets = "\n".join(["- " + x['bullet'] for x in topk])

print(bullets, urls)

gen_recitation = Together.chat(Prompts.bullets_to_recitation(bullets), max_tokens=1000)

print(gen_recitation)