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
