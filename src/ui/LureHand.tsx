import { Circle, G, Path } from 'react-native-svg';

/**
 * The handler's hand, seen from the side.
 *
 * A floating rounded rectangle reads as a pill, not a hand — what makes it
 * legible is the forearm it hangs from and the pinch at the front. So this is
 * drawn as three things: a thick forearm running off the edge of the frame, a
 * palm, and a thumb and finger meeting at a point. The treat, when there is
 * one, sits exactly in that pinch.
 */

export interface LureHandProps {
  readonly x: number;
  readonly y: number;
  /** Degrees. 0 points the pinch to the left, toward the dog's nose. */
  readonly rotate?: number;
  /** Draw a treat in the pinch. False once the lure has been faded out. */
  readonly treat?: boolean;
  /** 0–1, fades the treat out as it is handed over. */
  readonly treatOpacity?: number;
  readonly color: string;
}

const TREAT = '#c9872b';

export function LureHand({ x, y, rotate = 0, treat = true, treatOpacity = 1, color }: LureHandProps) {
  return (
    <G transform={`translate(${x} ${y}) rotate(${rotate})`}>
      {/* forearm, running out of frame so the hand belongs to a person */}
      <Path
        d="M 10 2 L 46 14"
        stroke={color}
        strokeWidth={12}
        strokeLinecap="round"
        fill="none"
      />
      {/* palm */}
      <Circle cx={4} cy={0} r={9} fill={color} />
      {/* thumb, curling down to the pinch */}
      <Path d="M 1 -7 Q -8 -7 -9 -1" stroke={color} strokeWidth={5.5} strokeLinecap="round" fill="none" />
      {/* index finger, curling up to meet it */}
      <Path d="M 1 6 Q -8 6 -9 1" stroke={color} strokeWidth={5.5} strokeLinecap="round" fill="none" />
      {treat ? <Circle cx={-11} cy={0} r={4} fill={TREAT} fillOpacity={treatOpacity} /> : null}
    </G>
  );
}
