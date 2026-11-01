# Copy review ledger — puppy-start content

Approval model: the user approved implementation with a blanket instruction ("don't
ask me, do everything"), so per-gate questions were waived (see `notes.md`). The
substantive checks ran anyway: full-page source reads, an independent reviewer
copy pass (round C below) and structural + semantic tests. Nothing here is a
clinical endorsement; the copy is owner-reviewable after shipping like all
welfare text in this app.

## Source access

`sources.md` S-1..S-6 were read in full in this conversation on 2026-10-24;
S-8 (Dogs Trust) was read in full during apply on the same date. S-7 (UC Davis)
stayed unreadable and is cited **nowhere** in shipped copy.

## Field-level claim map (shipped files, final content)

Guide files live under `puppy/`, cards under `behaviour/`. Source IDs from
`sources.md`. Disposition: **supported** / **omitted** / **blocked**.

| Resource | Field(s) | Claim shipped | Sources | Status |
| --- | --- | --- | --- | --- |
| puppy-rest | names, actions | overtired puppies get revved/bitey; rest is protective; day rhythm | S-4, S-5 | supported |
| puppy-rest | avoid[0..1] | undisturbed rest place; no rigid hour quotas, individual variation | S-4 | supported |
| puppy-rest | avoid[2] | pen/gate must not become punishment/distress | S-4 (den as safe place), welfare consensus | supported |
| puppy-rest | urgent, professional, observe | sudden sleep/behaviour change → veterinarian; tracking without certainty | S-4 | supported |
| puppy-world | names, actions[0..1] | distance, voluntary approach, right to leave | S-2, S-3, S-8 | supported |
| puppy-world | actions[2] | vaccination/infection-risk decision routed to the owner's vet; avoid unknown-dog places | S-3, S-8, S-2 | supported; deliberately no schedule |
| puppy-world | actions[3] | short calm opportunities instead of one big outing | S-2, S-8 | supported (no cadence quota after C-4) |
| puppy-world | observe | signals read together, treat-taking ≠ proof of comfort | S-3 | supported |
| puppy-world | urgent, professional | panic/freeze/refusal → vet + behaviour professional before further encounters | S-2, S-3 | supported |
| puppy-world | practices[] = [] | no exercise demanded during scary exposures (C-6) | — | deliberate omission |
| puppy-play | actions | series + breaks, toy outlet, quiet mouth work in the evening | S-5 | supported |
| puppy-play | avoid[0] | running-to-exhaustion can raise arousal, not cure it | S-5 (running alone insufficient), S-4 | supported, causal softening after C-9 |
| puppy-play | avoid[1] | high squeal can excite more | S-5 | supported |
| puppy-play | avoid[2] | adult supervises child–puppy play | S-5 | supported |
| puppy-play | urgent, professional | stiff growly play / snaps → behaviour professional; sudden change → vet | S-1, product red lines | supported |
| puppy-first-exercises | urgent, avoid[0] | basic needs unconditional; exercise never replaces needs; red-flag short-circuit | S-1, product invariants | supported |
| puppy-first-exercises | avoid[1] | stillness is not calm | product invariant + S-1 framing | supported |
| puppy-first-exercises | actions[1] | five-rep set framing honest, unfinished = information | existing domain rules | supported |
| puppy-first-exercises | actions[2] | raise difficulty gradually per environment | existing progression model | supported |
| puppy-first-exercises | observe, professional | simplify immediately, no stubbornness inference; stalled training → reward-based instructor + vet; exercises don't treat fear | S-1 | supported (3-day threshold removed, C-8) |
| overarousal | names.tagline | arousal alone doesn't say what the dog feels | S-4/S-5 context framing | supported after C-11 |
| overarousal | recognizes, now | climbing arousal is not wellbeing; remove input, check needs, end series early | S-4, S-5 | supported |
| overarousal | avoid[0..2] | more exercise can lift arousal; cues-at-peak unhelpful; punishment not for arousal | S-1 (aversives rejected), S-4/S-5 | supported |
| overarousal | work, observe | antecedent logging; later tools framing; recovery tracking | behaviour-change practice, S-1 | supported |
| overarousal | urgent, professional | pain/illness rule-out first; bite history/guarding/separation panic → professionals, no waiting | S-6 analogue, product red lines | supported (C-3 line added) |
| fear-withdrawal | all actionable fields | distance/exit, no forced contact, no aversives, recovery tracking, professional routing incl. pain rule-out | S-1, S-2, S-3, S-8 | supported (tagline softened C-5; "small distances" criterion replaced C-1) |
| mounting (existing) | professional | months-threshold replaced by functioning-based trigger | design §4, S-6 | supported |
| mounting (existing) | now.en[0,1,3], work.en[3] | EN aligned to the already-approved PL (no attention-reward assumption, approx-30s phrasing, rest+sniffing, no "missing brake") | CONV-001, PL copy approved 2026-10-22 | corrected (C-12) |
| nipping (existing) | urgent.en, professional.en, avoid.en[1], work.en[0] | EN aligned to current PL (drawn blood wording; hedged squeal/hit and toy-outlet wording) | CONV-001 | corrected (C-12) |
| nipping/mounting | evidence | provenance added (S-5/S-1, S-6/S-1) | — | metadata |
| (calming products, neutering, medication, sleep quotas, exposure cadences) | — | not shipped | — | **omitted deliberately** |

No shipped sentence is translated or copied from a source; the reuse-restricted
S-3 was corroboration only.

## Bounded replacements on existing cards (field-level)

See the last three table rows; PL bodies of untouched fields are byte-preserved
(their earlier modifications in the working tree predate this change — build-5
copy rounds — and the frozen baseline hashes prove that). Full diff of every
touched field is in the file diff under these hashes.

## Reviewer round C (independent copy review, 2026-10-24)

Verdict **fix first**; findings C-1…C-14 triaged by the implementer under the
user's blanket approval (per `notes.md`):

- **C-1 fear "small distances" as a professional-selection criterion — accepted**; replaced with comfort-adapted distance/pace wording in both locales.
- **C-2 world guide missing the vaccination/infection boundary — accepted**; explicit vet-conversation action added, unknown-dog places flagged; ledger corrected accordingly.
- **C-3 red-flag short-circuit — accepted in targeted form**: added to overarousal.professional, fear-withdrawal.urgent and first-exercises.urgent, where a reader might otherwise substitute training for help. Not pasted into rest/play/world, whose advice cannot plausibly stand in for those red lines (rationale kept here rather than as boilerplate).
- **C-4 world guide Polish grammar + English "exposures" + weekly cadence — accepted**; full rewrite of the guide in original Polish, no cadence claim.
- **C-5 fear tagline absolute — accepted** (both locales rewritten as an action).
- **C-6 practice links framed as later tools — accepted partially**: links removed from the world guide (asking a frightened puppy for eye contact is exactly the misuse); rest's `mat` and play's `drop/leave` kept (contextually safe), while both new cards already carry the "future tools, not rescue" line.
- **C-7 first-exercises EN drift (owner's place / force a sit) — accepted**, PL polished alongside.
- **C-8 invented three-day threshold — accepted** (simplify immediately, no causal claim).
- **C-9 play chase mistranslation — accepted**.
- **C-10 "only settle spot" guaranteed loss + crate/kojec mismatch — accepted**.
- **C-11 certainty phrasing (timed right / well spaced / tagline / own brake) — accepted**, softened to observation prompts.
- **C-12 old-card EN contradicting the already-approved PL — accepted as CONV-001 alignment**: mounting now.en[0,1,3], work.en[3]; nipping urgent.en/professional.en, avoid.en[1], work.en[0]. PL untouched; earlier approved audit/R-round wording preserved.
- **C-13 ledger not field-level + S-8 missing — accepted**: this table is now the field map; S-8 added to `sources.md` with access date and limits; the pre-existing diff hunks are noted above as prior rounds.
- **C-14 rest description/professional drift — accepted**.

## Hash ledger (this change's resource set only; final post-review values)

Starting hashes are what `ContentChecksums.swift` carried before this change
(approved build-5 copy + earlier rounds); frozen migration snapshots and all
unrelated files are untouched.

| Resource | Before | After (final) |
| --- | --- | --- |
| behaviour/nipping.json | 32752155b2f31ef1ed65c7f6bcc944a3a05f71eea42b15a793e7d3f519214469 | 22a6975a175a31691e7e9f6259067d678b00be0271b0a54d4a1afb929e12786d |
| behaviour/mounting.json | 5859173e30a0d10ada6cbc9cac152c2c9fe83fe2877010fdcee9222652d9a6b5 | 139aff66965dbf77c91afae1cdbf11cc1c588a78ec7af585150c2c9f5c908736 |
| behaviour/overarousal.json | (new) | 72d2cdaf27eb47ee1f0af406acc9c0a38e2db07b70bed6cf1cfd9dd17247d8c4 |
| behaviour/fear-withdrawal.json | (new) | b31e29e4754bd5954d941507d3ae9343cc6905503b3638533d7ceece954deac4 |
| puppy/puppy-rest.json | (new) | 191bde0052097359779afa864b18610e11ea4864e809abd6cb6c9a6f3f144f41 |
| puppy/puppy-world.json | (new) | cf9580a45c145f2196b67178d97654bbce3df647cc341421f5a6101602121a21 |
| puppy/puppy-play.json | (new) | 3a03b3fc168cf2d918ffd04b45871ff0a333d527f709c7dee10d12edd441d77e |
| puppy/puppy-first-exercises.json | (new) | 2248dcd83bb3a3c1356d92411bbe186180774a46d4b4afad87ef7ddfd7c49dc1 |

(The four guide digests were re-registered once more after the owner's "no
icons" feedback: the required `pose` field was added to `PuppyGuide`, the
validator and all four resources. Values above are the final shipped bytes.)

`ContentChecksums.swift` carries the "After" column; `testBundledBytesMatchBaselineChecksums`
plus the registered-vs-checksummed key equality assert it mechanically.

## Known-copy risks accepted with the blanket approval

- Reviewer round C was an independent editorial/welfare pass, **not** a
  veterinary review; no source endorsed the product.
- Exact PL/EN wording remains owner-reviewable in-app, per project convention.
