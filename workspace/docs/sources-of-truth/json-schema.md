# JSON Schema

> **Status:** stub — populated only where no standard format fits.

Used only for bespoke data that doesn't map to BPMN/CMMN/DMN, OpenAPI, or
Structurizr DSL. Every JSON source of truth must have a matching JSON
Schema file, and CI validates the data against it with `ajv-cli` before
any documentation is generated from it.

## Index

_No bespoke JSON sources of truth have been added yet._

| Data file | Schema file | Validated by CI |
|---|---|---|
| _e.g. `data/pricing-tiers.json`_ | _e.g. `data/pricing-tiers.schema.json`_ | ✅ |
