import 'package:flutter_test/flutter_test.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_cubit.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_state.dart';

void main() {
  group('VoyageCubit', () {
    late VoyageCubit voyageCubit;

    setUp(() {
      voyageCubit = VoyageCubit();
    });

    tearDown(() {
      voyageCubit.close();
    });

    test('initial state is correct', () {
      expect(voyageCubit.state, VoyageState.initial());
      expect(voyageCubit.state.status, VoyageStatus.initial);
      expect(voyageCubit.state.remainingDuration.inMinutes, 60);
    });

    test('startVoyage starts timer and updates status', () {
      voyageCubit.startVoyage();
      expect(voyageCubit.state.status, VoyageStatus.running);
    });
  });
}
