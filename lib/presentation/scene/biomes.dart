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

  const Biome({
    required this.name,
    required this.colors,
    required this.roughness,
    required this.seed,
    required this.landmark,
    this.foliageDensity = 0.5,
  });
}

final List<Biome> kBiomes = [
  Biome(
    name: 'Mongolia 🇲🇳',
    colors: const BiomeColors(
      skyTop: Color(0xFF5BA3D0),
      skyMiddle: Color(0xFF8BBFD9),
      skyBottom: Color(0xFFE8C5A0),
      farMountains: Color(0xFFA5D8E8),
      midHills: Color(0xFF6E9EB4),
      nearHills: Color(0xFF385E70),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.2,
    seed: 101,
    landmark: LandmarkType.yurt,
    foliageDensity: 0.2,
  ),
  Biome(
    name: 'Xinjiang 🇨🇳',
    colors: const BiomeColors(
      skyTop: Color(0xFF7FD6FF),
      skyMiddle: Color(0xFFC7F0FF),
      skyBottom: Color(0xFFF1D7A8),
      farMountains: Color(0xFFD7C4A3),
      midHills: Color(0xFFB59368),
      nearHills: Color(0xFF8A6B4E),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.0,
    seed: 111,
    landmark: LandmarkType.pagoda,
    foliageDensity: 0.4,
  ),
  Biome(
    name: 'Kazakhstan 🇰🇿',
    colors: const BiomeColors(
      skyTop: Color(0xFF84CCFF),
      skyMiddle: Color(0xFFB9E8FF),
      skyBottom: Color(0xFFEADFC0),
      farMountains: Color(0xFFC4D5DB),
      midHills: Color(0xFF8BA5AD),
      nearHills: Color(0xFF4E6B75),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.3,
    seed: 121,
    landmark: LandmarkType.fort,
    foliageDensity: 0.7,
  ),
  Biome(
    name: 'Uzbekistan 🇺🇿',
    colors: const BiomeColors(
      skyTop: Color(0xFF7FD1FF),
      skyMiddle: Color(0xFFBFEAFF),
      skyBottom: Color(0xFFF0D7B0),
      farMountains: Color(0xFFE2C9B0),
      midHills: Color(0xFFB57F50),
      nearHills: Color(0xFF7A4B2E),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.1,
    seed: 131,
    landmark: LandmarkType.minaret,
    foliageDensity: 0.3,
  ),
  Biome(
    name: 'Turkmenistan 🇹🇲',
    colors: const BiomeColors(
      skyTop: Color(0xFF8BD3FF),
      skyMiddle: Color(0xFFCDEEFF),
      skyBottom: Color(0xFFF3D6A6),
      farMountains: Color(0xFFEAD2C0),
      midHills: Color(0xFFB58B68),
      nearHills: Color(0xFF8A5B3C),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.0,
    seed: 141,
    landmark: LandmarkType.fortWall,
    foliageDensity: 0.1,
  ),
  Biome(
    name: 'Iran 🇮🇷',
    colors: const BiomeColors(
      skyTop: Color(0xFF7EC6E6),
      skyMiddle: Color(0xFFA5D8E8),
      skyBottom: Color(0xFFD7DCE0),
      farMountains: Color(0xFF7E72B5),
      midHills: Color(0xFF564C8A),
      nearHills: Color(0xFF3A3266),
      foreground: Colors.black,
      rocks: const Color(0xFF050505),
    ),
    roughness: 1.4,
    seed: 151,
    landmark: LandmarkType.iwan,
    foliageDensity: 0.5,
  ),
];
