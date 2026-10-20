<!-- template-intro:start -->
# Architecting toolkit template

## What this repo is

A template for architecting a system as a living set of documents. It is a Docker stack plus a repo skeleton, built so that each new system gets its **own independent repo and its own Docker stack**, seeded from this one.

- **Documentation:** an [arc42](https://arc42.org)-structured MkDocs Material site, with C4 diagrams. `workspace/architecting-agent.md` defines the conventions.
- **Sources of truth:** BPMN/CMMN/DMN, Structurizr DSL, OpenAPI, JSON Schema and Mermaid files. Diagrams and pages are generated from them, never hand-edited.
- **Three containers:** a rendered docs site, a raw-file server for implementation agents, and a watcher that regenerates diagrams when a source changes (see [Run it](#run-it)).

The template's own container, network and project names are placeholders. They're renamed per project when you create a new one, so several projects' stacks can run side by side without colliding. This stack is normally idle; run it only when you're developing the template itself.

## Creating a new project from this template

A Claude Code skill does the whole job, so you don't copy and rename things by hand.

**Where it's defined:** [.claude/skills/new-project-from-template/SKILL.md](.claude/skills/new-project-from-template/SKILL.md), with its rename script at [.claude/skills/new-project-from-template/scripts/rename_project.sh](.claude/skills/new-project-from-template/scripts/rename_project.sh). It's a project-level skill, so it's available whenever this repo is open in Claude Code.

**Before you start:**

1. Create an **empty** repo on your git host (on GitHub: "New repository" with no README, `.gitignore` or license) and copy its clone URL.
2. Make sure `git`, Docker and a bash shell (Git Bash on Windows) are available.

**How to use it:** open Claude Code in this repo and ask for a new project, for example *"Create a new project called acme-billing from this template"*, or run `/new-project-from-template`. Claude asks for the inputs below, then states the plan and waits for your go-ahead before it writes anything:

| Input | Notes |
|---|---|
| Prefix | The project's short name, such as `acme-billing`. Lowercase letters, digits and hyphens only, because Docker image names require that. |
| Remote URL | The empty repo from step 1. |
| Destination | Where to create the project locally. Defaults to a sibling folder of this repo, named after the prefix. |
| Description | Optional. One line on what the system is; it goes into the new project's README. |

**What it does:**

1. Exports the current tree with `git archive`, so the new repo gets a clean start with none of this repo's history.
2. Renames the Compose project, image, containers, network and devcontainer to the prefix, using `rename_project.sh`. It also replaces this template-only intro, the part of the README above "Run it", with a short intro for the new project.
3. Commits, then pushes to your remote as `main`.
4. Creates the project's `<prefix>-docs-net` network if it's missing, runs `docker compose build` and `up -d`, and health-checks the docs site (port 8000) and the raw server (port 8001).

The new repo shares no git history with this template, so later template improvements don't flow into it automatically.
<!-- template-intro:end -->

## Run it

First, one-time only, create the shared network implementation stacks will use to reach these containers:

```
docker network create arc42-docs-net
```

Then:

`docker compose up`

which serves:

- **`localhost:8000`** — the rendered MkDocs Material site, with live reload, for humans in a browser. Generated diagrams (BPMN, C4, Mermaid) are pan/zoom viewers on a white background: drag to pan, `+`/`-` or ctrl+wheel to zoom, and `RESET` to refit. Double-click a diagram (or use its "Open full page" link) to open it in a new tab at full window size, where the plain wheel and double-click zoom as well. The zoom library loads from a CDN, so without internet access diagrams fall back to plain images.
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

To avoid typing ssh-add manually each time, add this to `C:\Users\<you>\.ssh\config`:

```
Host *
    AddKeysToAgent yes
```    