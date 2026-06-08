#!/usr/bin/env python3

"""Send a prompt to the local llama-server and print the response."""

import json
import os
import sys
import urllib.error
import urllib.request

BASE_URL = os.environ.get("PRISM_LLAMA_URL", "http://127.0.0.1:8080")
CHAT_URL = f"{BASE_URL.rstrip('/')}/v1/chat/completions"


def main() -> int:
    try:
        prompt = input("Prompt: ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        return 130

    if not prompt:
        print("No prompt provided.", file=sys.stderr)
        return 1

    payload = {
        "messages": [{"role": "user", "content": prompt}],
        "stream": False,
    }

    request = urllib.request.Request(
        CHAT_URL,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            body = json.load(response)
    except urllib.error.URLError as exc:
        print(
            f"Could not reach llama-server at {BASE_URL}\n"
            f"Check: systemctl status llama-server\n"
            f"Error: {exc}",
            file=sys.stderr,
        )
        return 1

    try:
        content = body["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError):
        print("Unexpected response from llama-server:", file=sys.stderr)
        print(json.dumps(body, indent=2), file=sys.stderr)
        return 1

    print(content)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
