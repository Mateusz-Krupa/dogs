import Svg, { Circle, G, Path } from 'react-native-svg';

import type { StepMotion } from '../content/schema';
import { DogPose, type Pose } from './DogPose';

/**
 * A still diagram of one step: the dog, and what the step acts on.
 *
 * ## Why there is no hand
 *
 * Earlier versions drew the handler's hand and animated it. Both were worse
 * than this. A hand has to be good to read as a hand, and at this size it
 * mostly read as a shape floating next to the dog; the animation added motion
 * without adding information, because the only thing an owner needs from the
 * picture is *what moves, and where*.
 *
 * The vocabulary, and nothing else:
 *
 * - a filled dot — the treat, at the position it should be held
 * - a dashed arrow — the path something travels
 * - a hollow dot — the same position once the food has been faded out, so the
 *   gesture is identical but the hand is empty
 * - a sound arc — the owner spoke
 * - an accent ring or bars — a hand, or a held position
 * - a door line, a bowl — the object the step is about
 *
 * ## Stage versus mark
 *
 * The food ladder fades the *treat dot*: filled, hollow, gone. Arrows that
 * describe the dog's or the handler's movement (`away`, `return`) are not about
 * the hand, so they survive into the verbal stage; lure-path arrows (`up`,
 * `down`, `swap`) fade with the food, or they would contradict the sentence
 * printed under the picture. Object marks are always visible — a crossed-out
 * treat on the floor is there whether or not your hand holds food.
 *
 * The dog faces right in every pose, so every mark sits in front of the muzzle,
 * above the back, or beside the paws — never behind the tail.
 *
 * Canvas is 100×100 with the ground at y=82, matching `DogPose`.
 */

export type { StepMotion };

/** Which version of the movement a given step is actually practising. */
export type DiagramStage = 'lure' | 'empty-hand' | 'verbal';

export interface StepDiagramProps {
  readonly pose: Pose;
  readonly motion: StepMotion;
  readonly stage: DiagramStage;
  /** The owner's voice is part of this step. Verbal stages imply it. */
  readonly sound?: boolean;
  readonly size?: number;
  readonly color?: string;
  readonly accent?: string;
}

const INK = '#2f3a35';
const ACCENT = '#2e6f4e';
const TREAT = '#c9872b';

interface MotionMarks {
  /** Where the dot (or ring) sits; the arrow leaves from there. */
  readonly from?: readonly [number, number];
  /** Dashed travel path and its head, when the motion moves something. */
  readonly curve?: string;
  readonly head?: string;
}

/**
 * Which dot or arrow each motion draws. The fade rules live below in
 * FOOD_DOTS / OBJECT_DOTS / LURE_ARROWS, not here.
 */
const MARKS: Readonly<Record<StepMotion, MotionMarks>> = {
  up: { from: [92, 30], curve: 'M 90 23 Q 86 12 76 9', head: 'M 68 8 L 78 3 L 78 14 Z' },
  down: { from: [94, 44], curve: 'M 95 51 Q 95 64 93 71', head: 'M 91 80 L 86 71 L 97 72 Z' },
  // Down to the floor and then drawn toward the handler — the full down shape.
  draw: { from: [94, 44], curve: 'M 95 51 Q 97 63 92 67', head: 'M 96 74 L 87 70 L 93 63 Z' },
  hold: {},
  // Recall and loose lead: the dog travels *toward* the hand held up in front,
  // so the arrow starts low at the chest and ends at the dot. It is about the
  // dog's route, not the hand, so it stays once the food is gone.
  away: { from: [94, 42], curve: 'M 58 62 Q 70 58 79 51', head: 'M 87 48 L 78 43 L 80 54 Z' },
  // Loose lead paying spot: low, at the handler's leg — never out in front,
  // which would send the dog forward into the pulling.
  leg: { from: [90, 66], curve: 'M 56 72 Q 68 70 78 68', head: 'M 85 67 L 76 62 L 77 73 Z' },
  refuse: { from: [92, 74] },
  deny: { from: [92, 40] },
  // The better piece at the nose; the held item drops to the ground in front,
  // where the dog will find it again — trade, not confiscation.
  swap: { from: [92, 30], curve: 'M 92 38 Q 92 52 91 62', head: 'M 90 72 L 85 63 L 96 63 Z' },
  // A hand, not a treat: the contact dot is accent-coloured on purpose.
  contact: { from: [50, 22], curve: 'M 50 29 L 50 36', head: 'M 50 44 L 44 33 L 56 33 Z' },
  touchPaw: { curve: 'M 70 40 L 70 56', head: 'M 70 66 L 64 56 L 76 56 Z' },
  lift: { curve: 'M 70 50 L 70 64', head: 'M 70 44 L 65 52 L 75 52 Z' },
  face: { from: [94, 46] },
  // Your steps out and back to the held dog: one shaft, heads both ways.
  return: { curve: 'M 68 66 L 90 66', head: 'M 62 66 L 70 61 L 70 71 Z M 96 66 L 88 61 L 88 71 Z' },
  collar: { from: [72, 46], curve: 'M 92 32 Q 84 36 78 41', head: 'M 76 45 L 84 42 L 80 33 Z' },
  door: { curve: 'M 64 48 Q 74 47 82 45', head: 'M 89 44 L 80 40 L 80 49 Z' },
  bowl: { from: [88, 70], curve: 'M 95 44 L 95 60', head: 'M 95 38 L 90 46 L 100 46 Z M 95 66 L 90 58 L 100 58 Z' },
  toss: { from: [85, 66], curve: 'M 48 34 Q 64 26 78 48', head: 'M 83 58 L 73 55 L 79 44 Z' },
};

/** Two crossed strokes over a treat dot: “there, but not for the dog”. */
function CrossedTreat({ x, y }: { x: number; y: number }) {
  return (
    <G>
      <Circle cx={x} cy={y} r={6} fill={TREAT} fillOpacity={0.9} />
      <Path d={`M ${x - 9} ${y - 9} L ${x + 9} ${y + 9}`} stroke={ACCENT} strokeWidth={3.5} strokeLinecap="round" />
    </G>
  );
}

/** Motions whose dot is food: it fades with the lure stage. */
const FOOD_DOTS: ReadonlySet<StepMotion> = new Set(['up', 'down', 'draw', 'away', 'leg', 'swap', 'toss']);
/** Motions whose dot is something else — a hand, a bowl — always visible. */
const OBJECT_DOTS: ReadonlySet<StepMotion> = new Set(['contact', 'bowl']);
/** Pure lure-path arrows: they fade with the food, or they would contradict the copy. */
const LURE_ARROWS: ReadonlySet<StepMotion> = new Set(['up', 'down', 'draw', 'swap', 'toss', 'leg']);

export function StepDiagram({
  pose,
  motion,
  stage,
  sound,
  size = 132,
  color = INK,
  accent = ACCENT,
}: StepDiagramProps) {
  const marks = MARKS[motion];
  const verbal = stage === 'verbal';
  const spoke = sound ?? verbal;

  const showDot =
    marks.from !== undefined &&
    (FOOD_DOTS.has(motion) ? !verbal : OBJECT_DOTS.has(motion));
  const showArrow =
    marks.curve !== undefined && !(LURE_ARROWS.has(motion) && verbal);

  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      {motion === 'toss' ? (
        // The mat: a toss always lands somewhere, and the target must be
        // visible even when the step is practised standing on it.
        <Path d="M 12 76 L 92 76 L 92 83 L 12 83 Z" fill={color} fillOpacity={0.24} />
      ) : null}
      <DogPose accent={accent} color={color} pose={pose} size={100} />

      {spoke ? (
        // The fact that you spoke, drawn as two arcs leaving the muzzle.
        <G>
          <Path d="M 80 20 Q 88 20 88 28" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" />
          <Path d="M 74 14 Q 88 14 88 28" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" opacity={0.5} />
        </G>
      ) : null}

      {motion === 'door' ? (
        // The door itself: a straight leaf at the edge, the arrow the gap.
        <G>
          <Path d="M 92 26 L 92 80" stroke={accent} strokeWidth={4} strokeLinecap="round" />
        </G>
      ) : null}

      {motion === 'face' && marks.from ? (
        // A ring around the muzzle: lifted lip, inspected teeth.
        <Circle cx={marks.from[0]} cy={marks.from[1]} r={9} fill="none" stroke={accent} strokeWidth={3} />
      ) : null}

      {motion === 'collar' && marks.from ? (
        // A ring low on the neck: the collar, taken hold of and let go.
        <Circle cx={marks.from[0]} cy={marks.from[1]} r={8} fill="none" stroke={accent} strokeWidth={3} />
      ) : null}

      {motion === 'hold' ? (
        // A held position: two short bars meaning “nothing moves”.
        <G>
          <Path d="M 88 14 L 88 30" stroke={accent} strokeWidth={4} strokeLinecap="round" />
          <Path d="M 96 14 L 96 30" stroke={accent} strokeWidth={4} strokeLinecap="round" />
        </G>
      ) : null}

      {(motion === 'refuse' || motion === 'deny') ? <CrossedTreat x={marks.from![0]} y={marks.from![1]} /> : null}

      {showArrow ? (
        <G>
          <Path
            d={marks.curve}
            stroke={accent}
            strokeWidth={3}
            strokeLinecap="round"
            strokeDasharray="6 5"
            fill="none"
          />
          <Path d={marks.head} fill={accent} />
        </G>
      ) : null}

      {showDot ? (
        motion === 'contact' ? (
          // The hand that lands on the dog, not food.
          <Circle cx={marks.from![0]} cy={marks.from![1]} r={5} fill={accent} />
        ) : motion === 'bowl' ? (
          <Circle cx={marks.from![0]} cy={marks.from![1]} r={6.5} fill={TREAT} />
        ) : stage === 'lure' ? (
          <Circle cx={marks.from![0]} cy={marks.from![1]} r={5.5} fill={TREAT} />
        ) : (
          // Same place, same gesture — the ring is simply no longer filled.
          // A dashed ring reads as scribble at 64px; a solid one still reads.
          <Circle cx={marks.from![0]} cy={marks.from![1]} r={5.5} fill="none" stroke={TREAT} strokeWidth={3} />
        )
      ) : null}
    </Svg>
  );
}

/** The motion each exercise practises at its early steps; steps override it. */
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
