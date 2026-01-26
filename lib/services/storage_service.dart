import '../models/acceptance_act.dart';

abstract class StorageService {
  Future<List<AcceptanceAct>> loadActs();
  Future<void> saveAct(AcceptanceAct act);
  Future<void> deleteAct(AcceptanceAct act);

  /// Returns exported file path
  Future<String> exportAct(AcceptanceAct act);
}
