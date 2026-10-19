import Svg, { Circle, G, Path, Rect } from 'react-native-svg';

/**
 * A small top-down diagram of how a scent game is laid out.
 *
 * Deliberately schematic rather than pictorial: these answer "where do I put
 * things and how far apart", which a photograph of someone's living room would
 * not. Food is dots, the handler is a ring, distance is implied by spacing.
 *
 * Canvas 160×70, read left to right.
 */

export interface SetupSceneProps {
  readonly activity: string;
  readonly level: number;
  readonly width?: number;
}

const INK = '#4a554f';
const FOOD = '#c9872b';
const BLUE = '#2a4a6b';

/** Evenly jittered food dots inside a box, deterministic by index. */
function foodDots(x: number, y: number, w: number, h: number, n: number) {
  const dots = [];
  for (let i = 0; i < n; i += 1) {
    const col = i % 5;
    const row = Math.floor(i / 5);
    const jx = ((i * 37) % 11) - 5;
    const jy = ((i * 53) % 9) - 4;
    dots.push(
      <Circle
        cx={x + 8 + col * ((w - 16) / 4) + jx * 0.6}
        cy={y + 8 + row * ((h - 16) / 2) + jy * 0.6}
        fill={FOOD}
        key={i}
        r={2.4}
      />
    );
  }
  return dots;
}

export function SetupScene({ activity, level, width = 180 }: SetupSceneProps) {
  const s = { stroke: INK, strokeWidth: 2, fill: 'none', strokeLinejoin: 'round' as const };

  return (
    <Svg width={width} height={width * 0.44} viewBox="0 0 160 70">
      {activity === 'scatter' && (
        <G>
          {level === 2 ? (
            <G>
              {/* grass patch, wider area */}
              <Rect x={14} y={14} width={132} height={44} rx={6} {...s} strokeDasharray="5 4" />
              {[0, 1, 2, 3, 4, 5, 6, 7].map((i) => (
                <Path d={`M ${22 + i * 17} 58 Q ${24 + i * 17} 46 ${28 + i * 17} 42`} key={i} stroke={INK} strokeOpacity={0.4} strokeWidth={1.6} fill="none" />
              ))}
              {foodDots(14, 14, 132, 44, 10)}
            </G>
          ) : (
            <G>
              <Rect x={34} y={16} width={92} height={40} rx={5} {...s} />
              {foodDots(34, 16, 92, 40, 9)}
            </G>
          )}
        </G>
      )}

      {activity === 'snuffle' && (
        <G>
          {level === 3 ? (
            <G>
              {/* box with crumpled paper */}
              <Rect x={44} y={18} width={72} height={38} rx={4} {...s} />
              {[0, 1, 2].map((i) => (
                <Circle cx={60 + i * 22} cy={34} key={i} r={10} stroke={INK} strokeWidth={1.8} fill="none" strokeDasharray="4 3" />
              ))}
              <Circle cx={60} cy={40} fill={FOOD} r={2.4} />
              <Circle cx={92} cy={30} fill={FOOD} r={2.4} />
            </G>
          ) : (
            <G>
              {/* rolled towel, end on */}
              <Rect x={34} y={22} width={92} height={28} rx={14} {...s} />
              <Path d="M 58 22 Q 62 36 58 50" stroke={INK} strokeWidth={1.8} fill="none" strokeOpacity={0.6} />
              <Path d="M 84 22 Q 88 36 84 50" stroke={INK} strokeWidth={1.8} fill="none" strokeOpacity={0.6} />
              <Circle cx={46} cy={36} fill={FOOD} r={2.4} />
              <Circle cx={71} cy={36} fill={FOOD} r={2.4} />
              <Circle cx={100} cy={36} fill={FOOD} r={2.4} />
            </G>
          )}
        </G>
      )}

      {activity === 'cups' && (
        <G>
          {Array.from({ length: level === 1 ? 2 : level === 2 ? 3 : 5 }, (_, i) => {
            const count = level === 1 ? 2 : level === 2 ? 3 : 5;
            const gap = 130 / count;
            const x = 22 + i * gap;
            const hidden = i === Math.floor(count / 2);
            return (
              <G key={i}>
                <Path d={`M ${x - 11} 52 L ${x - 7} 26 L ${x + 7} 26 L ${x + 11} 52 Z`} {...s} />
                {hidden ? <Circle cx={x} cy={46} fill={FOOD} r={2.6} /> : null}
              </G>
            );
          })}
        </G>
      )}

      {activity === 'find-toy' && (
        <G>
          {/* room outline with a toy tucked behind furniture */}
          <Rect x={14} y={12} width={132} height={48} rx={4} {...s} />
          <Rect x={24} y={34} width={34} height={18} rx={3} {...s} strokeOpacity={0.6} />
          {level >= 2 ? <Rect x={96} y={20} width={30} height={14} rx={3} {...s} strokeOpacity={0.6} /> : null}
          <Circle cx={level === 1 ? 80 : level === 2 ? 68 : 112} cy={level === 3 ? 27 : 44} fill={BLUE} r={4.5} />
          {level === 3 ? <Path d="M 80 12 L 80 60" {...s} strokeDasharray="4 4" strokeOpacity={0.5} /> : null}
        </G>
      )}

      {activity === 'find-person' && (
        <G>
          <Rect x={14} y={12} width={132} height={48} rx={4} {...s} />
          {level >= 2 ? <Path d="M 80 12 L 80 60" {...s} strokeDasharray="4 4" strokeOpacity={0.5} /> : null}
          {/* dog start */}
          <Circle cx={34} cy={36} r={6} stroke={INK} strokeWidth={2} fill="none" />
          {/* person hidden */}
          <Circle cx={level === 1 ? 86 : 122} cy={36} r={7} fill={BLUE} />
          <Path
            d={`M 42 36 Q ${level === 1 ? 64 : 82} ${level === 1 ? 26 : 20} ${level === 1 ? 78 : 114} 36`}
            {...s}
            strokeDasharray="5 4"
            strokeOpacity={0.6}
          />
        </G>
      )}

      {activity === 'track' && (
        <G>
          {/* footprints, with a corner at level 3 */}
          {Array.from({ length: level === 1 ? 5 : 8 }, (_, i) => {
            const corner = level === 3 && i >= 5;
            const x = corner ? 104 : 20 + i * (level === 1 ? 20 : 14);
            const y = corner ? 50 - (i - 5) * 13 : 46;
            return <Circle cx={x} cy={y} fill={INK} fillOpacity={0.5} key={i} r={3} />;
          })}
          <Circle cx={level === 3 ? 104 : level === 1 ? 108 : 124} cy={level === 3 ? 14 : 46} fill={FOOD} r={4.5} />
          {level >= 2 ? (
            <Path d="M 20 60 L 140 60" {...s} strokeDasharray="3 5" strokeOpacity={0.4} />
          ) : null}
        </G>
      )}
    </Svg>
  );
}
