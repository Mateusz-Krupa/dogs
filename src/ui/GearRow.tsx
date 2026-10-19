import { StyleSheet, Text, View } from 'react-native';

import { GearIcon, type GearId } from './Gear';
import { t } from '../i18n';

export interface GearRowProps {
  readonly gear: readonly GearId[];
  /** Tint for the icons and the heading. */
  readonly color?: string;
  /**
   * Icons only, no heading and no labels — for list cards, which are scanned
   * rather than read. Three small icons say "you'll need a lead" at a glance;
   * three labelled pills turn the card into a paragraph.
   */
  readonly compact?: boolean;
}

/** Icons alone, with the names folded into one accessibility label. */
function CompactGear({ gear, color }: { gear: readonly GearId[]; color: string }) {
  return (
    <View
      accessibilityLabel={`${t('gear.title')}: ${gear.map((id) => t(`gear.${id}`)).join(', ')}`}
      style={styles.compactRow}
    >
      {gear.map((id) => (
        <View key={id} style={styles.compactItem}>
          <GearIcon color={color} gear={id} size={17} />
        </View>
      ))}
    </View>
  );
}

/**
 * "What you need" — the first question an owner asks before a session.
 *
 * Shown as icon plus label rather than a bulleted list, so it can be read at a
 * glance from across the room while you are still deciding whether you have
 * time to train at all.
 */
export function GearRow({ gear, color = '#4a554f', compact = false }: GearRowProps) {
  if (gear.length === 0) return null;
  if (compact) return <CompactGear color={color} gear={gear} />;

  return (
    <View style={styles.wrap}>
      <Text style={[styles.title, { color }]}>{t('gear.title').toUpperCase()}</Text>
      <View style={styles.row}>
        {gear.map((id) => (
          <View key={id} style={styles.item}>
            <GearIcon color={color} gear={id} size={26} />
            <Text style={styles.label}>{t(`gear.${id}`)}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { gap: 7 },
  title: { fontSize: 10, fontWeight: '700', letterSpacing: 1.1 },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  item: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
    backgroundColor: '#ffffff',
    borderRadius: 999,
    borderWidth: 1,
    borderColor: '#e3e7df',
    paddingVertical: 6,
    paddingLeft: 8,
    paddingRight: 13,
  },
  label: { fontSize: 13, color: '#3a433f' },

  compactRow: { flexDirection: 'row', gap: 5 },
  compactItem: {
    width: 26,
    height: 26,
    borderRadius: 8,
    backgroundColor: '#f1f3ee',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
