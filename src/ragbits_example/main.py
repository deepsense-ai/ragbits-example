"""
Section 1: LLM Proxy — Streaming Chat API

Step 1.2: Add an LLM
Introduces LiteLLM but doesn't connect it to the chat method yet.

Run with: ragbits api run ragbits_example.main:SimpleStreamingChat
"""

from collections.abc import AsyncGenerator

from ragbits.chat.api import RagbitsAPI
from ragbits.chat.interface import ChatInterface
from ragbits.chat.interface.types import ChatContext, ChatResponse
from ragbits.core.llms import LiteLLM
from ragbits.core.prompt import ChatFormat


class SimpleStreamingChat(ChatInterface):
    """A chat interface with LLM initialized but not yet connected."""

    def __init__(self, model_name: str = "gpt-4o-mini") -> None:
        self.model_name = model_name
        self.llm = LiteLLM(model_name=self.model_name)

    async def chat(
        self,
        message: str,
        history: ChatFormat,
        context: ChatContext,
    ) -> AsyncGenerator[ChatResponse, None]:
        """Process a chat message and return an echo response."""
        yield self.create_text_response("Hello! You said: " + message)


if __name__ == "__main__":
    api = RagbitsAPI(SimpleStreamingChat)
    api.run()
