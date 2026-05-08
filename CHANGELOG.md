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
