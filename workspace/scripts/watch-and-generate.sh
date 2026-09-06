#!/usr/bin/env bash
# Runs generate-docs.sh once immediately, then re-runs it whenever a
# source-of-truth file changes anywhere under the project except docs/
# itself (mkdocs serve already watches docs/ and reloads on its own once
# generate-docs.sh writes into it).
#
# This polls and hashes the tree itself rather than using an OS file
# watcher (inotify/watchmedo): Docker Desktop bind mounts on Windows/Mac
# don't reliably deliver inotify events for host-side edits, and
# watchmedo's own polling fallback (--debug-force-polling) was seen to
# retrigger in an infinite loop, since its --ignore-patterns didn't
# reliably exclude generate-docs.sh's own writes into docs/. Hashing only
# the non-docs/ tree sidesteps that entirely: this script's own writes are
# never part of what it compares.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

POLL_INTERVAL="${WATCH_POLL_INTERVAL:-2}"

hash_sources() {
  find . \( -path ./docs -o -path ./.git \) -prune -o -type f -print0 \
    | sort -z \
    | xargs -0 sha256sum 2>/dev/null \
    | sha256sum
}

last="$(hash_sources)"
./scripts/generate-docs.sh

while true; do
  sleep "$POLL_INTERVAL"
  current="$(hash_sources)"
  if [ "$current" != "$last" ]; then
    last="$current"
    ./scripts/generate-docs.sh
  fi
done
