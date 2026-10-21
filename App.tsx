import { useCallback, useReducer, useState } from 'react';
import { Pressable, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';

import { CATALOGUE, exerciseById } from './src/content/catalogue';
import { behaviourById } from './src/content/behaviour';
import { ENVIRONMENTS, STARTING_ENVIRONMENT_ID } from './src/content/environments';
import { mistakesFor } from './src/content/mistakes';
import { noseworkById } from './src/content/nosework';
import { NoseworkScreen } from './src/features/nosework/NoseworkScreen';
import { ExerciseList, type ExerciseProgress } from './src/features/catalogue/ExerciseList';
import { ProblemScreen } from './src/features/problems/ProblemScreen';
import { SetScreen } from './src/features/session/SetScreen';
import { getLocale, t } from './src/i18n';
import { initialSetState, setReducer } from './src/features/session/setMachine';
import { type RepOutcome } from './src/domain/verdict';
import { move, nextEnvironment, previousEnvironment } from './src/domain/progression';

/**
 * Temporary shell until navigation and persistence land.
 *
 * Deliberately: after a set the app *offers* a next step and never takes it.
 * Applying the verdict automatically would decide for the owner, which is the
 * one thing this product promised not to do.
 */
export default function App() {
  const [openId, setOpenId] = useState<string | null>(null);
  const [openNoseId, setOpenNoseId] = useState<string | null>(null);
  const [openProblemId, setOpenProblemId] = useState<string | null>(null);
  const [progress, setProgress] = useState<Record<string, ExerciseProgress>>({});
  const [nosework, setNosework] = useState<Record<string, number>>({});
  const [placeChange, setPlaceChange] = useState<'harder' | 'easier' | null>(null);
  const [state, dispatch] = useReducer(setReducer, undefined, initialSetState);

  const locale = getLocale();
  const entry = openId ? exerciseById(openId) : undefined;
  const activity = openNoseId ? noseworkById(openNoseId) : undefined;
  const problem = openProblemId ? behaviourById(openProblemId) : undefined;

  const open = useCallback((id: string) => {
    setPlaceChange(null);
    setOpenId(id);
    setOpenNoseId(null);
    setOpenProblemId(null);
    dispatch({ type: 'reset' });
  }, []);

  const openNose = useCallback((id: string) => {
    setOpenNoseId(id);
    setOpenId(null);
    setOpenProblemId(null);
  }, []);

  const openProblem = useCallback((id: string) => {
    setOpenProblemId(id);
    setOpenId(null);
    setOpenNoseId(null);
  }, []);

  const close = useCallback(() => {
    setOpenId(null);
    setOpenNoseId(null);
    setOpenProblemId(null);
    dispatch({ type: 'reset' });
  }, []);

  const record = useCallback((outcome: RepOutcome) => {
    dispatch({ type: 'record', outcome });
  }, []);

  /**
   * Applies a move along whichever axis it belongs to, then starts a fresh set.
   * The rules live in `domain/progression`, not here — this only stores the
   * result, so the UI cannot quietly invent a different progression.
   */
  const goTo = useCallback(
    (delta: -1 | 0 | 1) => {
      if (!entry) return;
      setProgress((current) => {
        const here = current[entry.id] ?? {
          stepOrdinal: 1,
          environmentId: STARTING_ENVIRONMENT_ID,
        };
        const after = move(here, entry.steps.length, delta);
        setPlaceChange(
          after.environmentId === here.environmentId ? null : delta === 1 ? 'harder' : 'easier'
        );
        return { ...current, [entry.id]: after };
      });
      dispatch({ type: 'reset' });
    },
    [entry]
  );

  if (activity) {
    return (
      <SafeAreaView style={styles.safe}>
        <View style={styles.bar}>
          <Pressable accessibilityRole="button" onPress={close} style={styles.barBack}>
            <Text style={styles.barBackText}>
              {t('common.allExercises')}
            </Text>
          </Pressable>
        </View>
        <NoseworkScreen
          activity={activity}
          levelDone={nosework[activity.id] ?? 0}
          onDone={(ordinal) => {
            setNosework((current) => ({
              ...current,
              [activity.id]: Math.max(current[activity.id] ?? 0, ordinal),
            }));
            close();
          }}
        />
        <StatusBar style="auto" />
      </SafeAreaView>
    );
  }

  if (problem) {
    return (
      <SafeAreaView style={styles.safe}>
        <View style={styles.bar}>
          <Pressable accessibilityRole="button" onPress={close} style={styles.barBack}>
            <Text style={styles.barBackText}>
              {t('common.allExercises')}
            </Text>
          </Pressable>
        </View>
        <ProblemScreen issue={problem} onOpenExercise={open} />
        <StatusBar style="auto" />
      </SafeAreaView>
    );
  }

  if (!entry) {
    const firstUntouched = CATALOGUE.find((candidate) => progress[candidate.id] === undefined);
    return (
      <SafeAreaView style={styles.safe}>
        <ExerciseList
          dogName={locale === 'en' ? 'Your dog' : 'Twój pies'}
          noseworkProgress={nosework}
          onOpen={open}
          onOpenNosework={openNose}
          onOpenProblem={openProblem}
          progress={progress}
          recommendedId={firstUntouched?.id ?? CATALOGUE[0]!.id}
        />
        <StatusBar style="auto" />
      </SafeAreaView>
    );
  }

  const current = progress[entry.id];
  const stepOrdinal = current?.stepOrdinal ?? 1;
  const step = entry.steps[stepOrdinal - 1]!;
  const text = locale === 'en' ? step.en : step.pl;
  const names = locale === 'en' ? entry.names.en : entry.names.pl;
  const environment = ENVIRONMENTS.find(
    (rung) => rung.id === (current?.environmentId ?? STARTING_ENVIRONMENT_ID)
  )!;
  const environmentName = locale === 'en' ? environment.names.en : environment.names.pl;

  const canAdvance = stepOrdinal < entry.steps.length;
  const canGoBack = stepOrdinal > 1;

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.bar}>
        <Pressable accessibilityRole="button" onPress={close} style={styles.barBack}>
          <Text style={styles.barBackText}>{t('common.allExercises')}</Text>
        </Pressable>
        <Text style={styles.barTitle}>{names.name}</Text>
        <Text style={styles.barMeta}>
          {environmentName} · {locale === 'en' ? 'step' : 'krok'} {stepOrdinal}/{entry.steps.length}
        </Text>
      </View>

      <SetScreen
        description={names.description}
        exerciseId={entry.id}
        gear={entry.gear}
        mistakes={mistakesFor(entry.id)}
        canGoEasierPlace={previousEnvironment(environment.id) !== undefined}
        placeChange={placeChange}
        canGoHarderPlace={nextEnvironment(environment.id) !== undefined}
        onChoose={goTo}
        onRecord={record}
        onUndo={() => dispatch({ type: 'undo' })}
        pose={entry.pose}
        state={state}
        stepCount={entry.steps.length}
        stepCriterion={text.criterion}
        stepInstruction={text.instruction}
        stepMotion={step.motion}
        stepNote={text.note}
        stepPose={step.pose}
        stepReps={text.reps}
        stepSetup={text.setup}
        stepSound={step.sound}
        stepOrdinal={stepOrdinal}
      />


      <StatusBar style="auto" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#f1f3ee' },
  bar: {
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
    paddingHorizontal: 18,
    paddingTop: 12,
    paddingBottom: 6,
    gap: 2,
  },
  barBack: { minHeight: 32, justifyContent: 'center' },
  barBackText: { fontSize: 14, color: '#2e6f4e', fontWeight: '600' },
  barTitle: { fontSize: 22, fontWeight: '700', color: '#14181a', letterSpacing: -0.3 },
  barMeta: { fontSize: 13, color: '#6b746e' },
  choices: {
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
    paddingHorizontal: 18,
    paddingBottom: 16,
    gap: 8,
  },
  choicesLabel: { fontSize: 12, color: '#6b746e' },
  choiceRow: { flexDirection: 'row', gap: 8 },
  choice: {
    flex: 1,
    minHeight: 52,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#dce0d7',
    backgroundColor: '#ffffff',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 8,
  },
  choicePrimary: { backgroundColor: '#2e6f4e', borderColor: '#2e6f4e' },
  choiceText: { fontSize: 14, fontWeight: '600', color: '#14181a', textAlign: 'center' },
  choicePrimaryText: { color: '#ffffff' },
});
