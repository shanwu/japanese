#!/bin/bash

# Check if gemini is installed
if ! command -v gemini &> /dev/null; then
    echo "Error: gemini command not found."
    exit 1
fi

# Get the diff from staged changes
DIFF_CONTENT=$(git diff --cached)

# Check if there are staged changes
if [ -z "$DIFF_CONTENT" ]; then
    echo "No staged changes found. Please stage your changes before running this script."
    exit 1
fi

# Read template
TEMPLATE_FILE="$(git rev-parse --show-toplevel)/.github/pull_request_template.md"
# Fallback to local templates directory (for dogfooding)
LOCAL_TEMPLATE="$(git rev-parse --show-toplevel)/templates/pull_request_template.md"

if [ -f "$TEMPLATE_FILE" ]; then
    TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")
elif [ -f "$LOCAL_TEMPLATE" ]; then
    TEMPLATE_CONTENT=$(cat "$LOCAL_TEMPLATE")
else
    # Fallback template failure
    TEMPLATE_CONTENT="Subject: <summary>\n\n<description>"
fi

# Prepare the prompt
PROMPT="Generate a concise PR description based on the following git diff.
Adhere strictly to this format:
$TEMPLATE_CONTENT

IMPORTANT RULES:
1. The first line must be the Subject.
2. The Subject must be plain text. DO NOT use Markdown (no bold **, no italics _).
3. The Subject should be concise and imperative (e.g., 'Fix typo', not 'Fixed typo').
4. The Body should describe WHY and WHAT changed.

Diff:
$DIFF_CONTENT"

# Call Gemini CLI
# Assuming 'gemini prompt' is the command based on help
gemini -p "$PROMPT"
