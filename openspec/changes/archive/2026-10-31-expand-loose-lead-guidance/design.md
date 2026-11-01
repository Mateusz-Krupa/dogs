## Context

`exercises-leash.json` has four scored steps. `mistakes-leash.json` has two bilingual symptom/why/fix cards. `SetView.disclosures` already renders the exercise description and any number of these cards; setup and note blocks also exist. No new content type or UI is needed. The broad active exercise-content change currently contains only metadata; this bounded proposal owns only loose-lead copy.

## Goals / Non-Goals

**Goals:** Give owners a clear equipment choice, permission for normal sniffing, practical transitions back to walking, and a safe response to refusal. Keep instructions concise during repetitions and place detail in existing disclosures.

**Non-Goals:** No new scored steps, revised success criteria, progress repair, persistent flags, screen changes, source browser, or global gear-label changes.

## Decisions

1. Use existing JSON fields. Put the equipment summary in the description and first-step setup/note; put three additional cases in troubleshooting (five cards total). Revise the two current cards and step-4 sniffing copy. This avoids a schema/UI expansion for one exercise.
2. Use the evidence mapping and bilingual editorial contract in `content-review.md`. Distinguish an unlocked reel's tension from a locked lead with slack. Recommend fixed length for this exercise, not a universal claim that every retractable lead always harms every dog.
3. Keep sniffing available outside scored practice, not something the dog must earn for the whole walk. Optional access to a safe smell can reward a short successful training stretch. Loose lead is not formal heel; rewarding beside the owner must not imply a mandatory position throughout the walk.
4. Refusal guidance puts possible pain/illness before training. Fear requires distance/retreat and support, not dragging or food-luring toward a frightening stimulus. Ordinary sniffing with relaxed movement is explicitly distinct from inability/refusal to move.
5. Preserve `leash`, its four ordinals, criteria, prerequisites and illustration fields. Copy-only changes need no DB migration and do not alter interrupted-set recovery. Five reps remain 5/5 push, 3–4 stick, 0–2 drop; cancellations fail, incomplete sets stay incomplete, verdicts remain derived. All progress/history semantics remain untouched.
6. Update only the three affected `ContentChecksums` values after copy review, with actual before/after hashes recorded locally. Do not regenerate migration snapshots or rebaseline unrelated dirty files. Add focused assertions to existing content test files rather than introducing a target/project change.
7. (R-1) Floor-scavenging advice lives inside the existing `puppy-first-exercises` foundation — its `avoid`/`actions`/`observe`/`urgent`/`practices`/`evidence` fields already carry this shape — rather than a fifth foundation or a duplicate scored exercise. The existing `puppy-start-guidance` spec stays unmodified: links are optional and uncapped, four foundations and stable IDs persist, and reading stays write-free (CONV-002). Acceptance cases for the new advice are added as ADDED requirements in this change's delta spec under `puppy-scavenging-guidance`.
8. (R-2) Ingestion and emergency claims are backed by the RSPCA Australia household/garden-danger pages read in full on 2026-10-29, training claims by the Dogs Trust leave-training and stealing pages, and the guide's pre-existing AVSAB/Dogs Trust sources were re-read the same day so a single `verifiedOn` stays truthful. Unsupported extras (e.g. do-it-yourself vomiting instructions) are omitted rather than guessed.
9. (R-3) `PuppyContentTests.swift:63,87` pin every guide's verification date and exactly three cue links; only the changed guide's expectations are adjusted, and the guide's assertions move to decoded bilingual content checks, not keyword presence.

## Risks / Trade-offs

- [Long copy during training] → Keep first-step additions brief and put troubleshooting in collapsed cards; inspect a phone-sized simulator in both languages.
- [Overconfident training/health claims] → Use cautious causes, no promised timelines, no fixed mandatory sniff duration, no diagnosis, and explicit professional escalation.
- [Existing uncommitted content/checksum edits] → Snapshot the current two resources and ledger entries at apply time, edit incrementally, and distinguish pre-existing test failures from this change. Do not reset or broadly refresh hashes.
- [Keyword tests do not prove humane meaning] → Combine targeted decoded-content assertions with independent bilingual editorial review.

## Migration Plan

Bundle replacement JSON only; no schema or data migration. Roll back only this change's copy/hash/test diff if needed, preserving unrelated work and all local training data.

## Open Questions

No product decision remains unresolved. Implementation is pending reviewer and user approval; any reviewer-driven changes require user selection first.
