/**
 * Migration runner for the app's SQLite database.
 *
 * Tracks the schema version in SQLite's `user_version` pragma rather than a
 * bookkeeping table. `PRAGMA foreign_keys` is applied here on every call
 * because SQLite defaults it off per connection.
 */

import { MIGRATIONS, type Migration } from './schema';

/** The minimal database surface the runner needs. Lets callers pass expo-sqlite, node:sqlite, or a fake. */
export interface MigrationDb {
  /** Runs one or more SQL statements, throwing on any failure. */
  execute(sql: string): void;
  /** Reads the current `user_version` pragma. */
  queryUserVersion(): number;
}

/** Throws RangeError unless ids are 1-based, strictly ascending, and contiguous. */
function assertContiguousIds(migrations: readonly Migration[]): void {
  for (const [index, migration] of migrations.entries()) {
    if (migration.id !== index + 1) {
      throw new RangeError(
        `Migration ids must be contiguous starting at 1, but migrations[${index}] has id ${migration.id}`
      );
    }
  }
}

/**
 * Applies every migration whose id is greater than the database's current
 * user_version, in ascending id order, then sets user_version to the highest
 * applied id. Returns the ids actually applied, in order.
 *
 * Idempotent: running twice applies nothing the second time. All pending
 * migrations are applied in one transaction; on failure the transaction is
 * rolled back and user_version is left untouched.
 *
 * Throws RangeError if migration ids are not contiguous starting at 1, or if
 * the database reports a user_version higher than the newest migration (the
 * app has been downgraded — refusing is safer than guessing).
 */
export function runMigrations(
  db: MigrationDb,
  migrations: readonly Migration[] = MIGRATIONS
): number[] {
  assertContiguousIds(migrations);

  const currentVersion = db.queryUserVersion();
  const latestVersion = migrations.at(-1)?.id ?? 0;
  if (currentVersion > latestVersion) {
    throw new RangeError(
      `Database is at user_version ${currentVersion}, newer than the newest migration (${latestVersion}); refusing to downgrade`
    );
  }

  // Per-connection pragma; a no-op inside a transaction, so it goes first.
  db.execute('PRAGMA foreign_keys = ON;');

  const pending = migrations.filter((migration) => migration.id > currentVersion);
  if (pending.length === 0) {
    return [];
  }

  const applied: number[] = [];
  db.execute('BEGIN');
  try {
    for (const migration of pending) {
      db.execute(migration.up);
      applied.push(migration.id);
    }
    db.execute(`PRAGMA user_version = ${latestVersion};`);
    db.execute('COMMIT');
  } catch (error) {
    try {
      db.execute('ROLLBACK');
    } catch {
      // The transaction was already rolled back or never opened; report the original failure.
    }
    throw error;
  }
  return applied;
}
