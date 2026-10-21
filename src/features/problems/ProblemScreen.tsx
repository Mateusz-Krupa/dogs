import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { exerciseById } from '../../content/catalogue';
import type { BehaviourIssue } from '../../content/behaviour';
import { hasProblemScene, ProblemScene } from '../../ui/ProblemScene';
import { getLocale, t } from '../../i18n';
import { SECTION_ORDER, sectionLines, sectionStyle, type SectionKind } from './problemSections';

const INK = '#14181a';
const MUTED = '#6b746e';
const GREEN = '#2e6f4e';
const BRICK = '#a8402c';
const BLUE = '#2a4a6b';
const SURFACE = '#ffffff';
const GROUND = '#f1f3ee';
const LINE = '#e3e7df';

export interface ProblemScreenProps {
  readonly issue: BehaviourIssue;
  /** Opens one of the exercises this problem recommends. */
  readonly onOpenExercise: (exerciseId: string) => void;
}

const SECTION_LABEL: Record<SectionKind, string> = {
  urgent: 'problems.stop',
  avoid: 'problems.dont',
  now: 'problems.now',
  work: 'problems.work',
};

const SECTION_ACCENT: Record<SectionKind, string> = {
  urgent: BRICK,
  avoid: BRICK,
  now: GREEN,
  work: MUTED,
};

/**
 * One behaviour problem, written for the moment of panic, not for study.
 *
 * The section order is not a style choice, it is the welfare rule of this
 * screen: the red-flag stop line comes before anything a person could start
 * doing, because an owner whose dog has bitten or is panicking must not be
 * handed a protocol on the way to the professional note at the bottom.
 * `problemSections` owns that order and the test suite pins it.
 *
 * The card opens with a scene pictogram: the dog, the trigger, and the one
 * spatial truth that matters — the distance to the tram, the door it bolts
 * through, the clock of an empty flat. Drawn in the same ink-and-green
 * language as the step diagrams, so a problem card and an exercise card feel
 * like one product.
 */
export function ProblemScreen({ issue, onOpenExercise }: ProblemScreenProps) {
  const locale = getLocale();
  const names = locale === 'en' ? issue.names.en : issue.names.pl;
  const recognizes = locale === 'en' ? issue.recognizes.en : issue.recognizes.pl;
  const professional = locale === 'en' ? issue.professional.en : issue.professional.pl;

  return (
    <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
      {hasProblemScene(issue.id) ? (
        <View style={styles.hero}>
          <ProblemScene id={issue.id} size={160} />
        </View>
      ) : null}
      <Text style={styles.name}>{names.name}</Text>
      <Text style={styles.tagline}>{names.tagline}</Text>
      <Text style={styles.recognizes}>{recognizes}</Text>

      {SECTION_ORDER.map((kind) => {
        const style = sectionStyle(kind);
        const lines = sectionLines(issue, kind, locale);
        if (style === 'stop') {
          return (
            <View key={kind} style={styles.urgent}>
              <Text style={styles.urgentLabel}>{t(SECTION_LABEL[kind]).toUpperCase()}</Text>
              <Text style={styles.urgentText}>{lines[0]}</Text>
            </View>
          );
        }
        if (style === 'steps') {
          return (
            <View key={kind} style={styles.block}>
              <Text style={[styles.blockLabel, { color: SECTION_ACCENT[kind] }]}>
                {t(SECTION_LABEL[kind]).toUpperCase()}
              </Text>
              {lines.map((line, i) => (
                <View key={line} style={styles.bulletRow}>
                  <Text style={styles.number}>{i + 1}</Text>
                  <Text style={styles.bulletText}>{line}</Text>
                </View>
              ))}
            </View>
          );
        }
        return (
          <View key={kind} style={styles.block}>
            <Text style={[styles.blockLabel, { color: SECTION_ACCENT[kind] }]}>
              {t(SECTION_LABEL[kind]).toUpperCase()}
            </Text>
            {lines.map((line) => (
              <View key={line} style={styles.bulletRow}>
                <Text style={[styles.bulletMark, { color: SECTION_ACCENT[kind] }]}>•</Text>
                <Text style={styles.bulletText}>{line}</Text>
              </View>
            ))}
          </View>
        );
      })}

      <Text style={styles.practicesLabel}>{t('problems.practices').toUpperCase()}</Text>
      <View style={styles.chipRow}>
        {issue.practices.map((exerciseId) => {
          const entry = exerciseById(exerciseId);
          if (!entry) return null;
          const cue = locale === 'en' ? entry.names.en.name : entry.names.pl.name;
          return (
            <Pressable
              accessibilityRole="button"
              key={exerciseId}
              onPress={() => onOpenExercise(exerciseId)}
              style={({ pressed }) => [styles.chip, pressed && styles.chipPressed]}
            >
              <Text style={styles.chipText}>{cue}</Text>
            </Pressable>
          );
        })}
      </View>

      <View style={styles.professional}>
        <Text style={styles.professionalLabel}>{t('problems.professional').toUpperCase()}</Text>
        <Text style={styles.professionalText}>{professional}</Text>
      </View>

      <Text style={styles.sudden}>{t('problems.sudden')}</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: {
    paddingHorizontal: 18,
    paddingTop: 10,
    paddingBottom: 40,
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
    gap: 12,
  },
  hero: {
    alignSelf: 'center',
    backgroundColor: SURFACE,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: LINE,
    paddingVertical: 10,
    paddingHorizontal: 14,
  },
  name: { fontSize: 24, fontWeight: '700', color: INK, letterSpacing: -0.3 },
  tagline: { fontSize: 15, color: MUTED, marginTop: -6 },
  recognizes: { fontSize: 15, lineHeight: 22, color: INK },

  urgent: {
    backgroundColor: '#f7e8e2',
    borderRadius: 12,
    borderLeftWidth: 3,
    borderLeftColor: BRICK,
    padding: 12,
    gap: 3,
  },
  urgentLabel: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1, color: BRICK },
  urgentText: { fontSize: 13.5, lineHeight: 20, color: '#5a2417' },

  block: {
    backgroundColor: SURFACE,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: LINE,
    padding: 13,
    gap: 7,
  },
  blockLabel: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1, color: MUTED },
  bulletRow: { flexDirection: 'row', gap: 10, alignItems: 'flex-start' },
  bulletMark: { fontSize: 15, lineHeight: 21, width: 14, textAlign: 'center' },
  number: {
    fontSize: 12,
    lineHeight: 21,
    fontWeight: '700',
    color: GREEN,
    width: 14,
    textAlign: 'center',
  },
  bulletText: { flex: 1, fontSize: 15, lineHeight: 21, color: INK },

  practicesLabel: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1, color: MUTED, marginTop: 2 },
  chipRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  chip: {
    minHeight: 44,
    borderRadius: 22,
    borderWidth: 1.5,
    borderColor: GREEN,
    paddingHorizontal: 15,
    justifyContent: 'center',
    backgroundColor: SURFACE,
  },
  chipPressed: { opacity: 0.75 },
  chipText: { fontSize: 14.5, fontWeight: '600', color: GREEN },

  professional: {
    backgroundColor: '#e7edf3',
    borderRadius: 12,
    borderLeftWidth: 3,
    borderLeftColor: BLUE,
    padding: 12,
    gap: 3,
  },
  professionalLabel: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1, color: BLUE },
  professionalText: { fontSize: 13.5, lineHeight: 20, color: '#24384a' },

  sudden: { fontSize: 12.5, lineHeight: 18, color: MUTED, marginTop: 2 },
});
