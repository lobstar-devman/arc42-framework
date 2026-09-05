# Run it with:

First, one-time only, create the shared network implementation stacks will use to reach these containers:

```
docker network create arc42-docs-net
```

Then:

`docker compose up`

which serves:

- **`localhost:8000`** — the rendered MkDocs Material site, with live reload, for humans in a browser.
- **`localhost:8001`** — the docs markdown plus every sources-of-truth directory (`processes/`, `architecture/`, `apis/`, `data-model/`, `data/`) served raw (plain files, no HTML). `/` redirects to `/docs/index.md`; top-level toolkit files (`AGENTS.md`, `CLAUDE.md`, `architecting-agent.md`, `mkdocs.yml`) are denied — see `serve-raw.py`. This is what a separate implementation-stack agent should read from; see `workspace/docs/index.md`'s "For implementation agents" section for how to resolve an embedded diagram back to its source-of-truth file instead of consuming the SVG. A stack on the `arc42-docs-net` network can also reach it by container name (`architecting-toolkit-raw:8001`) instead of the published host port.

For one-off validation/regeneration steps (e.g. re-exporting a Structurizr diagram or linting an OpenAPI file), use `docker compose run --rm architecting-toolkit scripts/generate-docs.sh` — the comments in both files show example invocations for each tool.