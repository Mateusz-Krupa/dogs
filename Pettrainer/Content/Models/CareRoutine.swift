import Foundation

/// Typed shape of one hygiene routine: `data/care/<care-id>.json` (port of the
/// `CareRoutine` types in `src/content/schema.ts`).
///
/// Care is participation-only. There is no criterion, repetition target or
/// pass condition anywhere in these types, on purpose: hygiene is trained by
/// the dog cooperating, and a scored set would turn "not today" into a failure.

/// A cited page behind a routine's advice. Offline provenance — the app never
/// needs it open to follow the routine.
struct CareSource {
    let title: String
    /// Absolute `https://` address; validated, not assumed.
    let url: String
}

/// One language's copy for one stage.
struct CareStageCopy {
    let title: String
    let setup: String
    let how: String
    let watchFor: String
    /// This stage's own hazard line, rendered before the instructions.
    let stop: String
}

/// One invitation in a routine. Ending it without any contact is a valid
/// outcome, so there is deliberately nothing to score here.
struct CareStage {
    /// 1-based position; every routine offers exactly three.
    let ordinal: Int
    let gear: [GearId]
    let pl: CareStageCopy
    let en: CareStageCopy
}

struct CareRoutine {
    let id: String
    let pose: Pose
    let sortOrder: Int
    let names: Localized<CueNames>
    let tagline: Localized<String>
    /// Safety boundary shown before anything else on the screen.
    let urgent: Localized<String>
    /// Where professional help takes over; never a nudge to keep going.
    let professional: Localized<String>
    /// Exercise ids worth practising first. Advisory, never a gate.
    let practices: [String]
    let sources: [CareSource]
    let stages: [CareStage]
}
