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

A third service, `architecting-toolkit-watch`, runs in the background (no port) watching every source-of-truth file for changes and re-running `scripts/generate-docs.sh` automatically — edit a `.dsl`/`.bpmn`/`.mmd`/etc. file while the stack is up and its diagram + embed link regenerate on their own, with the rendered site live-reloading once they land under `docs/`. `docker compose run --rm architecting-toolkit scripts/generate-docs.sh` still works for a one-off run without the full stack up — the comments in both scripts show example invocations for each tool.

## Developing in VS Code

`.devcontainer/devcontainer.json` points VS Code's Dev Containers extension at the `architecting-toolkit` service above, so "Reopen in Container" (or "Attach to Running Container" after `docker compose up`) opens the same container the compose stack already runs, with `/workspace` as the folder — no separate dev-only image. `git` is already in the image, so commits/pushes work from VS Code's terminal or Source Control view.

For pushing/pulling over SSH, use the Dev Containers extension's built-in [SSH agent forwarding](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials) rather than putting a key anywhere near the container. One-time setup on Windows:

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add C:\Users\<you>\.ssh\id_ed25519
```

With the agent running and the key added, VS Code forwards it automatically into any container it connects to (reopen or attach, no compose changes needed) — no key file, not even a copy, ever touches the container's disk. This only covers terminals VS Code itself opens after connecting; a plain `docker exec` from PowerShell won't see the forwarded agent.