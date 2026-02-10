"""
Section 1: LLM Proxy — Streaming Chat API

Step 1.3: Connect the LLM to Chat
Streams LLM responses but doesn't use conversation history yet.

Run with: ragbits api run ragbits_example.main:SimpleStreamingChat
"""

from collections.abc import AsyncGenerator

from ragbits.chat.api import RagbitsAPI
from ragbits.chat.interface import ChatInterface
from ragbits.chat.interface.types import ChatContext, ChatResponse
from ragbits.core.llms import LiteLLM
from ragbits.core.prompt import ChatFormat


class SimpleStreamingChat(ChatInterface):
    """A streaming chat interface that proxies requests to an LLM."""

    def __init__(self) -> None:
        self.llm = LiteLLM(model_name="gpt-4o-mini")

    async def chat(
        self,
        message: str,
        history: ChatFormat,
        context: ChatContext,
    ) -> AsyncGenerator[ChatResponse, None]:
        """Process a chat message and stream the LLM response."""
        conversation = [{"role": "user", "content": message}]
        stream = self.llm.generate_streaming(conversation)

        async for chunk in stream:
            yield self.create_text_response(chunk)


if __name__ == "__main__":
    api = RagbitsAPI(SimpleStreamingChat)
    api.run()
