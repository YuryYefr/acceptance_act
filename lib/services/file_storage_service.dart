import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/acceptance_act.dart';
import 'storage_service.dart';
import 'excel_service.dart';

class FileStorageService implements StorageService {
  final String folderPath;

  FileStorageService._(this.folderPath);

  static Future<FileStorageService> create() async {
    final appDir = await getApplicationSupportDirectory();
    final folder = Directory(p.join(appDir.path, 'acceptance_act'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return FileStorageService._(folder.path);
  }

  @override
  Future<List<AcceptanceAct>> loadActs() async {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) return [];

    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.xlsx'))
        .map((f) {
      final name = p.basenameWithoutExtension(f.path);
      return AcceptanceAct(
        id: name,
        name: name,
        category: '',
        sum: 0,
        quantity: 0,
        invoices: [],
      );
    }).toList();
  }

  @override
  Future<void> saveAct(AcceptanceAct act) async {
    final path = p.join(folderPath, '${act.name}.xlsx');
    await ExcelService.export(act: act, desktopPath: path);
  }

  @override
  Future<void> deleteAct(AcceptanceAct act) async {
    final file = File(p.join(folderPath, '${act.name}.xlsx'));
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String> exportAct(AcceptanceAct act) async {
    Directory? downloads;

    try {
      downloads = await getDownloadsDirectory();
    } catch (_) {}

    final exportDir = downloads != null
        ? Directory(p.join(downloads.path, 'acceptance_act'))
        : Directory(folderPath);

    if (!exportDir.existsSync()) {
      exportDir.createSync(recursive: true);
    }

    final path = p.join(exportDir.path, '${act.name}.xlsx');
    await ExcelService.export(act: act, desktopPath: path);
    return path;
  }
}
