import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_state.dart';

class VoyageCubit extends Cubit<VoyageState> {
  Timer? _timer;

  VoyageCubit() : super(VoyageState.initial());

  void startVoyage() {
    if (state.status == VoyageStatus.running || state.status == VoyageStatus.countingDown) return;

    if (state.status == VoyageStatus.initial || state.status == VoyageStatus.paused) {
      if (state.status == VoyageStatus.initial) {
        // Start countdown only for fresh start
        emit(state.copyWith(status: VoyageStatus.countingDown, countdownValue: 3));
        
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (state.countdownValue > 1) {
            emit(state.copyWith(countdownValue: state.countdownValue - 1));
          } else {
            timer.cancel();
            _startActualVoyage();
          }
        });
      } else {
        // Resume directly if paused
        _startActualVoyage();
      }
    }
  }

  void _startActualVoyage() {
    emit(state.copyWith(
      status: VoyageStatus.running,
      countdownValue: 0,
      voyage: state.voyage.startTime == null 
          ? state.voyage.copyWith(startTime: DateTime.now())
          : state.voyage,
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingDuration.inSeconds <= 0) {
        _timer?.cancel();
        emit(state.copyWith(status: VoyageStatus.completed));
      } else {
        final newRemaining = state.remainingDuration - const Duration(seconds: 1);
        final elapsedSeconds = (state.voyage.totalDurationMinutes * 60) - newRemaining.inSeconds;
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
    _startActualVoyage();
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
