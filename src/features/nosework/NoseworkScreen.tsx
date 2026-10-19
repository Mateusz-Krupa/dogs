import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import type { NoseworkActivity } from '../../content/nosework';
import { DogPose } from '../../ui/DogPose';
import { getLocale, t } from '../../i18n';

const INK = '#14181a';
const MUTED = '#6b746e';
const GREEN = '#2e6f4e';
const BLUE = '#2a4a6b';
const SURFACE = '#ffffff';
const GROUND = '#f1f3ee';
const LINE = '#e3e7df';

export interface NoseworkScreenProps {
  readonly activity: NoseworkActivity;
  /** Highest level the dog has done, 0 when none. */
  readonly levelDone: number;
  readonly onDone: (levelOrdinal: number) => void;
}

/**
 * A scent game, with no hit/miss anywhere.
 *
 * The whole screen is built around that absence: there is one button, it says
 * "done", and it records that the game happened. Nothing here judges the dog,
 * because sniffing cannot be done wrong and an owner invited to score it will
 * start helping instead of watching.
 */
export function NoseworkScreen({ activity, levelDone, onDone }: NoseworkScreenProps) {
  const locale = getLocale();
  const [selected, setSelected] = useState(Math.min(levelDone, activity.levels.length - 1));
  const level = activity.levels[selected]!;
  const copy = locale === 'en' ? level.en : level.pl;
  const names = locale === 'en' ? activity.names.en : activity.names.pl;

  return (
    <View style={styles.screen}>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.hero}>
          <DogPose accent={BLUE} color="#2f3a35" pose={activity.pose} size={120} />
          <Text style={styles.name}>{names.name}</Text>
          <Text style={styles.description}>{names.description}</Text>
        </View>

        <View style={styles.notScored}>
          <Text style={styles.notScoredText}>{t('nosework.notScored')}</Text>
        </View>

        <View style={styles.levelRow}>
          {activity.levels.map((candidate, i) => {
            const active = i === selected;
            const complete = candidate.ordinal <= levelDone;
            return (
              <Pressable
                accessibilityLabel={t('nosework.level', { n: candidate.ordinal, total: activity.levels.length })}
                accessibilityRole="button"
                key={candidate.ordinal}
                onPress={() => setSelected(i)}
                style={[styles.levelChip, active && styles.levelChipActive, complete && styles.levelChipDone]}
              >
                <Text style={[styles.levelChipText, active && styles.levelChipTextActive]}>
                  {candidate.ordinal}
                </Text>
              </Pressable>
            );
          })}
          <Text style={styles.minutes}>{t('nosework.minutes', { n: level.minutes })}</Text>
        </View>

        <Text style={styles.levelTitle}>{copy.title}</Text>

        <View style={styles.block}>
          <Text style={styles.blockLabel}>{t('nosework.setup').toUpperCase()}</Text>
          <Text style={styles.blockText}>{copy.setup}</Text>
        </View>

        <View style={styles.block}>
          <Text style={styles.blockLabel}>{t('nosework.how').toUpperCase()}</Text>
          <Text style={styles.blockText}>{copy.how}</Text>
        </View>

        <View style={[styles.block, styles.watch]}>
          <Text style={[styles.blockLabel, styles.watchLabel]}>{t('nosework.watchFor').toUpperCase()}</Text>
          <Text style={styles.blockText}>{copy.watchFor}</Text>
        </View>
      </ScrollView>

      <View style={styles.dock}>
        <Pressable
          accessibilityLabel={t('nosework.done')}
          accessibilityRole="button"
          onPress={() => onDone(level.ordinal)}
          style={({ pressed }) => [styles.done, pressed && styles.pressed]}
        >
          <Text style={styles.doneLabel}>{t('nosework.done')}</Text>
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
    gap: 12,
  },
  hero: { alignItems: 'center', gap: 6 },
  name: { fontSize: 26, fontWeight: '700', color: INK, letterSpacing: -0.4 },
  description: { fontSize: 14, lineHeight: 21, color: MUTED, textAlign: 'center' },

  notScored: {
    backgroundColor: '#e7edf3',
    borderRadius: 12,
    borderLeftWidth: 3,
    borderLeftColor: BLUE,
    padding: 12,
  },
  notScoredText: { fontSize: 13, lineHeight: 19, color: '#24384a' },

  levelRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 4 },
  levelChip: {
    width: 40,
    height: 40,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: LINE,
    backgroundColor: SURFACE,
    alignItems: 'center',
    justifyContent: 'center',
  },
  levelChipActive: { borderColor: BLUE },
  levelChipDone: { backgroundColor: '#e2eee7' },
  levelChipText: { fontSize: 16, fontWeight: '700', color: MUTED },
  levelChipTextActive: { color: BLUE },
  minutes: { marginLeft: 'auto', fontSize: 13, color: MUTED },

  levelTitle: { fontSize: 19, fontWeight: '700', color: INK },

  block: {
    backgroundColor: SURFACE,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: LINE,
    padding: 13,
    gap: 4,
  },
  blockLabel: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1, color: MUTED },
  blockText: { fontSize: 14.5, lineHeight: 21, color: INK },
  watch: { backgroundColor: '#eef3ec', borderColor: '#d8e4d6' },
  watchLabel: { color: GREEN },

  dock: {
    width: '100%',
    maxWidth: 560,
    alignSelf: 'center',
    paddingHorizontal: 18,
    paddingBottom: 14,
  },
  done: {
    minHeight: 64,
    borderRadius: 16,
    backgroundColor: BLUE,
    alignItems: 'center',
    justifyContent: 'center',
  },
  doneLabel: { fontSize: 19, fontWeight: '700', color: '#ffffff' },
  pressed: { opacity: 0.75 },
});
