import React, { useEffect, useRef, useState } from 'react';

// ============================================================================
// TYPES
// ============================================================================
interface Point {
    x: number;
    y: number;
}

interface Particle {
    x: number;
    y: number;
    vx: number;
    vy: number;
    life: number;
    maxLife: number;
    size: number;
}

interface Landmark {
    x: number;
    name: string;
    reached: boolean;
}

type Rock = { x: number; size: number; seed: number };

type Biome = {
    name: string;
    baseY: number; // fraction of WORLD_HEIGHT
    roughness: number;
    seed: number;
    ground: string;
    rock: string;
    rockDensity: number;
    skyDay: [string, string, string];
    skyDusk: [string, string, string];
    sun: [string, string];
};

// ============================================================================
// HELPERS
// ============================================================================
function lerp(a: number, b: number, t: number): number {
    return a + (b - a) * t;
}

function easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, 3);
}

function clamp(v: number, a: number, b: number): number {
    return Math.max(a, Math.min(b, v));
}

function lerpColor(hex1: string, hex2: string, t: number): string {
    const r1 = parseInt(hex1.slice(1, 3), 16);
    const g1 = parseInt(hex1.slice(3, 5), 16);
    const b1 = parseInt(hex1.slice(5, 7), 16);

    const r2 = parseInt(hex2.slice(1, 3), 16);
    const g2 = parseInt(hex2.slice(3, 5), 16);
    const b2 = parseInt(hex2.slice(5, 7), 16);

    const r = Math.round(r1 + (r2 - r1) * t);
    const g = Math.round(g1 + (g2 - g1) * t);
    const b = Math.round(b1 + (b2 - b1) * t);

    return `rgb(${r}, ${g}, ${b})`;
}

// Deterministic pseudo-random number generator
function pseudoRandom(seed: number): number {
    const x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
}

function sampleTerrainY(points: Point[], worldX: number, worldWidth: number): number {
    const n = points.length - 1;
    const nx = clamp(worldX / worldWidth, 0, 1);
    const idx = nx * n;
    const lo = Math.floor(idx);
    const hi = Math.min(lo + 1, n);
    const t = idx - lo;
    return lerp(points[lo].y, points[hi].y, t);
}

function blendTerrain(a: Point[], b: Point[], t: number): Point[] {
    if (!a.length) return b;
    if (!b.length) return a;
    const n = Math.min(a.length, b.length);
    const out: Point[] = new Array(n);
    for (let i = 0; i < n; i++) {
        out[i] = { x: a[i].x, y: lerp(a[i].y, b[i].y, t) };
    }
    return out;
}

function generateRocks(worldWidth: number, seed: number, density: number): Rock[] {
    const rocks: Rock[] = [];
    const count = Math.floor((worldWidth / 300) * density);

    for (let i = 0; i < count; i++) {
        const s = seed * 1000 + i * 17;
        const x = pseudoRandom(s) * worldWidth;
        const size = 6 + pseudoRandom(s + 9) * 22;
        rocks.push({ x, size, seed: s });
    }

    rocks.sort((r1, r2) => r1.x - r2.x);
    return rocks;
}

// Quick RGB helper for internal dusk blending
function rgbToHex(rgb: string): string {
    // rgb(r, g, b)
    const m = rgb.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (!m) return '#000000';
    const r = clamp(parseInt(m[1], 10), 0, 255);
    const g = clamp(parseInt(m[2], 10), 0, 255);
    const b = clamp(parseInt(m[3], 10), 0, 255);
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
}

// ============================================================================
// TERRAIN GENERATION
// ============================================================================
function generateTerrainLayer(width: number, baseY: number, roughness: number, seedOffset: number): Point[] {
    const points: Point[] = [];
    const segments = 150;

    for (let i = 0; i <= segments; i++) {
        const x = (i / segments) * width;
        const normalizedX = i / segments;

        let y = baseY;
        y += Math.sin(normalizedX * Math.PI * 2 + seedOffset) * roughness * 80;
        y += Math.sin(normalizedX * Math.PI * 6 + seedOffset) * roughness * 40;
        y += Math.sin(normalizedX * Math.PI * 12 + seedOffset) * roughness * 20;
        y += (pseudoRandom(i + seedOffset * 100) - 0.5) * roughness * 10;

        points.push({ x, y });
    }

    return points;
}

const LANDMARKS: Omit<Landmark, 'reached'>[] = [
    { x: 0.12, name: 'Mountain Trail' },
    { x: 0.28, name: 'Hilltop View' },
    { x: 0.45, name: 'Valley Path' },
    { x: 0.62, name: 'Ridge Walk' },
    { x: 0.78, name: 'Scenic Overlook' },
    { x: 0.92, name: "Journey's End" }
];

// ============================================================================
// BIOMES (change every 1k steps)
// ============================================================================
const BIOMES: readonly Biome[] = [
    {
        name: 'Mongolia 🇲🇳',
        baseY: 0.84,
        roughness: 0.85,
        seed: 101,
        ground: '#2c3a2a',
        rock: '#1a1a1a',
        rockDensity: 0.8,
        skyDay: ['#86D3FF', '#BDEBFF', '#E9D8B3'],
        skyDusk: ['#5B6DA8', '#7A82B9', '#E0B693'],
        sun: ['#FFEFA3', '#FFB56A']
    },
    {
        name: 'China (Xinjiang) 🇨🇳',
        baseY: 0.83,
        roughness: 0.75,
        seed: 111,
        ground: '#4a3a22',
        rock: '#231a10',
        rockDensity: 1.0,
        skyDay: ['#7FD6FF', '#C7F0FF', '#F1D7A8'],
        skyDusk: ['#B06457', '#D38A73', '#F1C2A0'],
        sun: ['#FFF0B0', '#FF8F66']
    },
    {
        name: 'Kazakhstan 🇰🇿',
        baseY: 0.845,
        roughness: 0.95,
        seed: 121,
        ground: '#2a3b2e',
        rock: '#131417',
        rockDensity: 0.9,
        skyDay: ['#84CCFF', '#B9E8FF', '#EADFC0'],
        skyDusk: ['#516AA3', '#6E7DB6', '#DAB89E'],
        sun: ['#FFEFA3', '#FFAF70']
    },
    {
        name: 'Uzbekistan 🇺🇿',
        baseY: 0.835,
        roughness: 0.8,
        seed: 131,
        ground: '#3b2f23',
        rock: '#1a1510',
        rockDensity: 1.1,
        skyDay: ['#7FD1FF', '#BFEAFF', '#F0D7B0'],
        skyDusk: ['#7E5B8F', '#A07AA6', '#E4B9A2'],
        sun: ['#FFE87C', '#FF8C69']
    },
    {
        name: 'Turkmenistan 🇹🇲',
        baseY: 0.84,
        roughness: 0.7,
        seed: 141,
        ground: '#5a3b1c',
        rock: '#2b1d0f',
        rockDensity: 0.95,
        skyDay: ['#8BD3FF', '#CDEEFF', '#F3D6A6'],
        skyDusk: ['#B4655C', '#D08A73', '#F2C7A8'],
        sun: ['#FFF0A6', '#FF8A5B']
    },
    {
        name: 'Iran (Persia) 🇮🇷',
        baseY: 0.83,
        roughness: 1.05,
        seed: 151,
        ground: '#2f2b3d',
        rock: '#0f0f12',
        rockDensity: 1.2,
        skyDay: ['#7EC6E6', '#A5D8E8', '#D7DCE0'],
        skyDusk: ['#4B3C7A', '#6C4E9A', '#C79AB2'],
        sun: ['#FFE87C', '#FF6B4A']
    }
];

// ============================================================================
// MAIN COMPONENT
// ============================================================================
export default function FantasyHikeProgress() {
    const canvasRef = useRef < HTMLCanvasElement > (null);
    const [steps, setSteps] = useState(0);
    const [landmarkNotification, setLandmarkNotification] = useState < string | null > (null);
    const [biomeNotification, setBiomeNotification] = useState < string | null > (null);

    const stepsRef = useRef(0);
    const lastStepsRef = useRef(0);

    const animationFrameRef = useRef < number > ();
    const cameraRef = useRef({ x: 0 });

    const markerPosRef = useRef({ x: 0, y: 0 });
    const targetMarkerPosRef = useRef({ x: 0, y: 0 });

    const bobOffsetRef = useRef(0);
    const walkCycleRef = useRef(0);

    const particlesRef = useRef < Particle[] > ([]);
    const stepTweenRef = useRef({ active: false, progress: 0, startX: 0, endX: 0 });
    const shakeRef = useRef({ x: 0, y: 0, intensity: 0 });

    const terrainRef = useRef < Point[] > ([]);
    const terrainFromRef = useRef < Point[] > ([]);
    const terrainToRef = useRef < Point[] > ([]);

    const rocksFromRef = useRef < Rock[] > ([]);
    const rocksToRef = useRef < Rock[] > ([]);

    const landmarksRef = useRef < Landmark[] > ([]);

    const biomeIndexRef = useRef(0);
    const biomeFromRef = useRef(0);
    const biomeToRef = useRef(0);
    const biomeTransitionRef = useRef({ active: false, t: 1 });

    const METERS_PER_STEP = 0.8;
    const WORLD_WIDTH = 8000;
    const WORLD_HEIGHT = 1000;

    const MARKER_SIZE = 28;
    const CAMERA_LERP_SPEED = 0.06;
    const BOB_SPEED = 0.08;
    const BOB_AMPLITUDE = 3;

    // Init
    useEffect(() => {
        const b = BIOMES[0];
        const initial = generateTerrainLayer(WORLD_WIDTH, WORLD_HEIGHT * b.baseY, b.roughness, b.seed);
        terrainRef.current = initial;
        terrainFromRef.current = initial;
        terrainToRef.current = initial;

        rocksFromRef.current = generateRocks(WORLD_WIDTH, b.seed, b.rockDensity);
        rocksToRef.current = rocksFromRef.current;

        landmarksRef.current = LANDMARKS.map(lm => ({
            ...lm,
            x: lm.x * WORLD_WIDTH,
            reached: false
        }));
    }, []);

    // Steps + biome changes
    useEffect(() => {
        const stepDiff = steps - lastStepsRef.current;

        const nextBiomeIndex = Math.floor(steps / 1000) % BIOMES.length;
        if (nextBiomeIndex !== biomeIndexRef.current) {
            const from = biomeIndexRef.current;
            const to = nextBiomeIndex;

            const currentBlendT = biomeTransitionRef.current.active ? easeOutCubic(biomeTransitionRef.current.t) : 1;
            const currentTerrain = blendTerrain(terrainFromRef.current, terrainToRef.current, currentBlendT);
            terrainFromRef.current = currentTerrain;
            terrainRef.current = currentTerrain;

            biomeFromRef.current = from;
            biomeToRef.current = to;
            biomeIndexRef.current = to;

            const bFrom = BIOMES[from];
            const bTo = BIOMES[to];

            terrainToRef.current = generateTerrainLayer(WORLD_WIDTH, WORLD_HEIGHT * bTo.baseY, bTo.roughness, bTo.seed);

            rocksFromRef.current = rocksToRef.current.length
                ? rocksToRef.current
                : generateRocks(WORLD_WIDTH, bFrom.seed, bFrom.rockDensity);

            rocksToRef.current = generateRocks(WORLD_WIDTH, bTo.seed, bTo.rockDensity);

            biomeTransitionRef.current = { active: true, t: 0 };

            setBiomeNotification(bTo.name);
            window.setTimeout(() => setBiomeNotification(null), 2200);

            shakeRef.current.intensity = 2;
            landmarksRef.current = landmarksRef.current.map(lm => ({ ...lm, reached: false }));
        }

        if (stepDiff > 0) {
            stepTweenRef.current = {
                active: true,
                progress: 0,
                startX: markerPosRef.current.x,
                endX: Math.min(steps * METERS_PER_STEP, WORLD_WIDTH - 100)
            };

            for (let i = 0; i < 2; i++) {
                particlesRef.current.push({
                    x: markerPosRef.current.x,
                    y: markerPosRef.current.y,
                    vx: (Math.random() - 0.5) * 1.5,
                    vy: -Math.random() * 1.5 - 0.5,
                    life: 1,
                    maxLife: 20 + Math.random() * 15,
                    size: 1.5 + Math.random() * 1.5
                });
            }

            if (stepDiff >= 100) shakeRef.current.intensity = 6;
        }

        stepsRef.current = steps;
        lastStepsRef.current = steps;
    }, [steps]);

    // Render
    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;

        const ctx = canvas.getContext('2d', { alpha: false });
        if (!ctx) return;

        let viewWidth = 0;
        let viewHeight = 0;
        let dpr = 1;

        const resize = () => {
            dpr = window.devicePixelRatio || 1;
            const rect = canvas.getBoundingClientRect();
            viewWidth = rect.width;
            viewHeight = rect.height;
            canvas.width = viewWidth * dpr;
            canvas.height = viewHeight * dpr;
            ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        };

        resize();
        window.addEventListener('resize', resize);

        const timeProgress = () => Math.min((stepsRef.current * METERS_PER_STEP) / WORLD_WIDTH, 1);

        const drawSky = (progress: number) => {
            const raw = biomeTransitionRef.current.active ? biomeTransitionRef.current.t : 1;
            const t = biomeTransitionRef.current.active ? easeOutCubic(raw) : 1;

            const bFrom = BIOMES[biomeFromRef.current];
            const bTo = BIOMES[biomeToRef.current];

            const dayTop = lerpColor(bFrom.skyDay[0], bTo.skyDay[0], t);
            const dayMid = lerpColor(bFrom.skyDay[1], bTo.skyDay[1], t);
            const dayBot = lerpColor(bFrom.skyDay[2], bTo.skyDay[2], t);

            const duskTop = lerpColor(bFrom.skyDusk[0], bTo.skyDusk[0], t);
            const duskMid = lerpColor(bFrom.skyDusk[1], bTo.skyDusk[1], t);
            const duskBot = lerpColor(bFrom.skyDusk[2], bTo.skyDusk[2], t);

            const gradient = ctx.createLinearGradient(0, 0, 0, viewHeight);

            if (progress < 0.7) {
                gradient.addColorStop(0, dayTop);
                gradient.addColorStop(0.6, dayMid);
                gradient.addColorStop(1, dayBot);
            } else {
                const td = (progress - 0.7) / 0.3;
                gradient.addColorStop(0, lerpColor(rgbToHex(dayTop), rgbToHex(duskTop), td));
                gradient.addColorStop(0.6, lerpColor(rgbToHex(dayMid), rgbToHex(duskMid), td));
                gradient.addColorStop(1, lerpColor(rgbToHex(dayBot), rgbToHex(duskBot), td));
            }

            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, viewWidth, viewHeight);

            if (progress < 0.88) {
                const sunProgress = progress / 0.88;
                const sunX = viewWidth * 0.2 + viewWidth * 0.6 * sunProgress;
                const sunY = viewHeight * 0.25 - Math.sin(sunProgress * Math.PI) * viewHeight * 0.15;

                const sunA0 = lerpColor(bFrom.sun[0], bTo.sun[0], t);
                const sunA1 = lerpColor(bFrom.sun[1], bTo.sun[1], t);
                const sunColor =
                    progress < 0.6 ? sunA0 : lerpColor(rgbToHex(sunA0), rgbToHex(sunA1), (progress - 0.6) / 0.28);

                const glowGradient = ctx.createRadialGradient(sunX, sunY, 0, sunX, sunY, 80);
                glowGradient.addColorStop(0, sunColor.replace(')', ', 0.55)').replace('rgb', 'rgba'));
                glowGradient.addColorStop(0.5, sunColor.replace(')', ', 0.18)').replace('rgb', 'rgba'));
                glowGradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
                ctx.fillStyle = glowGradient;
                ctx.fillRect(0, 0, viewWidth, viewHeight);

                ctx.fillStyle = sunColor;
                ctx.beginPath();
                ctx.arc(sunX, sunY, 40, 0, Math.PI * 2);
                ctx.fill();
            }

            if (progress > 0.85) {
                const starOpacity = (progress - 0.85) / 0.15;
                ctx.fillStyle = `rgba(255, 255, 255, ${starOpacity})`;
                for (let i = 0; i < 30; i++) {
                    const x = (i * viewWidth * 0.07) % viewWidth;
                    const y = (i * 37) % (viewHeight * 0.5);
                    const size = 1 + (i % 3) * 0.5;
                    ctx.beginPath();
                    ctx.arc(x, y, size, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
        };

        function drawSignpost(x: number, y: number, opacity: number) {
            ctx.globalAlpha = opacity;
            ctx.fillStyle = '#000';
            ctx.fillRect(x - 3, y - 60, 6, 60);
            ctx.fillRect(x - 25, y - 70, 50, 15);
            ctx.beginPath();
            ctx.moveTo(x + 25, y - 62.5);
            ctx.lineTo(x + 32, y - 62.5);
            ctx.lineTo(x + 28.5, y - 67.5);
            ctx.lineTo(x + 28.5, y - 57.5);
            ctx.closePath();
            ctx.fill();
            ctx.globalAlpha = 1;
        }

        function drawArchitecture(kind: 'yurt' | 'pagoda' | 'minaret' | 'iwan' | 'fort', x: number, groundY: number, s: number, alpha: number) {
            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.fillStyle = '#000';

            if (kind === 'yurt') {
                ctx.beginPath();
                ctx.ellipse(x, groundY - s * 0.35, s * 0.55, s * 0.35, 0, Math.PI, Math.PI * 2);
                ctx.closePath();
                ctx.fill();
                ctx.fillRect(x - s * 0.55, groundY - s * 0.35, s * 1.1, s * 0.35);
                ctx.clearRect(x - s * 0.12, groundY - s * 0.18, s * 0.24, s * 0.18);
            }

            if (kind === 'pagoda') {
                const tiers = 3;
                for (let i = 0; i < tiers; i++) {
                    const w = s * (1.1 - i * 0.25);
                    const h = s * 0.16;
                    const yy = groundY - s * 0.15 - i * (h + s * 0.08);
                    ctx.beginPath();
                    ctx.moveTo(x - w * 0.5, yy);
                    ctx.lineTo(x + w * 0.5, yy);
                    ctx.lineTo(x + w * 0.38, yy - h);
                    ctx.lineTo(x - w * 0.38, yy - h);
                    ctx.closePath();
                    ctx.fill();
                }
                ctx.fillRect(x - s * 0.18, groundY - s * 0.55, s * 0.36, s * 0.4);
            }

            if (kind === 'minaret') {
                ctx.fillRect(x - s * 0.12, groundY - s * 0.8, s * 0.24, s * 0.8);
                ctx.beginPath();
                ctx.arc(x, groundY - s * 0.82, s * 0.16, 0, Math.PI * 2);
                ctx.fill();
                ctx.beginPath();
                ctx.arc(x + s * 0.06, groundY - s * 0.98, s * 0.06, 0, Math.PI * 2);
                ctx.fill();
            }

            if (kind === 'iwan') {
                ctx.fillRect(x - s * 0.5, groundY - s * 0.65, s, s * 0.65);
                ctx.globalCompositeOperation = 'destination-out';
                ctx.beginPath();
                ctx.ellipse(x, groundY - s * 0.25, s * 0.28, s * 0.35, 0, Math.PI, Math.PI * 2);
                ctx.closePath();
                ctx.fill();
                ctx.globalCompositeOperation = 'source-over';
            }

            if (kind === 'fort') {
                ctx.fillRect(x - s * 0.6, groundY - s * 0.35, s * 1.2, s * 0.35);
                const crenels = 6;
                for (let i = 0; i < crenels; i++) {
                    if (i % 2 === 0) {
                        ctx.fillRect(
                            x - s * 0.6 + (i * (s * 1.2)) / crenels,
                            groundY - s * 0.47,
                            (s * 1.2) / crenels,
                            s * 0.12
                        );
                    }
                }
                ctx.fillRect(x - s * 0.78, groundY - s * 0.55, s * 0.22, s * 0.55);
            }

            ctx.restore();
        }

        function drawRocks(rocks: Rock[], terrainA: Point[], terrainB: Point[], bt: number, color: string, alpha: number) {
            if (alpha <= 0.001) return;
            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.fillStyle = color;

            const left = cameraRef.current.x - 120;
            const right = cameraRef.current.x + viewWidth + 120;

            for (let i = 0; i < rocks.length; i++) {
                const r = rocks[i];
                if (r.x < left) continue;
                if (r.x > right) break;

                const yA = sampleTerrainY(terrainA, r.x, WORLD_WIDTH);
                const yB = sampleTerrainY(terrainB, r.x, WORLD_WIDTH);
                const y = lerp(yA, yB, bt);

                const wobble = (pseudoRandom(r.seed + 3) - 0.5) * 2;
                const w = r.size * (0.9 + pseudoRandom(r.seed + 1) * 0.4);
                const h = r.size * (0.5 + pseudoRandom(r.seed + 2) * 0.35);

                ctx.beginPath();
                ctx.ellipse(r.x + wobble, y - h * 0.25, w, h, wobble * 0.03, 0, Math.PI * 2);
                ctx.fill();
            }

            ctx.restore();
        }

        const animate = () => {
            const progress = timeProgress();

            if (stepTweenRef.current.active) {
                stepTweenRef.current.progress += 0.06;
                if (stepTweenRef.current.progress >= 1) {
                    stepTweenRef.current.active = false;
                    stepTweenRef.current.progress = 1;
                }
                const eased = easeOutCubic(stepTweenRef.current.progress);
                targetMarkerPosRef.current.x = lerp(stepTweenRef.current.startX, stepTweenRef.current.endX, eased);
            } else {
                targetMarkerPosRef.current.x = Math.min(stepsRef.current * METERS_PER_STEP, WORLD_WIDTH - 100);
            }

            markerPosRef.current.x = lerp(markerPosRef.current.x, targetMarkerPosRef.current.x, 0.15);

            if (biomeTransitionRef.current.active) {
                biomeTransitionRef.current.t += 0.018;
                if (biomeTransitionRef.current.t >= 1) {
                    biomeTransitionRef.current.active = false;
                    biomeTransitionRef.current.t = 1;
                    terrainRef.current = terrainToRef.current;
                    terrainFromRef.current = terrainToRef.current;
                    rocksFromRef.current = rocksToRef.current;
                }
            }

            const bt = biomeTransitionRef.current.active ? easeOutCubic(biomeTransitionRef.current.t) : 1;
            const terrainA = terrainFromRef.current.length ? terrainFromRef.current : terrainRef.current;
            const terrainB = terrainToRef.current.length ? terrainToRef.current : terrainRef.current;

            markerPosRef.current.y = lerp(
                sampleTerrainY(terrainA, markerPosRef.current.x, WORLD_WIDTH),
                sampleTerrainY(terrainB, markerPosRef.current.x, WORLD_WIDTH),
                bt
            );

            for (const lm of landmarksRef.current) {
                if (!lm.reached && markerPosRef.current.x >= lm.x) {
                    lm.reached = true;
                    setLandmarkNotification(lm.name);
                    window.setTimeout(() => setLandmarkNotification(null), 2500);
                }
            }

            bobOffsetRef.current += BOB_SPEED;
            walkCycleRef.current += stepTweenRef.current.active ? 0.18 : 0.04;
            const bobY = Math.sin(bobOffsetRef.current) * BOB_AMPLITUDE;

            particlesRef.current = particlesRef.current.filter(p => {
                p.x += p.vx;
                p.y += p.vy;
                p.vy += 0.08;
                p.life++;
                return p.life < p.maxLife;
            });

            if (shakeRef.current.intensity > 0) {
                shakeRef.current.intensity *= 0.9;
                shakeRef.current.x = (Math.random() - 0.5) * shakeRef.current.intensity;
                shakeRef.current.y = (Math.random() - 0.5) * shakeRef.current.intensity;
            } else {
                shakeRef.current.x = 0;
                shakeRef.current.y = 0;
            }

            const targetCameraX = markerPosRef.current.x - viewWidth * 0.35;
            cameraRef.current.x = lerp(cameraRef.current.x, targetCameraX, CAMERA_LERP_SPEED);
            cameraRef.current.x = clamp(cameraRef.current.x, 0, WORLD_WIDTH - viewWidth);

            ctx.clearRect(0, 0, viewWidth, viewHeight);

            ctx.save();
            ctx.translate(shakeRef.current.x, shakeRef.current.y);

            drawSky(progress);

            const bFrom = BIOMES[biomeFromRef.current];
            const bTo = BIOMES[biomeToRef.current];

            const groundColor = lerpColor(bFrom.ground, bTo.ground, bt);
            const rockColor = lerpColor(bFrom.rock, bTo.rock, bt);

            ctx.save();
            ctx.translate(-cameraRef.current.x, 0);

            ctx.fillStyle = groundColor;
            ctx.beginPath();
            ctx.moveTo(0, WORLD_HEIGHT);
            for (let i = 0; i < terrainA.length; i++) {
                const x = terrainA[i].x;
                const y = lerp(terrainA[i].y, terrainB[i].y, bt);
                ctx.lineTo(x, y);
            }
            ctx.lineTo(WORLD_WIDTH, WORLD_HEIGHT);
            ctx.closePath();
            ctx.fill();

            if (biomeTransitionRef.current.active) {
                drawRocks(rocksFromRef.current, terrainA, terrainB, bt, rockColor, 1 - bt);
                drawRocks(rocksToRef.current, terrainA, terrainB, bt, rockColor, bt);
            } else {
                drawRocks(rocksToRef.current, terrainA, terrainB, bt, rockColor, 1);
            }

            const biomeName = BIOMES[biomeIndexRef.current].name;
            const archKind: 'yurt' | 'pagoda' | 'minaret' | 'iwan' | 'fort' =
                biomeName.startsWith('Mongolia')
                    ? 'yurt'
                    : biomeName.startsWith('China')
                        ? 'pagoda'
                        : biomeName.startsWith('Kazakhstan')
                            ? 'fort'
                            : biomeName.startsWith('Uzbekistan')
                                ? 'minaret'
                                : biomeName.startsWith('Turkmenistan')
                                    ? 'fort'
                                    : 'iwan';

            for (const lm of landmarksRef.current) {
                const x = lm.x;
                if (x < cameraRef.current.x - 120 || x > cameraRef.current.x + viewWidth + 120) continue;
                const y = lerp(sampleTerrainY(terrainA, x, WORLD_WIDTH), sampleTerrainY(terrainB, x, WORLD_WIDTH), bt);

                const s = 42;
                drawArchitecture(archKind, x - 34, y, s, 0.95);
                drawSignpost(x, y, 1);
            }

            for (const p of particlesRef.current) {
                const alpha = 1 - p.life / p.maxLife;
                ctx.fillStyle = `rgba(150, 150, 100, ${alpha * 0.5})`;
                ctx.beginPath();
                ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
                ctx.fill();
            }

            // Character
            ctx.save();
            ctx.translate(markerPosRef.current.x, markerPosRef.current.y);

            const charLift = -MARKER_SIZE * 0.08;
            ctx.translate(0, charLift);

            const groundY = 0;

            ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
            ctx.beginPath();
            ctx.ellipse(0, -charLift, MARKER_SIZE * 0.5, MARKER_SIZE * 0.08, 0, 0, Math.PI * 2);
            ctx.fill();

            const legSwing = Math.sin(walkCycleRef.current) * 0.35;
            const armSwing = Math.sin(walkCycleRef.current + Math.PI) * 0.3;

            const hipY = -MARKER_SIZE * 0.75 + bobY;
            const bodyBaseY = hipY;

            ctx.strokeStyle = '#3A7FC1';
            ctx.lineCap = 'round';
            ctx.lineJoin = 'round';

            const footRy = MARKER_SIZE * 0.08;
            const footY = -footRy * 0.9;

            ctx.lineWidth = MARKER_SIZE * 0.15;

            ctx.beginPath();
            ctx.moveTo(-MARKER_SIZE * 0.15, bodyBaseY);
            ctx.lineTo(-MARKER_SIZE * 0.15 - legSwing * MARKER_SIZE * 0.28, footY);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(MARKER_SIZE * 0.15, bodyBaseY);
            ctx.lineTo(MARKER_SIZE * 0.15 + legSwing * MARKER_SIZE * 0.28, footY);
            ctx.stroke();

            ctx.fillStyle = '#2A5F8F';
            ctx.beginPath();
            ctx.ellipse(-MARKER_SIZE * 0.15 - legSwing * MARKER_SIZE * 0.28, footY, MARKER_SIZE * 0.12, footRy, 0, 0, Math.PI * 2);
            ctx.fill();

            ctx.beginPath();
            ctx.ellipse(MARKER_SIZE * 0.15 + legSwing * MARKER_SIZE * 0.28, footY, MARKER_SIZE * 0.12, footRy, 0, 0, Math.PI * 2);
            ctx.fill();

            ctx.fillStyle = '#3A7FC1';
            ctx.beginPath();
            ctx.ellipse(0, bodyBaseY - MARKER_SIZE * 0.3, MARKER_SIZE * 0.38, MARKER_SIZE * 0.55, 0, 0, Math.PI * 2);
            ctx.fill();

            ctx.fillStyle = '#2A5F8F';
            ctx.fillRect(-MARKER_SIZE * 0.38, bodyBaseY - MARKER_SIZE * 0.5, MARKER_SIZE * 0.28, MARKER_SIZE * 0.4);

            ctx.strokeStyle = '#3A7FC1';
            ctx.lineWidth = MARKER_SIZE * 0.12;
            const shoulderY = bodyBaseY - MARKER_SIZE * 0.5;

            ctx.beginPath();
            ctx.moveTo(-MARKER_SIZE * 0.36, shoulderY);
            ctx.lineTo(-MARKER_SIZE * 0.36 - armSwing * MARKER_SIZE * 0.22, shoulderY + MARKER_SIZE * 0.45);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(MARKER_SIZE * 0.36, shoulderY);
            ctx.lineTo(MARKER_SIZE * 0.36 + armSwing * MARKER_SIZE * 0.22, shoulderY + MARKER_SIZE * 0.45);
            ctx.stroke();

            const stickHandX = MARKER_SIZE * 0.36 + armSwing * MARKER_SIZE * 0.22;
            const stickHandY = shoulderY + MARKER_SIZE * 0.45;

            ctx.strokeStyle = '#5a4a3a';
            ctx.lineWidth = MARKER_SIZE * 0.06;
            ctx.beginPath();
            ctx.moveTo(stickHandX, stickHandY);
            ctx.lineTo(MARKER_SIZE * 0.5 + armSwing * MARKER_SIZE * 0.3, groundY);
            ctx.stroke();

            const headY = bodyBaseY - MARKER_SIZE * 0.87;
            ctx.fillStyle = '#3A7FC1';
            ctx.beginPath();
            ctx.arc(0, headY, MARKER_SIZE * 0.32, 0, Math.PI * 2);
            ctx.fill();

            ctx.fillStyle = '#2A5F8F';
            ctx.beginPath();
            ctx.arc(0, headY - MARKER_SIZE * 0.08, MARKER_SIZE * 0.28, Math.PI, Math.PI * 2);
            ctx.fill();

            ctx.restore();

            const vignette = ctx.createRadialGradient(viewWidth / 2, viewHeight / 2, viewHeight * 0.2, viewWidth / 2, viewHeight / 2, viewHeight * 0.8);
            vignette.addColorStop(0, 'rgba(0, 0, 0, 0)');
            vignette.addColorStop(1, 'rgba(0, 0, 0, 0.35)');
            ctx.fillStyle = vignette;
            ctx.fillRect(cameraRef.current.x, 0, viewWidth, viewHeight);

            ctx.restore();
            ctx.restore();

            animationFrameRef.current = requestAnimationFrame(animate);
        };

        animate();

        return () => {
            window.removeEventListener('resize', resize);
            if (animationFrameRef.current) cancelAnimationFrame(animationFrameRef.current);
        };
    }, []);

    const distanceKm = (steps * METERS_PER_STEP) / 1000;
    const progressPercent = Math.min(((steps * METERS_PER_STEP) / WORLD_WIDTH) * 100, 100);
    const timeP = Math.min((steps * METERS_PER_STEP) / WORLD_WIDTH, 1);

    const getTimeOfDay = (p: number) => {
        if (p < 0.3) return 'Morning Journey';
        if (p < 0.7) return 'Sunset Trail';
        return 'Evening Path';
    };

    const breathScale = 1 + Math.sin(Date.now() * 0.001) * 0.015;

    return (
        <div style={styles.container}>
            <canvas ref={canvasRef} style={styles.canvas} />

            <div style={{ ...styles.centerStats, transform: `translate(-50%, -50%) scale(${breathScale})` }}>
                <div style={styles.dayLabel}>{getTimeOfDay(timeP)}</div>
                <div style={styles.mainStat}>{steps.toLocaleString()}</div>
                <div style={styles.subLabel}>steps</div>
                <div style={styles.progressLabel}>Walking through the valleys</div>
            </div>

            <div style={styles.topBar}>
                <div style={{ ...styles.topStat, transform: `scale(${breathScale})` }}>
                    <div style={styles.topStatValue}>{distanceKm.toFixed(2)}</div>
                    <div style={styles.topStatLabel}>km</div>
                </div>
                <div style={{ ...styles.topStat, transform: `scale(${breathScale})` }}>
                    <div style={styles.topStatValue}>{progressPercent.toFixed(0)}</div>
                    <div style={styles.topStatLabel}>%</div>
                </div>
            </div>

            {landmarkNotification && (
                <div style={styles.notification}>
                    <div style={styles.notificationContent}>✨ {landmarkNotification}</div>
                </div>
            )}

            {biomeNotification && (
                <div style={{ ...styles.notification, top: '70px' }}>
                    <div style={styles.notificationContent}>🗺️ {biomeNotification}</div>
                </div>
            )}

            <div style={styles.controls}>
                <div style={styles.controlPanel}>
                    <input
                        type="range"
                        min="0"
                        max="10000"
                        value={steps}
                        onChange={e => setSteps(Number(e.target.value))}
                        style={styles.slider}
                    />
                    <div style={styles.buttonGroup}>
                        <button onClick={() => setSteps(s => Math.min(s + 100, 10000))} style={styles.button}>
                            +100 Steps
                        </button>
                        <button onClick={() => setSteps(0)} style={{ ...styles.button, ...styles.resetButton }}>
                            Reset
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

// ============================================================================
// BASIC RUNTIME TESTS (DEV ONLY)
// ============================================================================
(function runTinyTests() {
    if (typeof window === 'undefined') return;

    // 1) lerpColor midpoint
    const mid = lerpColor('#000000', '#ffffff', 0.5);
    console.assert(mid === 'rgb(128, 128, 128)', `lerpColor failed: got ${mid}`);

    // 2) sampleTerrainY endpoints
    const pts: Point[] = [
        { x: 0, y: 10 },
        { x: 10, y: 20 }
    ];
    console.assert(sampleTerrainY(pts, 0, 10) === 10, 'sampleTerrainY start failed');
    console.assert(sampleTerrainY(pts, 10, 10) === 20, 'sampleTerrainY end failed');

    // 3) blendTerrain length + endpoints
    const a: Point[] = [
        { x: 0, y: 0 },
        { x: 10, y: 10 }
    ];
    const b: Point[] = [
        { x: 0, y: 10 },
        { x: 10, y: 20 }
    ];
    const blended = blendTerrain(a, b, 0.5);
    console.assert(blended.length === 2, 'blendTerrain length failed');
    console.assert(blended[0].y === 5 && blended[1].y === 15, 'blendTerrain values failed');

    // 4) generateRocks sorted
    const rocks = generateRocks(1000, 7, 1);
    for (let i = 1; i < rocks.length; i++) {
        console.assert(rocks[i - 1].x <= rocks[i].x, 'generateRocks not sorted');
    }
})();

const styles: Record<string, React.CSSProperties> = {
    container: {
        width: '100vw',
        height: '100vh',
        overflow: 'hidden',
        position: 'relative',
        backgroundColor: '#0a0a1e',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    },
    canvas: {
        display: 'block',
        width: '100%',
        height: '100%'
    },
    centerStats: {
        position: 'absolute',
        top: '50%',
        left: '50%',
        textAlign: 'center',
        pointerEvents: 'none',
        color: '#fff',
        textShadow: '0 2px 12px rgba(0,0,0,0.8)',
        transition: 'transform 0.3s ease'
    },
    dayLabel: {
        fontSize: '13px',
        fontWeight: '600',
        letterSpacing: '1.5px',
        opacity: 0.8,
        marginBottom: '8px',
        textTransform: 'uppercase'
    },
    mainStat: {
        fontSize: '64px',
        fontWeight: 'bold',
        fontVariantNumeric: 'tabular-nums',
        marginBottom: '4px',
        color: '#FFD700'
    },
    subLabel: {
        fontSize: '14px',
        opacity: 0.7,
        marginBottom: '16px'
    },
    progressLabel: {
        fontSize: '13px',
        fontStyle: 'italic',
        opacity: 0.75
    },
    topBar: {
        position: 'absolute',
        top: '20px',
        right: '20px',
        display: 'flex',
        gap: '16px',
        pointerEvents: 'none'
    },
    topStat: {
        textAlign: 'center',
        color: '#fff',
        textShadow: '0 2px 8px rgba(0,0,0,0.7)',
        transition: 'transform 0.3s ease'
    },
    topStatValue: {
        fontSize: '22px',
        fontWeight: 'bold',
        fontVariantNumeric: 'tabular-nums'
    },
    topStatLabel: {
        fontSize: '11px',
        opacity: 0.7,
        marginTop: '2px'
    },
    notification: {
        position: 'absolute',
        top: '100px',
        left: '50%',
        transform: 'translateX(-50%)',
        pointerEvents: 'none'
    },
    notificationContent: {
        background: 'rgba(0, 0, 0, 0.85)',
        backdropFilter: 'blur(10px)',
        borderRadius: '12px',
        padding: '12px 24px',
        border: '2px solid rgba(255, 215, 0, 0.5)',
        color: '#FFD700',
        fontSize: '15px',
        fontWeight: '600',
        boxShadow: '0 4px 20px rgba(255, 215, 0, 0.3)'
    },
    controls: {
        position: 'absolute',
        bottom: '20px',
        left: '50%',
        transform: 'translateX(-50%)',
        width: '90%',
        maxWidth: '500px'
    },
    controlPanel: {
        background: 'rgba(0, 0, 0, 0.8)',
        backdropFilter: 'blur(10px)',
        borderRadius: '16px',
        padding: '20px',
        border: '1px solid rgba(255, 255, 255, 0.1)'
    },
    slider: {
        width: '100%',
        height: '8px',
        borderRadius: '4px',
        outline: 'none',
        marginBottom: '16px',
        cursor: 'pointer'
    },
    buttonGroup: {
        display: 'flex',
        gap: '12px'
    },
    button: {
        flex: 1,
        padding: '12px 24px',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        border: 'none',
        borderRadius: '10px',
        color: '#fff',
        fontSize: '14px',
        fontWeight: '600',
        cursor: 'pointer',
        transition: 'all 0.2s'
    },
    resetButton: {
        background: 'rgba(255, 255, 255, 0.1)'
    }
};
