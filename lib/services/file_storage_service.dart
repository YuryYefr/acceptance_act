import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/acceptance_act.dart';
import 'storage_service.dart';

class FileStorageService implements StorageService {
  final Directory folder;

  FileStorageService._(this.folder);

  static Future<FileStorageService> create() async {
    final dir = await getApplicationSupportDirectory();
    final folder = Directory(p.join(dir.path, 'acceptance_acts'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return FileStorageService._(folder);
  }

  File _fileFor(String id) => File(p.join(folder.path, '$id.json'));

  @override
  Future<List<AcceptanceAct>> loadActs() async {
    if (!await folder.exists()) return [];

    final files = folder
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    final acts = <AcceptanceAct>[];

    for (final f in files) {
      final json = jsonDecode(await f.readAsString());
      acts.add(AcceptanceAct.fromJson(json));
    }

    acts.sort((a, b) => a.name.compareTo(b.name));
    return acts;
  }

  @override
  Future<void> saveAct(AcceptanceAct act) async {
    act.recalc();
    final file = _fileFor(act.id);
    await file.writeAsString(jsonEncode(act.toJson()));
  }

  @override
  Future<void> deleteAct(AcceptanceAct act) async {
    final file = _fileFor(act.id);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
