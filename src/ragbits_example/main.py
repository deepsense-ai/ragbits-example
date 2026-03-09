"""
Section 2: Application Configuration — Identity, Persistence & Customization

Step 2.4: Track State Across Messages
    HMAC-signed state update carries a message counter between turns.

Run with CLI:
    uv run ragbits api run ragbits_example.main:SimpleStreamingChat

Or programmatically:
    uv run python -m ragbits_example.main
"""

from collections.abc import AsyncGenerator

from ragbits.chat.api import RagbitsAPI
from ragbits.chat.interface import ChatInterface
from ragbits.chat.interface.types import ChatContext, ChatResponse
from ragbits.chat.persistence.file import FileHistoryPersistence
from ragbits.core.llms import LiteLLM
from ragbits.core.prompt import ChatFormat

from ragbits_example.config import DEFAULT_MODEL, ui_customization, user_settings


class SimpleStreamingChat(ChatInterface):
    """A streaming chat interface with custom branding and UI configuration."""

    ui_customization = ui_customization
    user_settings = user_settings

    conversation_history = True
    history_persistence = FileHistoryPersistence("./chat_history")

    def __init__(self) -> None:
        self.llm = LiteLLM(model_name=DEFAULT_MODEL)

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
        model_name = DEFAULT_MODEL
        if hasattr(context, "user_settings") and context.user_settings:
            model_name = context.user_settings.get("model", DEFAULT_MODEL)

        llm = LiteLLM(model_name=model_name)
        stream = llm.generate_streaming([*history, {"role": "user", "content": message}])

        message_count = context.state.get("message_count", 0) + 1

        async for chunk in stream:
            yield self.create_text_response(chunk)

        yield self.create_state_update({"message_count": message_count})


if __name__ == "__main__":
    api = RagbitsAPI(SimpleStreamingChat)
    api.run()
