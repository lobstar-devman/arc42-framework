---
name: new-project-from-template
description: Bootstraps a brand-new project repository from this arc42-framework architecting toolkit -- exports the current toolkit tree with no shared git history, renames every toolkit/container identifier (Docker Compose project name, image tag, all three container names, the external network name, the devcontainer name) to a new project's own prefix, commits and pushes to an empty remote repo the user provides, then creates the external Docker network and brings the renamed stack up with a health check. Use this whenever the user wants to start a new project, system, or service using this toolkit as a template -- phrases like "set up a new project from this framework", "spin up a new architecting stack for X", "init a new repo from this toolkit", "I want to use this repo to start project Y", or "create a new docker stack based on arc42-framework" should all trigger it, even if the user doesn't say "template" or name this skill explicitly.
---

# New project from the arc42-framework template

This toolkit (arc42-framework) is meant to be reused: every new system gets
its own repo and its own Docker stack, seeded from this one. That reuse has
two parts, and this skill does both:

1. **A clean start.** The new repo should not carry this repo's own commit
   history (which is about building the toolkit, not about the new
   project's architecture) or any of its untracked scratch files. `git
   archive HEAD` exports exactly the tracked tree at the current commit,
   with nothing else -- cleaner than `git clone` + `rm -rf .git`.
2. **No identifier collisions.** If two projects both used the literal
   names `architecting-toolkit`, `arc42-docs-net`, etc., running both
   stacks on the same machine at once would collide (duplicate container
   names, one project's containers joining the other's network). Every
   project built from this template needs its own prefix baked into those
   identifiers.

## Before you start: gather three things

Ask the user for whichever of these weren't already given:

1. **`prefix`** -- the new project's short name, e.g. `acme-billing`. This
   becomes the new repo's directory name and is used to derive every
   renamed identifier.
2. **`remote_url`** -- the URL of an **already-created, empty** remote repo
   to push to (e.g. `git@github.com:someorg/acme-billing.git`, or the same
   kind of custom SSH-alias URL this repo itself uses -- check `git remote
   -v` in this repo if you need an example of the host alias format the
   user's machine expects). `gh` (GitHub's CLI) isn't assumed to be
   installed, so this skill doesn't create the remote repo itself -- have
   the user create it via their git host's web UI first (on GitHub: "New
   repository", no README/gitignore/license, just empty) and paste the
   URL. If `gh` *is* available and the user would rather you use it, that's
   fine too (`gh repo create <prefix> --private --confirm`) -- just get the
   resulting clone URL either way before continuing.
3. **`destination`** -- local path for the new project. Default to a
   sibling directory of this toolkit repo's own parent folder, e.g. if this
   repo is at `.../GitHub/LOBStar/arc42-framework`, default to
   `.../GitHub/LOBStar/<prefix>`. Confirm the default with the user rather
   than assuming it silently.

Default the branch name to `main` unless told otherwise.

**Before doing anything that writes to disk or the network, state the plan
back to the user in one short summary** (prefix, destination path, remote
URL, branch) **and get a clear go-ahead.** This is a one-shot bootstrap with
real, slightly-irreversible-in-practice consequences (a real push to a real
repo) -- cheap to confirm, expensive to redo cleanly if the destination or
URL was mistyped.

## Steps

1. **Sanity-check you're actually in (a clone of) the toolkit.** Confirm
   `docker-compose.yml` and `workspace/architecting-agent.md` exist at the
   toolkit repo's root. If the destination directory already exists and
   isn't empty, stop and ask rather than overwriting anything.

2. **Export the tree, no history:**
   ```
   mkdir -p <destination>
   git -C <toolkit-repo-root> archive HEAD | tar -x -C <destination>
   ```

3. **Rename every toolkit identifier** using the bundled script -- don't
   try to hand-edit this with find/replace or the Edit tool; the script
   encodes exactly which tokens are safe to replace and, just as
   important, which one to leave alone:
   ```
   bash scripts/rename_project.sh --root <destination> --prefix <prefix>
   ```
   (Plain bash + sed, not Python -- this runs on the host machine before
   the new project's own Docker image exists, and a bare dev machine can't
   be assumed to have `python3` on PATH the way the toolkit's containers
   do. Learned the hard way on the first real run of this skill, against a
   Windows host with no Python installed at all.)

   It replaces `architecting-toolkit` -> `<prefix>-toolkit` (this single
   substring replacement also correctly covers the `-raw`/`-watch` variants
   and the `docker-compose.yml` service *keys* + `.devcontainer/
   devcontainer.json`'s `"service"` reference, since they're all the same
   literal string), `arc42-docs-net` -> `<prefix>-docs-net`, and
   `arc42-framework` -> `<prefix>`. If `<prefix>` already ends in
   `-toolkit` (e.g. a project literally named `something-toolkit`), the
   script drops the redundant suffix instead of producing
   `something-toolkit-toolkit` -- also found on the first real run, so
   don't be surprised if a prefix ending in `-toolkit` gets a shorter
   container-name form than you might expect; that's intentional.
   It deliberately does **not** touch bare `arc42` (e.g. `docs/arc42/`,
   "arc42 template", arc42.org links) -- that's the generic arc42
   documentation standard this toolkit follows, not this repo's own name,
   and every project built from this template should keep following it.
   Read the script's own comments if you want the full reasoning; don't
   re-derive the token list from scratch each time this skill runs.

   Review the script's printed file list against what you'd expect
   (`docker-compose.yml`, `README.md`, `Dockerfile`,
   `.devcontainer/devcontainer.json`, `workspace/architecting-agent.md`,
   plus any docs pages that happen to mention a container name). If a file
   you'd expect to change didn't, or one you wouldn't expect did, look
   before continuing -- don't just trust the exit code.

   **Before committing, spot-check line endings on at least one `.sh`
   file** (`file <destination>/workspace/scripts/watch-and-generate.sh`
   should say plain "Bourne-Again shell script", not "with CRLF line
   terminators"). `arc42-framework` ships a `.gitattributes` forcing LF on
   export specifically because `git archive` was seen converting LF to
   CRLF on a Windows host with `core.autocrlf=true`, which breaks
   `set -o pipefail` inside the Linux container ("invalid option name",
   since bash reads the trailing `\r` as part of the option name) -- if
   you ever export from a fork or an older clone that predates that fix,
   this check will catch a repeat of the same failure before it reaches
   the new repo.

4. **Initialize git, commit, push:**
   ```
   cd <destination>
   git init -b <branch>
   git add -A
   git commit -m "Initial commit from arc42-framework template"
   git remote add origin <remote_url>
   git push -u origin <branch>
   ```
   Use the same commit-attribution footer this session's other commits
   use, if one is configured.

5. **Bring the stack up.** The compose file needs its external network to
   exist before `docker compose up` will work -- that's a one-time,
   per-machine, non-git thing (a `docker network create` isn't part of any
   repo and can't be committed), so don't leave it as a manual step for the
   user to remember; do it as part of this skill, the same way you'd do it
   for your own use:
   ```
   cd <destination>
   docker network inspect <prefix>-docs-net >/dev/null 2>&1 || docker network create <prefix>-docs-net
   docker compose build
   docker compose up -d
   ```
   Then do a basic health check before declaring success rather than just
   trusting the exit code -- e.g. `curl -s -o /dev/null -w '%{http_code}'
   http://localhost:8000/` should be `200`, and the raw endpoint
   (`:8001/`) should redirect. If either container fails to start, look at
   `docker compose logs` before reporting anything as done.

6. **Report back:** the new repo's remote URL, the local path, whether the
   network already existed or was just created, and that the stack is up
   and responding at `localhost:8000` (rendered) / `localhost:8001` (raw).

   Also mention explicitly that this new repo now has **zero shared git
   history** with arc42-framework -- future improvements to the toolkit
   itself won't flow into it automatically. That's the intended trade-off
   for a clean start, but it's worth saying out loud so it isn't a later
   surprise.

## What NOT to do

- Don't use `git clone` + `rm -rf .git` instead of `git archive` -- it
  works, but risks carrying over untracked files (stray scratch content,
  local build output) that `git archive` naturally excludes since it only
  ever sees tracked, committed content.
- Don't hand-roll the renaming with sed/Edit/grep -A calls -- use the
  bundled script. It's the same three substitutions every time; encoding
  them once avoids subtly re-deriving (and possibly getting wrong) the
  "don't touch bare arc42" exception on some future run.
- Don't skip the plan-confirmation step even if the user seems to be in a
  hurry -- a wrong destination path or mistyped remote URL is much cheaper
  to catch before the push than after.
