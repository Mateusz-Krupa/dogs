## Why

Everyday hygiene can become frightening when an owner pushes through refusal or treats finishing the procedure as the goal. Add small, voluntary care practices that teach participation rather than endurance, with visible limits and guidance to the owner's veterinarian.

## What Changes

- Add **Higiena i pielęgnacja / Hygiene & care**, a participation-only content family with seven routines, each with three freely selectable stages:

  | Stable ID | PL | EN |
  | --- | --- | --- |
  | `care-paw-rinse` | Mycie łap | Paw rinsing |
  | `care-nails` | Pielęgnacja pazurów | Nail care |
  | `care-coat` | Czesanie | Brushing |
  | `care-checks` | Kontrola uszu, oczu i opuszek | Ear, eye and paw-pad checks |
  | `care-teeth` | Mycie zębów | Tooth brushing |
  | `care-towel` | Osuszanie ręcznikiem | Towel drying |
  | `care-bath` | Kąpiel | Bathing |

- Show required bilingual urgent/professional stop-lines **before instructions**. Withdrawal or freezing ends contact immediately; no restraint, deception, aversives or punishment. Necessary urgent care belongs with professionals rather than forced consent training.
- Display one shared localized not-veterinary-advice statement at the section header and each routine screen, plus the existing native catalogue menu. It states individual variation and recommends consulting one's own veterinarian before use; it makes no endorsement claim.
- Record only the **furthest stage tried**, explicitly marked by the owner, never mastery, success, procedure completion or a dated log. No care scoring, five-rep sets, verdicts or environment ladder.
- Add typed validation, equipment labels/icons, JS-reference and native navigation/screens, offline resources, and tests. Author content once and mirror bytes into the native bundle through a reviewed migration-baseline extension.
- Keep the scored `handling` exercise unchanged and link it advisory-only. No prerequisites or stages lock access.

## Capabilities

### New Capabilities

- `hygiene-cooperative-care`: Seven voluntary care routines, welfare-first bilingual content and disclaimer, participation tracking, offline access and cross-runtime resource parity.

### Modified Capabilities

None. No published specs exist. The live native migration has overlapping integration surfaces, not permission to alter its cutover requirements.

## Impact

Touches `src/content/`, `src/features/catalogue/`, new `src/features/care/`, `App.tsx`, `src/ui/Gear.tsx`, `src/i18n/locales/`; and native `Content/`, `Features/`, `App/`, `Data/`, `UI/Illustrations/`, bundled content/String Catalog, Xcode resource registration and tests. Reuse the existing participation storage shape, with namespaced care IDs, rather than add a table or migration. No new dependency or network service.

Coordinate changes to `openspec/changes/migrate-to-native-swift/baseline/` and `PettrainerTests/ContentChecksums.swift` with that change's owner before writes; the existing frozen reference must not silently move. No JS deletion, migration cutover or release operation happens here.

**Non-goals:** veterinary diagnosis/treatment features; reminders/notifications; product/brand recommendations; groomer booking; accounts/sync/network; care scoring or verdicts; content gating; dated care history; new database tables; changing training thresholds, raw history, dog/exercise/environment progress or `handling` content. This proposal is not implementation approval. After independent plan review and explicit user approval, implementation belongs to `/opsx-apply add-hygiene-care-section` (Flash Next).
