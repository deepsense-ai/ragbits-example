"""Application configuration — UI branding, forms, and settings."""

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from ragbits.chat.auth import ListAuthenticationBackend
from ragbits.chat.auth.session_store import InMemorySessionStore
from ragbits.chat.interface.forms import FeedbackConfig, UserSettings
from ragbits.chat.interface.ui_customization import HeaderCustomization, PageMetaCustomization, UICustomization

DEFAULT_MODEL = "gpt-4o-mini"

ui_customization = UICustomization(
    header=HeaderCustomization(
        title="Ragbits Assistant",
        subtitle="Built with Ragbits",
    ),
    welcome_message=(
        "**Welcome to Ragbits Assistant!**\n\n"
        "I'm a configurable AI assistant. Ask me anything to get started."
    ),
    starter_questions=[
        "What can you help me with?",
        "Explain how LLMs work in simple terms",
        "Write a Python function to sort a list",
    ],
    meta=PageMetaCustomization(page_title="Ragbits Assistant"),
)


class UserSettingsForm(BaseModel):
    """Settings form rendered in the UI, letting users pick their preferred model."""

    model_config = ConfigDict(title="Settings", json_schema_serialization_defaults_required=True)

    model: Literal["gpt-4o-mini", "gpt-4o", "claude-sonnet-4-20250514"] = Field(
        default=DEFAULT_MODEL,
        description="Choose your preferred AI model",
    )


user_settings = UserSettings(form=UserSettingsForm)


class LikeFeedbackForm(BaseModel):
    """Feedback form shown when a user likes a response."""

    model_config = ConfigDict(title="What did you like?", json_schema_serialization_defaults_required=True)

    reason: str = Field(
        description="What was helpful about this response?",
        min_length=1,
    )


class DislikeFeedbackForm(BaseModel):
    """Feedback form shown when a user dislikes a response."""

    model_config = ConfigDict(title="What went wrong?", json_schema_serialization_defaults_required=True)

    issue_type: Literal["Incorrect", "Unhelpful", "Unclear", "Other"] = Field(
        description="What was the issue?",
    )
    details: str = Field(
        description="Tell us more",
        min_length=1,
    )


feedback_config = FeedbackConfig(
    like_enabled=True,
    like_form=LikeFeedbackForm,
    dislike_enabled=True,
    dislike_form=DislikeFeedbackForm,
)


def get_auth_backend() -> ListAuthenticationBackend:
    """Create an authentication backend with demo users."""
    users = [
        {
            "user_id": "1",
            "username": "admin",
            "password": "admin",
            "full_name": "Admin User",
            "roles": ["admin"],
        },
        {
            "user_id": "2",
            "username": "user",
            "password": "user",
            "full_name": "Regular User",
            "roles": ["user"],
        },
    ]
    return ListAuthenticationBackend(users=users, session_store=InMemorySessionStore())
