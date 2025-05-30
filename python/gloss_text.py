#!/usr/bin/env python3
import sys
import openai
import os

openai.api_key = os.getenv("OPENAI_API_KEY")

def gloss(text):
    prompt = f"""You are a literary editor for the Arden Shakespeare series.

In iambic pentameter (or close to it) that does not halt, gloss the following Shakespearean passage.

Do not quote or reprint the original lines in your gloss. Instead, write a fluent, line-by-line gloss that preserves the dramatic flow, style, and rhetorical tone. Focus on clarity and insight.

Do not label the gloss. Do not summarize the play or scene.

Only gloss this passage:

{text}
"""

    client = openai.OpenAI()
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            { "role": "user", "content": prompt }
        ]
    )

    print(response.choices[0].message.content)

if __name__ == "__main__":
    input_text = sys.stdin.read().strip()
    gloss(input_text)
