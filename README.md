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
