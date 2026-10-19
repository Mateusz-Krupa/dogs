import Svg, { Circle, G, Path, Rect } from 'react-native-svg';

/**
 * Pose glyphs: a chunky dog silhouette in each trained position.
 *
 * Filled silhouettes, not line art. At the size these render (around 64px) thin
 * outlines turn to scribble — a solid shape still reads as a dog. One breed,
 * one angle, one weight throughout, because these exist so an owner can compare
 * their dog's body to the picture, not to decorate the list.
 *
 * Canvas is 100×100 with the ground at y=82.
 */

export type Pose =
  | 'sit'
  | 'down'
  | 'stand'
  | 'stay'
  | 'come'
  | 'look'
  | 'mat'
  | 'leave'
  | 'sniff'
  | 'search';

export interface DogPoseProps {
  readonly pose: Pose;
  readonly size?: number;
  /** Silhouette fill. */
  readonly color?: string;
  /** Accent used for props (hand, mat, the thing being left). */
  readonly accent?: string;
}

const INK = '#2f3a35';
const ACCENT = '#2e6f4e';
const GROUND = 82;

/** Head, muzzle and ear as one solid shape, rotated into place. */
function Head({ x, y, tilt = 0, color }: { x: number; y: number; tilt?: number; color: string }) {
  return (
    <G transform={`translate(${x} ${y}) rotate(${tilt})`}>
      {/* skull */}
      <Circle cx={0} cy={0} r={11} fill={color} />
      {/* muzzle */}
      <Path d="M 6 1 L 22 4 Q 25 6 22 9 L 6 10 Z" fill={color} />
      {/* ear, folded */}
      <Path d="M -7 -8 Q -16 -20 -2 -16 Q 2 -13 -1 -8 Z" fill={color} />
      {/* eye punched out of the silhouette */}
      <Circle cx={3} cy={-2} r={2.1} fill="#ffffff" fillOpacity={0.92} />
    </G>
  );
}

/** Tail as a tapered sweep. */
function Tail({ d, color }: { d: string; color: string }) {
  return <Path d={d} fill="none" stroke={color} strokeWidth={6} strokeLinecap="round" />;
}

export function DogPose({ pose, size = 72, color = INK, accent = ACCENT }: DogPoseProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      {/* ground */}
      <Rect x={8} y={GROUND} width={84} height={3.5} rx={1.75} fill={color} fillOpacity={0.18} />

      {pose === 'sit' || pose === 'look' || pose === 'stay' || pose === 'leave' ? (
        <G>
          {/* haunch and chest in one body shape */}
          <Path
            d={`M 30 ${GROUND} Q 24 58 34 46 Q 44 34 58 40 L 62 ${GROUND} L 50 ${GROUND} L 52 56 Q 42 60 38 ${GROUND} Z`}
            fill={color}
          />
          <Tail d={`M 30 66 Q 18 62 22 50`} color={color} />
        </G>
      ) : null}

      {pose === 'sit' && <Head x={64} y={34} color={color} />}
      {/* A head tilted this far up reads as "looking at you" on its own. The
          green gaze strokes that used to be here were a second, competing mark
          and nobody could tell what they meant. */}
      {pose === 'look' && <Head x={62} y={26} tilt={-38} color={color} />}
      {/* The item being left alone is StepDiagram's crossed-out mark, not part
          of the dog. */}
      {pose === 'leave' && <Head x={64} y={34} tilt={-22} color={color} />}
      {/* No palm. A held position is shown by StepDiagram's pause bars. */}
      {pose === 'stay' && <Head x={62} y={34} color={color} />}

      {(pose === 'down' || pose === 'mat') && (
        <G>
          {pose === 'mat' && (
            <Rect x={14} y={GROUND - 9} width={76} height={11} rx={5.5} fill={color} fillOpacity={0.28} />
          )}
          {/* body low, elbows and chest down */}
          <Path
            d={`M 26 ${GROUND - (pose === 'mat' ? 9 : 0)} Q 24 58 40 56 L 70 56 Q 80 56 80 ${
              GROUND - (pose === 'mat' ? 9 : 0)
            } Z`}
            fill={color}
          />
          <Tail d={`M 26 ${GROUND - 12} Q 12 ${GROUND - 14} 16 ${GROUND - 24}`} color={color} />
          <Head x={84} y={54} color={color} />
        </G>
      )}

      {pose === 'stand' && (
        <G>
          <Path d={`M 30 46 L 74 46 L 74 ${GROUND} L 66 ${GROUND} L 66 56 L 40 56 L 40 ${GROUND} L 32 ${GROUND} Z`} fill={color} />
          <Tail d={`M 30 44 Q 18 38 24 28`} color={color} />
          <Head x={80} y={40} color={color} />
        </G>
      )}

      {(pose === 'sniff' || pose === 'search') && (
        <G>
          {/* standing, head low to the ground, working */}
          <Path d={`M 32 48 L 72 46 L 72 ${GROUND} L 64 ${GROUND} L 64 56 L 40 57 L 40 ${GROUND} L 32 ${GROUND} Z`} fill={color} />
          <Tail
            d={pose === 'search' ? `M 32 46 Q 18 36 26 26` : `M 32 46 Q 18 42 22 32`}
            color={color}
          />
          <Head x={80} y={64} tilt={34} color={color} />
          {/* scent, rising from the ground where the nose is */}
          <Circle cx={88} cy={GROUND - 4} r={3} fill={accent} fillOpacity={0.9} />
          <Circle cx={80} cy={GROUND - 1} r={2.2} fill={accent} fillOpacity={0.6} />
          {pose === 'search' ? (
            <Circle cx={70} cy={GROUND - 3} r={1.8} fill={accent} fillOpacity={0.4} />
          ) : null}
        </G>
      )}

      {pose === 'come' && (
        <G>
          {/* mid-stride, legs split */}
          <Path d={`M 26 48 L 68 44 L 72 54 L 34 58 Z`} fill={color} />
          <Path d={`M 30 56 L 20 ${GROUND} L 28 ${GROUND} L 38 58 Z`} fill={color} />
          <Path d={`M 62 52 L 74 ${GROUND} L 82 ${GROUND} L 70 50 Z`} fill={color} />
          <Tail d={`M 26 46 Q 12 38 18 28`} color={color} />
          <Head x={76} y={38} tilt={-8} color={color} />
        </G>
      )}
    </Svg>
  );
}
