"""
Section 1: LLM Proxy — Streaming Chat API

Step 1.1: Create a Minimal Chat Interface
A simple echo-based chat that demonstrates the ChatInterface contract.

Run with: ragbits api run ragbits_example.main:SimpleStreamingChat
"""

from collections.abc import AsyncGenerator

from ragbits.chat.api import RagbitsAPI
from ragbits.chat.interface import ChatInterface
from ragbits.chat.interface.types import ChatContext, ChatResponse
from ragbits.core.prompt import ChatFormat


class SimpleStreamingChat(ChatInterface):
    """A minimal chat interface that echoes user messages."""

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
