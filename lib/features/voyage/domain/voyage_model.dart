import 'package:equatable/equatable.dart';

class VoyageModel extends Equatable {
  final String id;
  final String goalTitle;
  final int totalDurationMinutes;
  final double totalDistanceKm;
  final DateTime? startTime;

  const VoyageModel({
    required this.id,
    required this.goalTitle,
    required this.totalDurationMinutes,
    required this.totalDistanceKm,
    this.startTime,
  });

  @override
  List<Object?> get props => [id, goalTitle, totalDurationMinutes, totalDistanceKm, startTime];

  VoyageModel copyWith({
    String? id,
    String? goalTitle,
    int? totalDurationMinutes,
    double? totalDistanceKm,
    DateTime? startTime,
  }) {
    return VoyageModel(
      id: id ?? this.id,
      goalTitle: goalTitle ?? this.goalTitle,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      startTime: startTime ?? this.startTime,
    );
  }
}
