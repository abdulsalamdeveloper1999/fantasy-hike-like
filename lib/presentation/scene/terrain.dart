import 'dart:math' as math;
import 'dart:ui';

/// Deterministic pseudo-random number generator
double pseudoRandom(int seed) {
  final x = math.sin(seed.toDouble()) * 10000;
  return x - x.floor();
}

/// Generate terrain curve for a layer
List<Offset> generateTerrainLayer({
  required double width,
  required double baseHeight,
  required double roughness,
  required int seed,
  required int segments,
}) {
  final points = <Offset>[];
  
  for (int i = 0; i <= segments; i++) {
    final x = (i / segments) * width;
    final normalizedX = i / segments;
    
    double y = baseHeight;
    
    // Multi-octave noise for organic terrain
    y += math.sin(normalizedX * math.pi * 2 + seed) * roughness * 80;
    y += math.sin(normalizedX * math.pi * 6 + seed * 0.5) * roughness * 40;
    y += math.sin(normalizedX * math.pi * 12 + seed * 0.3) * roughness * 20;
    y += (pseudoRandom(i + seed * 100) - 0.5) * roughness * 10;
    
    points.add(Offset(x, y));
  }
  
  return points;
}

/// Sample Y coordinate from terrain at given X
double sampleTerrainY(List<Offset> terrain, double worldX, double worldWidth) {
  if (terrain.isEmpty) return 0;
  
  final normalized = (worldX / worldWidth).clamp(0.0, 1.0);
  final index = normalized * (terrain.length - 1);
  final lo = index.floor();
  final hi = (lo + 1).clamp(0, terrain.length - 1);
  final t = index - lo;
  
  return terrain[lo].dy + (terrain[hi].dy - terrain[lo].dy) * t;
}

/// Blend two terrain curves
List<Offset> blendTerrain(List<Offset> a, List<Offset> b, double t) {
  if (a.isEmpty) return b;
  if (b.isEmpty) return a;
  
  final length = math.min(a.length, b.length);
  final result = <Offset>[];
  
  for (int i = 0; i < length; i++) {
    result.add(Offset(
      a[i].dx,
      a[i].dy + (b[i].dy - a[i].dy) * t,
    ));
  }
  
  return result;
}

/// Rock prop
class Rock {
  final double x;
  final double size;
  final int seed;
  
  const Rock(this.x, this.size, this.seed);
}

/// Generate rocks determin istically
List<Rock> generateRocks(double worldWidth, int seed, int count) {
  final rocks = <Rock>[];
  
  for (int i = 0; i < count; i++) {
    final s = seed * 1000 + i * 17;
    final x = pseudoRandom(s) * worldWidth;
    final size = 6 + pseudoRandom(s + 9) * 22;
    rocks.add(Rock(x, size, s));
  }
  
  // Sort by X for efficient rendering
  rocks.sort((a, b) => a.x.compareTo(b.x));
  return rocks;
}
