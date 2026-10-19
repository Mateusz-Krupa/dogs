import { useEffect, useRef, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import Svg, { Circle, G, Path, Rect } from 'react-native-svg';

/**
 * The lure, animated.
 *
 * ## Why a capsule dog
 *
 * The dog here is built from thick round-capped strokes — a hip, a torso, a
 * neck, four legs — rather than one outlined silhouette. A silhouette has to be
 * redrawn for every frame of a fold; a capsule skeleton only needs its joints
 * moved, and it stays recognisable at every intermediate position. That is the
 * whole trick: joints interpolate cleanly, outlines do not.
 *
 * ## Why it loops with a pause
 *
 * The owner is comparing their own hand to the screen, so the useful moment is
 * the one *before* the dog folds. A continuous loop never lets you look at it;
 * a loop that holds at the end and restarts does.
 */

export type LureKind = 'sit' | 'down';

export interface LureAnimationProps {
  readonly kind: LureKind;
  readonly size?: number;
  readonly color?: string;
  readonly accent?: string;
}

const INK = '#2f3a35';
const ACCENT = '#2e6f4e';
const TREAT = '#c9872b';
const GROUND_Y = 86;

/** Linear interpolation. */
const mix = (a: number, b: number, t: number) => a + (b - a) * t;

/** Ease in and out, so the fold starts and ends softly rather than snapping. */
const ease = (t: number) => (t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) ** 2 / 2);

/** Maps elapsed loop time to the phases of one lure. */
function phase(t: number): { lure: number; fold: number; pay: number } {
  // 0.00–0.30  hand rises, dog's head follows, nothing folds yet
  // 0.30–0.65  the fold happens
  // 0.65–0.85  hold — this is the frame worth looking at
  // 0.85–1.00  the treat is delivered
  const lure = ease(Math.min(1, t / 0.3));
  const fold = t < 0.3 ? 0 : ease(Math.min(1, (t - 0.3) / 0.35));
  const pay = t < 0.85 ? 0 : (t - 0.85) / 0.15;
  return { lure, fold, pay };
}

export function LureAnimation({ kind, size = 170, color = INK, accent = ACCENT }: LureAnimationProps) {
  const [t, setT] = useState(0);
  const [playing, setPlaying] = useState(true);
  const started = useRef(0);

  useEffect(() => {
    if (!playing) return;
    let frame = 0;
    let cancelled = false;
    const DURATION = 3200;
    const HOLD = 700;

    const tick = (now: number) => {
      if (cancelled) return;
      if (started.current === 0) started.current = now;
      const elapsed = now - started.current;
      if (elapsed >= DURATION + HOLD) {
        started.current = now;
        setT(0);
      } else {
        setT(Math.min(1, elapsed / DURATION));
      }
      frame = requestAnimationFrame(tick);
    };
    frame = requestAnimationFrame(tick);
    return () => {
      cancelled = true;
      cancelAnimationFrame(frame);
      started.current = 0;
    };
  }, [playing, kind]);

  const { lure, fold, pay } = phase(t);

  // Joints. Standing first, then where each one ends up.
  const hipX = kind === 'sit' ? mix(36, 33, fold) : mix(36, 34, fold);
  const hipY = kind === 'sit' ? mix(50, 68, fold) : mix(50, 70, fold);
  const shoulderX = mix(66, kind === 'sit' ? 63 : 64, fold);
  const shoulderY = kind === 'sit' ? mix(48, 46, fold) : mix(48, 70, fold);

  // The head follows the treat: up and back for a sit, down and forward for a down.
  const headX = kind === 'sit' ? mix(mix(84, 80, lure), 76, fold) : mix(mix(84, 88, lure), 90, fold);
  const headY = kind === 'sit' ? mix(mix(42, 30, lure), 32, fold) : mix(mix(42, 56, lure), 74, fold);
  const headTilt = kind === 'sit' ? mix(mix(0, -22, lure), -16, fold) : mix(mix(0, 24, lure), 34, fold);

  // The hand sits just in front of the muzzle, holding the treat the dog is
  // following. Anchoring it to the head rather than animating it separately
  // keeps the fist off the dog's face at every frame — the two move together
  // because that is exactly what luring is.
  const lead = 6 * (1 - lure);
  const handX = headX + 25;
  const handY = headY + 17 - lead;

  const limb = {
    stroke: color,
    strokeLinecap: 'round' as const,
    fill: 'none',
  };

  return (
    <View style={styles.wrap}>
      <Pressable
        accessibilityLabel={kind}
        accessibilityRole="button"
        onPress={() => {
          started.current = 0;
          setT(0);
          setPlaying((p) => !p);
        }}
      >
        <Svg width={size} height={size * 0.72} viewBox="0 0 130 94">
          <Rect x={8} y={GROUND_Y} width={114} height={3.5} rx={1.75} fill={color} fillOpacity={0.18} />

          {/* rear leg — shortens into the haunch as the dog folds */}
          <Path d={`M ${hipX} ${hipY} L ${hipX + 2} ${GROUND_Y}`} {...limb} strokeWidth={9} />
          {/* front legs stay put; they are what the dog folds around */}
          <Path d={`M ${shoulderX} ${shoulderY} L ${shoulderX + 1} ${GROUND_Y}`} {...limb} strokeWidth={9} />
          <Path d={`M ${shoulderX - 7} ${shoulderY} L ${shoulderX - 6} ${GROUND_Y}`} {...limb} strokeWidth={8} />

          {/* torso */}
          <Path d={`M ${hipX} ${hipY} L ${shoulderX} ${shoulderY}`} {...limb} strokeWidth={21} />
          {/* haunch */}
          <Circle cx={hipX} cy={hipY} r={11.5} fill={color} />
          {/* neck */}
          <Path d={`M ${shoulderX} ${shoulderY - 4} L ${headX - 6} ${headY + 4}`} {...limb} strokeWidth={13} />
          {/* tail */}
          <Path
            d={`M ${hipX - 4} ${hipY - 6} Q ${hipX - 18} ${hipY - 12} ${hipX - 13} ${hipY - 22}`}
            {...limb}
            strokeWidth={6}
          />

          {/* head */}
          <G transform={`translate(${headX} ${headY}) rotate(${headTilt})`}>
            <Circle cx={0} cy={0} r={11} fill={color} />
            <Path d="M 6 1 L 21 4 Q 24 6 21 9 L 6 10 Z" fill={color} />
            <Path d="M -7 -8 Q -16 -20 -2 -16 Q 2 -13 -1 -8 Z" fill={color} />
            <Circle cx={3} cy={-2} r={2.1} fill="#ffffff" fillOpacity={0.9} />
          </G>

          {/* the handler's hand, holding the treat the dog is following */}
          <G transform={`translate(${handX} ${handY})`}>
            <Rect x={-7} y={-11} width={14} height={22} rx={7} fill={accent} />
            <Rect x={-3} y={9} width={6} height={11} rx={3} fill={accent} />
            <Circle cx={0} cy={-13} r={4.2} fill={TREAT} fillOpacity={pay > 0 ? 1 - pay : 1} />
          </G>
        </Svg>
      </Pressable>

      <Text style={styles.hint}>{playing ? '❙❙' : '▶'}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { alignItems: 'center' },
  hint: { fontSize: 11, color: '#9aa29c', marginTop: -2 },
});
