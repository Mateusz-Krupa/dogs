import Svg, { Circle, G, Path, Rect } from 'react-native-svg';

/**
 * What you need before you start.
 *
 * Deliberately geometric rather than illustrative: these sit at 28px in a row,
 * where a drawing turns to mush but a recognisable outline does not. Each is
 * built from the smallest number of shapes that still names the object.
 *
 * Canvas is 32×32 throughout.
 */

export type GearId =
  | 'treats'
  | 'lead'
  | 'longline'
  | 'mat'
  | 'towel'
  | 'box'
  | 'toy'
  | 'cups'
  | 'clippers'
  | 'bowl'
  | 'helper'
  | 'door'
  | 'grass'
  | 'nothing';

export interface GearIconProps {
  readonly gear: GearId;
  readonly size?: number;
  readonly color?: string;
}

const INK = '#4a554f';

export function GearIcon({ gear, size = 28, color = INK }: GearIconProps) {
  const s = { stroke: color, strokeWidth: 2, fill: 'none', strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const };

  return (
    <Svg width={size} height={size} viewBox="0 0 32 32">
      {gear === 'treats' && (
        <G>
          {/* a pouch with pieces spilling */}
          <Path d="M 7 12 L 25 12 L 23 26 L 9 26 Z" {...s} />
          <Path d="M 11 12 Q 16 5 21 12" {...s} />
          <Circle cx={13} cy={19} r={2} fill={color} />
          <Circle cx={19} cy={21} r={2} fill={color} />
        </G>
      )}

      {gear === 'lead' && (
        <G>
          {/* clip and a short curve */}
          <Path d="M 8 8 Q 18 10 20 20 Q 21 25 25 25" {...s} />
          <Rect x={4} y={5} width={7} height={7} rx={3.5} {...s} />
          <Circle cx={25} cy={25} r={3} {...s} />
        </G>
      )}

      {gear === 'longline' && (
        <G>
          {/* a long, loose line in loops */}
          <Path d="M 4 10 Q 12 2 16 10 Q 20 18 26 12" {...s} />
          <Path d="M 4 20 Q 12 12 16 20 Q 20 28 26 22" {...s} />
        </G>
      )}

      {gear === 'mat' && (
        <G>
          <Rect x={4} y={11} width={24} height={12} rx={4} {...s} />
          <Path d="M 9 17 L 23 17" {...s} strokeOpacity={0.5} />
        </G>
      )}

      {gear === 'towel' && (
        <G>
          {/* rolled cloth, seen end-on */}
          <Rect x={5} y={10} width={22} height={13} rx={6.5} {...s} />
          <Path d="M 12 10 Q 14 16.5 12 23" {...s} strokeOpacity={0.6} />
          <Path d="M 19 10 Q 21 16.5 19 23" {...s} strokeOpacity={0.6} />
        </G>
      )}

      {gear === 'box' && (
        <G>
          <Path d="M 5 12 L 16 8 L 27 12 L 27 24 L 16 28 L 5 24 Z" {...s} />
          <Path d="M 5 12 L 16 16 L 27 12" {...s} />
          <Path d="M 16 16 L 16 28" {...s} />
        </G>
      )}

      {gear === 'toy' && (
        <G>
          {/* a tug/bone shape */}
          <Path d="M 10 13 Q 16 16 22 13" {...s} />
          <Path d="M 10 19 Q 16 16 22 19" {...s} />
          <Circle cx={8} cy={13} r={3.2} {...s} />
          <Circle cx={8} cy={19} r={3.2} {...s} />
          <Circle cx={24} cy={13} r={3.2} {...s} />
          <Circle cx={24} cy={19} r={3.2} {...s} />
        </G>
      )}

      {gear === 'cups' && (
        <G>
          <Path d="M 4 24 L 6 14 L 12 14 L 14 24 Z" {...s} />
          <Path d="M 13 24 L 15 12 L 21 12 L 23 24 Z" {...s} />
          <Path d="M 22 24 L 24 16 L 29 16 L 30 24 Z" {...s} />
        </G>
      )}

      {gear === 'clippers' && (
        <G>
          <Path d="M 8 6 L 20 20" {...s} />
          <Path d="M 20 6 L 8 20" {...s} />
          <Circle cx={22} cy={24} r={4} {...s} />
          <Circle cx={7} cy={24} r={4} {...s} />
        </G>
      )}

      {gear === 'bowl' && (
        <G>
          <Path d="M 5 14 L 27 14 L 23 25 L 9 25 Z" {...s} />
          <Path d="M 5 14 Q 16 10 27 14" {...s} />
        </G>
      )}

      {gear === 'helper' && (
        <G>
          <Circle cx={16} cy={10} r={4.5} {...s} />
          <Path d="M 7 27 Q 8 17 16 17 Q 24 17 25 27" {...s} />
        </G>
      )}

      {gear === 'door' && (
        <G>
          <Rect x={8} y={4} width={16} height={24} rx={2} {...s} />
          <Circle cx={20} cy={17} r={1.6} fill={color} />
        </G>
      )}

      {gear === 'grass' && (
        <G>
          <Path d="M 6 26 Q 7 16 10 13" {...s} />
          <Path d="M 12 26 Q 13 14 17 10" {...s} />
          <Path d="M 19 26 Q 20 15 24 12" {...s} />
          <Path d="M 25 26 Q 26 19 28 16" {...s} />
        </G>
      )}

      {gear === 'nothing' && (
        <G>
          <Circle cx={16} cy={16} r={11} {...s} strokeOpacity={0.5} />
          <Path d="M 9 23 L 23 9" {...s} strokeOpacity={0.5} />
        </G>
      )}
    </Svg>
  );
}
