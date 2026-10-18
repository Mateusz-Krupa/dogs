import { getLocales } from 'expo-localization';
import { I18n } from 'i18n-js';
import type { TranslateOptions } from 'i18n-js';

import { en } from './locales/en';
import { pl } from './locales/pl';

/** Every locale the app ships. */
export const SUPPORTED_LOCALES = ['pl', 'en'] as const;

/** Locale codes the app supports. */
export type SupportedLocale = (typeof SUPPORTED_LOCALES)[number];

/** Polish is the default and the fallback for any missing key. */
export const DEFAULT_LOCALE: SupportedLocale = 'pl';

/** True when a locale code is one the app ships. */
function isSupportedLocale(value: string): value is SupportedLocale {
  return (SUPPORTED_LOCALES as readonly string[]).includes(value);
}

/**
 * Picks the best supported locale for a list of preferred language tags
 * (e.g. from expo-localization). Matches on the primary subtag, so 'pl-PL'
 * resolves to 'pl' and 'en-GB' to 'en'. Falls back to DEFAULT_LOCALE when
 * nothing matches. Must not throw on empty or malformed input.
 */
export function resolveLocale(preferred: readonly string[]): SupportedLocale {
  for (const tag of preferred) {
    const primary = String(tag)
      .toLowerCase()
      .split('-')[0]
      ?.trim();
    if (primary !== undefined && primary !== '' && isSupportedLocale(primary)) {
      return primary;
    }
  }
  return DEFAULT_LOCALE;
}

/**
 * Device preferences as language tags, or an empty list when expo-localization
 * gives us nothing usable (native module missing, host not an Expo runtime).
 */
function devicePreferredTags(): string[] {
  try {
    const locales = getLocales();
    if (!Array.isArray(locales)) {
      return [];
    }
    return locales
      .map((locale) => locale?.languageTag)
      .filter((tag): tag is string => typeof tag === 'string' && tag !== '');
  } catch {
    return [];
  }
}

/** Locale taken from the device, resolved onto a supported one. */
let activeLocale: SupportedLocale = resolveLocale(devicePreferredTags());

/** The configured i18n-js instance. */
export const i18n: I18n = new I18n(
  { pl, en },
  {
    locale: activeLocale,
    defaultLocale: DEFAULT_LOCALE,
    enableFallback: true,
    // 'message' renders a visible `[missing "…" translation]` marker instead of
    // quietly guessing a label from the key name.
    missingBehavior: 'message',
  }
);

/** Translates a key. Thin typed wrapper over i18n.t. */
export function t(key: string, options?: Record<string, unknown>): string {
  return i18n.t<string>(key, options as TranslateOptions | undefined);
}

/** Changes the active locale. Throws RangeError for an unsupported locale. */
export function setLocale(locale: SupportedLocale): void {
  const candidate = String(locale);
  if (!isSupportedLocale(candidate)) {
    throw new RangeError(`Unsupported locale: ${candidate}`);
  }
  activeLocale = candidate;
  i18n.locale = candidate;
}

/** The currently active locale. */
export function getLocale(): SupportedLocale {
  return activeLocale;
}
