#!/usr/bin/env python3
import sys
import openai
import os

openai.api_key = os.getenv("OPENAI_API_KEY")

def gloss(text):
    prompt = f"""You are a literary editor for the Arden Shakespeare series.
Gloss the following passage from Shakespeare line-by-line.

For each line:
- First, quote the original line exactly.
- Then, on the next line, provide a modern English paraphrase or gloss.
- Include brief notes for difficult words, cultural references, or rhetorical effects.
- Leave a blank line between each pair.

Do not label the lines. Do not summarize the play. Format strictly as:

[Shakespeare line]  
[Modern gloss or explanation]

Only gloss the following passage:

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
