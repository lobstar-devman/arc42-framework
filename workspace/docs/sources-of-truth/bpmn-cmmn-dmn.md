# BPMN / CMMN / DMN

> **Status:** stub — populated per process/case/decision as they are
> architected.

Business processes, case models, and decision logic are authored as
native BPMN 2.0, CMMN 1.1, and DMN XML respectively, edited and rendered
with [bpmn.io](https://bpmn.io) tooling (bpmn-js / cmmn-js / dmn-js).

CI validates each file against its OMG schema (`xmllint`) and exports it
to SVG (`bpmn-to-image`) for embedding in the relevant arc42 page
(Runtime View for BPMN, Cross-cutting Concepts for DMN).

## Index

_No processes, case models, or decisions have been added yet._

| File | Type | Embedded in |
|---|---|---|
| _e.g. `processes/order-fulfillment.bpmn`_ | BPMN | [Runtime View](../arc42/06-runtime-view.md) |
