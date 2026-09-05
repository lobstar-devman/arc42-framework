# Sources of Truth

Every diagram and every generated page in this documentation traces back
to exactly one editable source-of-truth file. Never edit a diagram or a
generated page directly — edit the source and let the CI pipeline
regenerate everything downstream.

| Domain | Format | Location convention | Rendered via | Generated diagram path |
|---|---|---|---|---|
| Business process | BPMN 2.0 XML | `processes/*.bpmn` | [bpmn.io](https://bpmn.io) tooling | `docs/diagrams/bpmn/<name>.svg` |
| Case management | CMMN 1.1 XML | `processes/*.cmmn` | [bpmn.io](https://bpmn.io) tooling | `docs/diagrams/cmmn/<name>.svg` |
| Decision logic | DMN XML | `decisions/*.dmn` | [bpmn.io](https://bpmn.io) tooling | `docs/diagrams/dmn/<name>.svg` |
| System structure (C4) | Structurizr DSL | `architecture/workspace.dsl` | Structurizr CLI | `docs/diagrams/c4/*.svg` (every C4-level diagram, from this one file) |
| API contracts | OpenAPI (YAML/JSON) | `apis/*.openapi.yaml` | Redoc | n/a — rendered directly to a docs page, not a diagram |
| UML (class/sequence/state) | Mermaid text | `architecture/*.mmd` | Mermaid CLI | `docs/diagrams/mermaid/<name>.svg` |
| ERD / database design | Mermaid `erDiagram` or SQL DDL | `data-model/*.mmd` or `data-model/schema.sql` | Mermaid CLI | `docs/diagrams/erd/<name>.svg` |
| Bespoke config/data | JSON + JSON Schema | `data/*.json` + `data/*.schema.json` | validated only, not rendered | n/a |

### Resolving a diagram back to its source

Every path in the "Generated diagram path" column follows `docs/diagrams/<kind>/<name>.svg`, where `<name>` matches the source file's basename in the "Location convention" column for that row — except C4 (Structurizr), where every diagram under `docs/diagrams/c4/` always comes from the single `architecture/workspace.dsl`, regardless of its own filename. An implementation agent that hits an embedded `<img>`/`![...]` diagram should use this table to fetch the source-of-truth file instead (over the raw file endpoint — see the site [Home](../index.md) page) rather than trying to parse the SVG.

See the following pages for detail on each format:

- [BPMN / CMMN / DMN](bpmn-cmmn-dmn.md)
- [Structurizr DSL (C4)](structurizr-dsl.md)
- [OpenAPI](openapi.md)
- [JSON Schema](json-schema.md)
- [Mermaid (UML/ERD)](mermaid.md)
