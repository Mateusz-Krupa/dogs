import Svg, { Circle, G, Path } from 'react-native-svg';

import { DogPoseGlyph, type Pose } from './DogPose';

/**
 * A scene pictogram for each behaviour problem.
 *
 * Where StepDiagram answers “what does my hand do“, these answer “what is
 * going on“: the dog, the thing that triggers it, and the spatial truth that
 * matters — distance to the tram, the door it bolts through, the clock of an
 * empty flat. One dog scale across all cards so the set reads as a family.
 *
 * The dog sits at 70% scale, ground aligned at y=82 like every other glyph
 * in this app; the props live on the right strip, x 62..98.
 */

const INK = '#2f3a35';
const ACCENT = '#2e6f4e';
const TREAT = '#c9872b';

const DOG_SCALE = 0.7;
/** Shift that keeps the scaled dog's own ground line at y=82. */
const DOG_SHIFT = 82 * (1 - DOG_SCALE);

export interface ProblemSceneProps {
  readonly id: string;
  readonly size?: number;
  readonly color?: string;
  readonly accent?: string;
}

function Dog({ pose, color, accent }: { pose: Pose; color: string; accent: string }) {
  return (
    <G transform={`translate(0 ${DOG_SHIFT}) scale(${DOG_SCALE})`}>
      <DogPoseGlyph accent={accent} color={color} pose={pose} />
    </G>
  );
}

/** An abstract person: dot head over a rounded body, feet on the ground. */
function Person({ x, color, opacity = 1 }: { x: number; color: string; opacity?: number }) {
  return (
    <G opacity={opacity}>
      <Circle cx={x} cy={40} r={6} fill={color} fillOpacity={0.85 * opacity} />
      <Path d={`M ${x - 6} 50 Q ${x - 6} 47 ${x - 3} 47 L ${x + 3} 47 Q ${x + 6} 47 ${x + 6} 50 L ${x + 6} 82 L ${x - 6} 82 Z`} fill={color} fillOpacity={0.85 * opacity} />
    </G>
  );
}

/** A door at the right edge: the leaf line and a knob. */
function Door({ color, accent }: { color: string; accent: string }) {
  return (
    <G>
      <Path d="M 93 34 L 93 82" stroke={color} strokeWidth={3} strokeOpacity={0.55} strokeLinecap="round" />
      <Circle cx={89} cy={60} r={2.5} fill={accent} />
    </G>
  );
}

/** Sound arcs aimed right — barking when paired with the muzzle, ringing at a bell. */
function Bark({ x, y, accent, flip = false }: { x: number; y: number; accent: string; flip?: boolean }) {
  const s = flip ? -1 : 1;
  return (
    <G>
      <Path d={`M ${x} ${y - 6} Q ${x + 6 * s} ${y} ${x} ${y + 6}`} stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" />
      <Path d={`M ${x + 5 * s} ${y - 11} Q ${x + 14 * s} ${y} ${x + 5 * s} ${y + 11}`} stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" opacity={0.5} />
    </G>
  );
}

/** The friction zigzag between two dogs who should not have to meet. */
function Friction({ accent }: { accent: string }) {
  return (
    <Path d="M 50 72 L 56 64 L 52 76 L 60 67" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" />
  );
}

/** A little dog of the same breed, for “there is another dog out there“. */
/** Mirrored: two dogs facing each other is the whole story here. */
function SmallDog({ color, accent }: { color: string; accent: string }) {
  return (
    <G transform={`translate(100 ${82 - 82 * 0.34}) scale(-0.34 0.34)`}>
      <DogPoseGlyph accent={accent} color={color} pose="sit" />
    </G>
  );
}

function Car({ color }: { color: string }) {
  return (
    <G>
      <Path d="M 72 48 L 92 48 Q 95 48 95 52 L 95 62 L 69 62 L 69 52 Q 69 48 72 48 Z" fill={color} fillOpacity={0.4} />
      <Path d="M 66 60 L 98 60 Q 100 60 100 63 L 100 72 Q 100 75 97 75 L 69 75 Q 66 75 66 72 Z" fill={color} fillOpacity={0.55} />
      <Circle cx={74} cy={77} r={4} fill={color} />
      <Circle cx={92} cy={77} r={4} fill={color} />
    </G>
  );
}

/** Dashed distance gauge with heads both ways: the gap that makes work possible. */
function Distance({ accent }: { accent: string }) {
  return (
    <G>
      <Path d="M 50 76 L 60 76" stroke={accent} strokeWidth={3} strokeLinecap="round" strokeDasharray="5 4" />
      <Path d="M 46 76 L 53 72 L 53 80 Z" fill={accent} />
      <Path d="M 64 76 L 57 72 L 57 80 Z" fill={accent} />
    </G>
  );
}

function Clock({ accent }: { accent: string }) {
  return (
    <G>
      <Circle cx={78} cy={40} r={11} fill="none" stroke={accent} strokeWidth={3} />
      <Path d="M 78 40 L 78 33" stroke={accent} strokeWidth={2.5} strokeLinecap="round" />
      <Path d="M 78 40 L 83 42" stroke={accent} strokeWidth={2.5} strokeLinecap="round" />
    </G>
  );
}

function Bolt({ accent }: { accent: string }) {
  return <Path d="M 26 12 L 17 31 L 25 31 L 16 47" stroke={accent} strokeWidth={3.5} strokeLinecap="round" strokeLinejoin="round" fill="none" />;
}

/** The window: frame and mullion, the television the dog is not allowed to watch. */
function Window({ color }: { color: string }) {
  return (
    <G>
      <Path d="M 68 30 L 96 30 L 96 72 L 68 72 Z" fill="none" stroke={color} strokeOpacity={0.5} strokeWidth={3} />
      <Path d="M 82 30 L 82 72" stroke={color} strokeOpacity={0.35} strokeWidth={2} />
    </G>
  );
}

/** The counter edge with a treat tipping over it. */
function Counter({ color, treat }: { color: string; treat: string }) {
  return (
    <G>
      <Path d="M 40 46 L 98 46 Q 100 46 100 49 L 100 52 L 40 52 Z" fill={color} fillOpacity={0.5} />
      <Circle cx={52} cy={37} r={5} fill={treat} />
      <Path d="M 50 41 Q 44 50 40 57" stroke={treat} strokeWidth={2.5} strokeDasharray="4 4" fill="none" />
    </G>
  );
}

interface SceneSpec {
  readonly pose: Pose;
  readonly extras: (color: string, accent: string) => React.ReactNode;
}

const SCENES: Readonly<Record<string, SceneSpec>> = {
  'bark-door': {
    pose: 'sit',
    extras: (_c, accent) => (
      <G>
        <Door accent={accent} color={_c} />
        <Bark accent={accent} x={62} y={40} />
        <Circle cx={76} cy={24} r={4} fill={accent} />
        <Bark accent={accent} flip x={67} y={24} />
      </G>
    ),
  },
  'bark-window': {
    pose: 'sit',
    extras: (color, accent) => (
      <G>
        <Window color={color} />
        <Bark accent={accent} x={60} y={44} />
      </G>
    ),
  },
  jumping: {
    pose: 'stand',
    extras: (color, accent) => (
      <G>
        <Person color={color} x={84} />
        <Path d="M 50 48 Q 62 30 74 44" stroke={accent} strokeWidth={3} strokeLinecap="round" strokeDasharray="5 4" fill="none" />
        <Path d="M 76 47 L 68 44 L 73 36 Z" fill={accent} />
      </G>
    ),
  },
  nipping: {
    pose: 'stand',
    extras: (color, accent) => (
      <G>
        <Person color={color} x={80} />
        <Path d="M 72 70 L 66 66 M 71 76 L 64 76 M 72 82 L 66 86" stroke={accent} strokeWidth={2.5} strokeLinecap="round" />
      </G>
    ),
  },
  stealing: {
    pose: 'down',
    extras: (color, _a) => <Counter color={color} treat={TREAT} />,
  },
  bolting: {
    pose: 'come',
    extras: (color, accent) => (
      <G>
        <Door accent={accent} color={color} />
        <Person color={color} opacity={0.45} x={66} />
        <Path d="M 44 74 L 76 74" stroke={accent} strokeWidth={3} strokeDasharray="6 5" strokeLinecap="round" />
        <Path d="M 86 74 L 76 69 L 76 79 Z" fill={accent} />
      </G>
    ),
  },
  reactivity: {
    pose: 'stand',
    extras: (color, accent) => (
      <G>
        <Path d="M 0 50 Q 14 57 26 57" stroke={accent} strokeWidth={2.5} fill="none" strokeLinecap="round" />
        <Friction accent={accent} />
        <SmallDog accent={accent} color={color} />
      </G>
    ),
  },
  traffic: {
    pose: 'stand',
    extras: (color, accent) => (
      <G>
        <Car color={color} />
        <Distance accent={accent} />
      </G>
    ),
  },
  noise: {
    pose: 'down',
    extras: (_c, accent) => (
      <G>
        <Bolt accent={accent} />
        <Path d="M 10 58 Q 3 65 10 72" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" opacity={0.8} />
        <Path d="M 15 54 Q 2 65 15 76" stroke={accent} strokeWidth={3} strokeLinecap="round" fill="none" opacity={0.4} />
      </G>
    ),
  },
  alone: {
    pose: 'down',
    extras: (color, accent) => (
      <G>
        <Door accent={accent} color={color} />
        <Clock accent={accent} />
      </G>
    ),
  },
};

/** True when a scene exists for this problem id. */
export function hasProblemScene(id: string): boolean {
  return SCENES[id] !== undefined;
}

export function ProblemScene({ id, size = 140, color = INK, accent = ACCENT }: ProblemSceneProps) {
  const scene = SCENES[id];
  if (!scene) return null;
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      <Dog accent={accent} color={color} pose={scene.pose} />
      {scene.extras(color, accent)}
    </Svg>
  );
}
