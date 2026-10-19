import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { useState } from 'react';

import { SET_SIZE, type RepOutcome } from '../../domain/verdict';
import type { Mistake } from '../../content/mistakes';
import { HandMotion, MOTION_BY_EXERCISE } from '../../ui/HandMotion';
import type { Pose } from '../../ui/DogPose';
import { getLocale, t } from '../../i18n';
import type { SetState } from './setMachine';

const INK = '#14181a';
const MUTED = '#6b746e';
const GREEN = '#2e6f4e';
const AMBER = '#91661a';
const BRICK = '#a8402c';
const SURFACE = '#ffffff';
const GROUND = '#f1f3ee';
const LINE = '#e3e7df';

export interface SetScreenProps {
  readonly exerciseId: string;
  readonly pose: Pose;
  /** The full description, shown under the step. Localised by the caller. */
  readonly description: string;
  readonly mistakes: readonly Mistake[];
  readonly stepOrdinal: number;
  readonly stepCount: number;
  /** Localised by the caller. */
  readonly stepInstruction: string;
  /** What counts as a correct rep. Localised by the caller. */
  readonly stepCriterion: string;
  readonly state: SetState;
  readonly onRecord: (outcome: RepOutcome) => void;
  readonly onUndo: () => void;
  readonly onFinish: () => void;
}

const VERDICT_COLOR = { push: GREEN, stick: AMBER, drop: BRICK } as const;

/** A segment per step, so the owner can see how far into the exercise they are. */
function StepRail({ ordinal, count }: { ordinal: number; count: number }) {
  return (
    <View accessibilityLabel={`${ordinal}/${count}`} style={styles.rail}>
      {Array.from({ length: count }, (_, i) => (
        <View key={i} style={[styles.railSeg, i < ordinal && styles.railSegDone]} />
      ))}
    </View>
  );
}

/**
 * The set screen: the one view used outdoors, one-handed, on a lead.
 *
 * Everything the thumb needs sits at the bottom and never moves; everything the
 * eye needs sits above it. The criterion gets its own block rather than a
 * caption, because it is the rule the owner scores against — if it reads as a
 * footnote, the scores stop meaning anything.
 */
export function SetScreen({
  exerciseId,
  pose,
  description,
  mistakes,
  stepOrdinal,
  stepCount,
  stepInstruction,
  stepCriterion,
  state,
  onRecord,
  onUndo,
  onFinish,
}: SetScreenProps) {
  const [openMistake, setOpenMistake] = useState<number | null>(null);
  const [showAbout, setShowAbout] = useState(false);
  const full = state.reps.length >= SET_SIZE;
  const verdict = state.verdict;
  const locale = getLocale();
  const motion = MOTION_BY_EXERCISE[exerciseId] ?? 'lure-up';

  return (
    <View style={styles.screen}>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <StepRail count={stepCount} ordinal={stepOrdinal} />

        <View style={styles.card}>
          <View style={styles.art}>
            <HandMotion motion={motion} pose={pose} size={148} />
          </View>
          <Text style={styles.instruction}>{stepInstruction}</Text>
        </View>

        <View style={styles.criterion}>
          <Text style={styles.criterionLabel}>{t('session.criterionLabel').toUpperCase()}</Text>
          <Text style={styles.criterionText}>{stepCriterion}</Text>
        </View>

        <Pressable
          accessibilityRole="button"
          onPress={() => setShowAbout((open) => !open)}
          style={styles.disclosure}
        >
          <Text style={styles.disclosureTitle}>
            {locale === 'en' ? 'About this exercise' : 'O tym ćwiczeniu'}
          </Text>
          <Text style={styles.chevron}>{showAbout ? '−' : '+'}</Text>
        </Pressable>
        {showAbout ? <Text style={styles.about}>{description}</Text> : null}

        {mistakes.length > 0 ? (
          <View style={styles.mistakes}>
            <Text style={styles.mistakesTitle}>
              {locale === 'en' ? 'When it is not working' : 'Gdy coś nie idzie'}
            </Text>
            {mistakes.map((mistake, i) => {
              const copy = locale === 'en' ? mistake.en : mistake.pl;
              const open = openMistake === i;
              return (
                <View key={copy.symptom} style={styles.mistake}>
                  <Pressable
                    accessibilityRole="button"
                    onPress={() => setOpenMistake(open ? null : i)}
                    style={styles.mistakeHead}
                  >
                    <Text style={styles.mistakeSymptom}>{copy.symptom}</Text>
                    <Text style={styles.chevron}>{open ? '−' : '+'}</Text>
                  </Pressable>
                  {open ? (
                    <View style={styles.mistakeBody}>
                      <Text style={styles.mistakeWhy}>{copy.why}</Text>
                      <View style={styles.fix}>
                        <Text style={styles.fixLabel}>
                          {locale === 'en' ? 'TRY THIS' : 'SPRÓBUJ TAK'}
                        </Text>
                        <Text style={styles.fixText}>{copy.fix}</Text>
                      </View>
                    </View>
                  ) : null}
                </View>
              );
            })}
          </View>
        ) : null}
      </ScrollView>

      <View style={styles.dock}>
        <View style={styles.pips}>
          {Array.from({ length: SET_SIZE }, (_, i) => {
            const outcome = state.reps[i];
            return (
              <View
                key={i}
                style={[
                  styles.pip,
                  outcome === 'hit' && styles.pipHit,
                  (outcome === 'miss' || outcome === 'cancelled') && styles.pipMiss,
                ]}
              />
            );
          })}
          <Text style={styles.pipCount}>
            {t('session.repCounter', { done: state.reps.length, total: SET_SIZE })}
          </Text>
        </View>

        {verdict ? (
          <View style={[styles.verdict, { borderColor: VERDICT_COLOR[verdict] }]}>
            <Text style={[styles.verdictLabel, { color: VERDICT_COLOR[verdict] }]}>
              {t(`verdict.${verdict}.label`)}
            </Text>
            <Text style={styles.verdictText}>{t(`verdict.${verdict}.explanation`)}</Text>
            <Pressable
              accessibilityLabel={t('session.setComplete')}
              accessibilityRole="button"
              onPress={onFinish}
              style={({ pressed }) => [styles.primary, pressed && styles.pressed]}
            >
              <Text style={styles.primaryLabel}>{t('session.setComplete')}</Text>
            </Pressable>
          </View>
        ) : (
          <View style={styles.actions}>
            <Pressable
              accessibilityLabel={t('session.hit')}
              accessibilityRole="button"
              disabled={full}
              onPress={() => onRecord('hit')}
              style={({ pressed }) => [styles.hit, full && styles.disabled, pressed && styles.pressed]}
            >
              <Text style={styles.hitLabel}>{t('session.hit')}</Text>
            </Pressable>
            <Pressable
              accessibilityLabel={t('session.miss')}
              accessibilityRole="button"
              disabled={full}
              onPress={() => onRecord('miss')}
              style={({ pressed }) => [styles.miss, full && styles.disabled, pressed && styles.pressed]}
            >
              <Text style={styles.missLabel}>{t('session.miss')}</Text>
            </Pressable>
          </View>
        )}

        {/* Keeps its space always: a control that appears after the first tap
            would shift the buttons under a thumb that is not looking. */}
        <Pressable
          accessibilityElementsHidden={state.reps.length === 0}
          accessibilityLabel={t('common.back')}
          accessibilityRole="button"
          disabled={state.reps.length === 0}
          onPress={onUndo}
          style={({ pressed }) => [
            styles.undo,
            state.reps.length === 0 && styles.undoHidden,
            pressed && styles.pressed,
          ]}
        >
          <Text style={styles.undoLabel}>↺ {t('common.back')}</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: GROUND },
  scroll: {
    paddingHorizontal: 18,
    paddingTop: 8,
    paddingBottom: 16,
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
    gap: 14,
  },

  rail: { flexDirection: 'row', gap: 4, marginTop: 4 },
  railSeg: { flex: 1, height: 6, borderRadius: 3, backgroundColor: '#ccd4ca' },
  railSegDone: { backgroundColor: GREEN },

  card: {
    backgroundColor: SURFACE,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: LINE,
    padding: 18,
    alignItems: 'center',
    gap: 10,
  },
  art: { alignItems: 'center', justifyContent: 'center' },
  instruction: { fontSize: 17, lineHeight: 25, color: INK, textAlign: 'center' },

  criterion: {
    borderLeftWidth: 3,
    borderLeftColor: GREEN,
    backgroundColor: '#e8f0ea',
    borderRadius: 10,
    paddingVertical: 10,
    paddingHorizontal: 13,
    gap: 3,
  },
  criterionLabel: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1, color: GREEN },
  criterionText: { fontSize: 14, lineHeight: 20, color: '#294036' },

  disclosure: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    minHeight: 44,
  },
  disclosureTitle: { fontSize: 14, fontWeight: '600', color: MUTED },
  chevron: { fontSize: 20, color: MUTED, paddingHorizontal: 6 },
  about: { fontSize: 14, lineHeight: 21, color: MUTED, marginTop: -4 },

  mistakes: { gap: 8, marginTop: 2 },
  mistakesTitle: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.1,
    textTransform: 'uppercase',
    color: AMBER,
  },
  mistake: {
    backgroundColor: SURFACE,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: LINE,
    overflow: 'hidden',
  },
  mistakeHead: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 11,
    paddingHorizontal: 13,
    minHeight: 46,
    gap: 8,
  },
  mistakeSymptom: { flex: 1, fontSize: 14, fontWeight: '600', color: INK, lineHeight: 19 },
  mistakeBody: { paddingHorizontal: 13, paddingBottom: 13, gap: 9 },
  mistakeWhy: { fontSize: 13.5, lineHeight: 20, color: MUTED },
  fix: {
    backgroundColor: '#f6f1e4',
    borderRadius: 9,
    padding: 10,
    gap: 3,
  },
  fixLabel: { fontSize: 9.5, fontWeight: '700', letterSpacing: 1, color: AMBER },
  fixText: { fontSize: 13.5, lineHeight: 20, color: '#4a3c1d' },

  dock: {
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
    paddingHorizontal: 18,
    paddingBottom: 10,
    gap: 10,
  },
  pips: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  pip: {
    width: 30,
    height: 30,
    borderRadius: 9,
    borderWidth: 2,
    borderColor: '#d5dbd1',
    backgroundColor: 'transparent',
  },
  pipHit: { backgroundColor: GREEN, borderColor: GREEN },
  pipMiss: { backgroundColor: '#c7cdc4', borderColor: '#c7cdc4' },
  pipCount: { marginLeft: 'auto', fontSize: 13, color: MUTED },

  actions: { gap: 10 },
  hit: {
    minHeight: 66,
    borderRadius: 16,
    backgroundColor: GREEN,
    alignItems: 'center',
    justifyContent: 'center',
  },
  hitLabel: { fontSize: 19, fontWeight: '700', color: '#ffffff' },
  miss: {
    minHeight: 58,
    borderRadius: 16,
    backgroundColor: SURFACE,
    borderWidth: 2,
    borderColor: '#d5dbd1',
    alignItems: 'center',
    justifyContent: 'center',
  },
  missLabel: { fontSize: 17, fontWeight: '600', color: MUTED },
  disabled: { opacity: 0.4 },
  pressed: { opacity: 0.75 },

  verdict: {
    borderWidth: 2,
    borderRadius: 16,
    backgroundColor: SURFACE,
    padding: 14,
    gap: 6,
  },
  verdictLabel: { fontSize: 20, fontWeight: '700' },
  verdictText: { fontSize: 14, lineHeight: 20, color: MUTED },
  primary: {
    marginTop: 6,
    minHeight: 54,
    borderRadius: 14,
    backgroundColor: INK,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryLabel: { fontSize: 16, fontWeight: '700', color: '#ffffff' },

  undo: { minHeight: 40, alignSelf: 'center', justifyContent: 'center', paddingHorizontal: 16 },
  undoHidden: { opacity: 0 },
  undoLabel: { fontSize: 14, color: MUTED },
});
