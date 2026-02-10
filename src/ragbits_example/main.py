"""
Section 1: LLM Proxy — Streaming Chat API

A minimal streaming chat application using Ragbits.
This establishes the foundational pattern that all subsequent sections build upon.

Run with CLI:
    ragbits api run ragbits_example.main:SimpleStreamingChat

Or programmatically:
    python -m ragbits_example.main
"""

from collections.abc import AsyncGenerator

from ragbits.chat.api import RagbitsAPI
from ragbits.chat.interface import ChatInterface
from ragbits.chat.interface.types import ChatContext, ChatResponse
from ragbits.core.llms import LiteLLM
from ragbits.core.prompt import ChatFormat


class SimpleStreamingChat(ChatInterface):
    """A minimal streaming chat interface that proxies requests to any LLM provider."""

    def __init__(self) -> None:
        self.llm = LiteLLM(model_name="gpt-4o-mini")

    async def chat(
        self,
        message: str,
        history: ChatFormat,
        context: ChatContext,
    ) -> AsyncGenerator[ChatResponse, None]:
        """
        Process a chat message and stream the response.

        Args:
            message: The current user message
            history: Previous messages in the conversation
            context: Additional context (user info, settings, etc.)

        Yields:
            ChatResponse objects containing streamed text chunks
        """
        stream = self.llm.generate_streaming([*history, {"role": "user", "content": message}])

        async for chunk in stream:
            yield self.create_text_response(chunk)


if __name__ == "__main__":
    api = RagbitsAPI(SimpleStreamingChat)
    api.run()
