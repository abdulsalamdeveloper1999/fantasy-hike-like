import 'package:equatable/equatable.dart';

class RouteWaypoint extends Equatable {
  final int id;
  final String name;
  final String country;
  final String emoji;
  final double latitude;
  final double longitude;
  final double distanceFromStart; // in kilometers

  const RouteWaypoint({
    required this.id,
    required this.name,
    required this.country,
    required this.emoji,
    required this.latitude,
    required this.longitude,
    required this.distanceFromStart,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    emoji,
    latitude,
    longitude,
    distanceFromStart,
  ];
}
