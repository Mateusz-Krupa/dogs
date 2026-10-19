import Svg, { Circle, G, Path, Rect } from 'react-native-svg';

import { DogPose, type Pose } from './DogPose';

/**
 * How the handler's hand moves, drawn over the dog.
 *
 * The half of training that prose cannot carry is where the hand starts, where
 * it travels and when it stops. A paragraph saying "draw the treat down and
 * toward you" is read five different ways; an arrow is read one way.
 *
 * Canvas matches DogPose: 100×100, ground at y=82.
 */

export type Motion =
  | 'lure-up' // treat above the nose, dog folds into a sit
  | 'lure-down' // nose to floor, then forward, into a down
  | 'palm-still' // open palm held up, nothing moves
  | 'away' // hand travels away from the dog, dog follows
  | 'trade' // a better treat offered beside the held item
  | 'hold-off' // closed fist, dog must back off
  | 'touch'; // a hand resting on the dog

export interface HandMotionProps {
  readonly pose: Pose;
  readonly motion: Motion;
  readonly size?: number;
  readonly color?: string;
  readonly accent?: string;
}

const ACCENT = '#2e6f4e';
const DOG = '#5b6760';

/** A simple mitten-shaped hand, optionally holding a treat. */
function Hand({ x, y, rotate = 0, treat, color }: { x: number; y: number; rotate?: number; treat?: boolean; color: string }) {
  return (
    <G transform={`translate(${x} ${y}) rotate(${rotate})`}>
      <Rect x={-7} y={-11} width={14} height={21} rx={7} fill={color} />
      <Rect x={-3} y={8} width={6} height={10} rx={3} fill={color} />
      {treat ? <Circle cx={0} cy={-13} r={4.2} fill="#c9872b" /> : null}
    </G>
  );
}

/** A curved motion arrow with a solid head. */
function Arrow({ d, head, color }: { d: string; head: string; color: string }) {
  return (
    <G>
      <Path d={d} fill="none" stroke={color} strokeWidth={3.5} strokeLinecap="round" strokeDasharray="7 5" />
      <Path d={head} fill={color} />
    </G>
  );
}

export function HandMotion({ pose, motion, size = 132, color = ACCENT, accent = DOG }: HandMotionProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      <G opacity={0.55}>
        <DogPose color={accent} pose={pose} size={100} />
      </G>

      {motion === 'lure-up' && (
        <G>
          <Hand color={color} treat x={70} y={22} />
          <Arrow
            color={color}
            d="M 70 44 Q 72 34 70 26"
            head="M 70 20 L 65 29 L 75 29 Z"
          />
        </G>
      )}

      {motion === 'lure-down' && (
        <G>
          <Hand color={color} rotate={14} treat x={74} y={48} />
          <Arrow
            color={color}
            d="M 76 36 Q 78 56 62 70"
            head="M 56 73 L 66 73 L 62 64 Z"
          />
        </G>
      )}

      {motion === 'palm-still' && (
        <G>
          <Rect x={70} y={20} width={17} height={27} rx={8.5} fill={color} />
          <Rect x={75} y={45} width={6} height={13} rx={3} fill={color} />
          {/* stillness marks */}
          <Path d="M 64 26 L 58 26" stroke={color} strokeWidth={3} strokeLinecap="round" />
          <Path d="M 64 34 L 56 34" stroke={color} strokeWidth={3} strokeLinecap="round" />
        </G>
      )}

      {motion === 'away' && (
        <G>
          <Hand color={color} rotate={-18} treat x={22} y={34} />
          <Arrow
            color={color}
            d="M 36 34 Q 26 32 18 34"
            head="M 12 34 L 21 29 L 21 39 Z"
          />
        </G>
      )}

      {motion === 'trade' && (
        <G>
          <Hand color={color} rotate={10} treat x={76} y={40} />
          <Circle cx={46} cy={64} r={7} fill={accent} />
          <Arrow
            color={color}
            d="M 66 48 Q 58 56 52 60"
            head="M 47 64 L 57 62 L 52 54 Z"
          />
        </G>
      )}

      {motion === 'hold-off' && (
        <G>
          {/* closed fist, nothing offered */}
          <Circle cx={74} cy={40} r={11} fill={color} />
          <Rect x={71} y={49} width={6} height={12} rx={3} fill={color} />
          <Path d="M 60 30 L 88 52" stroke="#ffffff" strokeWidth={3} strokeLinecap="round" strokeOpacity={0.85} />
        </G>
      )}

      {motion === 'touch' && (
        <G>
          <Hand color={color} rotate={62} x={52} y={38} />
          <Arrow color={color} d="M 52 20 L 52 28" head="M 52 34 L 47 25 L 57 25 Z" />
        </G>
      )}
    </Svg>
  );
}

/** The motion each exercise uses at its first steps. */
export const MOTION_BY_EXERCISE: Readonly<Record<string, Motion>> = {
  name: 'palm-still',
  sit: 'lure-up',
  look: 'lure-up',
  down: 'lure-down',
  stay: 'palm-still',
  come: 'away',
  leave: 'hold-off',
  drop: 'trade',
  wait: 'palm-still',
  leash: 'away',
  mat: 'lure-down',
  handling: 'touch',
};
