import { SIT, type StepCopy } from './sit';

/**
 * Every word of a step, whatever field it lives in.
 *
 * The copy moved from one prose paragraph into setup / repetition / note, and
 * these tests guard the teaching, not the layout — so they read the whole step
 * rather than any single field, and survive the next restructuring too.
 */
function allText(copy: StepCopy): string {
  return [copy.instruction, copy.criterion, copy.note ?? '', ...(copy.setup ?? []), ...(copy.reps ?? [])].join(' ');
}

describe('the sit exercise', () => {
  it('numbers its steps contiguously from 1', () => {
    const ordinals = SIT.steps.map((step) => step.ordinal);
    expect(ordinals).toEqual(Array.from({ length: SIT.steps.length }, (_, i) => i + 1));
  });

  it('writes every step in both locales', () => {
    for (const step of SIT.steps) {
      for (const locale of [step.pl, step.en]) {
        expect(locale.instruction.length).toBeGreaterThan(20);
        expect(locale.criterion.length).toBeGreaterThan(10);
      }
    }
  });

  it('gives every step actionable setup and numbered repetitions', () => {
    // A bare paragraph is hard to execute with a puppy already in front of you.
    for (const step of SIT.steps) {
      for (const locale of [step.pl, step.en]) {
        expect(locale.setup?.length ?? 0).toBeGreaterThan(0);
        expect(locale.reps?.length ?? 0).toBeGreaterThanOrEqual(3);
      }
    }
  });

  it('keeps the action lists short enough to read at a glance', () => {
    // Bullets carry actions; past four or five they become a wall and lose to
    // the paragraph they replaced.
    for (const step of SIT.steps) {
      for (const locale of [step.pl, step.en]) {
        expect(locale.setup!.length).toBeLessThanOrEqual(3);
        expect(locale.reps!.length).toBeLessThanOrEqual(4);
        for (const line of [...locale.setup!, ...locale.reps!]) {
          expect(line.length).toBeLessThanOrEqual(90);
        }
      }
    }
  });

  it('has no prerequisites — it is where everyone starts', () => {
    expect(SIT.requires).toEqual([]);
    expect(SIT.category).toBe('foundation');
    expect(SIT.sortOrder).toBe(1);
  });

  it('introduces the verbal cue late, not at the start', () => {
    // The single most common novice mistake is chanting the word from
    // repetition one ("sit, sit, SIT!"). The word is meant to arrive once the
    // behaviour is already reliable — roughly the last third of the ladder.
    // If a future edit moves "siad" earlier, this test should stop it.
    const firstVerbalStep = SIT.steps.find((step) =>
      /„siad"|“sit”/.test(allText(step.pl) + allText(step.en))
    );
    expect(firstVerbalStep).toBeDefined();
    expect(firstVerbalStep!.ordinal).toBeGreaterThan(SIT.steps.length * 0.6);
  });

  it('orders the verbal cue before the hand signal, never after', () => {
    const cueStep = SIT.steps.find((step) => step.ordinal === 8);
    expect(cueStep).toBeDefined();
    // Word, pause, signal. The reverse order teaches the dog to ignore the word,
    // because the signal already predicts the reward.
    expect(allText(cueStep!.pl)).toMatch(/odczekaj|pauz/i);
    expect(allText(cueStep!.pl)).toMatch(/nigdy/i);
    expect(allText(cueStep!.en)).toMatch(/never/i);
  });

  it('makes the final steps pay only for the word alone', () => {
    // Step 9 is where the hand signal stops counting. Without this the dog
    // never actually learns the verbal cue, it just reads the hand.
    const step9 = SIT.steps.find((step) => step.ordinal === 9);
    expect(step9!.pl.criterion).toMatch(/pudł/i);
    expect(step9!.en.criterion).toMatch(/miss/i);
  });

  it('finishes by varying the handler, not just the dog', () => {
    // Dogs treat the handler's silhouette as part of the cue. A sit that only
    // works when you stand squarely in front is not a finished sit.
    const last = SIT.steps[SIT.steps.length - 1]!;
    expect(allText(last.pl)).toMatch(/pozycj|kucaj|krześl|bokiem/i);
    expect(allText(last.en)).toMatch(/posture|crouch|chair|sideways/i);
  });

  it('never tells the owner to push the dog into position', () => {
    // Pressure on the hips teaches a dog to brace against hands, which poisons
    // every later handling and grooming exercise.
    const everything = SIT.steps
      .flatMap((step) => [allText(step.pl), allText(step.en)])
      .join(' ')
      .toLowerCase();
    expect(everything).not.toMatch(/naciśnij|dociśnij|przyciśnij|wciśnij/);
    expect(everything).not.toMatch(/push (the )?(dog|puppy|rear|bottom)|press down/);
  });

  it('uses the Polish cue word the regulations and schools agree on', () => {
    // `siad` is unambiguous across ZKwP regulations and every Polish puppy
    // school. Unlike `waruj` / `leżeć` for the down, there is no dispute here.
    expect(SIT.names.pl.name).toBe('siad');
    expect(SIT.names.en.name).toBe('sit');
  });
});
