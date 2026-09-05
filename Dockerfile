# Architecting toolkit image
# Sources of truth in: BPMN/CMMN/DMN XML, Structurizr DSL, OpenAPI, JSON Schema, Mermaid
# Docs in: MkDocs Material (arc42 / C4 structure)
# Diagram rendering: bpmn.io tooling, Structurizr CLI, Mermaid CLI, Redoc
#
# NOTE: bind mounts are a runtime concept, not a Dockerfile directive.
# This image expects your project (sources of truth + mkdocs.yml + docs/)
# to be bind-mounted at /workspace at `docker run` time — see docker-compose.yml.

FROM python:3.12-slim

# ---- System dependencies -----------------------------------------------
# curl/gnupg    : add the Node.js apt repo
# default-jre-headless : run Structurizr CLI (Java) for C4 diagrams
# libxml2-utils : xmllint, for validating BPMN/CMMN/DMN XML against XSDs
# git           : mkdocs plugins / repo-aware docs features
# unzip         : unpack the Structurizr CLI release
# chromium + fonts : headless rendering backend for bpmn-to-image (Puppeteer)
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        default-jre-headless \
        libxml2-utils \
        git \
        unzip \
        chromium \
        fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# ---- Node.js 20.x --------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Point Puppeteer-based tools at the apt-installed Chromium instead of
# downloading their own copy (smaller image, more reliable builds).
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# ---- Python tooling: docs site + JSON Schema validation ------------------
RUN pip install --no-cache-dir \
        mkdocs-material \
        mkdocs-mermaid2-plugin \
        mkdocs-awesome-pages-plugin \
        jsonschema \
        pyyaml

# ---- Node tooling: Mermaid CLI, bpmn.io headless export, OpenAPI ---------
# @mermaid-js/mermaid-cli : renders Mermaid (UML/ERD) text -> SVG
# bpmn-to-image           : headless bpmn.io renderer, BPMN XML -> SVG/PNG
# @redocly/cli            : lint + bundle OpenAPI specs
# redoc-cli                : render OpenAPI -> static HTML docs
# ajv-cli                  : validate bespoke JSON against JSON Schema
RUN npm install -g \
        @mermaid-js/mermaid-cli \
        bpmn-to-image \
        @redocly/cli \
        redoc-cli \
        ajv-cli

# ---- Structurizr CLI (C4 model diagrams from Structurizr DSL) ------------
ARG STRUCTURIZR_CLI_VERSION=2025.11.09
RUN mkdir -p /opt/structurizr-cli \
    && curl -fsSL -o /tmp/structurizr-cli.zip \
        "https://github.com/structurizr/cli/releases/download/v${STRUCTURIZR_CLI_VERSION}/structurizr-cli.zip" \
    && unzip -q /tmp/structurizr-cli.zip -d /opt/structurizr-cli \
    && rm /tmp/structurizr-cli.zip \
    && chmod +x /opt/structurizr-cli/structurizr.sh \
    && ln -s /opt/structurizr-cli/structurizr.sh /usr/local/bin/structurizr-cli

# ---- Workspace -------------------------------------------------------------
# This directory is where the bind-mounted project lands (see docker-compose.yml).
WORKDIR /workspace

# 8000: rendered MkDocs Material site (for humans/browsers).
# 8001: raw project tree over plain HTTP (for implementation-stack agents —
# see docker-compose.yml's architecting-toolkit-raw service).
EXPOSE 8000 8001

# Default action: serve the MkDocs Material site.
# Override with `docker run ... <image> <command>` to instead run validation
# or diagram-regeneration steps, e.g.:
#   structurizr-cli export -w workspace.dsl -f mermaid -o docs/diagrams
#   mmdc -i docs/diagrams/erd.mmd -o docs/diagrams/erd.svg
#   bpmn-to-image process.bpmn:process.svg
#   xmllint --noout --schema bpmn20.xsd process.bpmn
#   ajv validate -s schema.json -d data.json
#   redocly lint openapi.yaml
#   python3 -m http.server 8001 --bind 0.0.0.0   # raw file serving, no rendering
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
