import 'package:equatable/equatable.dart';

class JourneyProgress extends Equatable {
  final int totalSteps;
  final double totalDistance; // in kilometers
  final int currentWaypointIndex;
  final double percentComplete;
  final DateTime startDate;
  final DateTime? estimatedCompletion;

  const JourneyProgress({
    required this.totalSteps,
    required this.totalDistance,
    required this.currentWaypointIndex,
    required this.percentComplete,
    required this.startDate,
    this.estimatedCompletion,
  });

  @override
  List<Object?> get props => [
    totalSteps,
    totalDistance,
    currentWaypointIndex,
    percentComplete,
    startDate,
    estimatedCompletion,
  ];

  JourneyProgress copyWith({
    int? totalSteps,
    double? totalDistance,
    int? currentWaypointIndex,
    double? percentComplete,
    DateTime? startDate,
    DateTime? estimatedCompletion,
  }) {
    return JourneyProgress(
      totalSteps: totalSteps ?? this.totalSteps,
      totalDistance: totalDistance ?? this.totalDistance,
      currentWaypointIndex: currentWaypointIndex ?? this.currentWaypointIndex,
      percentComplete: percentComplete ?? this.percentComplete,
      startDate: startDate ?? this.startDate,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
    );
  }
}
