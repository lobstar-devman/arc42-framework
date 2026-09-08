# Decisions (ADRs)

Architecture Decision Records for this project. Each significant decision
identified during an architecture step (see
[Solution Strategy](../arc42/04-solution-strategy.md) and
[Building Block View](../arc42/05-building-block-view.md)) is recorded
here, hand-authored in prose (ADRs are a narrative artifact, not a
diagrammable source of truth).

## Log

| # | Title | Status | Date |
|---|---|---|---|
| [ADR-001](#adr-001-adopt-mdns-technical-writing-guidance-as-the-documentation-style-guide) | Adopt MDN's technical writing guidance as the documentation style guide | accepted | 2026-09-08 |

### ADR-001: Adopt MDN's technical writing guidance as the documentation style guide

**Status:** accepted
**Date:** 2026-09-08

#### Context

Hand-authored prose on this site — the Home page, the Sources of Truth
overviews, ADR entries, and free-text cross-cutting sections — had no
shared writing convention. As more pages accumulate from different
authors, human and agent, tone, terminology, and structure risk drifting
apart, which makes the site slower to read and harder to trust.

#### Decision

Adopt the guidance from MDN's
[technical writing blog post](https://developer.mozilla.org/en-US/blog/technical-writing/)
as this project's documentation style guide, captured in
[style-guide.md](../style-guide.md). It covers clarity, conciseness, and
consistency; page structure (introduction, then what → why → how);
worked examples; list, link, and image formatting; inclusive language;
and a proofreading pass before publishing. The guide applies only to
hand-authored prose — generated content (BPMN/CMMN/DMN labels, OpenAPI
descriptions, Structurizr DSL element names, Mermaid node text) follows
its own source-of-truth format's conventions instead.

#### Consequences

Hand-authored pages gain a consistent voice and structure, and authors
spend less time deciding how to phrase a page from scratch. The
trade-off is one more document to keep current if MDN revises its
guidance, and a small upfront cost for new contributors to read the
guide before writing their first prose page.

## Template

\`\`\`markdown
# ADR-NNN: <Title>

**Status:** proposed | accepted | superseded by ADR-NNN
**Date:** YYYY-MM-DD

## Context
What is the issue that we're seeing that motivates this decision?

## Decision
What is the change that we're proposing/doing?

## Consequences
What becomes easier or harder as a result of this change?
\`\`\`
