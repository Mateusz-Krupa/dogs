# Reflection — expand-loose-lead-guidance

Reflected 2026-10-31, before archive. Sources: proposal, design, both delta specs,
tasks, puppy-scope-addendum, review, content-review and notes in this change,
the scoped changed-file inventory, and the orchestrator's recorded verification.
This reflection did not rerun tests, release commands or simulator inspection.
Durable memory is proposed only; approval and CLI archive remain the orchestrator's work.

## Intent versus final outcome; plan versus reality

- **Local:** The original two-resource loose-lead edit became three content resources
  after the user added floor-scavenging advice for puppies at home and outdoors.
  The addendum initially outpaced the main proposal/design/tasks/spec. R-1 reconciled
  ownership, acceptance criteria, checksums and tests before implementation, adding
  a puppy-scavenging delta capability rather than altering the four-foundation contract.
- **Project:** Existing description/setup/note fields, five troubleshooting disclosures
  and puppy guide sections were sufficient. Final app scope was three JSON resources,
  three checksum entries, and focused ContentLoaderTests/PuppyContentTests changes:
  six files, with no new schema, screen, dependency, translation key or migration.
  The broader working-tree diff is not this change's implementation diff.
- **Project:** `leave` before pickup and `drop` after pickup remain canonical scored
  exercises linked from the existing foundation; duplicating their steps would create
  a second training authority. Four foundations and stable IDs remain intact.
  Reading stays unscored; normal first-open exercise lazy initialization is not
  equivalent to a promise that following every link performs zero database writes.
- **Project:** Four loose-lead criteria/ordinals remain unchanged. No Domain/Data/session
  changes were introduced: five reps, 5/5 push, 3–4 stick, 0–2 drop, cancelled-rep
  failure, incomplete-set distinction, derived verdicts, per-dog/exercise/environment
  progress and raw offline history were preserved by the scoped content-only approach.

## Problems, wrong turns, and corrections that actually worked

1. **Procedural — blocked reviewer invocation:** Initial calls failed with
   `Subagent session not found`; the planner recorded the blocker instead of claiming
   review or implementing around it. A later independent review ran successfully;
   the user selected R-1–R-4 before their fixes were applied.
2. **Procedural — scope and evidence lag (R-1/R-2):** The new puppy request needed
   integrated acceptance cases, verified veterinary sources and exact bilingual field
   mapping, not just an addendum. Reconciling artifacts and the editorial ledger made
   escalation-before-practice and ownership explicit.
3. **Project — overconfident advice:** Retractable-lead advice was qualified: an unlocked
   reel maintains tension, while a locked lead can have slack. Normal sniffing is not
   disobedience, and fear/pain are not solved by insisting on a stationary dog. Two
   unsupported puppy drafts were removed/softened in both languages: home vomiting
   advice and the causal claim that fear of surrendering items makes a dog swallow
   on the run. Unsupported mechanisms were not shipped merely because plausible.
4. **Project — citation capacity:** The puppy validator caps evidence at five sources.
   The RSPCA chewing page was load-bearing for shipped punishment/health claims;
   the Dogs Trust stealing page had been read but was redundant for final claims.
   Keeping the former, recording the latter as read-but-dropped, and retaining the
   field-to-source mapping met the cap without pretending an uncited claim was supported.
5. **Procedural — stale tests and weak expectations (R-3/F-3):** Existing puppy tests
   pinned all dates and exactly three links. Expectations were narrowed to the changed
   guide. A changed assertion still executed against a stale incremental test binary,
   producing a false failure diagnosis; `xcodebuild clean` followed by the targeted run
   corrected it. A green or red rerun under that suspected stale state was not evidence
   of the current assertions. Tests now report the runtime list. Final review also
   replaced keyword proxies (`locked` matching `unlocked`, cue names without order,
   combined locale non-emptiness) with full safety clauses and independent PL/EN checks.
6. **Project — final welfare omissions (F-1/F-2/O-1):** The urgent branch had only
   escalating guarding, not an explicit stop/no-self-test/no-punishment referral for
   guarding signs. The trade instruction omitted returning a safe practice toy but
   never a dangerous find. Selected fixes added both in PL/EN and aligned EN's force
   ban with PL. Full-clause tests and the clean 58-test run verified the corrections.
7. **Procedural — checksum integrity:** Only three resource hashes were changed;
   an intermediate ledger after-hash had not actually been computed and was replaced
   by the real digest. Recomputing bytes, recording final hashes and rescanning all
   56 ledger entries—not trusting an edited line—produced zero drift without touching
   frozen migration baselines or rebaselining unrelated work.
8. **Project — wrong syntax tool:** `plutil -lint` rejected these bundled JSON resources
   even when untouched. A JSON parser was the working syntax check; loader/validator
   tests remained necessary for domain content validity.
9. **Local — garbled edit arguments:** Several absolute paths and one `oldString`
   acquired duplicated fragments. Re-reading real files and checking for stray text
   after successful-looking edits caught the issue; no malformed paths/text remained.
   Preserve this incident locally rather than adding another generic path rule.
10. **Procedural — genuine UI inspection without scoring:** A temporary XCUITest
    screenshot harness reached actual phone-sized PL/EN states, opened disclosures
    and produced 18 attachments without tapping Got it/Missed. It was deleted with
    no harness residue. This checks rendering, not database preservation; merely
    leaving the rep counter at zero does not prove write-free exercise navigation.
11. **Procedural — release scope (R-4):** The dirty workspace included unrelated native
    changes, untracked puppy dependencies and retired-runtime deletions. A six-file-only
    release was not viable. The inventory was presented and the user explicitly
    approved a whole-tree TestFlight build before archive/export/validation/upload.
    Release success therefore does not mean only this proposal's content shipped.

## Memory impact

- **Memory impact — DEC-001:** Helped: required current-working-tree before/after
  digests, registered-key equality, narrow checksum edits and a full-ledger rescan;
  prevented refreshing unrelated or frozen baselines.
- **Memory impact — CONV-001:** Helped: PL/EN welfare corrections needed matching
  field-level dispositions; final urgent/trade/force-ban fixes demonstrate its value.
- **Memory impact — CONV-002:** Helped as a boundary: reading guidance is write-free,
  canonical exercise links retain ordinary lazy initialization. No navigation rewrite.
- **Memory impact — PIT-001:** Helped with nested PL/EN field awareness; no batch
  walker was introduced, so its exact failure mode did not recur.
- **Memory impact — PIT-002:** Background/no actionable impact: date validation was
  reused, not changed; the guide's real re-verification date changed, not calendar logic.
- **Memory impact — PIT-003:** Helped for label-aware UI inspection and cold-start
  headroom; the temporary harness extends the inspection procedure, not scoring tests.
- **Memory impact — stale `opencode-implement` skill:** Noise and routing **CONFLICT**:
  its broad instruction to load/delegate on implementation is not applicable to an
  OpenCode implementer. Current AGENTS/workflow govern; only a Claude orchestrator
  may use that bridge. Do not recursively delegate or promote its unrelated project facts.

## Verification evidence and limits

Evidence below is recorded in notes/review/content-review and supplied by the
orchestrator, not independently re-executed by this reflection pass.

- **Unit tests:** After `xcodebuild clean`, ContentLoaderTests 10,
  ContentValidatorTests 16, PuppyContentTests 14, PuppyGuideValidatorTests 18:
  **58 passed, zero failures**, including re-verification after selected final fixes.
  This was targeted testing, not the entire unit/UI suite.
- **Simulator:** Temporary UI-test harness, two passes and 18 phone-sized attachments,
  PL/EN inspection of setup, About, troubleshooting and puppy safety/evidence/link
  states; no observed truncation; unchanged criteria and counter at 0/5; scoring
  buttons never tapped. Harness deleted afterwards. The final five-field welfare
  revision was verified by field diff and clean unit rerun; a second screenshot pass
  over that revision is not recorded.
- **Reviews:** Two independent `gpt-6.1-sol` passes: plan R-1–R-4 and final F-1–F-3
  plus O-1. All were user-selected and implemented. No additional independent review
  after those final fixes is claimed.
- **Content/OpenSpec:** `openspec validate expand-loose-lead-guidance --strict`
  passed; full checksum rescan **56 entries, zero drift**. JSON syntax checked with
  a parser. No claim that `plutil -lint` passed.
- **Release:** Approved whole-tree version **1.0.0 (1)**: archive, export, validation
  and TestFlight upload all succeeded. Delivery UUID:
  `4363ad62-fd23-4c6b-96e6-2b8fc0e6c2ad`. Upload is not Apple processing or tester access.
- **Not verified:** Apple processing completion, test-group/tester availability,
  physical-device lifecycle and in-place update preservation. Device/offline/history
  assurances remain owner-attested only, not an observed phone installation/update.
  Offline support was assessed structurally by absence of URLSession/Network/Safari
  services and bundled citations, **not by disconnecting the simulator**. The task's
  word “offline” must not be read as evidence of a disconnected-device test.

## Durable-memory proposal (not applied)

Candidate searches used `qdrant-code.search_memory`, `repo: "pettrainer"`, limit 3
per candidate; current category files were checked to resolve IDs and duplicates.
Search results were mostly the existing PIT/CONV/DEC entries and the stale bridge;
no matching JSON-tool, stale-binary or citation-cap entry exists locally.

- **ADD PIT-004 (project):** Validate bundled JSON syntax with a JSON parser,
  not `plutil -lint`; keep loader/schema checks separate. No close duplicate.
- **ADD PIT-005 (procedural):** When current assertions and incremental test output
  disagree, clean and rerun targeted tests before diagnosing content. This is a
  recovery procedure for observed staleness, not a requirement to clean every build
  or a claim that every incremental result is invalid. No close duplicate.
- **MERGE into PIT-003 (procedural):** Add the bounded temporary screenshot-harness
  procedure to existing UI inspection guidance rather than a separate overlapping
  entry. Retain its existing lookup/cold-start advice; do not infer DB preservation.
- **ADD CONV-003 (project):** Five-source puppy evidence cap, load-bearing citation
  selection, dropped-but-read ledger and omission of unsupported claims. DEC-001
  covers byte provenance, not claim provenance, so it is not the right merge target.
- **IGNORE garbled paths/oldString (local):** Keep the incident above; path hygiene
  is already mandated by AGENTS and a transient tool anomaly is not a new product fact.
- **IGNORE new scope/release/checksum/locale memory:** Existing workflow, DEC-001,
  CONV-001 and CONV-002 already encode the reusable rules; do not pad memory with
  this release's inventory, build number or delivery identifier.
- **CONFLICT / IGNORE stale bridge promotion:** Do not edit agent/skill configuration
  in reflection. Flag the retrieval conflict for the orchestrator; current routing
  resolves it without inventing a durable entry copied from another project.

Memory approval is pending; no category/index updates or archive operation were
performed by this reflection pass. Proposed category/index diff is returned to the
orchestrator for the user approval gate.
