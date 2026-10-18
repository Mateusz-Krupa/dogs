import {
  Pressable,
  StyleSheet,
  Text,
  View,
  type StyleProp,
  type ViewStyle,
} from 'react-native';

import { SET_SIZE, type RepOutcome } from '../../domain/verdict';
import { t } from '../../i18n';
import type { SetState } from './setMachine';

/** Props of the training-set screen. All state and effects belong to the caller. */
export interface SetScreenProps {
  /** What the owner is working on right now, already localised by the caller. */
  readonly stepInstruction: string;
  /** What counts as a correct rep, already localised. */
  readonly stepCriterion: string;
  readonly state: SetState;
  readonly onRecord: (outcome: RepOutcome) => void;
  readonly onUndo: () => void;
  readonly onFinish: () => void;
}

/** Fill of a pip: green for a hit, muted grey for a miss or cancellation. */
function pipFill(outcome: RepOutcome | undefined): StyleProp<ViewStyle> {
  if (outcome === undefined) {
    return styles.pipEmpty;
  }
  return outcome === 'hit' ? styles.pipHit : styles.pipMiss;
}

/**
 * The screen used outdoors: five reps of one step, one large button per outcome.
 * Presentational only — it holds no state and decides nothing; the verdict comes
 * in through `state` and every interaction is reported to the caller.
 *
 * Touch targets are deliberately large because the screen is operated one-handed
 * while holding a lead, often without looking.
 */
export function SetScreen({
  stepInstruction,
  stepCriterion,
  state,
  onRecord,
  onUndo,
  onFinish,
}: SetScreenProps) {
  const complete = state.reps.length >= SET_SIZE;
  const verdict = state.verdict;

  return (
    <View style={styles.screen}>
      <View style={styles.header}>
        <Text style={styles.instruction}>{stepInstruction}</Text>
        <Text style={styles.criterion}>{stepCriterion}</Text>
      </View>

      <View style={styles.pipRow} accessible={false}>
        {Array.from({ length: SET_SIZE }, (_unused, index) => (
          <View
            key={index}
            style={[styles.pip, pipFill(state.reps[index])]}
          />
        ))}
      </View>

      <Text style={styles.progress}>
        {t('session.repCounter', { done: state.reps.length, total: SET_SIZE })}
      </Text>

      <View style={styles.spacer} />

      {verdict === null ? (
        <View style={styles.actions}>
          <Pressable
            accessibilityLabel={t('session.hit')}
            accessibilityRole="button"
            accessibilityState={{ disabled: complete }}
            disabled={complete}
            onPress={() => {
              onRecord('hit');
            }}
            style={({ pressed }) => [
              styles.actionButton,
              styles.hitButton,
              pressed && styles.pressed,
              complete && styles.disabled,
            ]}
          >
            <Text style={styles.actionLabel}>{t('session.hit')}</Text>
          </Pressable>

          <Pressable
            accessibilityLabel={t('session.miss')}
            accessibilityRole="button"
            accessibilityState={{ disabled: complete }}
            disabled={complete}
            onPress={() => {
              onRecord('miss');
            }}
            style={({ pressed }) => [
              styles.actionButton,
              styles.missButton,
              pressed && styles.pressed,
              complete && styles.disabled,
            ]}
          >
            <Text style={styles.actionLabel}>{t('session.miss')}</Text>
          </Pressable>
        </View>
      ) : (
        <View style={styles.verdictPanel}>
          <Text style={styles.verdictLabel}>{t(`verdict.${verdict}.label`)}</Text>
          <Text style={styles.verdictExplanation}>
            {t(`verdict.${verdict}.explanation`)}
          </Text>
          <Pressable
            accessibilityLabel={t('session.setComplete')}
            accessibilityRole="button"
            onPress={onFinish}
            style={({ pressed }) => [
              styles.actionButton,
              styles.finishButton,
              pressed && styles.pressed,
            ]}
          >
            <Text style={styles.actionLabel}>{t('session.setComplete')}</Text>
          </Pressable>
        </View>
      )}

      {state.reps.length > 0 ? (
        <Pressable
          accessibilityLabel={t('common.back')}
          accessibilityRole="button"
          onPress={onUndo}
          style={({ pressed }) => [styles.undo, pressed && styles.pressed]}
        >
          <Text style={styles.undoLabel}>{t('common.back')}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

/** Green of a recorded hit: the hit button and filled hit pips. */
const COLOR_HIT = '#2e6f4e';

/** Muted tone for misses, cancellations and low-emphasis text. */
const COLOR_MUTED = '#6b746e';

/** Screen background. */
const COLOR_BACKGROUND = '#f1f3ee';

/** Main text colour. */
const COLOR_TEXT = '#14181a';

/** Borders and empty pips. */
const COLOR_OUTLINE = '#dce0d7';

/** Labels drawn on a filled button. */
const COLOR_ON_COLOR = '#ffffff';

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: COLOR_BACKGROUND,
    paddingHorizontal: 24,
    paddingTop: 24,
    paddingBottom: 16,
  },
  header: {
    gap: 6,
  },
  instruction: {
    fontSize: 24,
    fontWeight: '700',
    color: COLOR_TEXT,
  },
  criterion: {
    fontSize: 15,
    color: COLOR_MUTED,
  },
  pipRow: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 24,
  },
  pip: {
    width: 44,
    height: 44,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: COLOR_OUTLINE,
  },
  pipHit: {
    backgroundColor: COLOR_HIT,
    borderColor: COLOR_HIT,
  },
  pipMiss: {
    backgroundColor: COLOR_MUTED,
    borderColor: COLOR_MUTED,
  },
  pipEmpty: {
    backgroundColor: 'transparent',
  },
  progress: {
    marginTop: 12,
    fontSize: 15,
    color: COLOR_MUTED,
  },
  spacer: {
    flex: 1,
  },
  actions: {
    gap: 12,
  },
  actionButton: {
    minHeight: 64,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 16,
  },
  hitButton: {
    backgroundColor: COLOR_HIT,
  },
  missButton: {
    backgroundColor: COLOR_MUTED,
  },
  finishButton: {
    backgroundColor: COLOR_HIT,
    marginTop: 12,
  },
  actionLabel: {
    fontSize: 20,
    fontWeight: '700',
    color: COLOR_ON_COLOR,
  },
  pressed: {
    opacity: 0.85,
  },
  disabled: {
    opacity: 0.4,
  },
  verdictPanel: {
    backgroundColor: COLOR_BACKGROUND,
    borderWidth: 1,
    borderColor: COLOR_OUTLINE,
    borderRadius: 12,
    padding: 16,
    gap: 6,
  },
  verdictLabel: {
    fontSize: 22,
    fontWeight: '700',
    color: COLOR_TEXT,
  },
  verdictExplanation: {
    fontSize: 15,
    color: COLOR_MUTED,
  },
  undo: {
    minHeight: 44,
    alignSelf: 'center',
    justifyContent: 'center',
    paddingHorizontal: 16,
    marginTop: 8,
  },
  undoLabel: {
    fontSize: 15,
    color: COLOR_MUTED,
  },
});
