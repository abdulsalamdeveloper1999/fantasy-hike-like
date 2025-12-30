import 'dart:math' as math;
import 'package:flutter/material.dart';

class TerrainEngine {
  static const double kWorldWidth = 8000.0;
  static const double kWorldHeight = 1000.0;

  static double pseudoRandom(int seed) {
    final x = math.sin(seed.toDouble()) * 10000;
    return x - x.floor();
  }

  // 1D Perlin-like Noise (Fractal Brownian Motion)
  static double noise(double x) {
    final i = x.floor();
    final f = x - i;
    final u = f * f * (3.0 - 2.0 * f); // Smoothstep
    return math.sin(i.toDouble() * 1.57 + 0.3) * (1.0 - u) +
        math.sin((i + 1.0) * 1.57 + 0.3) * u;
  }

  static double fbm1D(
    double x,
    int octaves,
    double persistence,
    double lacunarity,
  ) {
    double total = 0.0;
    double frequency = 1.0;
    double amplitude = 1.0;
    double maxValue = 0.0;
    for (int i = 0; i < octaves; i++) {
      total += noise(x * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= lacunarity;
    }
    return total / maxValue;
  }

  static List<Offset> generateTerrain({
    required double baseY,
    required double roughness,
    required int seed,
    required int segments,
    int octaves = 4,
  }) {
    final points = <Offset>[];
    for (int i = 0; i <= segments; i++) {
      final x = (i / segments) * kWorldWidth;
      final nx = i / segments;

      // FBM for realistic peaks
      final noiseVal = fbm1D(nx * 40.0 + seed, octaves, 0.5, 2.0);
      final y = baseY - (noiseVal * roughness * 150);

      points.add(Offset(x, y));
    }
    return points;
  }

  static double sampleTerrainY(List<Offset> terrain, double worldX) {
    if (terrain.isEmpty) return kWorldHeight * 0.8;
    final nx = (worldX / kWorldWidth).clamp(0.0, 1.0);
    final idx = nx * (terrain.length - 1);
    final lo = idx.floor();
    final hi = (lo + 1).clamp(0, terrain.length - 1);
    final t = idx - lo;
    return terrain[lo].dy + (terrain[hi].dy - terrain[lo].dy) * t;
  }

  static double getGroundVisualY(
    List<Offset> terrain,
    double worldX,
    double scaleY,
  ) {
    final baseY = sampleTerrainY(terrain, worldX) * scaleY;
    // High frequency jitter for grass (must match SilkRoadMapPainter)
    final double noise =
        (math.sin(worldX * 2.0) + math.cos(worldX * 4.5)).abs() * 3.0;
    return baseY - noise;
  }

  static List<Offset> blendTerrain(List<Offset> a, List<Offset> b, double t) {
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    final len = math.min(a.length, b.length);
    final result = <Offset>[];
    for (int i = 0; i < len; i++) {
      final y = a[i].dy * (1 - t) + b[i].dy * t;
      result.add(Offset(a[i].dx, y));
    }
    return result;
  }
}

class Rock {
  final double x;
  final double size;
  final int seed;
  const Rock(this.x, this.size, this.seed);
}

class Foliage {
  final double x;
  final double scale;
  final int type; // 0: Tree, 1: Bush, 2: Grass
  const Foliage(this.x, this.scale, this.type);
}

List<Rock> generateRocks(int biomeSeed, int count) {
  final rocks = <Rock>[];
  for (int i = 0; i < count; i++) {
    final s = biomeSeed * 1000 + i * 17;
    final x = TerrainEngine.pseudoRandom(s) * TerrainEngine.kWorldWidth;
    final size = 4 + TerrainEngine.pseudoRandom(s + 9) * 16;
    rocks.add(Rock(x, size, s));
  }
  rocks.sort((a, b) => a.x.compareTo(b.x));
  return rocks;
}

List<Foliage> generateFoliage(int biomeSeed, double density) {
  final foliage = <Foliage>[];
  final count = (density * 300).toInt();
  for (int i = 0; i < count; i++) {
    final s = biomeSeed * 500 + i * 23;
    final x = TerrainEngine.pseudoRandom(s) * TerrainEngine.kWorldWidth;
    final scale =
        0.4 + TerrainEngine.pseudoRandom(s + 3) * 1.5; // Smaller, more delicate
    final type = (TerrainEngine.pseudoRandom(s + 7) * 4).floor().clamp(
      0,
      2,
    ); // Distribution
    foliage.add(Foliage(x, scale, type));
  }
  foliage.sort((a, b) => a.x.compareTo(b.x));
  return foliage;
}
