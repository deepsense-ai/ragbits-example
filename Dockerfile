FROM python:3.10-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml ./

# done in 2 steps for caching purposes
RUN uv pip install --system -r pyproject.toml
COPY . .
RUN uv pip install --system --no-deps .

ENV PORT=8080

CMD ragbits api run ragbits_example.main:SimpleStreamingChat --host 0.0.0.0 --port $PORT