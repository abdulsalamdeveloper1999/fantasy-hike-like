import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import '../../data/datasources/silk_road_data.dart';
import '../widgets/map_canvas_widget.dart';
import '../scene/biomes.dart';
import '../../data/datasources/narrative_data.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double distanceTraveled = 0.0;
  double _visualDistanceMeters = 0.0;
  double _currentMovementSpeed = 2.0; // Default Hike speed
  String selectedCharacter = 'default';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _visualDistanceMeters = distanceTraveled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Edge-to-edge Map View (Background)
          Positioned.fill(
            child: MapCanvasWidget(
              waypoints: SilkRoadData.waypoints,
              distanceTraveled: distanceTraveled,
              selectedCharacter: selectedCharacter,
              movementSpeed: _currentMovementSpeed,
              onProgressUpdate: (meters) {
                if (mounted) {
                  setState(() => _visualDistanceMeters = meters);
                }
              },
            ),
          ),

          // 2. Stats Overlay (Lower portion)
          Positioned(
            left: 0,
            right: 0,
            bottom: 105, // Lowered back down relative to new lower horizon
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    'Day 1',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        (_visualDistanceMeters / 1000).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32, // Larger
                          fontWeight: FontWeight.w900, // Extra bold
                          color: Color(0xFFFFD700),
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KM', // Units changed to KM
                        style: TextStyle(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    MapCanvasWidget.getCurrentCountry(
                      _visualDistanceMeters / 1000,
                    ).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, // Brighter
                      fontSize: 16, // Larger
                      fontWeight: FontWeight.w900, // Bolder
                      letterSpacing: 2.0, // More spaced out
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      NarrativeData.getNarrative(_visualDistanceMeters / 1000),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14, // Consistent with original design
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Multi-Speed Travel Buttons
          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                // HIKE (🚶) - Human Pace (~11 km/h)
                _TestButton(
                  icon: Icons.directions_walk,
                  onTap: () {
                    setState(() {
                      _currentMovementSpeed = 0.5; // ~11 km/h power-walk
                      distanceTraveled = (distanceTraveled + 1000.0).clamp(
                        0.0,
                        getTotalJourneyDistance() * 1000.0,
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                // GALLOP (🐎) - Fast (~65 km/h)
                _TestButton(
                  icon: Icons.speed,
                  onTap: () {
                    setState(() {
                      _currentMovementSpeed = 0.3; // ~65 km/h horse gallop
                      distanceTraveled = (distanceTraveled + 10000.0).clamp(
                        0.0,
                        getTotalJourneyDistance() * 1000.0,
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                // BLITZ (⚡) - Superfast (~320 km/h)
                _TestButton(
                  icon: Icons.bolt,
                  onTap: () {
                    setState(() {
                      _currentMovementSpeed = 1.5; // ~320 km/h superhuman
                      distanceTraveled = (distanceTraveled + 50000.0).clamp(
                        0.0,
                        getTotalJourneyDistance() * 1000.0,
                      );
                    });
                  },
                ),
                const SizedBox(height: 24),
                _TestButton(
                  icon: Icons.refresh,
                  onTap: () {
                    setState(() {
                      distanceTraveled = 0;
                      _visualDistanceMeters = 0;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF070707),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              Icons.directions_walk,
              0,
              _selectedIndex,
              (i) => setState(() => _selectedIndex = i),
            ),
            _NavIcon(
              Icons.map_outlined,
              1,
              _selectedIndex,
              (i) => setState(() => _selectedIndex = i),
            ),
            _NavIcon(
              Icons.emoji_events_outlined,
              2,
              _selectedIndex,
              (i) => setState(() => _selectedIndex = i),
            ),
            _NavIcon(
              Icons.backpack_outlined,
              3,
              _selectedIndex,
              (i) => setState(() => _selectedIndex = i),
            ),
            _NavIcon(
              Icons.settings_outlined,
              4,
              _selectedIndex,
              (i) => setState(() => _selectedIndex = i),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _NavIcon(this.icon, this.index, this.selectedIndex, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFFD700) : Colors.white30,
            size: 28,
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TestButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}
