#!/usr/bin/env bash
# Run this from inside ~/mxd-spec
# chmod +x setup-repo.sh && ./setup-repo.sh

set -e
echo "Writing MXD spec files..."

# ── package.json ─────────────────────────────────────────────────────────────
cat > package.json << 'ENDOFFILE'
{
  "name": "mxd-validate",
  "version": "0.2.0",
  "type": "module",
  "description": "MXD Format specification and CLI validator",
  "bin": { "mxd-validate": "./tools/validate.js" },
  "dependencies": {
    "ajv": "^8.12.0",
    "ajv-formats": "^2.1.1",
    "jsdom": "^24.0.0"
  }
}
ENDOFFILE
echo "  ✓ package.json"

# ── LICENSE ──────────────────────────────────────────────────────────────────
cat > LICENSE << 'ENDOFFILE'
Creative Commons Attribution 4.0 International (CC BY 4.0)

Copyright (c) 2026 MXD Format Contributors

You are free to:

  Share — copy and redistribute the material in any medium or format
  Adapt — remix, transform, and build upon the material for any purpose,
          even commercially

Under the following terms:

  Attribution — You must give appropriate credit to the MXD Format
  Specification (mxd-standard.org), provide a link to the license,
  and indicate if changes were made. You may do so in any reasonable
  manner, but not in any way that suggests the licensor endorses you
  or your use.

Full license text: https://creativecommons.org/licenses/by/4.0/legalcode
ENDOFFILE
echo "  ✓ LICENSE"

# ── .gitignore ────────────────────────────────────────────────────────────────
cat > .gitignore << 'ENDOFFILE'
node_modules/
.DS_Store
*.log
dist/
ENDOFFILE
echo "  ✓ .gitignore"

# ── README.md ────────────────────────────────────────────────────────────────
cat > README.md << 'ENDOFFILE'
# MXD Format Specification

**MXD (Machine-readable eXecutive Document)** is an open file format for business documents that are readable by both humans and machines — from the same file, without plugins, without middleware, and without a vendor.

An `.mxd` file is a single HTML5 document containing four embedded layers:

1. **HTML5 layer** — renders in any browser. No app required.
2. **MXD JSON layer** — structured metadata following the MXD schema.
3. **Regulatory XML layer** — verbatim UBL 2.1, PEPPOL BIS 3.0, Factur-X, or other compliance XML.
4. **Signature block** — SHA-256 tamper detection, optional RFC 3161 timestamp, optional X.509 signing.

> Think of it as what you'd get if ZUGFeRD (PDF + XML) swapped the PDF for HTML5, added a proper open spec, and made the whole thing verifiable without Acrobat.

---

## Why MXD?

| Format | Human readable | Machine readable | Open spec | Regulatory XML | Tamper-evident | No plugin |
|---|---|---|---|---|---|---|
| PDF/A-3 (ZUGFeRD) | ✓ | ✓ | ✗ | ✓ | Partial | ✗ |
| UBL XML | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ |
| Factur-X | ✓ | ✓ | Partial | ✓ | ✗ | ✗ |
| HTML5 (plain) | ✓ | Partial | ✓ | ✗ | ✗ | ✓ |
| **MXD v0.2** | **✓** | **✓** | **✓** | **✓** | **✓** | **✓** |

MXD does not replace regulatory XML — it **contains** it. The embedded XML layer is extractable by any ERP, PEPPOL access point, or tax system. The HTML layer is what humans read. Same file.

---

## Current Status

| Version | Status | Document Types |
|---|---|---|
| v0.2 | ✅ Draft — active | `invoice` |
| v0.3 | 🗓 Planned | `purchase-order`, `quote` |
| v0.4 | 🗓 Planned | `receipt` |
| v0.5 | 🗓 Planned | `contract` |

---

## Repository Structure

```
spec/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── package.json
├── spec/v0.2/
├── schemas/invoice/v0.2.json
├── examples/invoice-minimal.mxd
└── tools/validate.js
```

---

## Quick Start

### Validate an MXD file
```bash
npm install
node tools/validate.js examples/invoice-minimal.mxd
node tools/validate.js --verify examples/invoice-minimal.mxd
```

### Minimal valid MXD structure
```html
<!DOCTYPE html>
<html lang="en" data-mxd-type="invoice" data-mxd-version="0.2">
<head>
  <meta charset="UTF-8" />
  <meta name="mxd-schema" content="https://mxd-standard.org/schemas/invoice/v0.2.json" />
  <title>INV-001 — Sender Name</title>
</head>
<body>
  <!-- Layer 1: Human-readable HTML -->
  <script type="application/mxd+json" id="mxd-data">{ ... }</script>
  <script type="application/mxd+xml"  id="mxd-regulatory"><!-- xml --></script>
  <script type="application/mxd+sig"  id="mxd-signature">{ ... }</script>
</body>
</html>
```

---

## Implementations

| Tool | Type | Link |
|---|---|---|
| **KodaStudio** | Desktop app (reference implementation) | Coming soon |
| **Koda Web** | Web app | Coming soon |

Building an MXD tool? Open a PR to add it here.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the RFC process.

## License

[Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE)
ENDOFFILE
echo "  ✓ README.md"

# ── CHANGELOG.md ─────────────────────────────────────────────────────────────
cat > CHANGELOG.md << 'ENDOFFILE'
# MXD Format Changelog

All notable changes to the MXD specification are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [0.2] — 2026-05-08

### Added
- 4-layer file architecture: HTML5 + MXD JSON + Regulatory XML + Signature Block
- Layer 3: Regulatory XML embedding (UBL-2.1, PEPPOL-BIS-3.0, FACTURX-1.0, CII-D16B, FATTURAPA-1.2, NONE)
- Layer 4: Signature block with SHA-256, optional RFC 3161 TSA, optional X.509
- Audit hash chain: each audit_trail entry links to SHA-256 of previous entry
- Fields: regulatory_standard, regulatory_country, regulatory_profile, generator
- Fields: sender.peppol_id, sender.vat_number, recipient.peppol_id, recipient.vat_number
- Fields: line_items[].tax_category (EN 16931 codes), line_items[].item_ref
- Fields: invoice.po_reference, invoice.project_reference, sender.logo_base64
- MIME type: text/mxd+html (fallback: text/html)
- data-mxd-version="0.2" on html element

### Changed
- $mxd.version updated to "0.2"
- Signature block moved to dedicated Layer 4 script tag

---

## [0.1] — 2026-04-01

### Added
- Initial MXD specification
- Two-layer architecture: HTML5 + MXD JSON
- Invoice document type
- Core invoice fields: sender, recipient, line_items, totals, payment, reminders, audit_trail
- smart_tags array, basic SHA-256 signature
- File extension: .mxd

---

## Upcoming

### [0.3] — Planned
- New document types: purchase-order, quote
- Multi-currency support
- Recurring invoice definition

### [0.4] — Planned
- New document type: receipt
- QR code embedding spec
ENDOFFILE
echo "  ✓ CHANGELOG.md"

# ── CONTRIBUTING.md ───────────────────────────────────────────────────────────
cat > CONTRIBUTING.md << 'ENDOFFILE'
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
ENDOFFILE
echo "  ✓ CONTRIBUTING.md"

# ── schemas/invoice/v0.2.json ─────────────────────────────────────────────────
cat > schemas/invoice/v0.2.json << 'ENDOFFILE'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://mxd-standard.org/schemas/invoice/v0.2.json",
  "title": "MXD Invoice Schema",
  "description": "JSON Schema for Layer 2 of an MXD invoice document. Version 0.2.",
  "type": "object",
  "required": ["$mxd", "invoice", "sender", "recipient", "line_items", "totals"],
  "properties": {
    "$schema": { "type": "string", "format": "uri" },
    "$mxd": {
      "type": "object",
      "required": ["version", "type", "uuid", "created"],
      "properties": {
        "version":              { "type": "string", "const": "0.2" },
        "type":                 { "type": "string", "const": "invoice" },
        "uuid":                 { "type": "string" },
        "created":              { "type": "string", "format": "date-time" },
        "modified":             { "type": ["string", "null"], "format": "date-time" },
        "generator":            { "type": ["string", "null"] },
        "regulatory_standard":  { "type": "string", "enum": ["UBL-2.1","PEPPOL-BIS-3.0","FACTURX-1.0","CII-D16B","FATTURAPA-1.2","NONE"] },
        "regulatory_country":   { "type": ["string", "null"] },
        "regulatory_profile":   { "type": ["string", "null"] },
        "locale":               { "type": ["string", "null"] },
        "currency":             { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "invoice": {
      "type": "object",
      "required": ["number", "status", "issued_date", "due_date"],
      "properties": {
        "number":            { "type": "string" },
        "status":            { "type": "string", "enum": ["draft","unpaid","paid","overdue","cancelled","disputed"] },
        "issued_date":       { "type": "string", "format": "date" },
        "due_date":          { "type": "string", "format": "date" },
        "payment_terms":     { "type": ["string", "null"] },
        "po_reference":      { "type": ["string", "null"] },
        "project_reference": { "type": ["string", "null"] },
        "quote_ref":         { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "sender": {
      "type": "object",
      "required": ["name", "email"],
      "properties": {
        "name":        { "type": "string" },
        "email":       { "type": "string", "format": "email" },
        "phone":       { "type": ["string", "null"] },
        "website":     { "type": ["string", "null"] },
        "address":     { "$ref": "#/$defs/address" },
        "tax_id":      { "type": ["string", "null"] },
        "vat_number":  { "type": ["string", "null"] },
        "peppol_id":   { "type": ["string", "null"] },
        "logo_base64": { "type": ["string", "null"] },
        "logo_url":    { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "recipient": {
      "type": "object",
      "required": ["name", "email"],
      "properties": {
        "name":           { "type": "string" },
        "email":          { "type": "string", "format": "email" },
        "contact_person": { "type": ["string", "null"] },
        "address":        { "$ref": "#/$defs/address" },
        "tax_id":         { "type": ["string", "null"] },
        "vat_number":     { "type": ["string", "null"] },
        "peppol_id":      { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "line_items": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "description", "quantity", "unit_price", "subtotal"],
        "properties": {
          "id":           { "type": "string" },
          "description":  { "type": "string" },
          "category":     { "type": ["string", "null"] },
          "quantity":     { "type": "number", "minimum": 0 },
          "unit":         { "type": ["string", "null"] },
          "unit_price":   { "type": "number", "minimum": 0 },
          "discount_pct": { "type": "number", "minimum": 0, "maximum": 100, "default": 0 },
          "tax_rate":     { "type": "number", "minimum": 0, "maximum": 1 },
          "tax_category": { "type": ["string", "null"], "enum": ["S","Z","E","AE","K","G","O","L","M",null] },
          "subtotal":     { "type": "number", "minimum": 0 },
          "smart_tags":   { "type": "array", "items": { "type": "string" } },
          "item_ref":     { "type": ["string", "null"] }
        },
        "additionalProperties": false
      }
    },
    "totals": {
      "type": "object",
      "required": ["subtotal", "tax_total", "total", "amount_due"],
      "properties": {
        "subtotal":       { "type": "number", "minimum": 0 },
        "discount_total": { "type": "number", "minimum": 0 },
        "tax_total":      { "type": "number", "minimum": 0 },
        "total":          { "type": "number", "minimum": 0 },
        "amount_paid":    { "type": "number", "minimum": 0 },
        "amount_due":     { "type": "number", "minimum": 0 }
      },
      "additionalProperties": false
    },
    "payment": {
      "type": ["object", "null"],
      "properties": {
        "methods": { "type": "array", "items": { "type": "string" } },
        "bank": {
          "type": ["object", "null"],
          "properties": {
            "account_name":   { "type": ["string", "null"] },
            "iban":           { "type": ["string", "null"] },
            "account_number": { "type": ["string", "null"] },
            "routing":        { "type": ["string", "null"] },
            "swift":          { "type": ["string", "null"] }
          },
          "additionalProperties": false
        },
        "stripe_link": { "type": ["string", "null"] },
        "paypal_link": { "type": ["string", "null"] }
      },
      "additionalProperties": false
    },
    "smart_tags":     { "type": "array", "items": { "type": "string" } },
    "reminders": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["trigger", "channel", "sent"],
        "properties": {
          "trigger":  { "type": "string", "enum": ["due_minus_7d","due_minus_3d","due_minus_1d","due_plus_1d","due_plus_7d","due_plus_14d","due_plus_30d"] },
          "channel":  { "type": "string", "enum": ["email","sms","webhook"] },
          "sent":     { "type": "boolean" },
          "sent_at":  { "type": ["string", "null"] }
        },
        "additionalProperties": false
      }
    },
    "audit_trail": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["event", "actor", "timestamp"],
        "properties": {
          "event":     { "type": "string", "enum": ["created","modified","sent","viewed","reminder_sent","status_changed","paid","partially_paid","overdue","disputed","cancelled","peppol_submitted","signature_added"] },
          "actor":     { "type": "string" },
          "timestamp": { "type": "string", "format": "date-time" },
          "detail":    { "type": ["string", "null"] },
          "prev_hash": { "type": ["string", "null"] }
        },
        "additionalProperties": false
      }
    },
    "notes":         { "type": ["string", "null"] },
    "internal_memo": { "type": ["string", "null"] },
    "attachments":   { "type": "array" },
    "custom_fields": { "type": "object" }
  },
  "$defs": {
    "address": {
      "type": ["object", "null"],
      "properties": {
        "street":  { "type": ["string", "null"] },
        "city":    { "type": ["string", "null"] },
        "state":   { "type": ["string", "null"] },
        "zip":     { "type": ["string", "null"] },
        "country": { "type": ["string", "null"] }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
ENDOFFILE
echo "  ✓ schemas/invoice/v0.2.json"

# ── examples/invoice-minimal.mxd ─────────────────────────────────────────────
cat > examples/invoice-minimal.mxd << 'ENDOFFILE'
<!DOCTYPE html>
<html lang="en" data-mxd-type="invoice" data-mxd-version="0.2">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="generator" content="handwritten-example" />
  <meta name="mxd-schema" content="https://mxd-standard.org/schemas/invoice/v0.2.json" />
  <title>INV-2026-0001 — Acme Studio</title>
  <style>
    body{font-family:system-ui,sans-serif;max-width:720px;margin:48px auto;padding:0 24px;color:#1a1a1a}
    .header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:40px}
    .inv-number{font-size:1.6rem;font-weight:600}
    .badge{display:inline-block;padding:3px 10px;border-radius:999px;font-size:.75rem;font-weight:500;background:#fef3c7;color:#92400e}
    table{width:100%;border-collapse:collapse;margin:28px 0}
    th{background:#f5f5f5;padding:9px 12px;text-align:left;font-size:.8rem;font-weight:500;color:#555}
    td{padding:9px 12px;border-bottom:1px solid #eee;font-size:.9rem}
    .totals{text-align:right;margin-top:8px;font-size:.9rem;line-height:2}
    .amount-due{font-size:1.3rem;font-weight:600}
    .mxd-footer{margin-top:60px;padding-top:16px;border-top:1px solid #eee;font-size:.7rem;color:#aaa;text-align:center}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <div style="font-weight:600;font-size:1.1rem">Acme Studio</div>
      <div style="color:#666;font-size:.85rem">billing@acmestudio.io</div>
    </div>
    <div style="text-align:right">
      <div class="inv-number">INV-2026-0001</div>
      <span class="badge">UNPAID</span>
      <div style="font-size:.8rem;color:#666;margin-top:4px">Issued: 8 May 2026 &nbsp;·&nbsp; Due: 22 May 2026</div>
    </div>
  </div>
  <table>
    <thead>
      <tr>
        <th>Description</th>
        <th style="text-align:right">Qty</th>
        <th style="text-align:right">Unit price</th>
        <th style="text-align:right">Subtotal</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Brand Identity Design</td>
        <td style="text-align:right">1</td>
        <td style="text-align:right">$3,500.00</td>
        <td style="text-align:right">$3,500.00</td>
      </tr>
    </tbody>
  </table>
  <div class="totals">
    <div>Subtotal: $3,500.00</div>
    <div>Tax: $0.00</div>
    <div class="amount-due">Total Due: $3,500.00</div>
  </div>
  <div class="mxd-footer">MXD Format v0.2 &nbsp;·&nbsp; <a href="https://mxd-standard.org" style="color:#aaa">mxd-standard.org</a></div>

  <script type="application/mxd+json" id="mxd-data">
{
  "$schema": "https://mxd-standard.org/schemas/invoice/v0.2.json",
  "$mxd": {
    "version": "0.2",
    "type": "invoice",
    "uuid": "inv_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "created": "2026-05-08T10:00:00Z",
    "modified": "2026-05-08T10:00:00Z",
    "generator": "handwritten-example",
    "regulatory_standard": "NONE",
    "regulatory_country": null,
    "regulatory_profile": null,
    "locale": "en-US",
    "currency": "USD"
  },
  "invoice": {
    "number": "INV-2026-0001",
    "status": "unpaid",
    "issued_date": "2026-05-08",
    "due_date": "2026-05-22",
    "payment_terms": "NET_14",
    "po_reference": null,
    "project_reference": null
  },
  "sender": {
    "name": "Acme Studio",
    "email": "billing@acmestudio.io",
    "phone": null,
    "website": null,
    "address": { "street": "12 Maple Ave", "city": "Austin", "state": "TX", "zip": "78701", "country": "US" },
    "tax_id": null,
    "vat_number": null,
    "peppol_id": null,
    "logo_base64": null,
    "logo_url": null
  },
  "recipient": {
    "name": "Globex Corp",
    "email": "ap@globex.com",
    "contact_person": "Homer Simpson",
    "address": null,
    "tax_id": null,
    "vat_number": null,
    "peppol_id": null
  },
  "line_items": [
    {
      "id": "li_001",
      "description": "Brand Identity Design",
      "category": "design",
      "quantity": 1,
      "unit": "project",
      "unit_price": 3500.00,
      "discount_pct": 0,
      "tax_rate": 0,
      "tax_category": "Z",
      "subtotal": 3500.00,
      "smart_tags": [],
      "item_ref": null
    }
  ],
  "totals": {
    "subtotal": 3500.00,
    "discount_total": 0,
    "tax_total": 0,
    "total": 3500.00,
    "amount_paid": 0,
    "amount_due": 3500.00
  },
  "payment": {
    "methods": ["bank_transfer"],
    "bank": { "account_name": "Acme Studio", "iban": null, "account_number": "XXXX-1234", "routing": "XXXXXX123", "swift": null },
    "stripe_link": null,
    "paypal_link": null
  },
  "smart_tags": [],
  "reminders": [],
  "audit_trail": [
    { "event": "created", "actor": "user_example", "timestamp": "2026-05-08T10:00:00Z", "detail": null, "prev_hash": null }
  ],
  "notes": "Payment due within 14 days.",
  "internal_memo": null,
  "attachments": [],
  "custom_fields": {}
}
  </script>

  <script type="application/mxd+xml" id="mxd-regulatory">
  <!-- REGULATORY_STANDARD: NONE -->
  </script>

  <script type="application/mxd+sig" id="mxd-signature">
{
  "mxd_sig_version": "0.2",
  "algorithm": "SHA-256",
  "signed_layers": ["mxd-data", "mxd-regulatory"],
  "json_layer_hash": "REPLACE_WITH_SHA256_OF_MXD_DATA_CONTENT",
  "xml_layer_hash": "REPLACE_WITH_SHA256_OF_MXD_REGULATORY_CONTENT",
  "combined_hash": "REPLACE_WITH_SHA256_OF_CONCATENATED_HASHES",
  "timestamp": { "method": "local", "value": "2026-05-08T10:00:00Z", "tsa_token": null },
  "sender_signature": { "method": null, "certificate": null, "value": null },
  "verified": false,
  "verification_url": "https://mxd-standard.org/verify"
}
  </script>
</body>
</html>
ENDOFFILE
echo "  ✓ examples/invoice-minimal.mxd"

# ── tools/validate.js ─────────────────────────────────────────────────────────
cat > tools/validate.js << 'ENDOFFILE'
#!/usr/bin/env node
import { readFileSync } from "fs";
import { createHash } from "crypto";
import { JSDOM } from "jsdom";
import Ajv from "ajv";
import addFormats from "ajv-formats";

const args = process.argv.slice(2);
const flags = { verify: false, json: false };
const files = [];
for (const a of args) {
  if (a === "--verify") flags.verify = true;
  else if (a === "--json") flags.json = true;
  else files.push(a);
}
if (files.length === 0) {
  console.error("Usage: mxd-validate [--verify] [--json] <file.mxd>");
  process.exit(1);
}

const sha256 = (s) => createHash("sha256").update(s, "utf8").digest("hex");
const pass = (m) => `  \x1b[32m✓\x1b[0m  ${m}`;
const fail = (m) => `  \x1b[31m✗\x1b[0m  ${m}`;
const warn = (m) => `  \x1b[33m⚠\x1b[0m  ${m}`;

const SCHEMA = {
  $schema: "https://json-schema.org/draft/2020-12/schema",
  type: "object",
  required: ["$mxd","invoice","sender","recipient","line_items","totals"],
  properties: {
    $mxd: {
      type: "object", required: ["version","type","uuid","created"],
      properties: {
        version: { type: "string", const: "0.2" },
        type: { type: "string", const: "invoice" },
        uuid: { type: "string" },
        created: { type: "string", format: "date-time" },
        regulatory_standard: { type: "string", enum: ["UBL-2.1","PEPPOL-BIS-3.0","FACTURX-1.0","CII-D16B","FATTURAPA-1.2","NONE"] }
      }
    },
    invoice: {
      type: "object", required: ["number","status","issued_date","due_date"],
      properties: {
        number: { type: "string" },
        status: { type: "string", enum: ["draft","unpaid","paid","overdue","cancelled","disputed"] },
        issued_date: { type: "string", format: "date" },
        due_date: { type: "string", format: "date" }
      }
    },
    sender: { type: "object", required: ["name","email"], properties: { name: { type: "string" }, email: { type: "string", format: "email" } } },
    recipient: { type: "object", required: ["name","email"], properties: { name: { type: "string" }, email: { type: "string", format: "email" } } },
    line_items: { type: "array", minItems: 1, items: { type: "object", required: ["id","description","quantity","unit_price","subtotal"] } },
    totals: { type: "object", required: ["subtotal","tax_total","total","amount_due"] }
  }
};

async function validate(filePath) {
  const report = { file: filePath, valid: false, checks: [], errors: [], warnings: [] };

  let raw;
  try { raw = readFileSync(filePath, "utf8"); }
  catch (e) { report.errors.push(`Cannot read file: ${e.message}`); return report; }

  const dom = new JSDOM(raw);
  const doc = dom.window.document;
  const html = doc.documentElement;
  const mxdType = html.getAttribute("data-mxd-type");
  const mxdVer  = html.getAttribute("data-mxd-version");

  if (mxdType && mxdVer) {
    report.checks.push(pass(`HTML: data-mxd-type="${mxdType}" data-mxd-version="${mxdVer}"`));
  } else {
    report.checks.push(fail("HTML: missing data-mxd-type or data-mxd-version"));
    report.errors.push("Missing MXD HTML attributes");
  }

  const jsonEl = doc.getElementById("mxd-data");
  if (!jsonEl) { report.errors.push("Layer 2 not found"); return report; }
  report.checks.push(pass("Layer 2: <script id='mxd-data'> found"));

  let jsonData;
  try {
    jsonData = JSON.parse(jsonEl.textContent.trim());
    report.checks.push(pass("Layer 2: valid JSON"));
  } catch (e) {
    report.checks.push(fail(`Layer 2: invalid JSON — ${e.message}`));
    report.errors.push("JSON parse error"); return report;
  }

  const ajv = new Ajv({ allErrors: true });
  addFormats(ajv);
  const ok = ajv.compile(SCHEMA)(jsonData);
  if (ok) {
    report.checks.push(pass("Layer 2: passes MXD invoice schema v0.2"));
  } else {
    const errs = ajv.compile(SCHEMA).errors?.map(e => `${e.instancePath} ${e.message}`).join("; ") || "unknown";
    report.checks.push(fail(`Layer 2: schema errors — ${errs}`));
    report.errors.push(errs);
  }

  let mathOk = true;
  for (const li of (jsonData.line_items || [])) {
    const exp = li.quantity * li.unit_price * (1 - (li.discount_pct || 0) / 100);
    if (Math.abs(exp - li.subtotal) > 0.01) {
      report.checks.push(fail(`Line ${li.id}: subtotal mismatch (expected ${exp.toFixed(2)}, got ${li.subtotal})`));
      report.errors.push(`Line ${li.id} subtotal mismatch`); mathOk = false;
    }
  }
  if (mathOk) report.checks.push(pass("Line items: subtotals correct"));

  const t = jsonData.totals || {};
  const expTotal = (t.subtotal||0) - (t.discount_total||0) + (t.tax_total||0);
  if (Math.abs(expTotal - (t.total||0)) > 0.01) {
    report.checks.push(fail(`Totals: total mismatch (expected ${expTotal.toFixed(2)})`));
    report.errors.push("Total mismatch");
  } else report.checks.push(pass("Totals: math correct"));

  const xmlEl = doc.getElementById("mxd-regulatory");
  if (!xmlEl) {
    report.checks.push(warn("Layer 3: not found (regulatory XML recommended)"));
    report.warnings.push("No regulatory XML layer");
  } else {
    const std = jsonData?.$mxd?.regulatory_standard || "NONE";
    report.checks.push(pass(`Layer 3: found. Standard: ${std}`));
  }

  const sigEl = doc.getElementById("mxd-signature");
  if (!sigEl) {
    report.checks.push(warn("Layer 4: not found (signature recommended)"));
    report.warnings.push("No signature block");
  } else {
    try {
      const sd = JSON.parse(sigEl.textContent.trim());
      report.checks.push(pass("Layer 4: signature block found"));
      if (flags.verify) {
        const jRaw = doc.getElementById("mxd-data")?.textContent?.trim() || "";
        const xRaw = doc.getElementById("mxd-regulatory")?.textContent?.trim() || "";
        if (sd.json_layer_hash?.startsWith("REPLACE")) {
          report.checks.push(warn("Signature: placeholder hashes — file not yet signed"));
          report.warnings.push("File unsigned");
        } else {
          const jh = sha256(jRaw), xh = sha256(xRaw), ch = sha256(jh + xh);
          report.checks.push(sd.json_layer_hash === jh ? pass("Signature: JSON hash matches ✓") : fail("Signature: JSON hash MISMATCH — possible tampering"));
          report.checks.push(sd.xml_layer_hash  === xh ? pass("Signature: XML hash matches ✓")  : fail("Signature: XML hash MISMATCH"));
          report.checks.push(sd.combined_hash   === ch ? pass("Signature: combined hash matches ✓") : fail("Signature: combined hash MISMATCH"));
          if (sd.json_layer_hash !== jh || sd.xml_layer_hash !== xh) report.errors.push("Hash mismatch — file may be tampered");
        }
      }
    } catch { report.checks.push(fail("Layer 4: invalid JSON")); report.errors.push("Signature JSON error"); }
  }

  const trail = jsonData.audit_trail || [];
  if (trail.length === 0) {
    report.checks.push(warn("Audit trail: empty"));
  } else if (trail[0].prev_hash !== null) {
    report.checks.push(fail("Audit trail: first entry prev_hash must be null"));
    report.errors.push("Audit trail chain error");
  } else {
    report.checks.push(pass(`Audit trail: ${trail.length} entries, chain origin valid`));
  }

  report.valid = report.errors.length === 0;
  return report;
}

for (const f of files) {
  const r = await validate(f);
  if (flags.json) { console.log(JSON.stringify(r, null, 2)); continue; }
  const status = r.valid ? "\x1b[32m✓ VALID\x1b[0m" : "\x1b[31m✗ INVALID\x1b[0m";
  console.log(`\nMXD Validator v0.2 — mxd-standard.org`);
  console.log(`──────────────────────────────────────`);
  console.log(`File:   ${r.file}`);
  console.log(`Status: ${status}\n`);
  r.checks.forEach(c => console.log(c));
  if (r.warnings.length) { console.log(`\nWarnings:`); r.warnings.forEach(w => console.log(`  ⚠  ${w}`)); }
  if (r.errors.length)   { console.log(`\nErrors:`);   r.errors.forEach(e => console.log(`  ✗  ${e}`)); }
  console.log(`\nVerify: https://mxd-standard.org/verify\n`);
  if (!r.valid) process.exitCode = 1;
}
ENDOFFILE
echo "  ✓ tools/validate.js"

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "All files written. Now run:"
echo ""
echo "  git add --all"
echo "  git status"
echo "  git commit -m 'chore: initial MXD v0.2 specification'"
echo "  git branch -M main"
echo "  git push -u origin main"
