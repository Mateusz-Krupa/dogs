/**
 * Validation tests for behaviour-problem files.
 *
 * Every section of a card is load-bearing — a card without `avoid` defaults
 * the owner to punishment, a card without `professional` hides the welfare
 * line — so the tests guard their presence and their both-locale shape, not
 * their wording.
 */

import { parseBehaviourIssue } from '../schema';

function issueFixture(override: Record<string, unknown> = {}): unknown {
  return {
    id: 'bark-door',
    sortOrder: 1,
    names: {
      pl: { name: 'Szczekanie na dzwonek', tagline: 'Drzwi to fajerwerki' },
      en: { name: 'Doorbell barking', tagline: 'The door is a firework' },
    },
    recognizes: { pl: 'Pies eksploduje na dzwonek.', en: 'The dog explodes at the bell.' },
    urgent: {
      pl: 'Jeśli pies kogokolwiek ugryzł — trening zatrzymuje się u behawiorysty.',
      en: 'If the dog has bitten anyone, the training stops at a behaviourist.',
    },
    avoid: {
      pl: ['Nie krzycz „cicho\" — to szczekanie razem z psem.'],
      en: ['Do not shout “quiet” — that is barking along with the dog.'],
    },
    now: {
      pl: ['Rzuć smakołyki na podłogę z dala od drzwi.'],
      en: ['Scatter treats on the floor away from the door.'],
    },
    work: {
      pl: ['Nagraj dzwonek i odtwarzaj cicho.'],
      en: ['Record the bell and play it quietly.'],
    },
    professional: {
      pl: 'Ugryzienia — behawiorysta.',
      en: 'Bites — a behaviourist.',
    },
    practices: ['mat', 'sit'],
    ...override,
  };
}

describe('behaviour cards', () => {
  it('accept a well-formed card', () => {
    expect(() => parseBehaviourIssue(issueFixture(), 'bark-door.json')).not.toThrow();
    const issue = parseBehaviourIssue(issueFixture(), 'bark-door.json');
    expect(issue.practices).toEqual(['mat', 'sit']);
    expect(issue.avoid.pl).toHaveLength(1);
  });

  it('reject a card with no avoid list, naming the field', () => {
    const broken = issueFixture({ avoid: undefined }) as Record<string, unknown>;
    delete broken.avoid;
    expect(() => parseBehaviourIssue(broken, 'bark-door.json')).toThrow(/avoid/);
  });

  it('reject an empty work list — a header with no steps', () => {
    expect(() =>
      parseBehaviourIssue(issueFixture({ work: { pl: [], en: [] } }), 'bark-door.json'),
    ).toThrow(/work/);
  });

  it('reject a card that points at no exercises', () => {
    expect(() =>
      parseBehaviourIssue(issueFixture({ practices: [] }), 'bark-door.json'),
    ).toThrow(/practices/);
  });

  it('reject a card with no red-flag stop line', () => {
    const broken = issueFixture({ urgent: undefined }) as Record<string, unknown>;
    delete broken.urgent;
    expect(() => parseBehaviourIssue(broken, 'bark-door.json')).toThrow(/urgent/);
  });

  it('reject a card that is missing its welfare line', () => {
    const broken = issueFixture({ professional: undefined }) as Record<string, unknown>;
    delete broken.professional;
    expect(() => parseBehaviourIssue(broken, 'bark-door.json')).toThrow(/professional/);
  });

  it('reject a half-translated card', () => {
    expect(() =>
      parseBehaviourIssue(
        issueFixture({ recognizes: { pl: 'Tylko po polsku.' } }),
        'bark-door.json',
      ),
    ).toThrow(/recognizes/);
  });
});
