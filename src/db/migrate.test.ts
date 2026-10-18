/**
 * @jest-environment node
 */
/// <reference types="node" />
import { DatabaseSync } from 'node:sqlite';

import { runMigrations, type MigrationDb } from './migrate';
import { MIGRATIONS, type Migration } from './schema';

/** Adapts node:sqlite to the runner's minimal interface. */
class SqliteMigrationDb implements MigrationDb {
  readonly db: DatabaseSync;

  constructor(db: DatabaseSync) {
    this.db = db;
  }

  execute(sql: string): void {
    this.db.exec(sql);
  }

  queryUserVersion(): number {
    const row = this.db.prepare('PRAGMA user_version').get();
    return Number(row?.['user_version'] ?? 0);
  }
}

const LATEST_VERSION = MIGRATIONS.at(-1)?.id ?? 0;

/**
 * A fresh in-memory database with foreign keys explicitly OFF.
 *
 * node:sqlite enables foreign key constraints by default, but SQLite itself —
 * and expo-sqlite on the device — defaults them off per connection. Starting
 * them off means the only thing that can turn them on is the migration
 * runner's own `PRAGMA foreign_keys = ON`, so the foreign-key test below
 * exercises our code instead of a node:sqlite default.
 */
function freshDb(): SqliteMigrationDb {
  return new SqliteMigrationDb(
    new DatabaseSync(':memory:', { enableForeignKeyConstraints: false })
  );
}

/** Migrates a fresh in-memory database and returns the adapter over it. */
function migratedDb(): SqliteMigrationDb {
  const adapter = freshDb();
  runMigrations(adapter);
  return adapter;
}

/** Inserts one exercise, step, and environment so progress rows can reference them. */
function seedContent(adapter: SqliteMigrationDb): void {
  adapter.db.exec(`
    INSERT INTO exercise (id, category, sort_order) VALUES ('sit', 'foundation', 1);
    INSERT INTO step (id, exercise_id, ordinal) VALUES ('sit-1', 'sit', 1);
    INSERT INTO environment (id, difficulty, distraction_kind, sort_order)
      VALUES ('quiet-room', 1, 'none', 1);
  `);
}

/** Inserts a dog plus one session with one rep on step 'sit-1' in 'quiet-room'. */
function seedProgress(adapter: SqliteMigrationDb): void {
  seedContent(adapter);
  adapter.db.exec(`
    INSERT INTO dog (id, name, created_at) VALUES ('rex', 'Rex', '2026-10-01T08:00:00Z');
    INSERT INTO session (id, dog_id, step_id, environment_id, started_at)
      VALUES ('s1', 'rex', 'sit-1', 'quiet-room', '2026-10-01T09:00:00Z');
    INSERT INTO rep (session_id, ordinal, outcome) VALUES ('s1', 1, 'hit');
  `);
}

function countRows(db: DatabaseSync, sql: string): number {
  const row = db.prepare(sql).get();
  return Number(row?.['count'] ?? 0);
}

describe('runMigrations', () => {
  test('migrates a fresh database cleanly and sets user_version', () => {
    const adapter = freshDb();
    const applied = runMigrations(adapter);

    expect(applied).toEqual(MIGRATIONS.map((migration) => migration.id));
    expect(adapter.queryUserVersion()).toBe(LATEST_VERSION);
  });

  test('is idempotent: a second run applies nothing', () => {
    const adapter = migratedDb();

    expect(runMigrations(adapter)).toEqual([]);
    expect(adapter.queryUserVersion()).toBe(LATEST_VERSION);
  });

  test('creates every table', () => {
    const { db } = migratedDb();
    const names = new Set(
      db
        .prepare("SELECT name FROM sqlite_master WHERE type = 'table'")
        .all()
        .map((row) => String(row['name']))
    );

    for (const table of [
      'exercise',
      'exercise_name',
      'exercise_prerequisite',
      'step',
      'step_text',
      'environment',
      'environment_name',
      'dog',
      'session',
      'rep',
      'mastery',
    ]) {
      expect(names.has(table)).toBe(true);
    }
  });

  test('enforces foreign keys: a session needs an existing dog', () => {
    const adapter = migratedDb();
    seedContent(adapter);

    expect(() =>
      adapter.db
        .prepare(
          `INSERT INTO session (id, dog_id, step_id, environment_id, started_at)
           VALUES ('s1', 'nobody', 'sit-1', 'quiet-room', '2026-10-01T09:00:00Z')`
        )
        .run()
    ).toThrow(/FOREIGN KEY/i);
  });

  test('rep.outcome CHECK rejects values outside hit, miss, cancelled', () => {
    const adapter = migratedDb();
    seedProgress(adapter);

    expect(() =>
      adapter.db.prepare("INSERT INTO rep (session_id, ordinal, outcome) VALUES ('s1', 2, 'nope')").run()
    ).toThrow(/CHECK constraint/i);
  });

  test('rep.ordinal CHECK rejects 0 and 6', () => {
    const adapter = migratedDb();
    seedProgress(adapter);

    expect(() =>
      adapter.db.prepare("INSERT INTO rep (session_id, ordinal, outcome) VALUES ('s1', 0, 'hit')").run()
    ).toThrow(/CHECK constraint/i);
    expect(() =>
      adapter.db.prepare("INSERT INTO rep (session_id, ordinal, outcome) VALUES ('s1', 6, 'hit')").run()
    ).toThrow(/CHECK constraint/i);
  });

  test('exercise_prerequisite rejects a self-referencing row', () => {
    const adapter = migratedDb();
    adapter.db.exec("INSERT INTO exercise (id, category, sort_order) VALUES ('sit', 'foundation', 1)");

    expect(() =>
      adapter.db
        .prepare("INSERT INTO exercise_prerequisite (exercise_id, requires_id) VALUES ('sit', 'sit')")
        .run()
    ).toThrow(/CHECK constraint/i);
  });

  test('environment.difficulty CHECK rejects 0 and 11', () => {
    const adapter = migratedDb();

    expect(() =>
      adapter.db
        .prepare("INSERT INTO environment (id, difficulty, distraction_kind, sort_order) VALUES ('e0', 0, 'none', 1)")
        .run()
    ).toThrow(/CHECK constraint/i);
    expect(() =>
      adapter.db
        .prepare("INSERT INTO environment (id, difficulty, distraction_kind, sort_order) VALUES ('e11', 11, 'none', 1)")
        .run()
    ).toThrow(/CHECK constraint/i);
  });

  test('deleting a dog cascades to its sessions and their reps', () => {
    const adapter = migratedDb();
    seedProgress(adapter);

    adapter.db.prepare("DELETE FROM dog WHERE id = 'rex'").run();

    expect(countRows(adapter.db, "SELECT COUNT(*) AS count FROM session WHERE dog_id = 'rex'")).toBe(0);
    expect(countRows(adapter.db, "SELECT COUNT(*) AS count FROM rep WHERE session_id = 's1'")).toBe(0);
  });

  test('stores mastery per dog × exercise × environment', () => {
    const adapter = migratedDb();
    seedContent(adapter);
    adapter.db.exec(`
      INSERT INTO environment (id, difficulty, distraction_kind, sort_order)
        VALUES ('park', 7, 'other_dogs', 5);
      INSERT INTO dog (id, name, created_at) VALUES ('rex', 'Rex', '2026-10-01T08:00:00Z');
    `);

    // Central modelling requirement: the same dog and exercise coexist in two
    // environments with different mastery, because a dog that sits in a quiet
    // room and fails in a park is the normal case, not a contradiction.
    adapter.db.exec(`
      INSERT INTO mastery (dog_id, exercise_id, environment_id, highest_step_ordinal, updated_at)
        VALUES ('rex', 'sit', 'quiet-room', 4, '2026-10-01T09:00:00Z');
      INSERT INTO mastery (dog_id, exercise_id, environment_id, highest_step_ordinal, updated_at)
        VALUES ('rex', 'sit', 'park', 1, '2026-10-02T09:00:00Z');
    `);

    expect(
      countRows(adapter.db, "SELECT COUNT(*) AS count FROM mastery WHERE dog_id = 'rex' AND exercise_id = 'sit'")
    ).toBe(2);
  });

  test('throws RangeError on non-contiguous migration ids', () => {
    const adapter = freshDb();
    const gapped: readonly Migration[] = [
      { id: 1, name: 'first', up: 'SELECT 1;' },
      { id: 3, name: 'third', up: 'SELECT 1;' },
    ];

    expect(() => runMigrations(adapter, gapped)).toThrow(RangeError);
    expect(adapter.queryUserVersion()).toBe(0);

    const missingFirst: readonly Migration[] = [{ id: 2, name: 'second', up: 'SELECT 1;' }];
    expect(() => runMigrations(adapter, missingFirst)).toThrow(RangeError);
  });

  test('throws RangeError when the database is newer than the newest migration', () => {
    const adapter = freshDb();
    runMigrations(adapter);
    adapter.execute(`PRAGMA user_version = ${LATEST_VERSION + 1};`);

    expect(() => runMigrations(adapter)).toThrow(RangeError);
    expect(adapter.queryUserVersion()).toBe(LATEST_VERSION + 1);
  });
});
