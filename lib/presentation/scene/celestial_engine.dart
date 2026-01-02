import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'biomes.dart';

class CelestialEngine {
  static const int kStepsPerCycle =
      40000; // 40km instead of 5km for better pacing

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
    // Lowered start (1.4) to stay hidden behind mountains longer
    final sunY = 1.4 - (math.sin(progress * math.pi) * 1.4);

    // Calculate sun opacity (alpha)
    // 0.0 - 0.05: Completely hidden
    // 0.05 - 0.15: Fade in
    double sunAlpha = 1.0;
    if (progress < 0.15) {
      sunAlpha = ((progress - 0.05) / 0.1).clamp(0.0, 1.0);
    } else if (progress > 0.85) {
      // Fade out at night
      sunAlpha = ((0.95 - progress) / 0.1).clamp(0.0, 1.0);
    }

    // --- Atmospheric Micro-Pacing ---
    // Change things subtly every 1km
    final kmProgress = distance / 1000.0;

    // 1. Mid-Stop Wobble: Shifting the horizon density point between 0.4 and 0.5
    final skyMidStop = 0.45 + (math.sin(kmProgress * math.pi * 2) * 0.05);

    // 2. Color Shift: Subtly brighten/dim colors based on km distance
    final atmosShift = (math.cos(kmProgress * math.pi) * 10.0).toInt();

    Color top, mid, bot, glowColor;
    bool isDay;

    // Transition Regions
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

    // Apply Subtle Micro-Pacing Color Shift
    top = _applyShift(top, atmosShift);
    mid = _applyShift(mid, atmosShift);
    bot = _applyShift(bot, atmosShift);

    return CelestialState(
      progress: progress,
      sunPosition: Offset(sunX, sunY),
      sunAlpha: sunAlpha,
      skyTop: top,
      skyMid: mid,
      skyBot: bot,
      skyMidStop: skyMidStop,
      glowColor: glowColor,
      isDay: isDay,
    );
  }

  // Helper to nudge colors slightly for variety
  static Color _applyShift(Color color, int shift) {
    return Color.fromARGB(
      color.alpha,
      (color.red + shift).clamp(0, 255),
      (color.green + shift).clamp(0, 255),
      (color.blue + shift).clamp(0, 255),
    );
  }
}

class CelestialState {
  final double progress;
  final Offset sunPosition;
  final double sunAlpha;
  final Color skyTop;
  final Color skyMid;
  final Color skyBot;
  final double skyMidStop;
  final Color glowColor;
  final bool isDay;

  const CelestialState({
    required this.progress,
    required this.sunPosition,
    required this.sunAlpha,
    required this.skyTop,
    required this.skyMid,
    required this.skyBot,
    required this.skyMidStop,
    required this.glowColor,
    required this.isDay,
  });
}
