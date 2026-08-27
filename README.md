# Run it with:

`docker compose up`

which serves the docs site at localhost:8000 with live reload. 
For one-off validation/regeneration steps (e.g. re-exporting a Structurizr diagram or linting an OpenAPI file), use `docker compose run --rm architecting-toolkit scripts/generate-docs.sh` — the comments in both files show example invocations for each tool.