import 'package:flutter/material.dart';

enum LandmarkType { yurt, pagoda, fort, minaret, fortWall, iwan }

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
  final bool isDesert;

  const Biome({
    required this.name,
    required this.colors,
    required this.roughness,
    required this.seed,
    required this.landmark,
    this.foliageDensity = 0.5,
    required this.distanceKm,
    this.isDesert = false,
  });
}

final List<Biome> kBiomes = [
  Biome(
    name: 'Mongolia 🇲🇳',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB), // Clear blue sky
      skyMiddle: Color(0xFFB0E0E6), // Powder blue
      skyBottom: Color(0xFFF0E68C), // Pale yellow horizon
      farMountains: Color(0xFFD4E8D4), // Pale green mountains
      midHills: Color(0xFFA8C896), // Muted green
      nearHills: Color(0xFF8FBC8F), // Green steppes
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.3, // Very flat
    seed: 101,
    landmark: LandmarkType.yurt,
    foliageDensity: 0.2,
    distanceKm: 1800.0,
    isDesert: false,
  ),
  Biome(
    name: 'Xinjiang 🇨🇳',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB), // Desert sky
      skyMiddle: Color(0xFFB8D4E8), // Light blue
      skyBottom: Color(0xFFE8C896), // Sand gold horizon
      farMountains: Color(0xFFD4A86C), // Sand gold
      midHills: Color(0xFFB8784C), // Burnt clay
      nearHills: Color(0xFF9A5F3C), // Deep burnt clay
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.6, // Low hills
    seed: 111,
    landmark: LandmarkType.pagoda,
    foliageDensity: 0.4,
    distanceKm: 1200.0,
    isDesert: true,
  ),
  Biome(
    name: 'Kazakhstan 🇰🇿',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB), // Clear sky
      skyMiddle: Color(0xFFB0C8D8), // Soft blue
      skyBottom: Color(0xFFE8D8A8), // Straw horizon
      farMountains: Color(0xFFC8C896), // Pale straw
      midHills: Color(0xFF9CA878), // Muted olive
      nearHills: Color(0xFF7A8C5A), // Olive green
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.4, // Very flat
    seed: 121,
    landmark: LandmarkType.fort,
    foliageDensity: 0.7,
    distanceKm: 900.0,
    isDesert: false,
  ),
  Biome(
    name: 'Uzbekistan 🇺🇿',
    colors: const BiomeColors(
      skyTop: Color(0xFF5FB8D8), // Turquoise sky
      skyMiddle: Color(0xFF8FCCE8), // Light turquoise
      skyBottom: Color(0xFFD8C8A8), // Warm horizon
      farMountains: Color(0xFFC8A878), // Sandy brown
      midHills: Color(0xFF9A7854), // Earth brown
      nearHills: Color(0xFF78603C), // Deep earth brown
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.8, // Moderate
    seed: 131,
    landmark: LandmarkType.minaret,
    foliageDensity: 0.3,
    distanceKm: 700.0,
    isDesert: true,
  ),
  Biome(
    name: 'Turkmenistan 🇹🇲',
    colors: const BiomeColors(
      skyTop: Color(0xFF87CEEB), // Desert sky
      skyMiddle: Color(0xFFB0C8D8), // Pale blue
      skyBottom: Color(0xFFD8C8B0), // Ash beige horizon
      farMountains: Color(0xFFC8B898), // Ash beige
      midHills: Color(0xFFA88868), // Rust brown
      nearHills: Color(0xFF8A6848), // Deep rust
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 0.9, // Moderate
    seed: 141,
    landmark: LandmarkType.fortWall,
    foliageDensity: 0.1,
    distanceKm: 1100.0,
    isDesert: true,
  ),
  Biome(
    name: 'Iran 🇮🇷',
    colors: const BiomeColors(
      skyTop: Color(0xFF6A8CAF), // Mountain sky
      skyMiddle: Color(0xFF8FA8C8), // Soft blue
      skyBottom: Color(0xFFB8A878), // Gold horizon
      farMountains: Color(0xFF5A5A5A), // Dark stone
      midHills: Color(0xFF484848), // Darker stone
      nearHills: Color(0xFF3A3A3A), // Deep dark stone
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.6, // Mountain (highest!)
    seed: 151,
    landmark: LandmarkType.iwan,
    foliageDensity: 0.5,
    distanceKm: 100.0, // Final destination - short segment
    isDesert: true,
  ),
];

// Helper function to get total journey distance
double getTotalJourneyDistance() {
  return kBiomes.fold(0.0, (sum, biome) => sum + biome.distanceKm);
}
