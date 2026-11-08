# Development and Delivery

> **Status:** stub — hand-authored. Fill it in as the delivery approach is
> decided.

This section describes how the system is built, checked and run outside
production: the development method, the non-production environments, the
risks in how the system is delivered, and the decisions behind them. The
production architecture, in
[Architecture (arc42)](../arc42/01-introduction-and-goals.md), doesn't
depend on any of it: the same system could have been built another way.
[How This Documentation Is Organised](../about/structure.md) explains the
split.

## Which log a decision goes in

A decision goes in the [production log](../decisions/index.md) if it
changes what the system is or does: its structure, behaviour, data,
interfaces or qualities in production. It goes in the
[Development and Delivery log](decisions.md) if it changes only how the
system is built, checked or run outside production. If it's unclear, it
goes in the production log. Both logs share one number sequence.

## Constraints
_Constraints on how the system is built and delivered, for example
mandated tooling, review rules, or who may change what. Free text,
hand-authored, cross-linked to ADRs in [Decisions](decisions.md)._

## Strategy
_Each delivery approach, mapped to the quality goal it serves and the
decision that records it. Free text and table, hand-authored._

| Approach | Quality goal served | Decision |
|---|---|---|
| _approach_ | _quality goal_ | _[ADR-NNN](decisions.md)_ |

## Pages

- [Development Method](method.md): the rules that people and agents
  follow when they build the system, and the checks that enforce them.
- [Environments](environments.md): the development and staging
  environments.
- [Delivery Quality Requirements](quality.md): the scenarios that test how
  code changes are checked before they merge.
- [Delivery Risks and Technical Debt](risks.md): what could go wrong in
  how the system is built and checked.
- [Delivery Glossary](glossary.md): the terms used in this section.
- [Development and Delivery Decisions](decisions.md): the decision log for
  this section.
