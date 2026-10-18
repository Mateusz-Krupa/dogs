import Svg, { Circle, Ellipse, Path, Rect, G } from 'react-native-svg';

/**
 * Line illustrations of a dog in each trained position.
 *
 * One dog, one style, drawn side-on, because the point of these is to show a
 * body position the owner can compare against — not to decorate. A different
 * breed or angle per exercise would make them harder to read, not nicer.
 *
 * Drawn on a 120×96 canvas with the ground at y=78.
 */

export type Pose =
  | 'sit'
  | 'down'
  | 'stand'
  | 'stay'
  | 'come'
  | 'look'
  | 'mat'
  | 'leave';

export interface DogPoseProps {
  readonly pose: Pose;
  readonly size?: number;
  /** Line colour. Defaults to the app's ink. */
  readonly color?: string;
  /** Fill behind the dog. Defaults to a soft tint. */
  readonly tint?: string;
}

const INK = '#14181a';
const TINT = '#dfe7df';
const GROUND = 78;

/** Shared ground line so every pose sits on the same baseline. */
function Ground({ color }: { color: string }) {
  return (
    <Path
      d={`M 12 ${GROUND} L 108 ${GROUND}`}
      stroke={color}
      strokeOpacity={0.25}
      strokeWidth={2}
      strokeLinecap="round"
    />
  );
}

/** The dog's head, ear and eye, placed where the pose needs it. */
function Head({
  x,
  y,
  color,
  tint,
  tilt = 0,
}: {
  x: number;
  y: number;
  color: string;
  tint: string;
  tilt?: number;
}) {
  return (
    <G transform={`translate(${x} ${y}) rotate(${tilt})`}>
      <Ellipse cx={0} cy={0} rx={11} ry={9.5} fill={tint} stroke={color} strokeWidth={2.5} />
      {/* muzzle */}
      <Path
        d="M 8 2 L 18 4 L 17 8 L 7 7 Z"
        fill={tint}
        stroke={color}
        strokeWidth={2.5}
        strokeLinejoin="round"
      />
      <Circle cx={18} cy={5} r={1.8} fill={color} />
      {/* ear */}
      <Path
        d="M -6 -7 Q -12 -16 -3 -13"
        fill={tint}
        stroke={color}
        strokeWidth={2.5}
        strokeLinejoin="round"
      />
      <Circle cx={5} cy={-1} r={1.6} fill={color} />
    </G>
  );
}

/** One illustration. `pose` picks the body; everything else is shared. */
export function DogPose({ pose, size = 96, color = INK, tint = TINT }: DogPoseProps) {
  const stroke = { stroke: color, strokeWidth: 2.5, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const };

  return (
    <Svg width={size} height={size * 0.8} viewBox="0 0 120 96" accessibilityRole="image">
      <Ground color={color} />

      {pose === 'sit' && (
        <G>
          {/* haunches down, chest up */}
          <Path d={`M 40 ${GROUND} Q 34 60 42 48 Q 52 38 66 42`} fill={tint} {...stroke} />
          <Path d={`M 40 ${GROUND} L 56 ${GROUND}`} {...stroke} />
          <Path d={`M 62 46 L 64 ${GROUND}`} {...stroke} />
          <Path d={`M 38 62 Q 26 60 30 50`} {...stroke} fill="none" />
          <Head x={70} y={38} color={color} tint={tint} />
        </G>
      )}

      {pose === 'down' && (
        <G>
          {/* elbows and chest on the ground */}
          <Path d={`M 34 ${GROUND} Q 36 62 50 62 L 74 62 Q 82 62 82 ${GROUND}`} fill={tint} {...stroke} />
          <Path d={`M 50 62 L 46 ${GROUND}`} {...stroke} />
          <Path d={`M 74 62 L 78 ${GROUND}`} {...stroke} />
          <Path d={`M 34 70 Q 22 70 26 62`} {...stroke} fill="none" />
          <Head x={88} y={60} color={color} tint={tint} />
        </G>
      )}

      {pose === 'stand' && (
        <G>
          <Path d={`M 38 50 L 76 50`} fill={tint} {...stroke} />
          <Path d={`M 38 50 Q 32 50 32 56 L 32 ${GROUND}`} {...stroke} fill="none" />
          <Path d={`M 44 50 L 44 ${GROUND}`} {...stroke} />
          <Path d={`M 72 50 L 72 ${GROUND}`} {...stroke} />
          <Path d={`M 78 50 L 78 ${GROUND}`} {...stroke} />
          <Path d={`M 36 48 Q 24 42 30 34`} {...stroke} fill="none" />
          <Head x={84} y={42} color={color} tint={tint} />
        </G>
      )}

      {pose === 'stay' && (
        <G>
          {/* sit, with a hand signal in front */}
          <Path d={`M 30 ${GROUND} Q 24 60 32 48 Q 42 38 56 42`} fill={tint} {...stroke} />
          <Path d={`M 30 ${GROUND} L 46 ${GROUND}`} {...stroke} />
          <Path d={`M 52 46 L 54 ${GROUND}`} {...stroke} />
          <Head x={60} y={38} color={color} tint={tint} />
          {/* open palm */}
          <Rect x={88} y={30} width={16} height={22} rx={7} fill="none" {...stroke} />
          <Path d={`M 96 52 L 96 62`} {...stroke} />
        </G>
      )}

      {pose === 'come' && (
        <G>
          {/* mid-stride, moving right */}
          <Path d={`M 30 52 L 70 48`} fill={tint} {...stroke} />
          <Path d={`M 32 52 L 24 ${GROUND}`} {...stroke} />
          <Path d={`M 42 51 L 48 ${GROUND}`} {...stroke} />
          <Path d={`M 62 49 L 56 ${GROUND}`} {...stroke} />
          <Path d={`M 70 48 L 80 ${GROUND}`} {...stroke} />
          <Path d={`M 28 50 Q 16 42 22 34`} {...stroke} fill="none" />
          <Head x={80} y={40} color={color} tint={tint} tilt={-6} />
        </G>
      )}

      {pose === 'look' && (
        <G>
          {/* sit, head up, eye-contact lines */}
          <Path d={`M 36 ${GROUND} Q 30 60 38 48 Q 48 38 62 42`} fill={tint} {...stroke} />
          <Path d={`M 36 ${GROUND} L 52 ${GROUND}`} {...stroke} />
          <Path d={`M 58 46 L 60 ${GROUND}`} {...stroke} />
          <Head x={68} y={34} color={color} tint={tint} tilt={-16} />
          <Path d={`M 84 22 L 94 14`} {...stroke} strokeOpacity={0.45} />
          <Path d={`M 86 28 L 98 24`} {...stroke} strokeOpacity={0.45} />
        </G>
      )}

      {pose === 'mat' && (
        <G>
          {/* down, on a mat */}
          <Rect x={24} y={GROUND - 6} width={76} height={8} rx={4} fill={tint} {...stroke} />
          <Path d={`M 38 ${GROUND - 6} Q 40 58 54 58 L 74 58 Q 82 58 82 ${GROUND - 6}`} fill={tint} {...stroke} />
          <Path d={`M 38 66 Q 28 66 30 58`} {...stroke} fill="none" />
          <Head x={88} y={56} color={color} tint={tint} />
        </G>
      )}

      {pose === 'leave' && (
        <G>
          {/* sit, turning away from an item on the ground */}
          <Path d={`M 48 ${GROUND} Q 42 60 50 48 Q 60 38 74 42`} fill={tint} {...stroke} />
          <Path d={`M 48 ${GROUND} L 64 ${GROUND}`} {...stroke} />
          <Path d={`M 70 46 L 72 ${GROUND}`} {...stroke} />
          <Head x={78} y={38} color={color} tint={tint} tilt={-14} />
          {/* the thing being left alone */}
          <Circle cx={24} cy={GROUND - 5} r={6} fill="none" {...stroke} strokeOpacity={0.5} />
        </G>
      )}
    </Svg>
  );
}
