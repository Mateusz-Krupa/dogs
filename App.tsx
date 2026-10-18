import { useCallback, useReducer, useState } from 'react';
import { SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';

import { SIT } from './src/content/exercises/sit';
import { ENVIRONMENTS } from './src/content/environments';
import { getLocale } from './src/i18n';
import { initialSetState, setReducer } from './src/features/session/setMachine';
import { SetScreen } from './src/features/session/SetScreen';
import { nextStepIndex, type RepOutcome } from './src/domain/verdict';

/**
 * Temporary harness so the training loop can be seen end to end.
 *
 * Navigation, dog selection and persistence are not wired yet; this renders the
 * one screen that matters with real content, real reducer and real verdict
 * rules, so the loop can be exercised by hand.
 */
export default function App() {
  const [stepIndex, setStepIndex] = useState(0);
  const [state, dispatch] = useReducer(setReducer, undefined, initialSetState);

  const locale = getLocale();
  const step = SIT.steps[stepIndex]!;
  const text = locale === 'en' ? step.en : step.pl;
  const environment = ENVIRONMENTS[0]!;
  const environmentName = locale === 'en' ? environment.names.en : environment.names.pl;

  const record = useCallback((outcome: RepOutcome) => {
    dispatch({ type: 'record', outcome });
  }, []);

  /** Applies the verdict to the ladder position, then starts a fresh set. */
  const finish = useCallback(() => {
    if (state.verdict) {
      setStepIndex((current) => nextStepIndex(current, SIT.steps.length - 1, state.verdict!));
    }
    dispatch({ type: 'reset' });
  }, [state.verdict]);

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.context}>
        <Text style={styles.exercise}>
          {locale === 'en' ? SIT.names.en.name : SIT.names.pl.name}
        </Text>
        <Text style={styles.meta}>
          {environmentName} · {locale === 'en' ? 'step' : 'krok'} {step.ordinal}/{SIT.steps.length}
        </Text>
      </View>

      <SetScreen
        stepInstruction={text.instruction}
        stepCriterion={text.criterion}
        state={state}
        onRecord={record}
        onUndo={() => dispatch({ type: 'undo' })}
        onFinish={finish}
      />

      <StatusBar style="auto" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: '#f1f3ee',
  },
  context: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 4,
    gap: 2,
  },
  exercise: {
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 1.2,
    textTransform: 'uppercase',
    color: '#2e6f4e',
  },
  meta: {
    fontSize: 13,
    color: '#6b746e',
  },
});
