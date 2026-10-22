import Foundation

/// SQLite schema for the dog-training app: migration definitions (port of
/// `src/db/schema.ts`). Two kinds of table:
///
/// - **Content** (`exercise`, `exercise_name`, `exercise_prerequisite`, `step`,
///   `step_text`, `environment`, `environment_name`) ships with the app, is
///   seeded, and is read-only at runtime.
/// - **Progress** (`dog`, `session`, `rep`, `mastery`, plus the native-era
///   `session_choice`, `position`, `context_progress`, `nosework_progress`) is
///   written on the device and is the user's data.
///
/// Mastery is per (dog × exercise × environment) — never a boolean per
/// exercise. Verdicts are never stored; they are computed from raw `rep` rows.

struct Migration {
    /// 1-based, contiguous, ascending identifier.
    let id: Int
    /// Short slug describing the change, e.g. `initialSchema`.
    let name: String
    /// SQL to apply; may contain multiple statements.
    let up: String
}

enum Migrations {
    /// Ported byte-for-byte from `src/db/schema.ts` INITIAL_SCHEMA. Once a
    /// migration shipped it is immutable: never edit a migration that may
    /// already be applied on a device — add a new numbered one.
    static let initialSchema = """
    CREATE TABLE exercise (
      id TEXT PRIMARY KEY,
      category TEXT NOT NULL CHECK (category IN ('foundation', 'impulse_control', 'advanced')),
      sort_order INTEGER NOT NULL
    );

    CREATE TABLE exercise_name (
      exercise_id TEXT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
      locale TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      PRIMARY KEY (exercise_id, locale)
    );

    CREATE TABLE exercise_prerequisite (
      exercise_id TEXT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
      requires_id TEXT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
      PRIMARY KEY (exercise_id, requires_id),
      CHECK (exercise_id <> requires_id)
    );

    CREATE TABLE step (
      id TEXT PRIMARY KEY,
      exercise_id TEXT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
      ordinal INTEGER NOT NULL,
      media_ref TEXT,
      UNIQUE (exercise_id, ordinal)
    );

    CREATE TABLE step_text (
      step_id TEXT NOT NULL REFERENCES step(id) ON DELETE CASCADE,
      locale TEXT NOT NULL,
      instruction TEXT NOT NULL,
      criterion TEXT NOT NULL,
      PRIMARY KEY (step_id, locale)
    );

    CREATE TABLE environment (
      id TEXT PRIMARY KEY,
      difficulty REAL NOT NULL CHECK (difficulty >= 1 AND difficulty <= 10),
      distraction_kind TEXT NOT NULL,
      sort_order INTEGER NOT NULL
    );

    CREATE TABLE environment_name (
      environment_id TEXT NOT NULL REFERENCES environment(id) ON DELETE CASCADE,
      locale TEXT NOT NULL,
      name TEXT NOT NULL,
      PRIMARY KEY (environment_id, locale)
    );

    CREATE TABLE dog (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      born_on TEXT,
      created_at TEXT NOT NULL
    );

    CREATE TABLE session (
      id TEXT PRIMARY KEY,
      dog_id TEXT NOT NULL REFERENCES dog(id) ON DELETE CASCADE,
      step_id TEXT NOT NULL REFERENCES step(id),
      environment_id TEXT NOT NULL REFERENCES environment(id),
      started_at TEXT NOT NULL,
      ended_at TEXT,
      note TEXT
    );

    CREATE TABLE rep (
      session_id TEXT NOT NULL REFERENCES session(id) ON DELETE CASCADE,
      ordinal INTEGER NOT NULL CHECK (ordinal BETWEEN 1 AND 5),
      outcome TEXT NOT NULL CHECK (outcome IN ('hit', 'miss', 'cancelled')),
      PRIMARY KEY (session_id, ordinal)
    );

    CREATE TABLE mastery (
      dog_id TEXT NOT NULL REFERENCES dog(id) ON DELETE CASCADE,
      exercise_id TEXT NOT NULL REFERENCES exercise(id),
      environment_id TEXT NOT NULL REFERENCES environment(id),
      highest_step_ordinal INTEGER NOT NULL,
      updated_at TEXT NOT NULL,
      PRIMARY KEY (dog_id, exercise_id, environment_id)
    );

    CREATE INDEX idx_session_dog_started_at ON session (dog_id, started_at);

    CREATE INDEX idx_session_dog_step ON session (dog_id, step_id);

    CREATE INDEX idx_rep_session ON rep (session_id);
    """

    /// Native-era additions (spec in notes.md, "4.2 schema spec"). Everything
    /// is additive; no v1 row is dropped or rewritten except the F-3 lifecycle
    /// classification below.
    static let nativeRuntime = """
    ALTER TABLE session ADD COLUMN lifecycle TEXT NOT NULL DEFAULT 'active'
      CHECK (lifecycle IN ('active', 'completed', 'abandoned'));

    UPDATE session SET lifecycle = 'completed'
     WHERE (SELECT COUNT(*) FROM rep WHERE rep.session_id = session.id) = 5;

    UPDATE session SET lifecycle = 'abandoned'
     WHERE lifecycle = 'active'
       AND ended_at IS NOT NULL
       AND (SELECT COUNT(*) FROM rep WHERE rep.session_id = session.id) < 5;

    UPDATE session SET lifecycle = 'abandoned'
     WHERE lifecycle = 'active'
       AND id NOT IN (
         SELECT s2.id FROM session s2
         JOIN (
           SELECT dog_id, step_id, environment_id,
                  MAX(started_at || '#' || id) AS keep_key
           FROM session
           WHERE lifecycle = 'active'
           GROUP BY dog_id, step_id, environment_id
         ) newest
           ON s2.dog_id = newest.dog_id
          AND s2.step_id = newest.step_id
          AND s2.environment_id = newest.environment_id
          AND (s2.started_at || '#' || s2.id) = newest.keep_key
       );

    CREATE TABLE session_choice (
      session_id TEXT PRIMARY KEY REFERENCES session(id) ON DELETE CASCADE,
      delta INTEGER NOT NULL CHECK (delta IN (-1, 0, 1)),
      applied_at TEXT NOT NULL
    );

    CREATE TABLE position (
      dog_id TEXT NOT NULL REFERENCES dog(id) ON DELETE CASCADE,
      exercise_id TEXT NOT NULL REFERENCES exercise(id),
      step_ordinal INTEGER NOT NULL CHECK (step_ordinal >= 1),
      environment_id TEXT NOT NULL REFERENCES environment(id),
      updated_at TEXT NOT NULL,
      PRIMARY KEY (dog_id, exercise_id)
    );

    CREATE TABLE context_progress (
      dog_id TEXT NOT NULL REFERENCES dog(id) ON DELETE CASCADE,
      exercise_id TEXT NOT NULL REFERENCES exercise(id),
      environment_id TEXT NOT NULL REFERENCES environment(id),
      current_step_ordinal INTEGER NOT NULL CHECK (current_step_ordinal >= 1),
      updated_at TEXT NOT NULL,
      PRIMARY KEY (dog_id, exercise_id, environment_id)
    );

    CREATE TABLE nosework_progress (
      dog_id TEXT NOT NULL REFERENCES dog(id) ON DELETE CASCADE,
      activity_id TEXT NOT NULL,
      highest_level_ordinal INTEGER NOT NULL CHECK (highest_level_ordinal >= 1),
      updated_at TEXT NOT NULL,
      PRIMARY KEY (dog_id, activity_id)
    );
    """

    /// All migrations, in apply order. Ids must be 1-based and contiguous.
    static let all: [Migration] = [
        Migration(id: 1, name: "initialSchema", up: initialSchema),
        Migration(id: 2, name: "nativeRuntime", up: nativeRuntime),
    ]
}
