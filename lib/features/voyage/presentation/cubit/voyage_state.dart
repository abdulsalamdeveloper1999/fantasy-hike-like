import 'package:equatable/equatable.dart';
import 'package:step_journey/features/voyage/domain/voyage_model.dart';

enum VoyageStatus { initial, running, paused, completed }

class VoyageState extends Equatable {
  final VoyageStatus status;
  final VoyageModel voyage;
  final Duration remainingDuration;
  final double elapsedDistanceKm;

  const VoyageState({
    required this.status,
    required this.voyage,
    required this.remainingDuration,
    required this.elapsedDistanceKm,
  });

  factory VoyageState.initial() {
    return VoyageState(
      status: VoyageStatus.initial,
      voyage: const VoyageModel(
        id: '1',
        goalTitle: 'Finish Essay',
        totalDurationMinutes: 60,
        totalDistanceKm: 60.0,
      ),
      remainingDuration: const Duration(minutes: 60),
      elapsedDistanceKm: 0.0,
    );
  }

  @override
  List<Object?> get props => [status, voyage, remainingDuration, elapsedDistanceKm];

  VoyageState copyWith({
    VoyageStatus? status,
    VoyageModel? voyage,
    Duration? remainingDuration,
    double? elapsedDistanceKm,
  }) {
    return VoyageState(
      status: status ?? this.status,
      voyage: voyage ?? this.voyage,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      elapsedDistanceKm: elapsedDistanceKm ?? this.elapsedDistanceKm,
    );
  }

  double get progress => 1.0 - (remainingDuration.inSeconds / (voyage.totalDurationMinutes * 60));
}
