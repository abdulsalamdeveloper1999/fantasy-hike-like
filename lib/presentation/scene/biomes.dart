import 'package:flutter/material.dart';

enum LandmarkType { yurt, pagoda, mosque, horse, jaggedRock, flower }

class BiomeColors {
  final Color skyTop;
  final Color skyMiddle;
  final Color skyBottom;
  final Color farMountains;
  final Color midHills;
  final Color nearHills;
  final Color foreground;
  final Color rocks;
  final Color mist;

  const BiomeColors({
    required this.skyTop,
    required this.skyMiddle,
    required this.skyBottom,
    required this.farMountains,
    required this.midHills,
    required this.nearHills,
    required this.foreground,
    required this.rocks,
    this.mist = const Color(0x33FFFFFF),
  });

  static BiomeColors lerp(BiomeColors a, BiomeColors b, double t) {
    return BiomeColors(
      skyTop: Color.lerp(a.skyTop, b.skyTop, t)!,
      skyMiddle: Color.lerp(a.skyMiddle, b.skyMiddle, t)!,
      skyBottom: Color.lerp(a.skyBottom, b.skyBottom, t)!,
      farMountains: Color.lerp(a.farMountains, b.farMountains, t)!,
      midHills: Color.lerp(a.midHills, b.midHills, t)!,
      nearHills: Color.lerp(a.nearHills, b.nearHills, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      rocks: Color.lerp(a.rocks, b.rocks, t)!,
      mist: Color.lerp(a.mist, b.mist, t)!,
    );
  }
}

class Biome {
  final String name;
  final BiomeColors colors;
  final double roughness;
  final int seed;
  final LandmarkType landmark;
  final double foliageDensity;
  final double distanceKm; // Distance in kilometers for this country segment
  final bool hasRocks;
  final bool hasFoliage;

  const Biome({
    required this.name,
    required this.colors,
    required this.roughness,
    required this.seed,
    required this.landmark,
    this.foliageDensity = 0.5,
    required this.distanceKm,
    this.hasRocks = false,
    this.hasFoliage = true,
  });
}

final List<Biome> kBiomes = [
  Biome(
    name: 'Mongolia 🇲🇳',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB),
      skyMiddle: Color(0xFFB0E0E6),
      skyBottom: Color(0xFFF0E68C),
      farMountains: Color(0xFFD4E8D4),
      midHills: Color(0xFFA8C896),
      nearHills: Color(0xFF8FBC8F),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.3,
    seed: 101,
    landmark: LandmarkType.yurt,
    foliageDensity: 0.0,
    hasRocks: true,
    hasFoliage: false, // Rocky landscape and yurts
    distanceKm: 1200.0,
  ),
  Biome(
    name: 'China 🇨🇳',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB),
      skyMiddle: Color(0xFFB8D4E8),
      skyBottom: Color(0xFFE8C896),
      farMountains: Color(0xFFD4A86C),
      midHills: Color(0xFFB8784C),
      nearHills: Color(0xFF9A5F3C),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.6,
    seed: 111,
    landmark: LandmarkType.pagoda, // Will draw big trees
    foliageDensity: 0.8, // Big trees and shrubbery
    hasRocks: false,
    hasFoliage: true,
    distanceKm: 1000.0,
  ),
  Biome(
    name: 'Kazakhstan 🇰🇿',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB),
      skyMiddle: Color(0xFFB0C8D8),
      skyBottom: Color(0xFFE8D8A8),
      farMountains: Color(0xFFC8C896),
      midHills: Color(0xFF9CA878),
      nearHills: Color(0xFF7A8C5A),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.4,
    seed: 121,
    landmark: LandmarkType.horse, // Horses and yurts
    foliageDensity: 0.7,
    hasRocks: false,
    hasFoliage: true,
    distanceKm: 900.0,
  ),
  Biome(
    name: 'Uzbekistan 🇺🇿',
    colors: const BiomeColors(
      skyTop: Color(0xFF4FA0C1),
      skyMiddle: Color(0xFF8ECAE6),
      skyBottom: Color(0xFFFFB703),
      farMountains: Color(0xFFD1B072),
      midHills: Color(0xFFC2913C),
      nearHills: Color(0xFFA67117),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.2,
    seed: 131,
    landmark: LandmarkType.mosque, // Mosques / buildings
    foliageDensity: 0.3,
    hasRocks: true,
    hasFoliage: true,
    distanceKm: 800.0,
  ),
  Biome(
    name: 'Turkmenistan 🇹🇲',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB),
      skyMiddle: Color(0xFFB0C8D8),
      skyBottom: Color(0xFFD8C8B0),
      farMountains: Color(0xFFC8B898),
      midHills: Color(0xFFA88868),
      nearHills: Color(0xFF8A6848),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.9,
    seed: 141,
    landmark: LandmarkType.jaggedRock, // Jagged rocks
    foliageDensity: 0.0,
    hasRocks: true,
    hasFoliage: false,
    distanceKm: 800.0,
  ),
  Biome(
    name: 'Iran 🇮🇷',
    colors: const BiomeColors(
      skyTop: Color(0xFF6A8CAF),
      skyMiddle: Color(0xFF8FA8C8),
      skyBottom: Color(0xFFB8A878),
      farMountains: Color(0xFF5A5A5A),
      midHills: Color(0xFF484848),
      nearHills: Color(0xFF3A3A3A),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.6,
    seed: 151,
    landmark: LandmarkType.flower, // Shrubbery and flowers
    foliageDensity: 0.9,
    hasRocks: false,
    hasFoliage: true,
    distanceKm: 1000.0,
  ),
];

// Helper function to get total journey distance
double getTotalJourneyDistance() {
  return kBiomes.fold(0.0, (sum, biome) => sum + biome.distanceKm);
}
