import Foundation

/// Typed shapes of the bundled training content (port of `src/content/schema.ts`).
/// These are read-only seeds; runtime progress lives in the Data layer.

/// A `{ pl, en }` pair. Both locales are required everywhere, so a record
/// that is only half translated fails at load rather than showing one
/// language to a Polish owner.
struct Localized<Value> {
    let pl: Value
    let en: Value
}

/// One language's copy for a step.
struct StepCopy {
    /// One-line summary. Used on cards and wherever the full form does not fit.
    let instruction: String
    /// What counts as a correct rep. The owner scores against exactly this.
    let criterion: String
    /// What to arrange before the dog is involved.
    let setup: [String]?
    /// One repetition, start to finish, in order.
    let reps: [String]?
    /// The one trap worth naming, with its reason.
    let note: String?
    /// Heading for the step. Blank in the JSON means unwritten → nil.
    let title: String?
}

/// One micro-step on the installation ladder.
struct StepSeed {
    /// 1-based position in the ladder.
    let ordinal: Int
    /// Per-step diagram override; nil means the exercise default.
    let motion: StepMotion?
    /// Per-step pose override.
    let pose: Pose?
    /// Whether the owner's voice belongs to this step.
    let sound: Bool?
    let pl: StepCopy
    let en: StepCopy
}

/// The exercise with its catalogue display fields.
struct CatalogueEntry {
    let id: String
    let category: ExerciseCategory
    let sortOrder: Int
    /// Advisory prerequisites; they recommend and warn, never lock.
    let requires: [String]
    let names: Localized<CueNames>
    let steps: [StepSeed]
    let pose: Pose
    let tagline: Localized<String>
    let gear: [GearId]
}

struct CueNames {
    let name: String
    let description: String
}

/// A rung on the distraction ladder.
struct EnvironmentSeed {
    let id: String
    /// 1–10, ordinal only: it exists to tell whether a move is up or down.
    let difficulty: Double
    let distractionKind: DistractionKind
    let sortOrder: Int
    /// Distance at which the trigger is usually workable; nil where distance
    /// is not the relevant variable.
    let thresholdMetres: Double?
    let names: Localized<String>
}

/// Everything `environments.json` carries.
struct EnvironmentSet {
    let startingEnvironmentId: String
    let beyondPuppyScope: [String]
    let categoryOrder: [ExerciseCategory]
    let environments: [EnvironmentSeed]
}

/// One troubleshooting line for an exercise: a diagnosis in three parts, all
/// load-bearing (symptom makes an owner think "that's me", why makes them
/// accept the fix instead of repeating what just failed). Same `{pl,en}` shape
/// as the TS `Mistake` type.
typealias Mistake = Localized<MistakeEntry>

struct MistakeEntry {
    let symptom: String
    let why: String
    let fix: String
}

/// One level of a scent game. No scoring fields on purpose.
struct NoseworkLevel {
    let ordinal: Int
    let minutes: Double
    let gear: [GearId]
    let pl: LevelCopy
    let en: LevelCopy
}

struct LevelCopy {
    let title: String
    let setup: String
    let how: String
    let watchFor: String
}

struct NoseworkActivity {
    let id: String
    let pose: Pose
    let sortOrder: Int
    let names: Localized<CueNames>
    let tagline: Localized<String>
    let levels: [NoseworkLevel]
}

/// A behaviour-problem card. Every section is load-bearing (see validator).
struct BehaviourIssue {
    let id: String
    let sortOrder: Int
    let names: Localized<IssueNames>
    let recognizes: Localized<String>
    let urgent: Localized<String>
    let avoid: Localized<[String]>
    let now: Localized<[String]>
    let work: Localized<[String]>
    let professional: Localized<String>
    /// Exercise ids the card points at.
    let practices: [String]
    /// What the owner should track between sessions. Optional: cards shipped
    /// before the puppy-start change parse without it and render unchanged.
    var observe: Localized<[String]>? = nil
    /// Provenance for the advice on this card. Optional, same compatibility
    /// rule as `observe`; malformed evidence is rejected, never ignored.
    var evidence: GuidanceEvidence? = nil
}

struct IssueNames {
    let name: String
    let tagline: String
}

/// Provenance shipped with guidance that touches welfare or health. The app
/// works fully offline with it: the citations are for the owner to open by
/// choice, and the date is when a human actually re-read the pages.
struct GuidanceEvidence {
    /// 1–5 cited pages, validated like care sources.
    let sources: [CareSource]
    /// Real calendar date `YYYY-MM-DD`, never in the future.
    let verifiedOn: String
}

/// A titled reading block inside a puppy guide. Structure for the reader
/// only: the guide family has no stages, no order the dog can climb and no
/// completion state — a section is a heading with paragraphs, nothing else
/// (spec: optional foundation sections are validated without breaking older
/// guides).
struct PuppyGuideSection {
    let id: String
    let title: Localized<String>
    let paragraphs: Localized<[String]>
}

/// One puppy-start foundation guide: education to read, never an activity to
/// score. No reps, stages, timers or completion exist in this shape on
/// purpose — resting and feeling safe are not trained to a criterion.
struct PuppyGuide {
    let id: String
    let pose: Pose
    let sortOrder: Int
    let names: Localized<CueNames>
    /// Safety boundary, rendered before anything actionable.
    let urgent: Localized<String>
    let avoid: Localized<[String]>
    let actions: Localized<[String]>
    let observe: Localized<[String]>
    /// Where professional help takes over; never a nudge to keep going.
    let professional: Localized<String>
    /// Optional exercise ids; an empty list is a guide with nothing to drill.
    let practices: [String]
    let evidence: GuidanceEvidence
    /// Optional titled sections; guides written before this field render
    /// exactly as they did without it.
    let sections: [PuppyGuideSection]
}
