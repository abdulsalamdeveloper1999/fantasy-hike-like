import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_state.dart';

class VoyageCubit extends Cubit<VoyageState> {
  Timer? _timer;

  VoyageCubit() : super(VoyageState.initial());

  void startVoyage() {
    if (state.status == VoyageStatus.running) return;

    emit(state.copyWith(
      status: VoyageStatus.running,
      voyage: state.voyage.copyWith(startTime: DateTime.now()),
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingDuration.inSeconds <= 0) {
        _timer?.cancel();
        emit(state.copyWith(status: VoyageStatus.completed));
      } else {
        final newRemaining = state.remainingDuration - const Duration(seconds: 1);
        final elapsedSeconds = (state.voyage.totalDurationMinutes * 60) - newRemaining.inSeconds;
        // 1 minute = 1 km -> 1 second = 1/60 km
        final newDistance = elapsedSeconds / 60.0;

        emit(state.copyWith(
          remainingDuration: newRemaining,
          elapsedDistanceKm: newDistance,
        ));
      }
    });
  }

  void pauseVoyage() {
    _timer?.cancel();
    emit(state.copyWith(status: VoyageStatus.paused));
  }

  void resumeVoyage() {
    startVoyage();
  }

  void resetVoyage() {
    _timer?.cancel();
    emit(VoyageState.initial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
