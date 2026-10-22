import Foundation

/// Upserts the validated bundled content into the read-only content tables so
/// progress rows (`session`, `mastery`, …) can keep real foreign keys.
///
/// Content updates use upserts with stable ids and never cascade-delete
/// historical references: the DO UPDATE branch touches no primary key, so old
/// sessions keep pointing at the same `step.id`. Only advisory
/// `exercise_prerequisite` edges are pruned and re-inserted — nothing else
/// references them. The full prose always lives in the bundled JSON; the SQL
/// mirror only carries what foreign keys and history need.
enum ContentSeeder {
    /// Stable step identity: `<exerciseId>#<ordinal>` (baseline manifest).
    static func stepId(exerciseId: String, ordinal: Int) -> String {
        "\(exerciseId)#\(ordinal)"
    }

    static func seed(_ db: SQLiteDatabase, content: TrainingContent) throws {
        try db.transaction {
            for entry in content.catalogue {
                try db.run("""
                INSERT INTO exercise (id, category, sort_order) VALUES (?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                  category = excluded.category, sort_order = excluded.sort_order;
                """, [.text(entry.id), .text(entry.category.rawValue), .integer(entry.sortOrder)])

                try db.run("""
                INSERT INTO exercise_name (exercise_id, locale, name, description) VALUES (?, 'pl', ?, ?)
                ON CONFLICT(exercise_id, locale) DO UPDATE SET
                  name = excluded.name, description = excluded.description;
                """, [.text(entry.id), .text(entry.names.pl.name), .text(entry.names.pl.description)])
                try db.run("""
                INSERT INTO exercise_name (exercise_id, locale, name, description) VALUES (?, 'en', ?, ?)
                ON CONFLICT(exercise_id, locale) DO UPDATE SET
                  name = excluded.name, description = excluded.description;
                """, [.text(entry.id), .text(entry.names.en.name), .text(entry.names.en.description)])

                // Advisory edges only; safe to rebuild, and no stale edge can
                // survive a content edit.
                try db.run("DELETE FROM exercise_prerequisite WHERE exercise_id = ?;",
                           [.text(entry.id)])
                for requiresId in entry.requires {
                    try db.run("""
                    INSERT INTO exercise_prerequisite (exercise_id, requires_id) VALUES (?, ?);
                    """, [.text(entry.id), .text(requiresId)])
                }

                for step in entry.steps {
                    let id = stepId(exerciseId: entry.id, ordinal: step.ordinal)
                    try db.run("""
                    INSERT INTO step (id, exercise_id, ordinal, media_ref) VALUES (?, ?, ?, NULL)
                    ON CONFLICT(id) DO UPDATE SET
                      exercise_id = excluded.exercise_id, ordinal = excluded.ordinal;
                    """, [.text(id), .text(entry.id), .integer(step.ordinal)])
                    try db.run("""
                    INSERT INTO step_text (step_id, locale, instruction, criterion) VALUES (?, 'pl', ?, ?)
                    ON CONFLICT(step_id, locale) DO UPDATE SET
                      instruction = excluded.instruction, criterion = excluded.criterion;
                    """, [.text(id), .text(step.pl.instruction), .text(step.pl.criterion)])
                    try db.run("""
                    INSERT INTO step_text (step_id, locale, instruction, criterion) VALUES (?, 'en', ?, ?)
                    ON CONFLICT(step_id, locale) DO UPDATE SET
                      instruction = excluded.instruction, criterion = excluded.criterion;
                    """, [.text(id), .text(step.en.instruction), .text(step.en.criterion)])
                }
            }

            for environment in content.environments {
                try db.run("""
                INSERT INTO environment (id, difficulty, distraction_kind, sort_order) VALUES (?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                  difficulty = excluded.difficulty,
                  distraction_kind = excluded.distraction_kind,
                  sort_order = excluded.sort_order;
                """, [.text(environment.id), .real(environment.difficulty),
                      .text(environment.distractionKind.rawValue), .integer(environment.sortOrder)])
                try db.run("""
                INSERT INTO environment_name (environment_id, locale, name) VALUES (?, 'pl', ?)
                ON CONFLICT(environment_id, locale) DO UPDATE SET name = excluded.name;
                """, [.text(environment.id), .text(environment.names.pl)])
                try db.run("""
                INSERT INTO environment_name (environment_id, locale, name) VALUES (?, 'en', ?)
                ON CONFLICT(environment_id, locale) DO UPDATE SET name = excluded.name;
                """, [.text(environment.id), .text(environment.names.en)])
            }
        }
    }
}
