import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
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
  final ui.Image? characterImage;

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
    this.characterImage,
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

    // 4.5. Scenery (trees/plants or rocks)
    _drawTiledLayer(
      canvas,
      size,
      totalCamX,
      1.0, // foreground factor (same as terrain)
      (offset) =>
          _drawSceneryStrip(canvas, size, groundPts, scaleY, biomeTransitionT),
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

  void _drawSceneryStrip(
    Canvas canvas,
    Size size,
    List<Offset> terrain,
    double scaleY,
    double t,
  ) {
    final currentBiome = kBiomes[currentBiomeIndex];
    final targetBiome = kBiomes[targetBiomeIndex];

    // 1. Current Biome
    if (t < 0.5) {
      _drawBiomeFeatures(
        canvas,
        terrain,
        scaleY,
        currentBiome,
        rocksFrom,
        foliageFrom,
      );
    }

    // 2. Target Biome
    if (t >= 0.5) {
      _drawBiomeFeatures(
        canvas,
        terrain,
        scaleY,
        targetBiome,
        rocksTo,
        foliageTo,
      );
    }
  }

  void _drawBiomeFeatures(
    Canvas canvas,
    List<Offset> terrain,
    double scaleY,
    Biome biome,
    List<Rock> rocks,
    List<Foliage> foliage,
  ) {
    final rockColor = biome.colors.rocks;

    if (biome.hasRocks) {
      _drawRocks(canvas, terrain, scaleY, rocks, rockColor);
    }
    if (biome.hasFoliage) {
      _drawFoliage(canvas, terrain, scaleY, foliage);
    }

    // Draw Special Landmarks based on the Biome's LandmarkType
    // We space landmarks out using the biome seed
    final landmarkCount = 3;
    for (int i = 0; i < landmarkCount; i++) {
      final double landmarkX =
          (TerrainEngine.pseudoRandom(biome.seed + i * 55) * 0.8 + 0.1) *
          TerrainEngine.kWorldWidth;
      // Sink landmarks by 4 pixels to bridge gaps in jittery terrain
      final groundY =
          TerrainEngine.getGroundVisualY(terrain, landmarkX, scaleY) + 4.0;

      switch (biome.landmark) {
        case LandmarkType.yurt:
          _drawYurt(canvas, landmarkX, groundY, 1.0, Colors.black);
          break;
        case LandmarkType.mosque:
          _drawMosque(canvas, landmarkX, groundY, 0.8, Colors.black);
          break;
        case LandmarkType.pagoda:
          // User requested "big trees" for China
          _drawLargeTree(canvas, landmarkX, groundY, 1.2, Colors.black);
          break;
        case LandmarkType.jaggedRock:
          _drawJaggedRock(canvas, landmarkX, groundY, 1.0, Colors.black);
          break;
        case LandmarkType.flower:
          _drawFlower(canvas, landmarkX, groundY, 1.5, Colors.black);
          break;
        case LandmarkType.horse:
          // Kazakhstan: Horses and Yurts
          if (i % 2 == 0) {
            _drawHorse(canvas, landmarkX, groundY, 0.8, Colors.black);
          } else {
            _drawYurt(canvas, landmarkX, groundY, 0.9, Colors.black);
          }
          break;
        default:
          break;
      }
    }
  }

  void _drawRocks(
    Canvas canvas,
    List<Offset> terrain,
    double scaleY,
    List<Rock> rocks,
    Color color,
  ) {
    final paint = Paint()..color = color;
    for (var rock in rocks) {
      final groundY = TerrainEngine.getGroundVisualY(terrain, rock.x, scaleY);

      // Draw rock as a slightly flattened oval
      final width = rock.size;
      final height = rock.size * 0.7;

      // Embed rock slightly into the ground (center at groundY)
      // This ensures it doesn't look like it's floating on top of noise peaks
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rock.x, groundY),
          width: width,
          height: height,
        ),
        paint,
      );
    }
  }

  void _drawFoliage(
    Canvas canvas,
    List<Offset> terrain,
    double scaleY,
    List<Foliage> foliageList,
  ) {
    for (var foliage in foliageList) {
      final x = foliage.x;
      // Sink foliage by 3 pixels to bridge grass gaps
      final groundY = TerrainEngine.getGroundVisualY(terrain, x, scaleY) + 3.0;

      // Foliage color - dark green/black
      final foliageColor = Color.lerp(
        const Color(0xFF1A3A1A), // Dark green
        Colors.black,
        0.5,
      )!;

      if (foliage.type == 0) {
        // Tree - trunk + canopy
        _drawTree(canvas, x, groundY, foliage.scale, foliageColor);
      } else if (foliage.type == 1) {
        // Bush - rounded organic shape
        _drawBush(canvas, x, groundY, foliage.scale, foliageColor);
      } else {
        // Grass - small tuft
        _drawGrass(canvas, x, groundY, foliage.scale, foliageColor);
      }
    }
  }

  void _drawTree(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Trunk - thin vertical line
    final trunkWidth = 1.5 * scale;
    final trunkHeight = 10.0 * scale;
    canvas.drawRect(
      Rect.fromLTWH(
        x - trunkWidth / 2,
        groundY - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      paint,
    );

    // Canopy - organic blob made of overlapping circles
    final canopyRadius = 6.0 * scale;
    final canopyY = groundY - trunkHeight - canopyRadius * 0.5;

    // Main canopy body
    canvas.drawCircle(Offset(x, canopyY), canopyRadius, paint);

    // Additional circles for fuller, organic look
    canvas.drawCircle(
      Offset(x - canopyRadius * 0.5, canopyY + canopyRadius * 0.3),
      canopyRadius * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(x + canopyRadius * 0.5, canopyY + canopyRadius * 0.3),
      canopyRadius * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(x, canopyY - canopyRadius * 0.4),
      canopyRadius * 0.6,
      paint,
    );
  }

  void _drawBush(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw bush as overlapping circles for organic look
    final radius = 5.0 * scale;

    // Main body
    canvas.drawCircle(Offset(x, groundY - radius), radius, paint);

    // Left bump
    canvas.drawCircle(
      Offset(x - radius * 0.6, groundY - radius * 0.7),
      radius * 0.7,
      paint,
    );

    // Right bump
    canvas.drawCircle(
      Offset(x + radius * 0.6, groundY - radius * 0.7),
      radius * 0.7,
      paint,
    );
  }

  void _drawGrass(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Draw 3 grass blades
    final height = 4.0 * scale;
    final spread = 1.5 * scale;

    // Center blade
    canvas.drawLine(Offset(x, groundY), Offset(x, groundY - height), paint);

    // Left blade (slightly shorter and angled)
    canvas.drawLine(
      Offset(x - spread, groundY),
      Offset(x - spread * 0.5, groundY - height * 0.8),
      paint,
    );

    // Right blade (slightly shorter and angled)
    canvas.drawLine(
      Offset(x + spread, groundY),
      Offset(x + spread * 0.5, groundY - height * 0.8),
      paint,
    );
  }

  void _drawYurt(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final p = Paint()..color = color;
    final w = 30.0 * scale;
    final h = 12.0 * scale;
    final r = 18.0 * scale; // roof height

    // Base (rounded rectangle for organic feel)
    // Sinking base slightly deeper (extra 5px) to form a foundation
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - w / 2, groundY - h, w, h + 5.0),
        Radius.circular(2 * scale),
      ),
      p,
    );

    // Domed Roof
    final roofPath = Path();
    roofPath.moveTo(x - w / 2, groundY - h);
    roofPath.quadraticBezierTo(x, groundY - h - r, x + w / 2, groundY - h);
    roofPath.close();
    canvas.drawPath(roofPath, p);

    // Decorative center vertical line (door/opening)
    canvas.drawLine(
      Offset(x, groundY),
      Offset(x, groundY - h * 0.8),
      Paint()
        ..color = Colors.white10
        ..strokeWidth = 1.0,
    );
  }

  void _drawMosque(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final p = Paint()..color = color;
    final w = 40.0 * scale;
    final h = 25.0 * scale;

    // Main Hall - sinking slightly to ground
    canvas.drawRect(Rect.fromLTWH(x - w / 2, groundY - h, w, h + 5.0), p);

    // Dome
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(x, groundY - h),
        width: w * 0.7,
        height: h * 0.8,
      ),
      math.pi,
      math.pi,
      true,
      p,
    );

    // Minaret (Left) - Extended height to sink into ground
    canvas.drawRect(
      Rect.fromLTWH(x - w * 0.6, groundY - h * 1.5, w * 0.1, h * 1.5 + 5.0),
      p,
    );
    // Minaret (Right) - Extended height to sink into ground
    canvas.drawRect(
      Rect.fromLTWH(x + w * 0.5, groundY - h * 1.5, w * 0.1, h * 1.5 + 5.0),
      p,
    );
  }

  void _drawLargeTree(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final p = Paint()..color = color;
    // Massive trunk
    canvas.drawRect(
      Rect.fromLTWH(x - 4 * scale, groundY - 30 * scale, 8 * scale, 30 * scale),
      p,
    );
    // Huge wide canopy
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, groundY - 40 * scale),
        width: 80 * scale,
        height: 60 * scale,
      ),
      p,
    );
  }

  void _drawJaggedRock(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final p = Paint()..color = color;
    final path = Path();
    path.moveTo(x - 20 * scale, groundY);
    path.lineTo(x - 10 * scale, groundY - 40 * scale);
    path.lineTo(x, groundY - 15 * scale);
    path.lineTo(x + 15 * scale, groundY - 50 * scale);
    path.lineTo(x + 25 * scale, groundY);
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawFlower(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    // Stem
    canvas.drawLine(
      Offset(x, groundY),
      Offset(x, groundY - 10 * scale),
      Paint()..color = color,
    );
    // Petals
    final p = Paint()..color = const Color(0xFFFF69B4);
    canvas.drawCircle(Offset(x, groundY - 12 * scale), 4 * scale, p); // Center
    canvas.drawCircle(
      Offset(x - 3 * scale, groundY - 14 * scale),
      2 * scale,
      p,
    );
    canvas.drawCircle(
      Offset(x + 3 * scale, groundY - 14 * scale),
      2 * scale,
      p,
    );
    canvas.drawCircle(Offset(x, groundY - 16 * scale), 2 * scale, p);
  }

  void _drawHorse(
    Canvas canvas,
    double x,
    double groundY,
    double scale,
    Color color,
  ) {
    final p = Paint()..color = color;
    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, groundY - 12 * scale),
        width: 25 * scale,
        height: 12 * scale,
      ),
      p,
    );
    // Neck
    final neck = Path();
    neck.moveTo(x + 8 * scale, groundY - 15 * scale);
    neck.lineTo(x + 15 * scale, groundY - 25 * scale);
    neck.lineTo(x + 18 * scale, groundY - 22 * scale);
    neck.lineTo(x + 10 * scale, groundY - 10 * scale);
    neck.close();
    canvas.drawPath(neck, p);
    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 18 * scale, groundY - 23 * scale),
        width: 8 * scale,
        height: 5 * scale,
      ),
      p,
    );
    // Legs
    final lp = Paint()
      ..color = color
      ..strokeWidth = 2 * scale;
    canvas.drawLine(
      Offset(x - 8 * scale, groundY - 10 * scale),
      Offset(x - 10 * scale, groundY),
      lp,
    );
    canvas.drawLine(
      Offset(x - 4 * scale, groundY - 10 * scale),
      Offset(x - 2 * scale, groundY),
      lp,
    );
    canvas.drawLine(
      Offset(x + 4 * scale, groundY - 10 * scale),
      Offset(x + 2 * scale, groundY),
      lp,
    );
    canvas.drawLine(
      Offset(x + 8 * scale, groundY - 10 * scale),
      Offset(x + 10 * scale, groundY),
      lp,
    );
    // Tail
    canvas.drawLine(
      Offset(x - 12 * scale, groundY - 15 * scale),
      Offset(x - 18 * scale, groundY - 5 * scale),
      lp,
    );
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
    // Use smooth base terrain instead of jittery grass to stop vibration
    // Sunk deeper (12.0) to ensure feet are ALWAYS inside the black terrain even on hills
    final y = (TerrainEngine.sampleTerrainY(terrain, worldX) * scaleY) + 12.0;
    final x = screenX;

    if (characterImage != null) {
      // Draw character image
      final imageWidth = 40.0;
      final imageHeight = 40.0;

      // Add walking animation - bounce UP from the ground
      // Using abs() ensures we don't clip into the ground
      // and subtraction moves it upwards in Flutter's coordinate system
      final bounce = -(math.sin(walkCycle).abs() * 3.0);

      // Calculate destination rectangle - Bottom aligned to ground + bounce
      final dst = Rect.fromLTWH(
        x - imageWidth / 2,
        y - imageHeight + bounce,
        imageWidth,
        imageHeight,
      );

      // Draw the character image
      canvas.drawImageRect(
        characterImage!,
        Rect.fromLTWH(
          0,
          0,
          characterImage!.width.toDouble(),
          characterImage!.height.toDouble(),
        ),
        dst,
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      // Fallback: Draw stick figure
      // Add same walking vertical bounce to stick figure
      final bounce = -(math.sin(walkCycle).abs() * 3.0);
      final drawY = y + bounce;

      // Subtle visibility glow
      canvas.drawCircle(
        Offset(x, drawY - 18),
        16,
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Body (stick man/silhouette)
      final p = Paint()..color = color;
      canvas.drawCircle(Offset(x, drawY - 28), 6, p); // Head
      canvas.drawRect(Rect.fromLTWH(x - 4, drawY - 22, 8, 14), p); // Body

      final l = math.sin(walkCycle) * 8;
      canvas.drawLine(
        Offset(x - 2, drawY - 8),
        Offset(x - 2 + l, y), // Note: Legs stay pinned to literal y (ground)
        p
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(x + 2, drawY - 8),
        Offset(x + 2 - l, y),
        p
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      // Stick
      canvas.drawLine(
        Offset(x + 6, drawY - 18),
        Offset(x + 10 + l * 0.5, y),
        p..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SilkRoadMapPainter oldDelegate) => true;
}
