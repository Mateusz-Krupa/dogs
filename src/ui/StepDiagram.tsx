import Svg, { Circle, G, Path } from 'react-native-svg';

import { DogPose, type Pose } from './DogPose';

/**
 * A still diagram of one step: the dog, and where the food goes.
 *
 * ## Why there is no hand
 *
 * Earlier versions drew the handler's hand and animated it. Both were worse
 * than this. A hand has to be good to read as a hand, and at this size it
 * mostly read as a shape floating next to the dog; the animation added motion
 * without adding information, because the only thing an owner needs from the
 * picture is *where the food is and which way it travels*.
 *
 * So the vocabulary is three marks and nothing else:
 *
 * - a filled dot — the treat, at the position it should be held
 * - a dashed arrow — the path it travels
 * - a hollow dot — the same position once the food has been faded out, so the
 *   gesture is identical but the hand is empty
 *
 * On a verbal step there is no mark at all, because there is nothing in your
 * hand and nothing to move. It gets a sound mark instead.
 *
 * Canvas is 100×100 with the ground at y=82, matching `DogPose`.
 */

export type StepMotion =
  | 'up' // treat above the nose, dog folds into a sit
  | 'down' // nose to floor then forward, into a down
  | 'hold' // nothing moves; the dog holds position
  | 'away' // the food travels away and the dog follows
  | 'refuse' // food present but not available
  | 'swap' // a better piece offered for the one they have
  | 'contact'; // a hand rests on the dog — shown as a contact mark

/** Which mark a step shows, depending on how far the lure has been faded. */
export type DiagramStage = 'lure' | 'empty-hand' | 'verbal';

export interface StepDiagramProps {
  readonly pose: Pose;
  readonly motion: StepMotion;
  readonly stage: DiagramStage;
  readonly size?: number;
  readonly color?: string;
  readonly accent?: string;
}

const INK = '#2f3a35';
const ACCENT = '#2e6f4e';
const TREAT = '#c9872b';

/** Where the mark sits and which way it travels, per motion. */
const PATHS: Readonly<
  Record<StepMotion, { readonly from: readonly [number, number]; readonly to: readonly [number, number]; readonly curve: string; readonly head: string }>
> = {
  // The dot marks where the food is *held*; the arrow shows where it goes from
  // there. Both sit clear of the muzzle so neither reads as part of the dog.
  up: { from: [92, 30], to: [70, 8], curve: 'M 90 23 Q 86 12 76 9', head: 'M 68 8 L 78 3 L 78 14 Z' },
  down: { from: [94, 48], to: [62, 78], curve: 'M 94 56 Q 93 74 72 78', head: 'M 64 79 L 74 74 L 75 85 Z' },
  hold: { from: [92, 38], to: [92, 38], curve: '', head: '' },
  away: { from: [30, 36], to: [6, 36], curve: 'M 25 35 Q 17 31 11 33', head: 'M 4 35 L 14 29 L 15 40 Z' },
  refuse: { from: [22, 74], to: [22, 74], curve: '', head: '' },
  swap: { from: [92, 40], to: [50, 66], curve: 'M 87 46 Q 70 58 58 63', head: 'M 50 67 L 61 63 L 57 53 Z' },
  contact: { from: [50, 22], to: [50, 42], curve: 'M 50 29 L 50 36', head: 'M 50 44 L 44 33 L 56 33 Z' },
};

export function StepDiagram({
  pose,
  motion,
  stage,
  size = 132,
  color = INK,
  accent = ACCENT,
}: StepDiagramProps) {
  const path = PATHS[motion];
  const [fx, fy] = path.from;
  const filled = stage === 'lure';
  const showMark = stage !== 'verbal' && motion !== 'hold';

  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      <DogPose accent={accent} color={color} pose={pose} size={100} />

      {stage === 'verbal' ? (
        // Nothing in the hand and nothing to move — only the fact that you spoke.
        <G>
          <Path d="M 80 20 Q 88 20 88 28" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" />
          <Path d="M 74 14 Q 88 14 88 28" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" opacity={0.5} />
        </G>
      ) : null}

      {showMark && path.curve ? (
        <G>
          <Path
            d={path.curve}
            stroke={accent}
            strokeWidth={3}
            strokeLinecap="round"
            strokeDasharray="6 5"
            fill="none"
          />
          <Path d={path.head} fill={accent} />
        </G>
      ) : null}

      {showMark ? (
        filled ? (
          <Circle cx={fx} cy={fy} r={5.5} fill={TREAT} />
        ) : (
          // Same place, same gesture — the food is simply no longer there.
          <Circle cx={fx} cy={fy} r={5.5} fill="none" stroke={TREAT} strokeWidth={2.5} strokeDasharray="3 3" />
        )
      ) : null}

      {motion === 'refuse' && stage !== 'verbal' ? (
        <G>
          <Circle cx={fx} cy={fy} r={6} fill={TREAT} fillOpacity={0.9} />
          <Path d={`M ${fx - 9} ${fy - 9} L ${fx + 9} ${fy + 9}`} stroke={accent} strokeWidth={3.5} strokeLinecap="round" />
        </G>
      ) : null}

      {motion === 'hold' && stage !== 'verbal' ? (
        // A held position: two short bars meaning "nothing moves".
        <G>
          <Path d="M 84 30 L 84 46" stroke={accent} strokeWidth={4} strokeLinecap="round" />
          <Path d="M 92 30 L 92 46" stroke={accent} strokeWidth={4} strokeLinecap="round" />
        </G>
      ) : null}
    </Svg>
  );
}

/** The motion each exercise practises at its early steps. */
export const MOTION_BY_EXERCISE: Readonly<Record<string, StepMotion>> = {
  name: 'hold',
  sit: 'up',
  look: 'up',
  down: 'down',
  stay: 'hold',
  come: 'away',
  leave: 'refuse',
  drop: 'swap',
  wait: 'hold',
  leash: 'away',
  mat: 'down',
  handling: 'contact',
};
