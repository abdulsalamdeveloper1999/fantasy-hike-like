import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../scene/biomes.dart';
import '../scene/terrain_engine.dart';
import '../scene/silk_road_painter.dart';

class MapCanvasWidget extends StatefulWidget {
  final List<dynamic> waypoints;
  final double distanceTraveled;
  final String selectedCharacter;
  final Function(double meters)? onProgressUpdate;
  final double movementSpeed; // Meters per frame

  const MapCanvasWidget({
    super.key,
    required this.waypoints,
    required this.distanceTraveled,
    required this.selectedCharacter,
    this.onProgressUpdate,
    this.movementSpeed = 2.0, // Default to natural walk
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
  ui.Image? _characterImage;

  @override
  void initState() {
    super.initState();
    _animatedDistance = widget.distanceTraveled;
    _initializeScene();
    _loadCharacterImage();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16),
          )
          ..addListener(_tick)
          ..repeat();
  }

  Future<void> _loadCharacterImage() async {
    try {
      debugPrint('🎨 MapCanvas: Attempting to load character asset...');
      final ByteData data = await rootBundle.load('assets/character.png');
      debugPrint('🎨 MapCanvas: Asset data size: ${data.lengthInBytes}');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _characterImage = frame.image;
        });
        debugPrint(
          '🎨 MapCanvas: Character asset loaded successfully (${frame.image.width}x${frame.image.height}).',
        );
      }
    } catch (e) {
      debugPrint('⚠️ MapCanvas Error loading character image: $e');
      debugPrint(
        '⚠️ MapCanvas: Check if assets/character.png exists and is listed in pubspec.yaml',
      );
    }
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
      // Step Pulse: Character pushes off the ground
      final stepPulse = (math.sin(_walkCycle * math.pi * 2).abs() + 0.3);

      final maxDeltaPerFrame = widget.movementSpeed;
      final step =
          distDiff.clamp(-maxDeltaPerFrame, maxDeltaPerFrame) * stepPulse;

      _animatedDistance += step;
      widget.onProgressUpdate?.call(_animatedDistance);

      // Animation Sync: Stride length increases with speed to prevent blurring
      final strideLength = (widget.movementSpeed * 30.0).clamp(2.0, 100.0);
      final cycleIncrement = (step.abs() / strideLength);

      // Cap frequency at ~4 cycles per second (8 steps/sec) to keep visual clarity
      _walkCycle += cycleIncrement.clamp(0.0, 0.08);
    } else {
      _animatedDistance = widget.distanceTraveled;
      widget.onProgressUpdate?.call(_animatedDistance);
      _walkCycle += 0.015; // Idle breath
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
      final biomeEnd =
          cumulativeDistance +
          (biome.distanceKm * 1000.0); // Convert KM to Meters

      if (distance < biomeEnd || i == kBiomes.length - 1) {
        // We're in this biome
        final localDistance = distance - cumulativeDistance;
        final transitionStart =
            (biome.distanceKm * 1000.0) - 50000.0; // Last 50km for transition

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

          // Increased sensitivity for "Fast Scroll"
          // In previous version sensitivity was 0.1 (10 pixels = 1 meter)
          // Now 1 pixel = 1 meter, so dragging across screen (e.g. 400px) moves 400m
          const double sensitivity = 1.0;
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
            characterImage: _characterImage,
          ),
          child: Container(),
        ),
      ),
    );
  }
}
