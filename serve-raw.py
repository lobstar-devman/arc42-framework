#!/usr/bin/env python3
"""Raw file server for the architecting toolkit's second endpoint (port 8001).

Serves /workspace as-is (no rendering) for implementation-stack agents, with
two adjustments over a plain `http.server`:

  - `GET /` redirects to `/docs/index.md` (the actual project home page)
    instead of showing a directory listing.
  - Any file directly at the workspace root (AGENTS.md, CLAUDE.md,
    architecting-agent.md, mkdocs.yml, ...) is denied with 403 — those are
    toolkit-authoring files, not project/design content. Everything under a
    subdirectory (docs/, and the sources-of-truth directories such as
    processes/, architecture/, apis/, data-model/, data/) is served normally.
"""
import http.server
import os
import socketserver
import sys
from urllib.parse import unquote, urlsplit

ROOT = "/workspace"
HOME_REDIRECT = "/docs/index.md"


class RawHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def send_head(self):
        raw_path = urlsplit(self.path).path

        if raw_path == "/":
            self.send_response(302)
            self.send_header("Location", HOME_REDIRECT)
            self.end_headers()
            return None

        rel = os.path.normpath(unquote(raw_path).lstrip("/"))
        is_top_level_file = "/" not in rel and os.path.isfile(os.path.join(ROOT, rel))
        if is_top_level_file:
            self.send_error(
                403,
                "Toolkit-authoring files are not served here",
                "Only docs/ and the sources-of-truth directories are served.",
            )
            return None

        return super().send_head()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8001
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("0.0.0.0", port), RawHandler) as httpd:
        httpd.serve_forever()
