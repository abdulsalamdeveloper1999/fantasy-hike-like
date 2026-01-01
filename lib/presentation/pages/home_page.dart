import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import '../../data/datasources/silk_road_data.dart';
import '../widgets/map_canvas_widget.dart';
import '../scene/biomes.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double distanceTraveled = 0.0;
  String selectedCharacter = 'default';
  int _selectedIndex = 0;

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
                        '${distanceTraveled.toInt()}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'metres',
                        style: TextStyle(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    MapCanvasWidget.getCurrentCountry(distanceTraveled),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      'Walking down the garden path',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Subtle Add Step Buttons (Top right floaters for testing)
          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                _TestButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      final maxDistance = getTotalJourneyDistance();
                      distanceTraveled = (distanceTraveled + 10.0).clamp(
                        0.0,
                        maxDistance,
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                _TestButton(
                  icon: Icons.refresh,
                  onTap: () => setState(() => distanceTraveled = 0),
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
