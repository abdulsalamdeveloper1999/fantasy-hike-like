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
  int _jumpCounter = 0;

  void _jumpToCountry(double km) {
    setState(() {
      distanceTraveled = km * 1000.0;
      _visualDistanceMeters = distanceTraveled; // Instant UI sync
      _jumpCounter++; // Trigger visual snap
    });
  }

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
              jumpCounter: _jumpCounter,
              onProgressUpdate: (meters) {
                if (mounted) {
                  setState(() => _visualDistanceMeters = meters);
                }
              },
              onDistanceDelta: (delta) {
                setState(() {
                  distanceTraveled = (distanceTraveled + delta).clamp(
                    0.0,
                    getTotalJourneyDistance() * 1000.0,
                  );
                });
              },
            ),
          ),

          // 2. Stats Overlay (Lower portion)
          Positioned(
            left: 0,
            right: 0,
            bottom:
                40, // Lowered to clear the visual path for the character and horses
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
                        _visualDistanceMeters < 1000
                            ? _visualDistanceMeters.toInt().toString()
                            : (_visualDistanceMeters / 1000).toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 32, // Larger
                          fontWeight: FontWeight.w900, // Extra bold
                          color: Color(0xFFFFD700),
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _visualDistanceMeters < 1000 ? 'M' : 'KM',
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

          // 4. Instant Country Jump Sidebar (Left)
          Positioned(
            left: 16,
            top: 50,
            bottom: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _JumpButton(label: '🇲🇳', onTap: () => _jumpToCountry(0)),
                  const SizedBox(height: 8),
                  _JumpButton(label: '🇨🇳', onTap: () => _jumpToCountry(120)),
                  const SizedBox(height: 8),
                  _JumpButton(label: '🇰🇿', onTap: () => _jumpToCountry(220)),
                  const SizedBox(height: 8),
                  _JumpButton(label: '🇺🇿', onTap: () => _jumpToCountry(310)),
                  const SizedBox(height: 8),
                  _JumpButton(label: '🇹🇲', onTap: () => _jumpToCountry(390)),
                  const SizedBox(height: 8),
                  _JumpButton(label: '🇮🇷', onTap: () => _jumpToCountry(470)),
                ],
              ),
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

class _JumpButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _JumpButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
