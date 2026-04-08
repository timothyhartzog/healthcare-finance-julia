# PubMed RAG Pipeline

## Goal

Integrate peer-reviewed evidence from PubMed into financial models. This enables evidence-augmented analytics: for example, automatically surfacing relevant cost-effectiveness studies when computing an ICER, or retrieving published ACO savings benchmarks when computing shared savings.

## Architecture

```
Query / Context
     ↓
PubMed Entrez API (E-utilities)
     ↓
Abstract + MeSH extraction
     ↓
Embedding model (e.g. BioBERT / OpenAI text-embedding)
     ↓
Vector store (DuckDB vss extension or Qdrant)
     ↓
Retrieval (top-k cosine similarity)
     ↓
Prompt augmentation → LLM response / annotation
```

## Implementation steps

### 1. Query PubMed via E-utilities

Use the NCBI E-utilities REST API:
- `esearch.fcgi` — search for PMIDs matching a query
- `efetch.fcgi` — fetch abstracts in XML or plain text

Example query parameters:
```
db=pubmed
term=value+based+care+hospital+finance
retmax=50
retmode=xml
```

### 2. Extract and clean abstracts

Parse XML responses to extract:
- PMID
- Title
- Abstract text
- MeSH terms
- Publication year
- Journal name

### 3. Embed documents

Use a biomedical-domain embedding model for best retrieval quality. Options:
- `BioBERT` (HuggingFace Transformers via Python subprocess)
- OpenAI `text-embedding-3-small` via REST API
- Local sentence-transformers model

Store embeddings as Float32 vectors alongside metadata.

### 4. Vector store

Store embeddings + metadata in:
- **DuckDB** with the `vss` extension for development (no extra infrastructure)
- **Qdrant** for production workloads requiring fast ANN search over millions of vectors

### 5. Retrieval and augmentation

Given a query context (e.g., "ICER threshold for oncology interventions"):
1. Embed the query using the same model
2. Run nearest-neighbor search (cosine similarity)
3. Return top-k abstracts
4. Inject as context into the LLM prompt or display alongside computed metrics

## Julia integration

The pipeline can be called from Julia via:
- HTTP.jl for E-utilities API calls
- JSON3.jl for response parsing
- DuckDB.jl for vector storage (vss extension)
- A Python bridge (PyCall.jl) for embedding models not yet native to Julia

## Status

- [ ] PubMed API query wrapper
- [ ] Abstract XML parser
- [ ] Embedding pipeline (BioBERT / OpenAI)
- [ ] DuckDB vector store schema
- [ ] Retrieval function
- [ ] Dashboard integration (show related literature with each metric)
