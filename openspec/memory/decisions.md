# Decisions

<!--
Entry format (each ## section is one retrievable memory):

## DEC-001: Short imperative title
**When relevant:** comma, separated, retrieval, keywords
**Learning:** The durable fact a future agent should know before working here.
**Why:** Why it is true / what went wrong when it was ignored.
**Evidence:**
- openspec/changes/archive/YYYY-MM-DD-<change>
**Last verified:** YYYY-MM-DD

Populated by /opsx-archive reflection. Do not hand-edit for one-off details.
-->

## DEC-001: ContentChecksums is the shipped-byte ledger, guarded by registered-key equality
**When relevant:** adding any content family or resource, updating hashes after approved copy
**Learning:** New families must be added to the explicit enumeration in `ContentLoaderTests` AND
`ContentChecksums`; the suite asserts registered-source keys == checksummed keys, so a family can
never be bundled without digests. Copy changes record before/after digests in the change's
`content-review.md`; frozen migration/parity snapshots are never regenerated.
**Why:** Enumeration was previously per-family manual; the key-equality assert closes the silent-skip
hole found while reviewing add-puppy-start-section (finding P-2).
**Evidence:**
- openspec/changes/archive/2026-10-24-add-puppy-start-section/content-review.md (hash ledger)
- PettrainerTests/ContentLoaderTests.swift (`testBundledBytesMatchBaselineChecksums`)
**Last verified:** 2026-10-24
