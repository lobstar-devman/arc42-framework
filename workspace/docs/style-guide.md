# Documentation Style Guide

This guide sets the writing conventions for every hand-authored prose page
in this documentation:

- [Home](index.md)
- the [Sources of Truth](sources-of-truth/index.md) pages
- entries in the ADR (Architecture Decision Record) log
- free-text sections inside arc42 pages, for example the
  cross-cutting-concerns text in
  [Cross-cutting Concepts](arc42/08-crosscutting-concepts.md)

Without a shared style, pages written by different authors — human or
agent — drift apart in tone, terms, and structure. That drift makes the
site harder to trust and slower to read.

The rules below are adapted from MDN's
[technical writing guidance](https://developer.mozilla.org/en-US/blog/technical-writing/).
This page follows them itself, so treat it as a worked example as well as
a rulebook.

**Out of scope:** this guide doesn't cover generated content, since each
of the following follows its own source-of-truth format instead:

- BPMN/CMMN/DMN labels
- OpenAPI descriptions rendered by Redoc
- Structurizr DSL element names
- Mermaid node text

Authors should still write these clearly, but this guide governs prose
pages, not diagram labels.

## Write for clarity

Use simple words, and write for readers who may not be software architects
or programmers. Prefer active voice whenever the reader needs to
know who or what performs an action — for example, write "the CLI validates
the schema," not "the schema is validated." Introduce a new term before you
use it in a later section, so readers never meet an undefined word.

Watch your pronouns. Replace "it," "this," and "these" with the actual
noun whenever more than one thing on the page could be the antecedent.
Keep to one idea per sentence. Keep to one main idea per paragraph too.
Make each sentence follow logically from the one before it.

## Write concisely

Keep sentences short: aim for 15–20 words. Cut redundancy (restating an
idea without adding to it) and repetitiveness (reusing the same word or
phrase when a pronoun or synonym would do). For example, "the CLI tool,
which is a command-line interface, validates the schema" restates
"command-line" and adds nothing; "the CLI validates the schema" says the
same thing in fewer words. A shorter sentence is easier to scan and
easier to translate.

## Stay consistent

Pick one term per concept and use it everywhere. In this project, that
means always writing "source of truth," never swapping in "source file"
or "SOT." Keep casing consistent too — "Structurizr DSL," not
"structurizr dsl" — and reuse the same heading and table structure across
sibling pages, the way every page under `sources-of-truth/` already does.

## Structure each page

Open with an introduction that states what the page covers and why the
reader should care, ideally with a concrete scenario. Then order the rest
of the content **what → why → how**: describe the thing, explain the
motivation, then walk through the mechanics. The [Home](index.md) page
follows exactly this shape: it states what the site is, explains why
nothing on it is hand-edited, then tells the reader how to change
something — edit the source of truth.

Give every heading a real job. Don't leave a lone subsection under a
heading with no siblings — fold it back into the surrounding prose
instead. If a section grows long, split it into two clearly-named
sections rather than stacking a fourth level of headings underneath it.

## Show, don't just tell

Back every non-trivial concept with at least one concrete example, drawn
from this project's own domain rather than a generic placeholder. The
`sources-of-truth/index.md` table is one such example: it doesn't just
describe the convention, it shows the exact path for every format.

## Format lists, links, and images

Lead every list with a sentence that tells the reader what they're about
to see — a list without a lead sentence forces the reader to guess the
list's purpose. Use bullets for items with no required order, and numbers
when the reader must follow steps in sequence. Convert a comma-delimited
run of examples into a list once it reaches four items, or once one item
needs its own explanation. A shorter run stays inline, introduced by
"for example." Add a comma after an introductory clause (as in this
sentence) to mark where the main clause begins.

Write link text that makes sense out of context — "see the
[ADR log](decisions/index.md)," not "see [here]." A screen reader user
often jumps from link to link without reading the surrounding sentence.
The link text alone has to carry the destination. Give every embedded
diagram descriptive alt text, since a generated SVG carries none on its
own.

## Use inclusive language

Choose words that don't assume a reader's background, ability, or first
language. Favor plain phrasing over idioms and culture-specific
references — write "let's get started," not "let's hit the ground
running," since idioms rarely translate word for word. A large share of
this site's readers — and its implementation agents — read a second
language, or no natural language at all.

## Proofread before publishing

Follow the same sequence every time you publish a hand-authored page:

1. Draft the page.
2. Step away from it.
3. Reread it with fresh eyes.
4. Publish it.

On the reread, check for inconsistent tone, tense, and formatting. Also
watch for near-miss word swaps — "he" for "the," for instance — that a
spell-checker won't catch.

## Applying this guide

New hand-authored pages should follow every section above. When you
touch an existing hand-authored page for another reason, bring the parts
you edit into line with this guide. Don't leave the drift in place. The
decision to adopt this guide is recorded as
[ADR-001](decisions/index.md) in the ADR log.
