import 'scheduling_models.dart';

abstract interface class SchedulingRepository {
  Future<WeekLoadResult> getOrCreateCurrentWeek();

  Future<SwapResult> confirmSwap({
    required String weekId,
    required String firstItemId,
    required String secondItemId,
  });
}
