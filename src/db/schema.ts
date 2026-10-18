/**
 * SQLite schema for the dog-training app: migration definitions and row types.
 *
 * Two kinds of table:
 *
 * - **Content** (`exercise`, `exercise_name`, `exercise_prerequisite`, `step`,
 *   `step_text`, `environment`, `environment_name`) ships with the app, is
 *   seeded, and is read-only at runtime.
 * - **Progress** (`dog`, `session`, `rep`, `mastery`) is written on the device
 *   and is the user's data.
 *
 * Mastery is per (dog × exercise × environment) — never a boolean per exercise.
 * Verdicts are never stored; they are computed from raw `rep` rows.
 */

import type { RepOutcome } from '../domain/verdict';

/** One schema change set applied by the migration runner. */
export interface Migration {
  /** 1-based, contiguous, ascending identifier. */
  readonly id: number;
  /** Short slug describing the change, e.g. 'initial_schema'. */
  readonly name: string;
  /** SQL to apply; may contain multiple statements. */
  readonly up: string;
}

/** Training categories an exercise belongs to. */
export type ExerciseCategory = 'foundation' | 'impulse_control' | 'advanced';

/** A row of the `exercise` table. */
export interface ExerciseRow {
  id: string;
  category: ExerciseCategory;
  sort_order: number;
}

/** A row of the `exercise_name` table: the cue name per locale. */
export interface ExerciseNameRow {
  exercise_id: string;
  locale: string;
  name: string;
  description: string;
}

/** A row of the `exercise_prerequisite` table. Advisory dependency edge only. */
export interface ExercisePrerequisiteRow {
  exercise_id: string;
  requires_id: string;
}

/** A row of the `step` table: one micro-step on the installation axis. */
export interface StepRow {
  id: string;
  exercise_id: string;
  ordinal: number;
  media_ref: string | null;
}

/** A row of the `step_text` table: step wording per locale. */
export interface StepTextRow {
  step_id: string;
  locale: string;
  instruction: string;
  criterion: string;
}

/** A row of the `environment` table: a rung on the distraction ladder. */
export interface EnvironmentRow {
  id: string;
  difficulty: number;
  distraction_kind: string;
  sort_order: number;
}

/** A row of the `environment_name` table: environment label per locale. */
export interface EnvironmentNameRow {
  environment_id: string;
  locale: string;
  name: string;
}

/** A row of the `dog` table. */
export interface DogRow {
  id: string;
  name: string;
  born_on: string | null;
  created_at: string;
}

/** A row of the `session` table: one set of repetitions. */
export interface SessionRow {
  id: string;
  dog_id: string;
  step_id: string;
  environment_id: string;
  started_at: string;
  ended_at: string | null;
  note: string | null;
}

/** A row of the `rep` table: one repetition. Source of truth for verdicts. */
export interface RepRow {
  session_id: string;
  ordinal: number;
  outcome: RepOutcome;
}

/** A row of the `mastery` table: highest step per dog × exercise × environment. */
export interface MasteryRow {
  dog_id: string;
  exercise_id: string;
  environment_id: string;
  highest_step_ordinal: number;
  updated_at: string;
}

const INITIAL_SCHEMA = `
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
`;

/** All migrations, in apply order. Ids must be 1-based and contiguous. */
export const MIGRATIONS: readonly Migration[] = [
  { id: 1, name: 'initial_schema', up: INITIAL_SCHEMA },
];
