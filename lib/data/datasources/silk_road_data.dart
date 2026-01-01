import '../../domain/entities/route_waypoint.dart';

class SilkRoadData {
  static const double totalRouteDistance =
      5700.0; // Align with narrative segments

  static final List<RouteWaypoint> waypoints = [
    const RouteWaypoint(
      id: 0,
      name: 'Ulaanbaatar',
      country: 'Mongolia',
      emoji: '🇲🇳',
      latitude: 47.8864,
      longitude: 106.9057,
      distanceFromStart: 0,
    ),
    const RouteWaypoint(
      id: 1,
      name: 'Great Wall Reach',
      country: 'Northern China',
      emoji: '🇨🇳',
      latitude: 40.4319,
      longitude: 116.5704,
      distanceFromStart: 1800,
    ),
    const RouteWaypoint(
      id: 2,
      name: 'Steppe Pass',
      country: 'Kazakhstan',
      emoji: '🇰🇿',
      latitude: 43.2220,
      longitude: 76.8512,
      distanceFromStart: 3000,
    ),
    const RouteWaypoint(
      id: 3,
      name: 'Desert Oasis',
      country: 'Turkmenistan',
      emoji: '🇹🇲',
      latitude: 37.6650,
      longitude: 62.1900,
      distanceFromStart: 3900,
    ),
    const RouteWaypoint(
      id: 4,
      name: 'Persian Frontier',
      country: 'Persia (Iran)',
      emoji: '🇮🇷',
      latitude: 35.6892,
      longitude: 51.3890,
      distanceFromStart: 4600,
    ),
    const RouteWaypoint(
      id: 5,
      name: 'Imperial Capital',
      country: 'Persian Empire',
      emoji: '🏛️',
      latitude: 32.6539,
      longitude: 51.6660,
      distanceFromStart: 5700,
    ),
  ];
}
