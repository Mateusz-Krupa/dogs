# Project Memory Index

Human-readable table of contents for project memory. This file is **not** indexed
for retrieval (agents query `search_memory` instead) — keep it as a reviewable map.

## Architecture (`architecture.md`)
## Conventions (`conventions.md`)
- CONV-002: Educational surfaces are write-free; exercise links keep lazy-initialization semantics
- CONV-003: Fit puppy evidence to five load-bearing sources, not five arbitrary links
- CONV-004: Welfare copy attributes symptoms to causes tentatively in BOTH locales
## Pitfalls (`pitfalls.md`)
- PIT-002: Bundle-content date checks must ignore the device calendar style
- PIT-003: XCUITest element lookups match identifiers, not labels; cold launch needs ~30 s
- PIT-004: Validate bundled JSON syntax with a JSON parser, not plutil lint
- PIT-005: Clean suspected stale test binaries before diagnosing current assertions
- PIT-006: Fixed `.system(size:)` typography never scales; "large text" checks need AccessibilityL
## Decisions (`decisions.md`)
- DEC-001: ContentChecksums is the shipped-byte ledger, guarded by registered-key equality
## Workflows (`workflows.md`)
