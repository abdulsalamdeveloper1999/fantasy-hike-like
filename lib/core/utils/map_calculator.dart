import 'dart:ui';
import '../../domain/entities/route_waypoint.dart';

class MapCalculator {
  /// Convert steps to kilometers (average: 1 step ≈ 0.0008 km)
  static double stepsToKilometers(int steps) {
    return steps * 0.0008;
  }

  /// Calculate which waypoint segment the user is currently in
  static int getCurrentWaypointIndex(
    double distanceTraveled,
    List<RouteWaypoint> waypoints,
  ) {
    for (int i = waypoints.length - 1; i >= 0; i--) {
      if (distanceTraveled >= waypoints[i].distanceFromStart) {
        return i;
      }
    }
    return 0;
  }

  /// Interpolate position between two waypoints based on distance traveled
  static Offset interpolatePosition({
    required double distanceTraveled,
    required RouteWaypoint fromWaypoint,
    required RouteWaypoint toWaypoint,
    required Size canvasSize,
    required List<RouteWaypoint> allWaypoints,
  }) {
    // Calculate normalized positions for waypoints across the canvas
    final fromX = _normalizeX(
      fromWaypoint.id,
      allWaypoints.length,
      canvasSize.width,
    );
    final toX = _normalizeX(
      toWaypoint.id,
      allWaypoints.length,
      canvasSize.width,
    );

    final fromY = _normalizeY(fromWaypoint.latitude, canvasSize.height);
    final toY = _normalizeY(toWaypoint.latitude, canvasSize.height);

    // Calculate progress between the two waypoints
    final segmentDistance =
        toWaypoint.distanceFromStart - fromWaypoint.distanceFromStart;
    final progressInSegment =
        (distanceTraveled - fromWaypoint.distanceFromStart) / segmentDistance;
    final clampedProgress = progressInSegment.clamp(0.0, 1.0);

    // Interpolate position
    final x = fromX + (toX - fromX) * clampedProgress;
    final y = fromY + (toY - fromY) * clampedProgress;

    return Offset(x, y);
  }

  /// Normalize waypoint index to X coordinate
  static double _normalizeX(
    int waypointIndex,
    int totalWaypoints,
    double canvasWidth,
  ) {
    const padding = 40.0;
    final usableWidth = canvasWidth - (padding * 2);
    return padding + (waypointIndex / (totalWaypoints - 1)) * usableWidth;
  }

  /// Normalize latitude to Y coordinate (inverted for canvas)
  static double _normalizeY(double latitude, double canvasHeight) {
    // Latitude range for Silk Road: ~35° to 48°
    const minLat = 35.0;
    const maxLat = 48.0;
    const padding = 60.0;

    final normalizedLat = (latitude - minLat) / (maxLat - minLat);
    final usableHeight = canvasHeight - (padding * 2);

    // Invert Y because canvas Y increases downward
    return canvasHeight - (padding + normalizedLat * usableHeight);
  }

  /// Get all waypoint positions for drawing on canvas
  static List<Offset> getWaypointPositions(
    List<RouteWaypoint> waypoints,
    Size canvasSize,
  ) {
    return waypoints.map((waypoint) {
      final x = _normalizeX(waypoint.id, waypoints.length, canvasSize.width);
      final y = _normalizeY(waypoint.latitude, canvasSize.height);
      return Offset(x, y);
    }).toList();
  }
}
