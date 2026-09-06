#!/usr/bin/env bash
# Regenerates every diagram from its source of truth and links the
# `<!-- embed: ... -->` placeholders in docs/arc42/*.md to the result.
# See architecting-agent.md for the source-of-truth conventions this
# implements. Safe to re-run: sources that don't exist yet are skipped,
# not errored on.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DIAGRAMS_DIR="docs/diagrams"
mkdir -p "$DIAGRAMS_DIR/c4" "$DIAGRAMS_DIR/mermaid" "$DIAGRAMS_DIR/erd" "$DIAGRAMS_DIR/bpmn"

# Puppeteer (used by mmdc and bpmn-to-image) refuses to launch Chromium as
# root without --no-sandbox.
PUPPETEER_CONFIG="$(mktemp)"
echo '{"args": ["--no-sandbox"]}' > "$PUPPETEER_CONFIG"
trap 'rm -f "$PUPPETEER_CONFIG"' EXIT

render_mermaid() {
  local input="$1" output="$2"
  mmdc -i "$input" -o "$output" -p "$PUPPETEER_CONFIG" -b transparent
}

# The Structurizr CLI release ships as structurizr.sh + lib/*.jar, not a
# single runnable jar - resolve whichever layout is actually installed
# rather than assuming a specific wrapper is on PATH.
run_structurizr() {
  if [ -x /opt/structurizr-cli/structurizr.sh ]; then
    bash /opt/structurizr-cli/structurizr.sh "$@"
  elif [ -d /opt/structurizr-cli/lib ]; then
    java -cp "/opt/structurizr-cli:/opt/structurizr-cli/lib/*" com.structurizr.cli.StructurizrCliApplication "$@"
  else
    structurizr-cli "$@"
  fi
}

echo "==> Structurizr DSL -> C4 diagrams"
if [ -f architecture/workspace.dsl ]; then
  STRUCTURIZR_TMP="$(mktemp -d)"
  run_structurizr export -w architecture/workspace.dsl -f mermaid -o "$STRUCTURIZR_TMP"

  declare -A C4_MAP=(
    [structurizr-SystemContext.mmd]=context
    [structurizr-Containers.mmd]=containers
    [structurizr-Components.mmd]=components
    [structurizr-Deployment.mmd]=deployment
  )
  for src in "$STRUCTURIZR_TMP"/*.mmd; do
    [ -e "$src" ] || continue
    base="$(basename "$src")"
    name="${C4_MAP[$base]:-}"
    if [ -n "$name" ]; then
      render_mermaid "$src" "$DIAGRAMS_DIR/c4/$name.svg"
      echo "   - c4/$name.svg"
    else
      echo "   ! no mapping for exported view $base, skipping"
    fi
  done
  rm -rf "$STRUCTURIZR_TMP"
else
  echo "   (no architecture/workspace.dsl yet, skipping)"
fi

echo "==> Mermaid sequence/UML diagrams (architecture/*.mmd)"
shopt -s nullglob
for src in architecture/*.mmd; do
  name="$(basename "$src" .mmd)"
  render_mermaid "$src" "$DIAGRAMS_DIR/mermaid/$name.svg"
  echo "   - mermaid/$name.svg"
done

echo "==> Mermaid ER diagrams (data-model/*.mmd)"
for src in data-model/*.mmd; do
  name="$(basename "$src" .mmd)"
  render_mermaid "$src" "$DIAGRAMS_DIR/erd/$name.svg"
  echo "   - erd/$name.svg"
done

echo "==> BPMN process diagrams (processes/*.bpmn)"
for src in processes/*.bpmn; do
  name="$(basename "$src" .bpmn)"
  bpmn-to-image "$src:$DIAGRAMS_DIR/bpmn/$name.svg"
  echo "   - bpmn/$name.svg"
done

echo "==> Validating bespoke JSON against JSON Schema (data/*.json)"
for src in data/*.json; do
  case "$src" in *.schema.json) continue ;; esac
  schema="${src%.json}.schema.json"
  if [ -f "$schema" ]; then
    ajv validate -s "$schema" -d "$src"
    echo "   - $src valid against $schema"
  fi
done

echo "==> Linting OpenAPI specs (apis/*.openapi.yaml)"
for src in apis/*.openapi.yaml; do
  redocly lint "$src"
done
shopt -u nullglob

echo "==> Linking embed placeholders to generated diagrams"
python3 scripts/link-embeds.py

echo "Done."
