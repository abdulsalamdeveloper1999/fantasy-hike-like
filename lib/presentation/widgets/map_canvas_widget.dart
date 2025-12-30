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
    // Raising horizons so text at bottom has a clean black background
    _terrainFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.55, // Raised significantly
      roughness: 1.1,
      seed: 101,
      segments: 400,
      octaves: 5,
    );
    _terrainTo = _terrainFrom;

    _nearHillsFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.45,
      roughness: 0.9,
      seed: 106,
      segments: 300,
      octaves: 4,
    );
    _nearHillsTo = _nearHillsFrom;

    _midHillsFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.42,
      roughness: 0.7,
      seed: 111,
      segments: 200,
      octaves: 4,
    );
    _midHillsTo = _midHillsFrom;

    _farMountainsFrom = TerrainEngine.generateTerrain(
      baseY: TerrainEngine.kWorldHeight * 0.35,
      roughness: 0.6,
      seed: 121,
      segments: 300,
      octaves: 5,
    );
    _farMountainsTo = _farMountainsFrom;

    // Generate props for the entire world once
    _rocksFrom = generateRocks(101, 150);
    _rocksTo = _rocksFrom;

    _foliageFrom = generateFoliage(101, 1.0);
    _foliageTo = _foliageFrom;
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
    setState(() {});
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

    // Biome Logic: Biomes are 1000m apart.
    // Transition over the last 300m of each biome segment.
    const double biomeWidth = 1000.0;
    const double transitionWidth = 300.0;

    final pos = visualDistance / biomeWidth;
    final currentBiomeIndex = pos.floor() % kBiomes.length;
    final targetBiomeIndex = (currentBiomeIndex + 1) % kBiomes.length;
    final localDist = visualDistance % biomeWidth;

    double biomeTransitionT = 0.0;
    if (localDist > (biomeWidth - transitionWidth)) {
      biomeTransitionT =
          (localDist - (biomeWidth - transitionWidth)) / transitionWidth;
    }

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
