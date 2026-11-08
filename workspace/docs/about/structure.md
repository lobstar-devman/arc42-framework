# How This Documentation Is Organised

This site has two main parts: the architecture of the production system,
and how that system is developed and delivered. They're kept apart so
that a reader assessing the system sees only the system.

## The parts

| Part | What it describes | Who it's for |
|---|---|---|
| [Architecture (arc42)](../arc42/01-introduction-and-goals.md) and [Decisions (ADRs)](../decisions/index.md) | The production system: its goals, constraints, structure, behaviour, deployment, concepts, decisions, quality requirements and risks | Anyone who needs to understand or assess the system, such as its owners, assessors and operators |
| [Development and Delivery](../delivery/index.md) | How the system is built, checked and run outside production: the development method, non-production environments, delivery quality requirements, delivery risks, and their decisions | The people and agents who build the system |
| [Sources of Truth](../sources-of-truth/index.md) | Which file each generated diagram and page comes from | Anyone changing the design |

The production chapters may link to Development and Delivery, but never
rely on it: each one makes sense without it.

## Which part a topic belongs in

A topic or decision belongs in the production architecture if it changes
what the system is or does: its structure, behaviour, data, interfaces
or qualities in production. It belongs in Development and Delivery if it
changes only how the system is built, checked or run outside production,
so that the same system could have been reached another way. If it's
unclear, it goes in the production architecture.

## Two decision logs, one sequence

Each part has its own decision log. Both logs share one number
sequence: a number is used once, in one log. A decision recorded in the
Development and Delivery log keeps a heading and a row in the production
log that point to it, so links to it from elsewhere, such as an
implementation repository, resolve.

## Generated pages

Diagrams and generated pages are produced from the sources of truth, and
are never edited by hand. Chapter 9's log table is copied from the
production decision log in the same way.
[Sources of Truth](../sources-of-truth/index.md) explains where each
source lives and how a diagram is traced back to it.

## Why it's organised this way

- **arc42 keeps section 9 for significant decisions:** those that are
  important, expensive, risky or long-lasting, and that shape the
  system's structure, qualities, dependencies or interfaces
  ([arc42 FAQ C-9-1](../about/bibliography.md#arc42-faq-c-9-1),
  [arc42 section 9](../about/bibliography.md#arc42-section-9)). arc42 and Nygard also count
  construction techniques as architecturally significant
  ([Nygard, 2011](../about/bibliography.md#nygard-2011)). Here, those decisions are recorded
  in their own log, so the production log holds only decisions about the
  system itself.
- **arc42 suggests splitting a large documentation set** into a common
  part and separate parts, each using only the arc42 sections it needs,
  linked to each other ([arc42 FAQ J-1](../about/bibliography.md#arc42-faq-j-1)). Development
  and Delivery is one such part.
- **arc42 groups development concepts apart.** Its FAQ groups
  cross-cutting concepts, and treats development concepts (build, code
  generation, configuration, testing, migration) and operations
  concepts as groups of their own
  ([arc42 FAQ C-8-2](../about/bibliography.md#arc42-faq-c-8-2)).
- **arc42 asks for every relevant environment to be documented,** with a
  copy of the deployment view for each where they differ
  ([arc42 section 7](../about/bibliography.md#arc42-section-7)). The production deployment
  is in chapter 7. Development and staging are described in
  [Environments](../delivery/environments.md).
- **The architecture description standard organises views by
  stakeholder concern**
  ([ISO/IEC/IEEE 42010:2022](../about/bibliography.md#iso-42010-2022)). Developers' concerns
  have a view of their own: the development view in the 4+1
  model ([Kruchten, 1995](../about/bibliography.md#kruchten-1995)), and the Development
  viewpoint, covering module and codeline organisation and standards for
  design and testing
  ([Rozanski and Woods, 2011](../about/bibliography.md#rozanski-woods-2011)).
- **The Software Guidebook gives the development environment a section
  of its own,** apart from deployment and from operation and support
  ([Brown](../about/bibliography.md#brown-software-guidebook)).

The decision is recorded as
[ADR-002](../delivery/decisions.md#adr-002-keep-development-and-delivery-apart-from-the-production-architecture).

## Citing sources

Any outside source a page relies on is listed in the
[Bibliography](bibliography.md), and the page links to its entry.
