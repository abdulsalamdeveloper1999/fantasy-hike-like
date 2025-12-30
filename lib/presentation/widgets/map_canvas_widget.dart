import 'package:flutter/material.dart';
import '../scene/biomes.dart';
import '../scene/terrain_engine.dart';
import '../scene/silk_road_painter.dart';

class MapCanvasWidget extends StatefulWidget {
  final List<dynamic> waypoints;
  final double distanceTraveled;
  final String selectedCharacter;

  const MapCanvasWidget({
    super.key,
    required this.waypoints,
    required this.distanceTraveled,
    required this.selectedCharacter,
  });

  // Static helper to get current country name
  static String getCurrentCountry(double distance) {
    double cumulativeDistance = 0.0;

    for (int i = 0; i < kBiomes.length; i++) {
      final biome = kBiomes[i];
      final biomeEnd = cumulativeDistance + biome.distanceKm;

      if (distance < biomeEnd || i == kBiomes.length - 1) {
        return biome.name;
      }

      cumulativeDistance = biomeEnd;
    }

    return kBiomes[0].name; // Fallback
  }

  @override
  State<MapCanvasWidget> createState() => _MapCanvasWidgetState();
}

class _MapCanvasWidgetState extends State<MapCanvasWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Data State
  List<Offset> _terrainFrom = [];
  List<Offset> _terrainTo = [];
  List<Offset> _nearHillsFrom = [];
  List<Offset> _nearHillsTo = [];
  List<Offset> _midHillsFrom = [];
  List<Offset> _midHillsTo = [];
  List<Offset> _farMountainsFrom = [];
  List<Offset> _farMountainsTo = [];
  List<Rock> _rocksFrom = [];
  List<Rock> _rocksTo = [];
  List<Foliage> _foliageFrom = [];
  List<Foliage> _foliageTo = [];

  // Logic State
  double _animatedDistance = 0.0;
  double _walkCycle = 0.0;
  double _viewOffset = 0.0; // New state for interactive review
  int _currentBiomeIndex = 0;

  @override
  void initState() {
    super.initState();
    _animatedDistance = widget.distanceTraveled;
    _initializeScene();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16),
          )
          ..addListener(_tick)
          ..repeat();
  }

  void _initializeScene() {
    _generateTerrainForBiome(0);

    // Also generate the target biome terrain for smooth transitions
    final targetBiome = kBiomes[1 % kBiomes.length];
    _terrainTo = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.55,
      roughness: targetBiome.roughness,
      seed: targetBiome.seed,
      segments: 400,
      octaves: 5,
    );
    _nearHillsTo = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.45,
      roughness: targetBiome.roughness * 0.85,
      seed: targetBiome.seed + 5,
      segments: 300,
      octaves: 4,
    );
    _midHillsTo = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.42,
      roughness: targetBiome.roughness * 0.65,
      seed: targetBiome.seed + 10,
      segments: 200,
      octaves: 4,
    );
    _farMountainsTo = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.35,
      roughness: targetBiome.roughness * 0.5,
      seed: targetBiome.seed + 20,
      segments: 300,
      octaves: 5,
    );
    _rocksTo = generateRocks(targetBiome.seed, 150);
    _foliageTo = generateFoliage(targetBiome.seed, targetBiome.foliageDensity);
  }

  void _generateTerrainForBiome(int biomeIndex) {
    final biome = kBiomes[biomeIndex % kBiomes.length];

    // Generate terrain based on biome-specific parameters
    _terrainFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.55,
      roughness: biome.roughness,
      seed: biome.seed,
      segments: 400,
      octaves: 5,
    );

    _nearHillsFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.45,
      roughness: biome.roughness * 0.85,
      seed: biome.seed + 5,
      segments: 300,
      octaves: 4,
    );

    _midHillsFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.42,
      roughness: biome.roughness * 0.65,
      seed: biome.seed + 10,
      segments: 200,
      octaves: 4,
    );

    _farMountainsFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.35,
      roughness: biome.roughness * 0.5,
      seed: biome.seed + 20,
      segments: 300,
      octaves: 5,
    );

    _rocksFrom = generateRocks(biome.seed, 150);
    _foliageFrom = generateFoliage(biome.seed, biome.foliageDensity);
  }

  void _updateBiomeTransition(int newCurrentBiome, int newTargetBiome) {
    if (newCurrentBiome != _currentBiomeIndex) {
      // Biome changed - update terrain
      _currentBiomeIndex = newCurrentBiome;

      // Current biome's terrain becomes the "from" terrain
      _terrainFrom = _terrainTo;
      _nearHillsFrom = _nearHillsTo;
      _midHillsFrom = _midHillsTo;
      _farMountainsFrom = _farMountainsTo;
      _rocksFrom = _rocksTo;
      _foliageFrom = _foliageTo;

      // Generate new "to" terrain for target biome
      final targetBiome = kBiomes[newTargetBiome % kBiomes.length];

      _terrainTo = TerrainEngine.generateTerrain(
        baseY: TerrainEngine.kWorldHeight * 0.55,
        roughness: targetBiome.roughness,
        seed: targetBiome.seed,
        segments: 400,
        octaves: 5,
      );

      _nearHillsTo = TerrainEngine.generateTerrain(
        baseY: TerrainEngine.kWorldHeight * 0.45,
        roughness: targetBiome.roughness * 0.85,
        seed: targetBiome.seed + 5,
        segments: 300,
        octaves: 4,
      );

      _midHillsTo = TerrainEngine.generateTerrain(
        baseY: TerrainEngine.kWorldHeight * 0.42,
        roughness: targetBiome.roughness * 0.65,
        seed: targetBiome.seed + 10,
        segments: 200,
        octaves: 4,
      );

      _farMountainsTo = TerrainEngine.generateTerrain(
        baseY: TerrainEngine.kWorldHeight * 0.35,
        roughness: targetBiome.roughness * 0.5,
        seed: targetBiome.seed + 20,
        segments: 300,
        octaves: 5,
      );

      _rocksTo = generateRocks(targetBiome.seed, 150);
      _foliageTo = generateFoliage(
        targetBiome.seed,
        targetBiome.foliageDensity,
      );
    }
  }

  void _tick() {
    final distDiff = widget.distanceTraveled - _animatedDistance;
    if (distDiff.abs() > 0.1) {
      _animatedDistance += distDiff * 0.15;
      _walkCycle += 0.45;
    } else {
      _animatedDistance = widget.distanceTraveled;
      _walkCycle += 0.02;
    }

    // Check for biome transitions using cumulative distances
    final biomeInfo = _getBiomeAtDistance(_animatedDistance);
    _updateBiomeTransition(biomeInfo.currentIndex, biomeInfo.targetIndex);

    setState(() {});
  }

  // Helper to determine which biome we're in based on distance traveled
  ({int currentIndex, int targetIndex, double transitionT}) _getBiomeAtDistance(
    double distance,
  ) {
    double cumulativeDistance = 0.0;

    for (int i = 0; i < kBiomes.length; i++) {
      final biome = kBiomes[i];
      final biomeEnd = cumulativeDistance + biome.distanceKm;

      if (distance < biomeEnd || i == kBiomes.length - 1) {
        // We're in this biome
        final localDistance = distance - cumulativeDistance;
        final transitionStart =
            biome.distanceKm - 50.0; // Last 50km for transition

        double transitionT = 0.0;
        if (localDistance > transitionStart && biome.distanceKm > 0) {
          transitionT = (localDistance - transitionStart) / 50.0;
          transitionT = transitionT.clamp(0.0, 1.0);
        }

        final targetIndex = (i + 1) % kBiomes.length;
        return (
          currentIndex: i,
          targetIndex: targetIndex,
          transitionT: transitionT,
        );
      }

      cumulativeDistance = biomeEnd;
    }

    // Fallback (shouldn't reach here)
    return (currentIndex: 0, targetIndex: 1, transitionT: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visualDistance = (_animatedDistance - _viewOffset).clamp(
      0.0,
      double.infinity,
    );

    // Get biome information based on actual distances
    final biomeInfo = _getBiomeAtDistance(visualDistance);
    final currentBiomeIndex = biomeInfo.currentIndex;
    final targetBiomeIndex = biomeInfo.targetIndex;
    final biomeTransitionT = biomeInfo.transitionT;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          //details.primaryDelta > 0 is drag right (look back)
          //details.primaryDelta < 0 is drag left (return to character)

          // Use a sensitivity factor to match real-world step feeling
          // Note: kVisualScale is 10.0 in painter, so 1 pixel = 0.1 meters
          const double sensitivity = 0.1;
          _viewOffset -= details.primaryDelta! * sensitivity;

          // Clamp _viewOffset:
          // 0.0: Exactly at character
          // _animatedDistance: At the very start
          _viewOffset = _viewOffset.clamp(0.0, _animatedDistance);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: SilkRoadMapPainter(
            distanceTraveled: visualDistance,
            selectedCharacter: widget.selectedCharacter,
            terrainFrom: _terrainFrom,
            terrainTo: _terrainTo,
            nearHillsFrom: _nearHillsFrom,
            nearHillsTo: _nearHillsTo,
            midHillsFrom: _midHillsFrom,
            midHillsTo: _midHillsTo,
            farMountainsFrom: _farMountainsFrom,
            farMountainsTo: _farMountainsTo,
            rocksFrom: _rocksFrom,
            rocksTo: _rocksTo,
            foliageFrom: _foliageFrom,
            foliageTo: _foliageTo,
            currentBiomeIndex: currentBiomeIndex,
            targetBiomeIndex: targetBiomeIndex,
            biomeTransitionT: biomeTransitionT,
            walkCycle: _walkCycle,
            particles: [], // Simplified for now
          ),
          child: Container(),
        ),
      ),
    );
  }
}
