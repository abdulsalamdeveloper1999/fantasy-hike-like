import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoyageLandscapePainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final double sailingIntensity;

  VoyageLandscapePainter({
    required this.progress,
    required this.animationValue,
    required this.sailingIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final horizonY = size.height * 0.455;
    final cx = size.width / 2;

    // ── 1. ANIMATED ROLLING HORIZON (Moodier Backdrop) ─────────────────────────
    final waterPath = Path();
    waterPath.moveTo(0, size.height);
    waterPath.lineTo(0, horizonY);

    for (double x = 0; x <= size.width; x += 15) {
      final wave1 = math.sin(x * 0.015 + animationValue * 2 * math.pi) * 3;
      final wave2 = math.sin(x * 0.03 + animationValue * 4 * math.pi) * 1.5;
      waterPath.lineTo(x, horizonY + wave1 + wave2);
    }

    waterPath.lineTo(size.width, size.height);
    waterPath.close();

    // ── 2. GRADIENT SEA FOUNDATION (Muted & Deeper) ────────────────────────────────────────
    final waterRect = Rect.fromLTWH(
      0,
      horizonY - 10,
      size.width,
      size.height - horizonY + 10,
    );
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF8BA3B5), // Softened top
          Color(0xFF5C7D8F),
          Color(0xFF3A5568),
          Color(0xFF1E3140),
          Color(0xFF0F1B24), // Deeper bottom for depth
        ],
        stops: const [0.0, 0.20, 0.45, 0.75, 1.0],
      ).createShader(waterRect);

    canvas.drawPath(waterPath, waterPaint);

    // ── 3. ATMOSPHERIC LIFE (Birds - Always On) ─────────────────────
    _drawSeaBirds(canvas, size, horizonY);
    _drawHorizonHaze(canvas, size, horizonY);

    // ── 4. DRIFTING ELEMENTS (Modulated by Intensity) ──────────────────
    _drawDriftingArchipelago(canvas, size, horizonY, cx);
    _drawDriftingIcebergs(canvas, size, horizonY, cx);

    // ── 5. NATURAL SURFACE FILL ────────────────────
    _drawNaturalOceanFill(canvas, size, horizonY);
    _drawCloudReflections(canvas, size, horizonY);

    // ── 6. WAVY ILLUSTRATED WAKE (Modulated Intensity) ──────────────────
    _drawWavyWake(canvas, size, cx);

    // ── 7. SURFACE MOTION ──────────────────────────
    _drawSurfaceShimmer(canvas, size, horizonY);
    _drawDriftingSurfaceHighlights(canvas, size, horizonY);

    // ── 8. ENHANCED REALISM (Lowered Brightness) ──────────────────────────
    _drawCausticPatterns(canvas, size, horizonY);
    _drawRollingWaveLayers(canvas, size, horizonY);
    _drawSunGlitterPath(canvas, size, horizonY);
    _drawShipSpray(canvas, size, cx);
    _drawDistantWaveFoam(canvas, size, horizonY);
    _drawColorTemperatureShift(canvas, size, horizonY);

    // ── 9. ADDITIONAL DEPTH & REALISM ────────────────────────────────────────
    _drawSubsurfaceScattering(canvas, size, horizonY);
    _drawWaveShadows(canvas, size, horizonY);
    _drawDynamicFoamStreaks(canvas, size, horizonY);
    _drawSplashParticles(canvas, size, cx);
    _drawUnderwaterHaze(canvas, size, horizonY);
  }

  void _drawSubsurfaceScattering(Canvas canvas, Size size, double horizonY) {
    final scatterRect = Rect.fromLTWH(0, horizonY + 20, size.width, 100);
    canvas.drawRect(
      scatterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7FB3D3).withValues(alpha: 0.04), // Reduced from 0.06
            Colors.transparent,
          ],
        ).createShader(scatterRect),
    );
  }

  void _drawWaveShadows(Canvas canvas, Size size, double horizonY) {
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.04 * sailingIntensity); // Slightly more shadow for depth

    for (int i = 0; i < 6; i++) {
      final t = (animationValue * sailingIntensity * 0.5 + i / 6.0) % 1.0;
      final x =
          (size.width * (i / 6.0) + animationValue * sailingIntensity * 20) %
          size.width;
      final y = horizonY + 30 + i * 35;
      final shadowLength =
          (25 + math.sin(animationValue * 3 + i) * 10) * sailingIntensity;

      canvas.drawLine(
        Offset(x - shadowLength, y + 4),
        Offset(x + shadowLength, y + 4),
        shadowPaint,
      );
    }
  }

  void _drawDynamicFoamStreaks(Canvas canvas, Size size, double horizonY) {
    final random = math.Random(333);
    final streakPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int i = 0; i < 8; i++) {
      final t = (animationValue * sailingIntensity * 1.5 + i / 8.0) % 1.0;
      final direction = (i % 2 == 0) ? 1 : -1;
      final startX = (size.width * (i / 8.0)) % size.width;
      final y = horizonY + 60 + random.nextDouble() * (size.height * 0.3);
      final length = (40 + random.nextDouble() * 60) * sailingIntensity;
      final offset = t * 80 * direction;

      final opacity = (1 - t * 0.7) * 0.06 * sailingIntensity; // Reduced from 0.08

      if (opacity > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(startX + offset, y - 2, length, 4),
            const Radius.circular(2),
          ),
          streakPaint
            ..color = Colors.white.withValues(alpha: opacity.clamp(0, 1)),
        );
      }
    }
  }

  void _drawSplashParticles(Canvas canvas, Size size, double cx) {
    final startY = size.height * 0.58;
    final random = math.Random(888);
    final splashPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final t = (animationValue * sailingIntensity * 3 + i / 30.0) % 1.0;
      final side = (i % 3 == 0) ? 1 : (i % 3 == 1 ? -1 : 0);
      final x = cx + (side * (20 + t * 80 + random.nextDouble() * 30));
      final y = startY - (t * t * 50) + random.nextDouble() * 20;
      final opacity = (1 - t) * 0.4 * sailingIntensity; // Slightly reduced
      final radius = (1 + random.nextDouble() * 2.5) * sailingIntensity;

      if (opacity > 0) {
        canvas.drawCircle(
          Offset(x, y),
          radius,
          splashPaint
            ..color = Colors.white.withValues(alpha: opacity.clamp(0, 1)),
        );
      }
    }
  }

  void _drawUnderwaterHaze(Canvas canvas, Size size, double horizonY) {
    final hazeRect = Rect.fromLTWH(
      0,
      size.height * 0.7,
      size.width,
      size.height * 0.3,
    );
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF030A10).withValues(alpha: 0.18), // Darker haze
          ],
        ).createShader(hazeRect),
    );
  }

  void _drawCausticPatterns(Canvas canvas, Size size, double horizonY) {
    final random = math.Random(555);
    final causticPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.02 * sailingIntensity); // Reduced from 0.035

    if (sailingIntensity <= 0.05) return;

    for (int i = 0; i < 10; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = horizonY + 20 + random.nextDouble() * 80;
      final animatedOffset =
          math.sin(animationValue * sailingIntensity * 2.5 + i) * 6;

      final path = Path()..moveTo(startX, startY);

      for (int j = 0; j < 5; j++) {
        final x = startX + (j * 30) + animatedOffset;
        final y =
            startY +
            math.sin(
              (j * 0.7) + animationValue * sailingIntensity * 3.5 + i,
            ) *
            10;
        path.quadraticBezierTo(x + 15, y - 5, x + 30, y);
      }

      canvas.drawPath(path, causticPaint);
    }
  }

  void _drawRollingWaveLayers(Canvas canvas, Size size, double horizonY) {
    for (int layer = 0; layer < 4; layer++) {
      final layerY = horizonY + 25 + (layer * 40);
      final alpha = (0.03 - (layer * 0.005)) * (0.5 + sailingIntensity * 0.5); // Reduced from 0.04
      final frequency = 0.02 + (layer * 0.01);
      final phase = animationValue * (2 + layer * 0.5) * math.pi;

      final wavePath = Path()..moveTo(0, layerY);

      for (double x = 0; x <= size.width; x += 20) {
        final yOffset = math.sin(x * frequency + phase) * (8 - layer * 1.5);
        wavePath.lineTo(x, layerY + yOffset);
      }

      canvas.drawPath(
        wavePath,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha.clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawSunGlitterPath(Canvas canvas, Size size, double horizonY) {
    final pathCenter = size.width / 2;
    final glitterPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (int i = 0; i < 8; i++) {
      final t = i / 7.0;
      final y = horizonY + 40 + t * (size.height - horizonY - 80);
      final width = 20 + t * 80;
      final xOffset = math.sin(animationValue * 4 + i) * 8;

      canvas.drawLine(
        Offset(pathCenter - width + xOffset, y),
        Offset(pathCenter + width + xOffset, y),
        glitterPaint
          ..color = Colors.white.withValues(
            alpha: (0.05 * (1 - t * 0.5)).clamp(0, 1), // Reduced from 0.08
          )
          ..strokeWidth = 1 + t,
      );
    }
  }

  void _drawShipSpray(Canvas canvas, Size size, double cx) {
    final startY = size.height * 0.62;
    final random = math.Random(777);
    final sprayPaint = Paint()..style = PaintingStyle.fill;

    if (sailingIntensity <= 0.1) return;

    for (int i = 0; i < 25; i++) {
      final t = (animationValue * sailingIntensity * 2 + i / 25.0) % 1.0;
      final side = (i % 2 == 0) ? 1 : -1;
      final x = cx + (side * (10 + t * 60 + random.nextDouble() * 20));
      final y = startY - (t * 30) + random.nextDouble() * 15;
      final opacity = (1 - t) * 0.25 * sailingIntensity; // Reduced from 0.3
      final radius = (1.5 + random.nextDouble() * 2) * sailingIntensity;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        sprayPaint..color = Colors.white.withValues(alpha: opacity.clamp(0, 1)),
      );
    }
  }

  void _drawDistantWaveFoam(Canvas canvas, Size size, double horizonY) {
    final foamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.04 * sailingIntensity); // Reduced from 0.06

    for (int i = 0; i < 12; i++) {
      final x =
          (size.width * (i / 12.0) + animationValue * sailingIntensity * 30) %
          size.width;
      final waveY =
          horizonY +
          5 +
          math.sin(i * 0.8 + animationValue * sailingIntensity * 2) * 3;

      canvas.drawLine(Offset(x - 15, waveY), Offset(x + 15, waveY), foamPaint);
    }
  }

  void _drawColorTemperatureShift(Canvas canvas, Size size, double horizonY) {
    final warmRect = Rect.fromLTWH(0, horizonY, size.width, 60);
    canvas.drawRect(
      warmRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE8DED3).withValues(alpha: 0.04), // Reduced from 0.06
            Colors.transparent,
          ],
        ).createShader(warmRect),
    );

    final coolRect = Rect.fromLTWH(
      0,
      size.height * 0.7,
      size.width,
      size.height * 0.3,
    );
    canvas.drawRect(
      coolRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0F1A25).withValues(alpha: 0.12), // Deeper cool tint
          ],
        ).createShader(coolRect),
    );
  }

  void _drawDriftingIcebergs(
    Canvas canvas,
    Size size,
    double horizonY,
    double cx,
  ) {
    final icePaint = Paint()..style = PaintingStyle.fill;
    final reflectionPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (int i = 0; i < 4; i++) {
      final t = (animationValue * sailingIntensity * 1.0 + (i / 4.0) + 0.5) % 1.0;
      final side = (i % 2 == 0) ? 1 : -1;
      final x = cx + (side * (120 + i * 40) * (1.0 + t * 5));
      final y = horizonY + (t * (size.height - horizonY));
      if (y > horizonY && y < size.height + 100) {
        final double fadeT = t < 0.1 ? t / 0.1 : (t > 0.9 ? (1.0 - t) / 0.1 : 1.0);
        final double baseAlpha = (0.75 * fadeT).clamp(0.0, 1.0).toDouble(); // Reduced from 0.9
        final w = (12 + i * 8) * (0.5 + t * 4);
        final h = (10 + i * 6) * (0.5 + t * 3);
        canvas.drawRect(
          Rect.fromLTWH(x - w / 2, y, w, h * 1.5),
          reflectionPaint
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFE0F7FA).withValues(alpha: 0.18 * fadeT), // Reduced from 0.25
                Colors.transparent,
              ],
            ).createShader(Rect.fromLTWH(x - w / 2, y, w, h * 1.5)),
        );
        final icePath = Path();
        icePath.moveTo(x - w / 2, y);
        icePath.lineTo(x - w * 0.3, y - h * 0.6);
        icePath.lineTo(x, y - h);
        icePath.lineTo(x + w * 0.4, y - h * 0.5);
        icePath.lineTo(x + w / 2, y);
        icePath.close();
        canvas.drawPath(
          icePath,
          icePaint..color = Colors.white.withValues(alpha: baseAlpha),
        );
      }
    }
  }

  void _drawSeaBirds(Canvas canvas, Size size, double horizonY) {
    final birdPaint = Paint()
      ..color = const Color(0xFF101923).withValues(alpha: 0.45) // Darker/Muted birds
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4; // Slightly thinner
    for (int i = 0; i < 3; i++) {
      final t = (animationValue * 1.0 + i / 3.0) % 1.0;
      final x = size.width - (t * (size.width + 150));
      final y = horizonY * (0.2 + math.sin(t * 10) * 0.1);
      final flap = math.sin(animationValue * 20 * math.pi + i) * 4;
      final birdPath = Path()
        ..moveTo(x - 8, y + flap)
        ..quadraticBezierTo(x, y - 4, x + 8, y + flap);
      canvas.drawPath(
        birdPath,
        birdPaint
          ..color = birdPaint.color.withValues(
            alpha: (0.45 * (1.0 - (t - 0.5).abs() * 2)).clamp(0, 1),
          ),
      );
    }
  }

  void _drawDriftingArchipelago(
    Canvas canvas,
    Size size,
    double horizonY,
    double cx,
  ) {
    final sandPaint = Paint()..style = PaintingStyle.fill;
    final treePaint = Paint()..style = PaintingStyle.fill;
    final reflectionPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    for (int i = 0; i < 12; i++) {
      final t = (animationValue * sailingIntensity * 1.0 + i / 12.0) % 1.0;
      final side = (i % 2 == 0) ? -1 : 1;
      final x = cx + (side * (80 + (i % 5) * 45) * (1.0 + t * 6));
      final y = horizonY + (t * (size.height - horizonY));
      if (y > horizonY && y < size.height + 150) {
        final double fadeT = t < 0.1 ? t / 0.1 : (t > 0.9 ? (1.0 - t) / 0.1 : 1.0);
        final double baseOpacity = (0.75 * fadeT).clamp(0.0, 1.0).toDouble(); // Reduced from 0.85
        final islandWidth = (16 + (i % 4) * 8) * (0.4 + t * 5);
        final islandHeight = (5 + (i % 3) * 4) * (0.4 + t * 4);
        canvas.drawRect(
          Rect.fromLTWH(
            x - islandWidth / 2.2,
            y,
            islandWidth * 0.8,
            islandHeight * 3.0,
          ),
          reflectionPaint
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF101923).withValues(alpha: 0.25 * fadeT), // Muted dark reflection
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromLTWH(
                x - islandWidth / 2.2,
                y,
                islandWidth * 0.8,
                islandHeight * 3.0,
              ),
            ),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: islandWidth * 1.2,
            height: islandHeight * 0.5,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.15 * fadeT) // Reduced highlight
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        final sandPath = Path();
        sandPath.moveTo(x - islandWidth / 2, y);
        sandPath.quadraticBezierTo(
          x,
          y - (islandHeight * 0.75),
          x + islandWidth / 2,
          y,
        );
        sandPath.close();
        canvas.drawPath(
          sandPath,
          sandPaint..color = const Color(0xFFB4A181).withValues(alpha: baseOpacity), // Muted sand
        );
        final treePath = Path();
        final treeWidth = islandWidth * 0.85;
        final treeHeight = islandHeight * 1.0;
        treePath.moveTo(x - treeWidth / 2.5, y - (islandHeight * 0.35));
        treePath.quadraticBezierTo(
          x,
          y - (islandHeight * 0.35) - treeHeight,
          x + treeWidth / 2.5,
          y - (islandHeight * 0.35),
        );
        treePath.close();
        canvas.drawPath(
          treePath,
          treePaint..color = const Color(0xFF244A1E).withValues(alpha: baseOpacity), // Muted green
        );
      }
    }
  }

  void _drawNaturalOceanFill(Canvas canvas, Size size, double horizonY) {
    final whitecapPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08) // Reduced from 0.12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // Thinner ripples
    for (int i = 0; i < 20; i++) {
      final t = (animationValue * sailingIntensity * 1.0 + i / 20.0) % 1.0;
      final x = (size.width * (i * 0.73) + math.sin(t * 3) * 120) % size.width;
      final y = horizonY + (t * (size.height - horizonY));
      if (i % 3 == 0) {
        final flicker = math.sin(animationValue * 10 * math.pi + i) * 0.5 + 0.5;
        if (flicker > 0.85) // Less frequent whitecaps
          canvas.drawCircle(
            Offset(x, y),
            1.0 + t * 3,
            whitecapPaint
              ..color = Colors.white.withValues(
                alpha: (0.2 * flicker * (1.0 - (t - 0.5).abs() * 2)).clamp(0, 1),
              ),
          );
      }
      if (i % 2 == 0) {
        final rippleWidth = (25 + i * 10) * (0.5 + t * 4);
        canvas.drawPath(
          Path()
            ..moveTo(x - rippleWidth / 2, y)
            ..quadraticBezierTo(x, y + 5 + t * 8, x + rippleWidth / 2, y),
          ripplePaint
            ..color = Colors.white.withValues(
              alpha: (0.08 * (1.0 - (t - 0.5).abs() * 2)).clamp(0, 1),
            ),
        );
      }
    }
  }

  void _drawWavyWake(Canvas canvas, Size size, double cx) {
    final startY = size.height * 0.64;
    final endY = size.height * 0.99;
    final wakePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * sailingIntensity) // Reduced from 0.25
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 // Slightly thinner
      ..strokeCap = StrokeCap.round;

    if (sailingIntensity <= 0.1) return;

    for (final layer in [0, 1, 2]) {
      final spread = 0.15 + (layer * 0.10);
      final speedFactor = (10 + (layer * 2)) * sailingIntensity;
      for (final side in [-1, 1]) {
        final path = Path();
        path.moveTo(cx * (1.0 + side * 0.03), startY);
        for (double t = 0; t <= 1.0; t += 0.05) {
          final xBase = cx + (side * (cx * 0.03 + t * size.width * spread));
          final yBase = startY + t * (endY - startY);
          final waveOffset =
              math.sin(t * 26 + animationValue * speedFactor * math.pi + layer) * 6;
          path.lineTo(xBase + (waveOffset * side), yBase);
        }
        canvas.drawPath(
          path,
          wakePaint
            ..color = Colors.white.withValues(
              alpha: (0.16 - (layer * 0.04)).clamp(0, 1) * sailingIntensity,
            ),
        );
      }
    }
  }

  void _drawHorizonHaze(Canvas canvas, Size size, double horizonY) {
    final hazePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12) // Reduced from 0.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawRect(Rect.fromLTWH(0, horizonY - 5, size.width, 15), hazePaint);
  }

  void _drawCloudReflections(Canvas canvas, Size size, double horizonY) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05) // Reduced from 0.08
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    for (int i = 0; i < 4; i++) {
      double y = horizonY + (size.height - horizonY) * (0.2 + i * 0.2);
      double width = size.width * (0.4 + i * 0.2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.width / 2, y), width: width, height: 15),
        cloudPaint,
      );
    }
  }

  void _drawSurfaceShimmer(Canvas size, Size sizeObj, double horizonY) {
    final rect = Rect.fromLTWH(0, horizonY, sizeObj.width, sizeObj.height - horizonY);
    final shimmerShift = math.sin(animationValue * 2.0 * math.pi) * 0.04; // Slightly reduced shift
    size.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.04 + shimmerShift), // Reduced from 0.08
            Colors.transparent,
            Colors.black.withValues(alpha: 0.06), // Slightly deeper shadow
          ],
        ).createShader(rect),
    );
  }

  void _drawDriftingSurfaceHighlights(Canvas canvas, Size size, double horizonY) {
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (int i = 0; i < 15; i++) {
      final t = (animationValue * sailingIntensity * 5.0 + i / 15.0) % 1.0;
      final x = (size.width * (i / 15.0) + math.sin(t * 5) * 40) % size.width;
      final y = horizonY + (t * t) * (size.height - horizonY);
      final opacity = (1.0 - (t - 0.5).abs() * 2.0) * 0.08 * sailingIntensity; // Reduced from 0.12
      if (opacity > 0)
        canvas.drawCircle(
          Offset(x, y),
          1.0 + t * 2.2,
          highlightPaint..color = Colors.white.withValues(alpha: opacity.clamp(0, 1)),
        );
    }
  }

  @override
  bool shouldRepaint(covariant VoyageLandscapePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.animationValue != animationValue ||
      oldDelegate.sailingIntensity != sailingIntensity;
}
