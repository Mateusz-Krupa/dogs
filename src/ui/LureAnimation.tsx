import { useEffect, useRef, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import Svg, { Circle, G, Path, Rect } from 'react-native-svg';

import { LureHand } from './LureHand';
import type { LureStage } from './lureStages';

/**
 * The lure, animated.
 *
 * ## Why a capsule dog
 *
 * The dog is built from thick round-capped strokes — a hip, a torso, a neck,
 * four legs — rather than one outlined silhouette. An outline has to be redrawn
 * for every frame of a fold; a skeleton only needs its joints moved, and stays
 * recognisable at every position in between.
 *
 * ## Why the stage matters
 *
 * The same fold is practised three different ways as the ladder progresses:
 * following food, following an empty hand, and responding to a word with no
 * hand at all. Showing the food lure on a verbal step would contradict the
 * instruction printed right below it.
 */

export type LureKind = 'sit' | 'down';

export interface LureAnimationProps {
  readonly kind: LureKind;
  readonly stage: LureStage;
  readonly size?: number;
  readonly color?: string;
  readonly accent?: string;
}

const INK = '#2f3a35';
const ACCENT = '#2e6f4e';
const GROUND_Y = 86;
const DURATION = 3200;
const HOLD = 700;

const mix = (a: number, b: number, t: number) => a + (b - a) * t;
const ease = (t: number) => (t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) ** 2 / 2);

/** Loop time to phases: the lure travels, then the fold, then a pause, then payment. */
function phase(t: number) {
  return {
    lure: ease(Math.min(1, t / 0.3)),
    fold: t < 0.3 ? 0 : ease(Math.min(1, (t - 0.3) / 0.35)),
    pay: t < 0.85 ? 0 : (t - 0.85) / 0.15,
  };
}

/** Drives a 0–1 loop with a hold at the end, so the final frame can be read. */
function useLoop(playing: boolean, resetKey: string) {
  const [t, setT] = useState(0);
  const started = useRef(0);

  useEffect(() => {
    started.current = 0;
    setT(0);
    if (!playing) return;
    let frame = 0;
    let cancelled = false;
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
    };
  }, [playing, resetKey]);

  return t;
}

export function LureAnimation({
  kind,
  stage,
  size = 190,
  color = INK,
  accent = ACCENT,
}: LureAnimationProps) {
  const [playing, setPlaying] = useState(true);
  const t = useLoop(playing, `${kind}-${stage}`);
  const { lure, fold, pay } = phase(t);
  const sit = kind === 'sit';

  const hipX = mix(36, sit ? 33 : 34, fold);
  const hipY = mix(50, sit ? 68 : 70, fold);
  const shoulderX = mix(66, sit ? 63 : 64, fold);
  const shoulderY = mix(48, sit ? 46 : 70, fold);

  // On a verbal step there is no hand to follow, so the head simply tracks the
  // fold rather than reaching for anything.
  const reach = stage === 'verbal' ? 0 : lure;
  const headX = sit ? mix(mix(84, 80, reach), 76, fold) : mix(mix(84, 88, reach), 90, fold);
  const headY = sit ? mix(mix(42, 30, reach), 32, fold) : mix(mix(42, 56, reach), 74, fold);
  const headTilt = sit ? mix(mix(0, -22, reach), -16, fold) : mix(mix(0, 24, reach), 34, fold);

  const limb = { stroke: color, strokeLinecap: 'round' as const, fill: 'none' };

  return (
    <View style={styles.wrap}>
      <Pressable accessibilityLabel={`${kind} ${stage}`} accessibilityRole="button" onPress={() => setPlaying((p) => !p)}>
        <Svg width={size} height={size * 0.72} viewBox="0 0 130 94">
          <Rect x={8} y={GROUND_Y} width={114} height={3.5} rx={1.75} fill={color} fillOpacity={0.18} />

          <Path d={`M ${hipX} ${hipY} L ${hipX + 2} ${GROUND_Y}`} {...limb} strokeWidth={9} />
          <Path d={`M ${shoulderX} ${shoulderY} L ${shoulderX + 1} ${GROUND_Y}`} {...limb} strokeWidth={9} />
          <Path d={`M ${shoulderX - 7} ${shoulderY} L ${shoulderX - 6} ${GROUND_Y}`} {...limb} strokeWidth={8} />
          <Path d={`M ${hipX} ${hipY} L ${shoulderX} ${shoulderY}`} {...limb} strokeWidth={21} />
          <Circle cx={hipX} cy={hipY} r={11.5} fill={color} />
          <Path d={`M ${shoulderX} ${shoulderY - 4} L ${headX - 6} ${headY + 4}`} {...limb} strokeWidth={13} />
          <Path
            d={`M ${hipX - 4} ${hipY - 6} Q ${hipX - 18} ${hipY - 12} ${hipX - 13} ${hipY - 22}`}
            {...limb}
            strokeWidth={6}
          />

          <G transform={`translate(${headX} ${headY}) rotate(${headTilt})`}>
            <Circle cx={0} cy={0} r={11} fill={color} />
            <Path d="M 6 1 L 21 4 Q 24 6 21 9 L 6 10 Z" fill={color} />
            <Path d="M -7 -8 Q -16 -20 -2 -16 Q 2 -13 -1 -8 Z" fill={color} />
            <Circle cx={3} cy={-2} r={2.1} fill="#ffffff" fillOpacity={0.9} />
          </G>

          {stage === 'verbal' ? (
            // No hand at all. The cue is the word, so the only thing to draw is
            // that something was said.
            <G opacity={lure}>
              <Path d="M 112 22 Q 118 22 118 28" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" />
              <Path d="M 106 16 Q 118 16 118 28" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" opacity={0.55} />
            </G>
          ) : (
            <LureHand
              color={accent}
              rotate={sit ? -14 : 24}
              treat={stage === 'lure'}
              treatOpacity={pay > 0 ? 1 - pay : 1}
              x={headX + 30}
              y={headY + 16 - 6 * (1 - lure)}
            />
          )}
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
