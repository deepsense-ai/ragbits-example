# Ragbits Example

Companion repository for the [Builder Journal](https://ragbits.deepsense.ai/builder-journal/) — a hands-on guide to building production-ready GenAI applications with [Ragbits](https://github.com/deepsense-ai/ragbits).

## Overview

This repository contains working code for each section of the Builder Journal. Each section builds on the previous one, progressively adding capabilities to a chat application:

| Section | What You Build | Key Concepts |
|---------|----------------|--------------|
| [1. LLM Proxy](https://ragbits.deepsense.ai/builder-journal/section-1-llm-proxy/) | Streaming chat API with web UI | ChatInterface, LiteLLM, RagbitsAPI |

## Prerequisites

- Python 3.10+
- An API key from any supported LLM provider (OpenAI, Anthropic, Azure, etc.)

## Installation

Install dependencies using [uv](https://github.com/astral-sh/uv):

```bash
uv sync
```

## Configuration

Set your LLM provider API key:

```bash
# OpenAI
export OPENAI_API_KEY="your-api-key"

# Or Anthropic
export ANTHROPIC_API_KEY="your-api-key"

# Or any other provider supported by LiteLLM
```

## Running the Application

Start the chat server:

```bash
ragbits api run ragbits_example.main:SimpleStreamingChat
```

Open http://127.0.0.1:8000 in your browser to access the chat interface.

### Server Options

```bash
# Custom host and port
ragbits api run ragbits_example.main:SimpleStreamingChat --host 0.0.0.0 --port 9000

# Auto-reload for development
ragbits api run ragbits_example.main:SimpleStreamingChat --reload

# Debug mode
ragbits api run ragbits_example.main:SimpleStreamingChat --debug
```

## Deploying the Application
In order to deploy the app on GCP follow instructions in [infrastructure/README.md](infrastructure/README.md)

## Project Structure

```
ragbits-example/
├── src/
│   └── ragbits_example/
│       ├── __init__.py
│       └── main.py      # Chat application implementation
├── pyproject.toml       # Project configuration and dependencies
└── README.md
```

## How to Use with the Builder Journal

1. Read a section in the [Builder Journal](https://ragbits.deepsense.ai/builder-journal/)
2. Reference the corresponding code in this repository
3. Run and experiment with the application
4. Modify and extend based on your needs

The documentation explains the concepts while this repository provides the working implementation.

## Links

- [Builder Journal](https://ragbits.deepsense.ai/builder-journal/) — Step-by-step tutorial
- [Ragbits Documentation](https://ragbits.deepsense.ai/) — Full documentation
- [Ragbits GitHub](https://github.com/deepsense-ai/ragbits) — Main repository
- [LiteLLM Providers](https://docs.litellm.ai/docs/providers) — Supported LLM providers
