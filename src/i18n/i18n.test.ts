import { en } from './locales/en';
import { pl } from './locales/pl';
import { DEFAULT_LOCALE, getLocale, resolveLocale, setLocale, SUPPORTED_LOCALES, t } from './index';

jest.mock('expo-localization', () => ({
  getLocales: () => [{ languageTag: 'pl-PL', languageCode: 'pl', regionCode: 'PL' }],
}));

/** Flattens a nested catalogue into dotted paths mapped onto their leaf text. */
function flattenCatalogue(catalogue: Record<string, unknown>, prefix = ''): Record<string, string> {
  const flattened: Record<string, string> = {};
  for (const [key, value] of Object.entries(catalogue)) {
    const path = prefix === '' ? key : `${prefix}.${key}`;
    if (typeof value === 'string') {
      flattened[path] = value;
    } else if (typeof value === 'object' && value !== null) {
      Object.assign(flattened, flattenCatalogue(value as Record<string, unknown>, path));
    } else {
      flattened[path] = String(value);
    }
  }
  return flattened;
}

describe('resolveLocale', () => {
  it('matches on the primary subtag', () => {
    expect(resolveLocale(['pl-PL'])).toBe('pl');
    expect(resolveLocale(['en-GB', 'pl'])).toBe('en');
  });

  it('falls back to Polish for unsupported or empty input', () => {
    expect(resolveLocale(['de-DE'])).toBe('pl');
    expect(resolveLocale([])).toBe('pl');
  });

  it('tolerates malformed tags', () => {
    expect(resolveLocale([''])).toBe('pl');
    expect(resolveLocale(['-'])).toBe('pl');
    expect(resolveLocale(['nope--'])).toBe('pl');
  });

  it('ignores case', () => {
    expect(resolveLocale(['EN'])).toBe('en');
    expect(resolveLocale(['PL-pl'])).toBe('pl');
  });
});

describe('locale catalogues', () => {
  it('have exactly the same key shapes', () => {
    const polishKeys = Object.keys(flattenCatalogue(pl));
    const englishKeys = Object.keys(flattenCatalogue(en));

    const missingFromEnglish = polishKeys.filter((key) => !englishKeys.includes(key));
    const missingFromPolish = englishKeys.filter((key) => !polishKeys.includes(key));

    expect({ missingFromEnglish, missingFromPolish }).toEqual({
      missingFromEnglish: [],
      missingFromPolish: [],
    });
    expect(polishKeys.length).toBeGreaterThan(0);
  });

  it('never hold an empty string', () => {
    const emptyKeys = [
      ...Object.entries(flattenCatalogue(pl)),
      ...Object.entries(flattenCatalogue(en)),
    ]
      .filter(([, value]) => value.trim() === '')
      .map(([key]) => key);

    expect(emptyKeys).toEqual([]);
  });
});

describe('t', () => {
  afterEach(() => {
    setLocale(DEFAULT_LOCALE);
  });

  it('translates in the active locale', () => {
    setLocale(DEFAULT_LOCALE);
    expect(getLocale()).toBe('pl');
    expect(t('verdict.push.label')).toBe('Podnieś poprzeczkę');

    setLocale('en');
    expect(getLocale()).toBe('en');
    expect(t('verdict.push.label')).toBe('Push');
    expect(t('verdict.drop.explanation')).toBe(
      'Too hard. Go back a step — this is a correction, not a failure.'
    );
  });

  it('interpolates the rep counter', () => {
    const translated = t('session.repCounter', { done: 3, total: 5 });
    expect(translated).toContain('3');
    expect(translated).toContain('5');
    expect(translated).not.toContain('{{');
  });

  it('reports a missing key instead of returning nothing', () => {
    const translated = t('no.such.key.at.all');
    expect(typeof translated).toBe('string');
    expect(translated.length).toBeGreaterThan(0);
    expect(translated).toContain('no.such.key.at.all');
  });
});

describe('verdict copy encodes the rule, not just words', () => {
  afterEach(() => {
    setLocale(DEFAULT_LOCALE);
  });

  // These six strings are the only place the product's core rule reaches the
  // user. The threshold is five out of five — a widely-copied but wrong variant
  // says "four or five", so a reworded explanation that drops the five is a
  // real bug, not a copy tweak. Assert the meaning, not the exact wording.
  it.each(SUPPORTED_LOCALES)('states the five-of-five threshold in %s', (locale) => {
    setLocale(locale);
    const explanation = t('verdict.push.explanation').toLowerCase();
    const saysFive = /pięć na pięć|five out of five/.test(explanation);
    expect(saysFive).toBe(true);
  });

  it.each(SUPPORTED_LOCALES)('explains what a drop means in %s', (locale) => {
    setLocale(locale);
    // Tone is not regex-checkable — both catalogues legitimately contain the
    // word "failure" inside a negation ("not a failure"). All that is worth
    // asserting here is that the explanation is substantive.
    expect(t('verdict.drop.explanation').length).toBeGreaterThan(20);
  });
});

describe('setLocale', () => {
  afterEach(() => {
    setLocale(DEFAULT_LOCALE);
  });

  it('accepts every supported locale', () => {
    for (const locale of SUPPORTED_LOCALES) {
      expect(() => setLocale(locale)).not.toThrow();
      expect(getLocale()).toBe(locale);
    }
  });

  it('throws RangeError for an unsupported locale', () => {
    expect(() => setLocale('de' as (typeof SUPPORTED_LOCALES)[number])).toThrow(RangeError);
    expect(getLocale()).toBe(DEFAULT_LOCALE);
  });
});
