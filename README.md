![ClassX Interface](./pi_transparent.png)

# ClassX: AI Classrooms in Vision Pro + GPT-4 Generative 3b1b Videos

_Submitted to TreeHacks 2024, Andrew Zheng_

- **Integrate Learning Environments**: ClassX synergizes online and offline learning methodologies, enabling students to rapidly assimilate class material through advanced 'ultralearning' techniques.
- **Advanced Resource Access Gateway (RAG)**: Utilizes a sophisticated multi-query RAG system to display pertinent teaching assistant notes, LaTeX-rendered equations, educational YouTube content, and 3blue1brown (3b1b) animations, directly within the student's field of vision.
- **Dynamic Audio Transcription**: Incorporates Whisper audio transcription technology, offering the unique capability to **_rewind_** through lecture transcripts and revisit previous search results, enhancing comprehension and retention.
- **✨ Generative Video Creation ✨**: Employs GPT-4's advanced generative capabilities, coupled with the Manim rendering engine, to produce educational videos in the style of 3blue1brown, offering custom, high-quality visual explanations of complex concepts.

# Tech Stack

Server

- **Together AI:** Mistral 7x8b Mixture of Experts chat model
- **OpenAI:** text-embedding-ada-3 embedding
- **Chroma** multi query vector search. Each document and transcript maps to many keys, and Chromadb reranks n->n SQL mapping by similarity.
- **3b1b Manim**: Grant Sanderson’s Python math rendering engine. GPT-4 generates 2d animation scenes as executable code, creating 10-sec crystal-clear AI animated video (without OpenAI Sora 😉).

visionOS

- **FastAPI**: serves generated video and APIs
  visionOS App
- **100% Swift and SwiftUI**: fully native app!
  - handles animations, images, webviews, and more
  - native visionOS dynamic layout grids and resizing support without breakpoints
- **Whisper (Local)**: Transcribe audio offline with timestamps
  - Live streaming via AVFoundation
- **LaTeX renderer** (with regex to extract LaTeX sections and handle inlining)

## Setup

Good luck 🫠 ...

But seriously, kindly DM us on [Twitter](https://x.com/photomz) if you really want help. But first you pay an entry fee of $3500 for the Vision Pro LMFAO
