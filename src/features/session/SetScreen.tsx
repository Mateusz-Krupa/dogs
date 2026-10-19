import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { SET_SIZE, type RepOutcome } from '../../domain/verdict';
import { DogPose, type Pose } from '../../ui/DogPose';
import { t } from '../../i18n';
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
  readonly pose: Pose;
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
  pose,
  stepOrdinal,
  stepCount,
  stepInstruction,
  stepCriterion,
  state,
  onRecord,
  onUndo,
  onFinish,
}: SetScreenProps) {
  const full = state.reps.length >= SET_SIZE;
  const verdict = state.verdict;

  return (
    <View style={styles.screen}>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <StepRail count={stepCount} ordinal={stepOrdinal} />

        <View style={styles.card}>
          <View style={styles.art}>
            <DogPose accent={GREEN} color="#2f3a35" pose={pose} size={120} />
          </View>
          <Text style={styles.instruction}>{stepInstruction}</Text>
        </View>

        <View style={styles.criterion}>
          <Text style={styles.criterionLabel}>{t('session.criterionLabel').toUpperCase()}</Text>
          <Text style={styles.criterionText}>{stepCriterion}</Text>
        </View>
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
