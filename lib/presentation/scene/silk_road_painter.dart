import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'biomes.dart';
import 'terrain_engine.dart';
import 'celestial_engine.dart';

class SilkRoadMapPainter extends CustomPainter {
  final double distanceTraveled;
  final String selectedCharacter;
  final List<Offset> terrainFrom;
  final List<Offset> terrainTo;
  final List<Offset> nearHillsFrom;
  final List<Offset> nearHillsTo;
  final List<Offset> midHillsFrom;
  final List<Offset> midHillsTo;
  final List<Offset> farMountainsFrom;
  final List<Offset> farMountainsTo;
  final List<Rock> rocksFrom;
  final List<Rock> rocksTo;
  final List<Foliage> foliageFrom;
  final List<Foliage> foliageTo;
  final int currentBiomeIndex;
  final int targetBiomeIndex;
  final double biomeTransitionT;
  final double walkCycle;
  final List<dynamic> particles;

  SilkRoadMapPainter({
    required this.distanceTraveled,
    required this.selectedCharacter,
    required this.terrainFrom,
    required this.terrainTo,
    required this.nearHillsFrom,
    required this.nearHillsTo,
    required this.midHillsFrom,
    required this.midHillsTo,
    required this.farMountainsFrom,
    required this.farMountainsTo,
    required this.rocksFrom,
    required this.rocksTo,
    required this.foliageFrom,
    required this.foliageTo,
    required this.currentBiomeIndex,
    required this.targetBiomeIndex,
    required this.biomeTransitionT,
    required this.walkCycle,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Amplify the visual movement (e.g. 10 pixels per meter)
    const double kVisualScale = 10.0;
    final scaleY = size.height / TerrainEngine.kWorldHeight;

    final currentBiome = kBiomes[currentBiomeIndex];
    final targetBiome = kBiomes[targetBiomeIndex];
    final colors = BiomeColors.lerp(
      currentBiome.colors,
      targetBiome.colors,
      biomeTransitionT,
    );
    final celestial = CelestialEngine.calculateState(
      distanceTraveled,
      0.8,
      colors,
    );

    // 1. Sky
    _drawSky(canvas, size, colors, celestial);

    // 2. Blend terrain data
    final farPts = TerrainEngine.blendTerrain(
      farMountainsFrom,
      farMountainsTo,
      biomeTransitionT,
    );
    final midPts = TerrainEngine.blendTerrain(
      midHillsFrom,
      midHillsTo,
      biomeTransitionT,
    );
    final nearPts = TerrainEngine.blendTerrain(
      nearHillsFrom,
      nearHillsTo,
      biomeTransitionT,
    );
    final groundPts = TerrainEngine.blendTerrain(
      terrainFrom,
      terrainTo,
      biomeTransitionT,
    );

    // 3. Draw Parallax Layers with Tiling
    // Calculate global camera position (unclamped)
    final totalCamX = (distanceTraveled * kVisualScale) - size.width * 0.35;

    _drawTiledLayer(
      canvas,
      size,
      totalCamX,
      0.15, // far factor
      (offset) => _drawMountainStrip(
        canvas,
        size,
        farPts,
        colors.farMountains,
        0.15,
        scaleY,
        colors.skyBottom,
        celestial.skyBot,
      ),
    );

    _drawTiledLayer(
      canvas,
      size,
      totalCamX,
      0.35, // mid factor
      (offset) => _drawMountainStrip(
        canvas,
        size,
        midPts,
        colors.midHills,
        0.35,
        scaleY,
        colors.skyBottom,
        celestial.skyBot,
      ),
    );

    _drawTiledLayer(
      canvas,
      size,
      totalCamX,
      0.60, // near factor
      (offset) => _drawMountainStrip(
        canvas,
        size,
        nearPts,
        colors.nearHills,
        0.60,
        scaleY,
        colors.skyBottom,
        celestial.skyBot,
      ),
    );

    // 4. Foreground
    _drawTiledLayer(
      canvas,
      size,
      totalCamX,
      1.0, // foreground factor
      (offset) =>
          _drawForegroundStrip(canvas, size, groundPts, Colors.black, scaleY),
    );

    // 4.5. Foliage (trees and bushes)
    _drawTiledLayer(
      canvas,
      size,
      totalCamX,
      1.0, // foreground factor (same as terrain)
      (offset) =>
          _drawFoliageStrip(canvas, size, groundPts, scaleY, biomeTransitionT),
    );

    // 5. Character
    // Map character's world position to the current tile
    final charWorldX = distanceTraveled * kVisualScale;
    final tileX = charWorldX % TerrainEngine.kWorldWidth;

    _drawAnimatedCharacter(
      canvas,
      size,
      tileX, // Use looped position for terrain sampling
      groundPts,
      size.width * 0.35, // Fixed screen position at 35% from left
      scaleY,
      Colors.black,
    );
  }

  void _drawTiledLayer(
    Canvas canvas,
    Size size,
    double cameraX,
    double factor,
    Function(double offset) drawCallback,
  ) {
    // Calculate how much this layer has moved
    final layerScroll = cameraX * factor;
    // Find visual offset within the tile width
    // We start at 0, scroll left.
    // effective offset is negative.
    double shift = -(layerScroll % TerrainEngine.kWorldWidth);

    // Draw first tile
    canvas.save();
    canvas.translate(shift, 0);
    drawCallback(shift);
    canvas.restore();

    // Draw second tile if needed (to fill right side)
    if (shift + TerrainEngine.kWorldWidth < size.width) {
      canvas.save();
      canvas.translate(shift + TerrainEngine.kWorldWidth, 0);
      drawCallback(shift + TerrainEngine.kWorldWidth);
      canvas.restore();
    }
  }

  void _drawSky(
    Canvas canvas,
    Size size,
    BiomeColors colors,
    CelestialState celestial,
  ) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [celestial.skyTop, celestial.skyMid, celestial.skyBot],
        stops: const [0.0, 0.45, 0.9],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw stars during night (when progress is between 0.75 and 1.0, or 0.0 and 0.15)
    if (!celestial.isDay || celestial.progress < 0.15) {
      _drawStars(canvas, size, celestial.progress);
    }

    // Bloom/Celestial body
    final sunX = celestial.sunPosition.dx * size.width;
    final sunY = 50 + celestial.sunPosition.dy * (size.height * 0.4);

    final bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          celestial.glowColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 100));
    canvas.drawCircle(Offset(sunX, sunY), 120, bloomPaint);

    // Dynamic celestial body color based on time of day
    Color celestialColor;
    if (celestial.isDay) {
      // Sun: yellow-orange during day
      celestialColor = const Color(0xFFFDB813);
    } else {
      // Moon: pale blue-white during night
      celestialColor = const Color(0xFFE8F4F8);
    }

    canvas.drawCircle(
      Offset(sunX, sunY),
      celestial.isDay ? 20 : 16,
      Paint()
        ..color = celestialColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _drawStars(Canvas canvas, Size size, double progress) {
    // Calculate star opacity based on time (fade in/out during transitions)
    double opacity = 1.0;
    if (progress < 0.15) {
      // Dawn - fade out
      opacity = 1.0 - (progress / 0.15);
    } else if (progress > 0.75 && progress < 0.85) {
      // Dusk - fade in
      opacity = (progress - 0.75) / 0.10;
    }

    // Draw 8 stars at random positions (predefined for consistency)
    const starCount = 8;
    final starPositions = [
      Offset(0.15, 0.12),
      Offset(0.73, 0.08),
      Offset(0.42, 0.25),
      Offset(0.88, 0.31),
      Offset(0.25, 0.45),
      Offset(0.61, 0.18),
      Offset(0.09, 0.38),
      Offset(0.95, 0.52),
    ];

    for (int i = 0; i < starCount; i++) {
      final pos = starPositions[i];
      final x = pos.dx * size.width;
      final y = pos.dy * (size.height * 0.6);

      // Vary star sizes
      final starSize = 1.5 + ((i % 3) * 0.5);

      // Twinkle effect based on progress
      final twinkle = math.sin((progress * 100 + i * 13) * math.pi) * 0.3 + 0.7;

      canvas.drawCircle(
        Offset(x, y),
        starSize,
        Paint()
          ..color = Colors.white.withOpacity(opacity * twinkle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  void _drawMountainStrip(
    Canvas canvas,
    Size size,
    List<Offset> points,
    Color color,
    double factor,
    double scaleY,
    Color mist,
    Color skyHorizon,
  ) {
    if (points.isEmpty) return;
    // No internal translation, we rely on _drawTiledLayer's canvas.translate

    final path = Path()..moveTo(points.first.dx, size.height);
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final y = p.dy * scaleY;
      if (i > 0) {
        final prev = points[i - 1];
        const double res = 3.0; // resolution
        for (double dx = prev.dx + res; dx < p.dx; dx += res) {
          final double t = (dx - prev.dx) / (p.dx - prev.dx);
          final interY = (prev.dy * (1 - t) + p.dy * t) * scaleY;
          final double noise =
              (math.sin(dx * 0.6 + factor * 50) + math.cos(dx * 1.5)).abs() *
              2.5;
          path.lineTo(dx, interY - noise);
        }
      }
      path.lineTo(p.dx, y);
    }
    path
      ..lineTo(points.last.dx, size.height)
      ..close();

    // Horizon Color Blending (Atmospheric Perspective)
    final atmosphericColor = Color.lerp(
      color,
      skyHorizon,
      0.3 + (1.0 - factor) * 0.4,
    )!;

    final grad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        atmosphericColor,
        Color.lerp(atmosphericColor, Colors.black, 0.4)!,
      ],
    ).createShader(Rect.fromLTWH(0, 0, TerrainEngine.kWorldWidth, size.height));

    canvas.drawPath(path, Paint()..shader = grad);

    // Simple vertical haze
    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyHorizon.withOpacity(0.0), skyHorizon.withOpacity(0.3)],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, 1, size.height));
    canvas.drawPath(path, hazePaint);

    canvas.drawPath(path, hazePaint);
  }

  void _drawForegroundStrip(
    Canvas canvas,
    Size size,
    List<Offset> points,
    Color color,
    double scaleY,
  ) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, size.height);
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (i > 0) {
        final prev = points[i - 1];
        const double res = 2.0;
        for (double dx = prev.dx + res; dx < p.dx; dx += res) {
          path.lineTo(dx, TerrainEngine.getGroundVisualY(points, dx, scaleY));
        }
      }
      path.lineTo(p.dx, TerrainEngine.getGroundVisualY(points, p.dx, scaleY));
    }
    path
      ..lineTo(TerrainEngine.kWorldWidth, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawFoliageStrip(
    Canvas canvas,
    Size size,
    List<Offset> terrain,
    double scaleY,
    double biomeTransitionT,
  ) {
    // Blend foliage between current and target biome
    final foliageList = <Foliage>[];

    // Mix foliage from both biomes during transition
    for (var f in foliageFrom) {
      if (biomeTransitionT < 0.5) {
        foliageList.add(f);
      }
    }
    for (var f in foliageTo) {
      if (biomeTransitionT > 0.5) {
        foliageList.add(f);
      }
    }

    // Draw each foliage item
    for (var foliage in foliageList) {
      final x = foliage.x;
      final groundY = TerrainEngine.getGroundVisualY(terrain, x, scaleY);

      // Foliage color - dark green/black
      final foliageColor = Color.lerp(
        const Color(0xFF1A3A1A), // Dark green
        Colors.black,
        0.5,
      )!;

      final paint = Paint()
        ..color = foliageColor
        ..style = PaintingStyle.fill;

      if (foliage.type == 0) {
        // Plant/Shrub - rounded bush shape
        final height = 12.0 * foliage.scale;
        final width = 10.0 * foliage.scale;

        // Draw as overlapping circles for a bushy look
        final plantPaint = Paint()
          ..color = foliageColor
          ..style = PaintingStyle.fill;

        // Main bush body
        canvas.drawCircle(
          Offset(x, groundY - height / 2),
          width / 2,
          plantPaint,
        );

        // Additional circles for fuller look
        canvas.drawCircle(
          Offset(x - width / 3, groundY - height / 3),
          width / 3,
          plantPaint,
        );
        canvas.drawCircle(
          Offset(x + width / 3, groundY - height / 3),
          width / 3,
          plantPaint,
        );
      } else if (foliage.type == 1) {
        // Bush - simple circle
        final radius = 4.0 * foliage.scale;
        canvas.drawCircle(Offset(x, groundY - radius), radius, paint);
      } else {
        // Grass - small vertical line
        canvas.drawLine(
          Offset(x, groundY),
          Offset(x, groundY - 3.0 * foliage.scale),
          paint..strokeWidth = 1,
        );
      }
    }
  }

  void _drawAnimatedCharacter(
    Canvas canvas,
    Size size,
    double worldX,
    List<Offset> terrain,
    double screenX, // Explicit screen position
    double scaleY,
    Color color,
  ) {
    // Use smooth terrain sampling to prevent character vibration
    // (getGroundVisualY adds jitter for grass effect, which makes character shake)
    var y = TerrainEngine.sampleTerrainY(terrain, worldX) * scaleY;
    y -= 2.0; // Slight offset to sit character on top of terrain
    final x = screenX;

    // Subtle visibility glow (white/soft)
    canvas.drawCircle(
      Offset(x, y - 18),
      16,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Body (stick man/silhouette) - Use foreground color for consistency
    final p = Paint()..color = color;
    canvas.drawCircle(Offset(x, y - 28), 6, p); // Head
    canvas.drawRect(Rect.fromLTWH(x - 4, y - 22, 8, 14), p); // Body

    final l = math.sin(walkCycle) * 8;
    canvas.drawLine(
      Offset(x - 2, y - 8),
      Offset(x - 2 + l, y),
      p
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(x + 2, y - 8),
      Offset(x + 2 - l, y),
      p
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Stick
    canvas.drawLine(
      Offset(x + 6, y - 18),
      Offset(x + 10 + l * 0.5, y),
      p..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant SilkRoadMapPainter oldDelegate) => true;
}
