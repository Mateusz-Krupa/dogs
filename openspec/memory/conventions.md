# Conventions

<!--
Entry format (each ## section is one retrievable memory):

## CONV-001: Short imperative title
**When relevant:** comma, separated, retrieval, keywords
**Learning:** The durable fact a future agent should know before working here.
**Why:** Why it is true / what went wrong when it was ignored.
**Evidence:**
- openspec/changes/archive/YYYY-MM-DD-<change>
**Last verified:** YYYY-MM-DD

Populated by /opsx-archive reflection. Do not hand-edit for one-off details.
-->

## CONV-001: Welfare and criteria copy changes require explicit EN field alignment
**When relevant:** correcting PL advice, welfare boundaries, success criteria, stop-referral language
**Learning:** For every PL welfare/criteria correction, always diff the corresponding EN field against
the corrected PL meaning and record the disposition (aligned / corrected / N/A) in the change ledger.
Do not assume EN is "already correct" — even when the fix appears language-only, EN may carry the same
over-broad claim or contradict the corrected criterion.
**Why:** The final reviewer found that 5 EN welfare/criteria fields still contradicted the corrected
Polish meaning after all 126 IDs were reported applied. Without that check the resource-guarding
referral, nipping warning, snuffle safety rule, and two criteria fields would have shipped with
divergent EN text.
**Evidence:**
- openspec/changes/archive/2026-10-23-correct-approved-polish-copy/learnings.md
**Last verified:** 2026-10-23

## CONV-002: Educational surfaces are write-free; exercise links keep lazy-initialization semantics
**When relevant:** guidance/hub/reading screens, links from unscored content into scored exercises
**Learning:** Reading guides or problem cards must write nothing. A guidance link to a NEVER-OPENED
exercise legitimately creates the same lazy state as the catalogue route (`ProgressRepository.position`
step-1/starting-environment row + empty active `resumableSet`); links to partial or choice-pending
sets must be byte-stable. Tests assert the exact initialization delta from the database, never "no
writes" in absolute terms and never UI labels as proxy.
**Why:** AppModel.makeSessionModel writes through position+resumableSet before any scoring; an
absolute no-write promise contradicts existing navigation (reviewer P-1) and would force out-of-scope
session changes.
**Evidence:**
- openspec/changes/archive/2026-10-24-add-puppy-start-section/design.md (§5)
- PettrainerTests/PuppyIsolationTests.swift
**Last verified:** 2026-10-24


## CONV-003: Fit puppy evidence to five load-bearing sources, not five arbitrary links
**When relevant:** puppy guide authoring, `evidence.sources`, source-supported welfare/health copy
**Learning:** Puppy guide evidence allows 1–5 sources. Map every touched claim to verified source
text first, then choose the citations that actually carry those claims within the cap. Record pages
that were read but dropped from the final set in the change's editorial ledger, with the reason. When
a claim lacks support, omit or soften it rather than letting a nearby citation imply coverage, and
keep the PL and EN meanings aligned with a truthful `verifiedOn` date.
**Why:** The loose-lead puppy extension needed the RSPCA chewing page for shipped claims while the
Dogs Trust stealing page was redundant; both were read and only the load-bearing one was cited. Two
unsupported draft claims were dropped or softened instead of shipped.
**Evidence:**
- Pettrainer/Content/Validators/PuppyGuideValidator.swift
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/content-review.md
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/learnings.md
**Last verified:** 2026-10-31

## CONV-004: Welfare copy attributes symptoms to causes tentatively in BOTH locales
**When relevant:** observation/urgent/professional copy, separation-anxiety or marking wording, per-locale copy tests
**Learning:** A symptom pattern never establishes a cause: write "may indicate / może wskazywać" and
route the determination to the veterinarian/behaviour professional, and enforce the modality with
BOTH a positive assertion of the hedged phrase and a negative assertion banning the categorical one,
per locale. CONV-001 aligns meanings across languages; this covers strength within each language —
the divergence can be one-sided (definitive PL next to hedged EN survived a content pass).
**Why:** Final review F-2 of add-puppy-toilet-guidance caught `observe[3]` PL stating absence-only
accidents were "sprawa lęku separacyjnego" while EN merely said "point to": a diagnostic assertion in
shipped copy; corrected in both locales plus negative tests so it cannot come back.
**Evidence:**
- openspec/changes/archive/2026-10-31-add-puppy-toilet-guidance/learnings.md
- PettrainerTests/PuppyContentTests.swift (testToiletGuideCarriesTheBeforeDuringAfterRulePerLocale)
- Pettrainer/Resources/Content/puppy-puppy-toilet.json
**Last verified:** 2026-10-31
