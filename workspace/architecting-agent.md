# Architecting Agent

**This is the toolkit to use whenever architecting a web application (or software system) in this workspace.** It defines the sources of truth, the documentation framework, and the pipeline that connects them. Every architecture step (database design, process modeling, decision logic, API contracts, system structure, etc.) must produce its deliverable through this toolkit — not ad hoc diagrams or prose.

## Core principle

This is a **living system**. Diagrams and documentation are never hand-drawn or hand-edited — they are always *generated* from a source-of-truth file. The source of truth is the only thing an author (human or agent) edits directly. If a diagram and its source ever disagree, the source of truth wins and the diagram is regenerated.

Deliverable for every architecture step = **(1) the source-of-truth file(s)** + **(2) the linked, generated documentation** that presents them in human-readable form.

## Sources of truth

Use the real standard format wherever good open tooling exists. Fall back to a pragmatic text DSL only where the "official" standard is impractical. Never hand-roll a format when a standard one is available.

| Domain | Source-of-truth format | Notes |
|---|---|---|
| Business process | **BPMN 2.0 XML** | Native standard, real tooling |
| Case management | **CMMN 1.1 XML** | Native standard |
| Decision logic | **DMN XML** | Native standard |
| System structure (C4 model) | **Structurizr DSL** | One `workspace.dsl` per system; generates all C4 levels (context/container/component) |
| API contracts | **OpenAPI (YAML/JSON)** | Native standard |
| Data contracts / bespoke config | **JSON, validated against JSON Schema** | Only used when no standard format fits; schema validation is mandatory in CI |
| UML (class, sequence, state, etc.) | **Mermaid text** | XMI interoperability is unreliable in practice; Mermaid is plain text, diffs cleanly in git, and renders via CLI |
| Entity-relationship / database design | **Mermaid `erDiagram`** (or actual SQL DDL where the database is the more authoritative source) | No dominant ERD standard exists; Mermaid is the pragmatic choice |

**Rule of thumb:** if it's BPMN/CMMN/DMN, OpenAPI, JSON Schema, or C4 — use the real standard. If it's UML or ERD — use Mermaid text. Anything left over — validated JSON + JSON Schema.

## Diagram tooling

- **[bpmn.io](https://bpmn.io)** (bpmn-js, dmn-js, cmmn-js) — the modeler and renderer for all BPMN, DMN, and CMMN XML sources. Used both for authoring/editing the XML and for headless export to SVG/PNG in the build pipeline.
- **Structurizr CLI** — renders C4 diagrams (context/container/component) from Structurizr DSL.
- **Mermaid CLI (mmdc)** — renders Mermaid text (UML and ERD) to SVG.
- **Redoc / Swagger UI** — renders OpenAPI specs into browsable API documentation.

## Documentation framework

**MkDocs Material**, following the **arc42 / C4-model** architecture documentation structure.

- Chosen over Docusaurus/Jupyter/marimo because: it's the de facto standard in the arc42/C4 architecture-documentation community (mature prior art and plugin ecosystem for exactly this use case), it's lighter-weight than a full JS framework, and it pairs naturally with Python-based build tooling.
- arc42 supplies the section structure (context & scope, building block view, runtime view, deployment view, cross-cutting concepts, decisions/ADRs, quality requirements, risks, glossary).
- C4 model supplies the system-structure diagrams (context/container/component) within that structure, generated from Structurizr DSL.
- Jupyter and marimo are **not** part of the documentation backbone. marimo may optionally be used for a standalone interactive artifact (e.g. a DMN decision-table simulator exported to WASM and embedded via iframe) — an enhancement, never the source of truth or the primary deliverable.

## CI pipeline

On every change to a source-of-truth file, CI:

1. **Validates** — lints BPMN/CMMN/DMN XML against their schemas, validates OpenAPI specs, validates bespoke JSON against its JSON Schema.
2. **Regenerates diagrams** — bpmn.io tooling for BPMN/CMMN/DMN, Structurizr CLI for C4, mmdc for Mermaid, Redoc for OpenAPI.
3. **Regenerates documentation** — rebuilds the affected MkDocs Material pages, embedding the freshly generated diagrams, and rebuilds cross-links between pages.
4. **Builds the site** — `mkdocs build`, failing the pipeline on broken links, missing diagrams, or validation errors.

No diagram or doc page is ever committed as a manually edited artifact — only the source-of-truth files and the pipeline configuration are hand-authored.

## Working rule for each architecture step

When performing an architecture step (e.g. database design, process modeling):

1. Identify which domain(s) it touches and pick the corresponding source-of-truth format from the table above.
2. Author/update the source-of-truth file only.
3. Run it through the CI pipeline (validate → render → regenerate docs → build).
4. The deliverable is the source-of-truth file(s) plus the resulting linked MkDocs Material page(s) — never a hand-drawn diagram or a standalone prose document.

## Implementation

Once a component's source-of-truth file(s) and generated documentation exist, the next step is implementation — turning the design into real, running code. This follows the same living-system discipline as the docs themselves, and happens in containers separate from the docs-toolkit.

- **Docs stay the source of truth for design.** Scaffold implementation code (classes/modules, migrations, service wiring) directly from the Building Block View, Runtime View, and domain model — method signatures and components should match what's documented, not diverge from it.
- **Traceability, not duplication.** If implementing something reveals the design needs to change, update the relevant source-of-truth file/doc first (and regenerate) — then adjust the code to match. Don't let code and docs silently drift apart. State this convention in the implementation's own README, pointing at the served docs site rather than assuming filesystem access to it (see below).
- **Implementation-level decisions are still ADRs.** A choice about how something gets built (containerization, testing strategy, a library or framework choice, an integration boundary) is as much an architecture decision as a choice about a data model, and gets recorded the same way.
- **One container (image) per concern.** The docs-toolkit container (Node/Java/Python tooling for rendering diagrams and building the docs site) stays documentation-only. Implementation gets its own container(s), sized to whatever stack the system actually needs — never folded into the docs-toolkit image, and vice versa.
- **Implementation containers read docs over HTTP, not a bind-mount.** The docs-toolkit already serves the rendered site (e.g. `mkdocs serve`) — anyone implementing against the design reads it there, in their editor, or in a browser, the same way they'd read any other reference material. Don't bind-mount the docs repo's filesystem into an implementation container "for convenience" — it isn't used that way in practice, and it silently couples the implementation to living inside the same repo/filesystem as the docs. (Structurizr and Mermaid both render to SVG, so diagram labels and relationship text stay real, searchable text on the served pages — nothing is lost by not having raw source-of-truth file access.)
- **Keep implementation code self-contained and relocatable.** Put it in its own directory (e.g. `implementation/`), with its own compose/build files, and zero references (paths, mounts, links) outside that directory. It can live alongside the docs for convenience early on, but should be a plain `cp` away from becoming its own repository — with its own history, CI, and release lifecycle — whenever that's warranted (e.g. publishing a package independently).
