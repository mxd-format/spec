# Contributing to the MXD Specification

## Types of Contributions

- **Spec bugs** — ambiguous language, contradictions. Open issue: `spec-bug`
- **Clarifications** — unclear but not wrong. Open issue: `clarification`
- **New fields** — optional additions to existing types. RFC process: `rfc-minor`
- **New document types** — new $mxd.type values. RFC process: `rfc-major`
- **Regulatory XML standards** — new named standards for Layer 3: `rfc-regulatory`
- **Tooling** — validators, SDKs, plugins. PR to add to README implementations table.

## The RFC Process

1. **Open a Discussion** in the RFC Proposals category. Describe what, why, and a rough sketch.
2. **Write the RFC** — create `rfcs/rfc-NNNN-short-title.md` using the template below.
3. **Review period** — 14 days minimum (30 days for major RFCs).
4. **Decision** — maintainers mark as `accepted`, `deferred`, or `rejected`.
5. **Implementation** — accepted RFCs are merged and appear in CHANGELOG.md.

## RFC Template

```markdown
# RFC-NNNN: Short Title

**Status:** Draft
**Type:** minor | major | regulatory
**Author:** Your Name (@handle)
**Created:** YYYY-MM-DD

## Summary
## Motivation
## Proposed Spec Change
## Backwards Compatibility
## Alternatives Considered
## Open Questions
```

## Reserved Field Names

These top-level JSON keys are reserved and cannot be used in custom_fields:
$mxd, $schema, invoice, sender, recipient, line_items, totals, payment,
smart_tags, reminders, audit_trail, notes, internal_memo, attachments, custom_fields

Extensions must use: `x-[vendor]-[field]`

## Versioning Rules

- Patch (0.2.x): clarifications only, no schema changes
- Minor (0.x.0): new optional fields, new document types, backwards compatible
- Major (x.0.0): breaking changes, required field additions, field removal

## Maintainers

Maintained by [Koda](https://usekoda.com), creator of the MXD format and reference implementation.
