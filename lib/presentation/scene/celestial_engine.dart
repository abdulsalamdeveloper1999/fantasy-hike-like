import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'biomes.dart';

class CelestialEngine {
  static const int kStepsPerCycle = 5000;

  // Smoothstep function for cross-dissolve effect
  static double _smooth(double t) => t * t * (3.0 - 2.0 * t);

  static CelestialState calculateState(
    double distance,
    double metersPerStep,
    BiomeColors biome,
  ) {
    final totalSteps = distance / metersPerStep;
    final progress = (totalSteps % kStepsPerCycle) / kStepsPerCycle;

    // Anchor Colors for perfect continuity
    const Color nightTop = Color(0xFF050B14);
    const Color nightMid = Color(0xFF0D1B2A);
    const Color nightBot = Color(0xFF1B263B);

    const Color sunsetTop = Color(0xFF2D1E3E);
    const Color sunsetMid = Color(0xFFBD5D38);
    const Color sunsetBot = Color(0xFFE89B5E);

    // Parabolic path for sun/moon
    final sunX = progress;
    final sunY = 1.0 - math.sin(progress * math.pi);

    Color top, mid, bot, glowColor;
    bool isDay;

    // Transition Regions
    // 0.0 - 0.25: Dawn (Night -> Biome Day)
    // 0.25 - 0.55: Day (Full Biome Colors)
    // 0.55 - 0.75: Sunset (Biome Day -> Deep Sunset)
    // 0.75 - 1.0: Night (Deep Sunset -> Night)

    if (progress < 0.25) {
      final t = _smooth(progress / 0.25);
      top = Color.lerp(nightTop, biome.skyTop, t)!;
      mid = Color.lerp(nightMid, biome.skyMiddle, t)!;
      bot = Color.lerp(nightBot, biome.skyBottom, t)!;
      glowColor = Color.lerp(Colors.blue, Colors.orange, t)!;
      isDay = true;
    } else if (progress < 0.55) {
      top = biome.skyTop;
      mid = biome.skyMiddle;
      bot = biome.skyBottom;
      glowColor = Colors.orange;
      isDay = true;
    } else if (progress < 0.75) {
      final t = _smooth((progress - 0.55) / 0.20);
      top = Color.lerp(biome.skyTop, sunsetTop, t)!;
      mid = Color.lerp(biome.skyMiddle, sunsetMid, t)!;
      bot = Color.lerp(biome.skyBottom, sunsetBot, t)!;
      glowColor = Color.lerp(Colors.orange, Colors.redAccent, t)!;
      isDay = true;
    } else {
      final t = _smooth((progress - 0.75) / 0.25);
      top = Color.lerp(sunsetTop, nightTop, t)!;
      mid = Color.lerp(sunsetMid, nightMid, t)!;
      bot = Color.lerp(sunsetBot, nightBot, t)!;
      glowColor = Color.lerp(Colors.redAccent, Colors.blue, t)!;
      isDay = false;
    }

    return CelestialState(
      progress: progress,
      sunPosition: Offset(sunX, sunY),
      skyTop: top,
      skyMid: mid,
      skyBot: bot,
      glowColor: glowColor,
      isDay: isDay,
    );
  }
}

class CelestialState {
  final double progress;
  final Offset sunPosition;
  final Color skyTop;
  final Color skyMid;
  final Color skyBot;
  final Color glowColor;
  final bool isDay;

  const CelestialState({
    required this.progress,
    required this.sunPosition,
    required this.skyTop,
    required this.skyMid,
    required this.skyBot,
    required this.glowColor,
    required this.isDay,
  });
}
