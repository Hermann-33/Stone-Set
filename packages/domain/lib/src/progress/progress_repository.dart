import 'progress_models.dart';

abstract interface class ProgressRepository {
  Future<ProgressSnapshot> getProgress();
}
