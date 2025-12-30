import '../../domain/entities/route_waypoint.dart';

class SilkRoadData {
  static const double totalRouteDistance = 5000.0; // kilometers

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
      name: 'Urumqi',
      country: 'Xinjiang, China',
      emoji: '🇨🇳',
      latitude: 43.8256,
      longitude: 87.6168,
      distanceFromStart: 1200,
    ),
    const RouteWaypoint(
      id: 2,
      name: 'Almaty',
      country: 'Kazakhstan',
      emoji: '🇰🇿',
      latitude: 43.2220,
      longitude: 76.8512,
      distanceFromStart: 2100,
    ),
    const RouteWaypoint(
      id: 3,
      name: 'Samarkand',
      country: 'Uzbekistan',
      emoji: '🇺🇿',
      latitude: 39.6270,
      longitude: 66.9750,
      distanceFromStart: 3200,
    ),
    const RouteWaypoint(
      id: 4,
      name: 'Merv',
      country: 'Turkmenistan',
      emoji: '🇹🇲',
      latitude: 37.6650,
      longitude: 62.1900,
      distanceFromStart: 4000,
    ),
    const RouteWaypoint(
      id: 5,
      name: 'Tehran',
      country: 'Iran (Persia)',
      emoji: '🇮🇷',
      latitude: 35.6892,
      longitude: 51.3890,
      distanceFromStart: 5000,
    ),
  ];
}
