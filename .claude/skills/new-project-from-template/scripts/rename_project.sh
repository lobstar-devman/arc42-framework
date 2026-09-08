#!/usr/bin/env bash
# Renames arc42-framework toolkit identifiers to a new project's prefix.
#
# Replaces three exact substrings across every text file under --root:
#
#   architecting-toolkit  ->  <prefix>-toolkit  (or just <prefix> if the
#                                                 prefix already ends in
#                                                 "-toolkit" -- see below)
#   arc42-docs-net        ->  <prefix>-docs-net
#   arc42-framework       ->  <prefix>
#
# "architecting-toolkit" is replaced as a plain substring, which is
# deliberate: it also covers "architecting-toolkit-raw" and
# "architecting-toolkit-watch" (the token plus a suffix) in one pass, and
# it covers the docker-compose.yml service *keys* (services:
# architecting-toolkit: etc.) as well as their container_name/image
# values -- so the compose file and .devcontainer/devcontainer.json's
# "service" reference stay consistent with each other automatically, with
# no special-casing needed.
#
# If the prefix itself already ends in "-toolkit" (e.g. a project called
# "acme-toolkit"), appending another "-toolkit" would produce a redundant
# "acme-toolkit-toolkit" everywhere -- caught for real on the first
# supervised run of this skill, against the prefix
# "arc42-iso42001-toolkit". In that case the replacement for
# "architecting-toolkit" drops to just "<prefix>" (no suffix at all),
# which -- because it's still the same single substring replacement --
# also correctly turns "architecting-toolkit-raw"/"-watch" into
# "<prefix>-raw"/"-watch" with no further special-casing needed.
#
# Deliberately does NOT touch bare "arc42" (e.g. docs/arc42/, "arc42
# template", arc42.org links) -- that's the generic arc42 documentation
# standard this toolkit follows, not this repo's own name, and it must
# survive into every project built from this template. Only the longer,
# more specific "arc42-framework" and "arc42-docs-net" tokens are
# replaced.
#
# Plain bash + sed, not Python: this runs on the *host* machine before the
# new project's own Docker image (which does have Python) even exists yet,
# and a bare Windows/macOS/Linux dev machine can't be assumed to have
# python3 on PATH. sed ships with Git Bash / any POSIX system.
set -euo pipefail

usage() { echo "usage: $0 --root DIR --prefix PREFIX" >&2; exit 2; }

ROOT=""
PREFIX=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --prefix) PREFIX="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$ROOT" ] && [ -n "$PREFIX" ] || usage
[ -d "$ROOT" ] || { echo "error: --root $ROOT is not a directory" >&2; exit 2; }

case "$PREFIX" in
  *[!a-z0-9-]*|"")
    echo "error: --prefix must be lowercase letters, digits, and hyphens only (got '$PREFIX') -- Docker image names require this" >&2
    exit 2
    ;;
esac

case "$PREFIX" in
  *-toolkit) TOOLKIT_REPLACEMENT="$PREFIX" ;;
  *) TOOLKIT_REPLACEMENT="${PREFIX}-toolkit" ;;
esac

changed=0
while IFS= read -r -d '' f; do
  # -I makes grep skip binary files entirely (treats them as non-matching)
  # rather than risk sed -i corrupting one.
  if grep -Iq -e "architecting-toolkit" -e "arc42-docs-net" -e "arc42-framework" "$f" 2>/dev/null; then
    sed -i \
      -e "s/architecting-toolkit/${TOOLKIT_REPLACEMENT}/g" \
      -e "s/arc42-docs-net/${PREFIX}-docs-net/g" \
      -e "s/arc42-framework/${PREFIX}/g" \
      "$f"
    echo "  - ${f#"$ROOT"/}"
    changed=$((changed + 1))
  fi
done < <(find "$ROOT" -type f -not -path '*/.git/*' -print0)

if [ "$changed" -eq 0 ]; then
  echo "No files matched any of the tokens -- check --root and that it's really a copy of the arc42-framework toolkit." >&2
  exit 1
fi
echo "Renamed references in $changed file(s) using prefix '$PREFIX'."
