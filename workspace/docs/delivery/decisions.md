# Development and Delivery Decisions

Decisions about how the system is built, checked and run outside production. Decisions about the production system itself are in [Decisions (ADRs)](../decisions/index.md). Both logs share one number sequence: a number is used once, in one log.

## Log

| # | Title | Status | Date |
|---|---|---|---|
| [ADR-001](#adr-001-adopt-mdns-technical-writing-guidance-as-the-documentation-style-guide) | Adopt MDN's technical writing guidance as the documentation style guide | accepted | 2026-09-08 |
| [ADR-002](#adr-002-keep-development-and-delivery-apart-from-the-production-architecture) | Keep development and delivery apart from the production architecture | accepted | 2026-11-08 |

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

### ADR-002: Keep development and delivery apart from the production architecture

**Status:** accepted
**Date:** 2026-11-08

#### Context

A documentation set covers two subjects: the production system, and how
it is built, checked and run outside production. Decisions about the
second, such as coding rules, review, CI and test environments, could go
another way without changing the product. When both subjects share the
arc42 chapters and one decision log, the decisions that shape the
product are harder to find.

Practitioner guidance supports keeping them apart:

- **arc42** keeps its decisions section for significant decisions
  ([arc42 FAQ C-9-1](../about/bibliography.md#arc42-faq-c-9-1)), suggests splitting a large
  documentation set into linked parts
  ([arc42 FAQ J-1](../about/bibliography.md#arc42-faq-j-1)), and groups development concepts
  apart from the others ([arc42 FAQ C-8-2](../about/bibliography.md#arc42-faq-c-8-2)).
- **Views by stakeholder concern:** the architecture description
  standard organises views this way
  ([ISO/IEC/IEEE 42010:2022](../about/bibliography.md#iso-42010-2022)). Developers' concerns
  have a view of their own in the 4+1 model
  ([Kruchten, 1995](../about/bibliography.md#kruchten-1995)) and in the Development
  viewpoint ([Rozanski and Woods, 2011](../about/bibliography.md#rozanski-woods-2011)).
- **The Software Guidebook** describes the development environment in
  its own section
  ([Brown](../about/bibliography.md#brown-software-guidebook)).

arc42 and Nygard count construction techniques as architecturally
significant ([Nygard, 2011](../about/bibliography.md#nygard-2011)), so those decisions are
recorded, but in a log of their own.

#### Decision

- **The production architecture covers only the production system.**
  arc42 chapters 1 to 12 and the production decision log describe what
  the system is and does.
- **Development and Delivery is a section of its own,** with the
  development method, non-production environments, delivery quality
  requirements, delivery risks and technical debt, a glossary, and its
  own decision log.
- **The rule for where a decision goes:** one that changes what the
  system is or does in production goes in the production log; one that
  changes only how it's built, checked or run outside production goes
  in the Development and Delivery log; if unclear, the production log.
- **Decisions about how the documentation is written and organised go in
  the Development and Delivery log,** because they change nothing about
  the system in production.
- **One number sequence across both logs.** A number is used once, in
  one log. Each Development and Delivery ADR has a heading and a row in
  the production log that point to it, so the sequence has no gaps there
  and links to its anchor resolve.
- **Production chapters may link to Development and Delivery,** but
  never rely on it.
- **Outside sources are cited through the
  [Bibliography](../about/bibliography.md).**
  [How This Documentation Is Organised](../about/structure.md) describes
  the structure.

#### Consequences

A reader of the production architecture sees only the system, and its
decision log holds only decisions about it.

The trade-offs are listed below.

- **There are two logs to look in.** The shared sequence and the
  pointers in the production log keep every number findable.
- **The pointers must be kept** for as long as anything links to the
  old anchors.
- **Some topics sit on the line,** such as quality scenarios about
  change safety. Each is placed by the rule, and moved later if the rule
  places it differently.
