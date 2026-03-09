"""Application configuration — UI branding, forms, and settings."""

from ragbits.chat.interface.ui_customization import HeaderCustomization, PageMetaCustomization, UICustomization

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
