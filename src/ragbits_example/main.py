"""
Section 2: Application Configuration — Identity, Persistence & Customization

Step 2.6: Require Authentication
    Credential-based login gate with demo users; greeting on first message.

Run with CLI:
    uv run ragbits api run ragbits_example.main:SimpleStreamingChat \
        --auth ragbits_example.config:get_auth_backend

Or programmatically:
    uv run python -m ragbits_example.main
"""

import json
import logging
import time
from collections.abc import AsyncGenerator
from pathlib import Path
from typing import Any

from ragbits.chat.api import RagbitsAPI
from ragbits.chat.interface import ChatInterface
from ragbits.chat.interface.types import ChatContext, ChatResponse, FeedbackType
from ragbits.chat.persistence.file import FileHistoryPersistence
from ragbits.core.llms import LiteLLM
from ragbits.core.prompt import ChatFormat

from ragbits_example.config import DEFAULT_MODEL, feedback_config, get_auth_backend, ui_customization, user_settings

logger = logging.getLogger(__name__)


class SimpleStreamingChat(ChatInterface):
    """A streaming chat interface with custom branding and UI configuration."""

    ui_customization = ui_customization
    user_settings = user_settings
    feedback_config = feedback_config

    conversation_history = True
    history_persistence = FileHistoryPersistence("./chat_history")
    feedback_path = Path("./chat_history/feedback.jsonl")

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
        if context.user and not history:
            name = context.user.full_name or context.user.username
            yield self.create_text_response(f"Hello, {name}! ")

        model_name = DEFAULT_MODEL
        if hasattr(context, "user_settings") and context.user_settings:
            model_name = context.user_settings.get("model", DEFAULT_MODEL)

        llm = LiteLLM(model_name=model_name)
        stream = llm.generate_streaming([*history, {"role": "user", "content": message}])

        message_count = context.state.get("message_count", 0) + 1

        async for chunk in stream:
            yield self.create_text_response(chunk)

        yield self.create_state_update({"message_count": message_count})

    async def save_feedback(
        self,
        message_id: str,
        feedback: FeedbackType,
        payload: dict[str, Any] | None = None,
    ) -> None:
        """Persist feedback to a JSONL file for later analysis."""
        await super().save_feedback(message_id, feedback, payload)
        self.feedback_path.parent.mkdir(parents=True, exist_ok=True)
        record = {
            "message_id": message_id,
            "feedback": feedback.value,
            "payload": payload,
            "timestamp": time.time(),
        }
        with open(self.feedback_path, "a") as f:
            f.write(json.dumps(record) + "\n")


if __name__ == "__main__":
    api = RagbitsAPI(SimpleStreamingChat, auth_backend=get_auth_backend())
    api.run()
