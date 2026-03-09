"""Application configuration — UI branding, forms, and settings."""

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from ragbits.chat.interface.forms import UserSettings
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
