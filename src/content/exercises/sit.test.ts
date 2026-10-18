import { SIT } from './sit';

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
      /„siad"|“sit”/.test(step.pl.instruction + step.en.instruction)
    );
    expect(firstVerbalStep).toBeDefined();
    expect(firstVerbalStep!.ordinal).toBeGreaterThan(SIT.steps.length * 0.6);
  });

  it('orders the verbal cue before the hand signal, never after', () => {
    const cueStep = SIT.steps.find((step) => step.ordinal === 8);
    expect(cueStep).toBeDefined();
    // Word, pause, signal. The reverse order teaches the dog to ignore the word,
    // because the signal already predicts the reward.
    expect(cueStep!.pl.instruction).toMatch(/odczekaj|pauz/i);
    expect(cueStep!.pl.instruction).toMatch(/nigdy/i);
    expect(cueStep!.en.instruction).toMatch(/never/i);
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
    expect(last.pl.instruction).toMatch(/pozycj|kucaj|krześl|bokiem/i);
    expect(last.en.instruction).toMatch(/posture|crouch|chair|sideways/i);
  });

  it('never tells the owner to push the dog into position', () => {
    // Pressure on the hips teaches a dog to brace against hands, which poisons
    // every later handling and grooming exercise.
    const everything = SIT.steps
      .flatMap((step) => [step.pl.instruction, step.pl.criterion, step.en.instruction, step.en.criterion])
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
