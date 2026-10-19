import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { CATALOGUE, type CatalogueEntry } from '../../content/catalogue';
import { ENVIRONMENTS } from '../../content/environments';
import { NOSEWORK } from '../../content/nosework';
import { DogPose } from '../../ui/DogPose';
import { getLocale, t } from '../../i18n';

const INK = '#14181a';
const MUTED = '#6b746e';
const GREEN = '#2e6f4e';
const SURFACE = '#ffffff';
const GROUND = '#f1f3ee';
const LINE = '#e3e7df';
const BLUE = '#2a4a6b';

/** Where a dog is on one exercise. Absent means never trained. */
export interface ExerciseProgress {
  readonly stepOrdinal: number;
  readonly environmentId: string;
}

export interface ExerciseListProps {
  readonly dogName: string;
  /** Keyed by exercise id. */
  readonly progress: Readonly<Record<string, ExerciseProgress>>;
  /** Highest nosework level reached, keyed by activity id. */
  readonly noseworkProgress: Readonly<Record<string, number>>;
  /** Exercise the app suggests working on next. */
  readonly recommendedId: string;
  readonly onOpen: (exerciseId: string) => void;
  readonly onOpenNosework: (activityId: string) => void;
}

/** Prerequisites that are not yet started, for the advisory note. */
function unmetPrerequisites(
  entry: CatalogueEntry,
  progress: Readonly<Record<string, ExerciseProgress>>
): string[] {
  const locale = getLocale();
  return entry.requires
    .filter((id) => progress[id] === undefined)
    .map((id) => {
      const required = CATALOGUE.find((candidate) => candidate.id === id);
      if (!required) return id;
      return locale === 'en' ? required.names.en.name : required.names.pl.name;
    });
}

function ExerciseCard({
  entry,
  progress,
  allProgress,
  recommended,
  onOpen,
}: {
  entry: CatalogueEntry;
  progress: ExerciseProgress | undefined;
  allProgress: Readonly<Record<string, ExerciseProgress>>;
  recommended: boolean;
  onOpen: () => void;
}) {
  const locale = getLocale();
  const names = locale === 'en' ? entry.names.en : entry.names.pl;
  const missing = unmetPrerequisites(entry, allProgress);
  const environment = progress
    ? ENVIRONMENTS.find((rung) => rung.id === progress.environmentId)
    : undefined;
  const environmentName = environment
    ? locale === 'en'
      ? environment.names.en
      : environment.names.pl
    : undefined;

  const done = progress ? progress.stepOrdinal - 1 : 0;
  const pct = Math.max(0, Math.min(1, done / entry.steps.length));

  return (
    <Pressable
      accessibilityHint={names.description}
      accessibilityLabel={names.name}
      accessibilityRole="button"
      onPress={onOpen}
      style={({ pressed }) => [styles.card, recommended && styles.cardRecommended, pressed && styles.cardPressed]}
    >
      <View style={styles.art}>
        <DogPose accent={GREEN} color={recommended ? '#2f3a35' : '#6f7a74'} pose={entry.pose} size={72} />
      </View>

      <View style={styles.body}>
        <View style={styles.titleRow}>
          <Text style={styles.name}>{names.name}</Text>
          {recommended ? (
            <View style={styles.chip}>
              <Text style={styles.chipText}>{locale === 'en' ? 'next up' : 'na teraz'}</Text>
            </View>
          ) : null}
        </View>

        <Text numberOfLines={1} style={styles.tagline}>
          {locale === 'en' ? entry.tagline.en : entry.tagline.pl}
        </Text>

        {/* A zero-length bar reads as a stray rule across the card, so an
            untouched exercise shows its step count instead of empty track. */}
        {progress ? (
          <View style={styles.track}>
            <View style={[styles.trackFill, { width: `${Math.max(pct, 0.06) * 100}%` }]} />
          </View>
        ) : null}

        <Text style={styles.meta}>
          {progress
            ? `${locale === 'en' ? 'Step' : 'Krok'} ${progress.stepOrdinal} / ${entry.steps.length}${
                environmentName ? ` · ${environmentName}` : ''
              }`
            : `${entry.steps.length} ${locale === 'en' ? 'steps' : 'kroków'}`}
        </Text>

        {missing.length > 0 ? (
          <Text style={styles.hint}>
            {locale === 'en'
              ? `Goes easier once ${missing.join(' and ')} is solid — but go ahead if you like.`
              : `Łatwiej pójdzie, gdy ${missing.join(' i ')} będzie pewne — ale możesz zacząć od razu.`}
          </Text>
        ) : null}
      </View>
    </Pressable>
  );
}

/** The browsable curriculum: every exercise, always openable. */
export function ExerciseList({
  dogName,
  progress,
  noseworkProgress,
  recommendedId,
  onOpen,
  onOpenNosework,
}: ExerciseListProps) {
  const locale = getLocale();

  return (
    <ScrollView contentContainerStyle={styles.scroll} style={styles.screen}>
      <Text style={styles.eyebrow}>{locale === 'en' ? 'Training plan' : 'Plan treningu'}</Text>
      <Text style={styles.heading}>{dogName}</Text>
      <Text style={styles.sub}>
        {locale === 'en'
          ? 'Everything is open. The order is a suggestion, not a gate.'
          : 'Wszystko jest otwarte. Kolejność to podpowiedź, nie zamek.'}
      </Text>

      <View style={styles.list}>
        {CATALOGUE.map((entry) => (
          <ExerciseCard
            allProgress={progress}
            entry={entry}
            key={entry.id}
            onOpen={() => onOpen(entry.id)}
            progress={progress[entry.id]}
            recommended={entry.id === recommendedId}
          />
        ))}
      </View>

      <View style={styles.sectionHead}>
        <Text style={styles.sectionTitle}>{t('nosework.title')}</Text>
        <Text style={styles.sectionSub}>{t('nosework.subtitle')}</Text>
      </View>

      <View style={styles.list}>
        {NOSEWORK.map((activity) => {
          const names = locale === 'en' ? activity.names.en : activity.names.pl;
          const doneLevel = noseworkProgress[activity.id] ?? 0;
          return (
            <Pressable
              accessibilityLabel={names.name}
              accessibilityRole="button"
              key={activity.id}
              onPress={() => onOpenNosework(activity.id)}
              style={({ pressed }) => [styles.card, styles.cardNose, pressed && styles.cardPressed]}
            >
              <View style={styles.art}>
                <DogPose accent={BLUE} color="#6f7a74" pose={activity.pose} size={72} />
              </View>
              <View style={styles.body}>
                <Text style={styles.name}>{names.name}</Text>
                <Text numberOfLines={1} style={styles.tagline}>
                  {locale === 'en' ? activity.tagline.en : activity.tagline.pl}
                </Text>
                <Text style={styles.meta}>
                  {doneLevel > 0
                    ? t('nosework.level', { n: doneLevel, total: activity.levels.length })
                    : `${activity.levels.length} ${locale === 'en' ? 'levels' : 'poziomy'}`}
                </Text>
              </View>
            </Pressable>
          );
        })}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: GROUND,
  },
  scroll: {
    paddingHorizontal: 18,
    paddingTop: 20,
    paddingBottom: 36,
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
  },
  eyebrow: {
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1.4,
    textTransform: 'uppercase',
    color: GREEN,
  },
  heading: {
    fontSize: 32,
    fontWeight: '700',
    letterSpacing: -0.5,
    color: INK,
    marginTop: 4,
  },
  sub: {
    fontSize: 14,
    lineHeight: 20,
    color: MUTED,
    marginTop: 6,
    maxWidth: 420,
  },
  list: {
    marginTop: 22,
    gap: 12,
  },
  sectionHead: {
    marginTop: 30,
    gap: 2,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: INK,
    letterSpacing: -0.3,
  },
  sectionSub: {
    fontSize: 13,
    color: MUTED,
  },
  cardNose: {
    borderColor: '#d9e2ea',
  },
  card: {
    flexDirection: 'row',
    gap: 14,
    backgroundColor: SURFACE,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: LINE,
    padding: 14,
    alignItems: 'center',
  },
  cardRecommended: {
    borderColor: GREEN,
    borderWidth: 2,
  },
  cardPressed: {
    opacity: 0.75,
  },
  art: {
    width: 84,
    alignItems: 'center',
    justifyContent: 'center',
  },
  body: {
    flex: 1,
    gap: 6,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  name: {
    fontSize: 20,
    fontWeight: '700',
    color: INK,
    letterSpacing: -0.2,
  },
  chip: {
    backgroundColor: '#e2eee7',
    borderRadius: 999,
    paddingHorizontal: 9,
    paddingVertical: 3,
  },
  chipText: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.6,
    textTransform: 'uppercase',
    color: GREEN,
  },
  tagline: {
    fontSize: 14,
    lineHeight: 19,
    color: MUTED,
  },
  track: {
    height: 5,
    borderRadius: 999,
    backgroundColor: '#eaeee7',
    overflow: 'hidden',
    marginTop: 2,
  },
  trackFill: {
    height: 5,
    borderRadius: 999,
    backgroundColor: GREEN,
  },
  meta: {
    fontSize: 12,
    color: MUTED,
  },
  hint: {
    fontSize: 12,
    lineHeight: 17,
    color: '#91661a',
  },
});
