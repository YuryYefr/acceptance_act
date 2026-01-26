import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/acceptance_act.dart';

class ExcelService {
  /// Exports the Acceptance Act to a .xlsx file at the specified path
  static Future<void> export({
    required AcceptanceAct act,
    required String desktopPath, // full path including filename
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Acceptance Act'];
    int row = 0;

    // ---- Act Name ----
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(act.name);

    row = 2;

    // ---- Summary Header ----
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Category');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('Quantity');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('Sum');

    row++;

    // ---- Summary Values ----
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(act.category);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = IntCellValue(act.quantity);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = DoubleCellValue(act.sum);

    row += 2;

    // ---- Invoice Table ----
    final headers = ['Category', 'Unit', 'Price', 'Quantity', 'Total'];
    for (int i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
          .value = TextCellValue(headers[i]);
    }

    row++;

    for (var inv in act.invoices) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(inv.category);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(inv.unit);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = DoubleCellValue(inv.price);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = IntCellValue(inv.quantity);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = DoubleCellValue(inv.total);
      row++;
    }

    // Encode Excel
    final bytes = excel.encode();
    if (bytes == null) return;

    // Write to file
    final file = File(desktopPath);
    await file.writeAsBytes(Uint8List.fromList(bytes));
  }

  /// Loads all .xlsx files from a folder and returns paths
  static List<String> loadActsFromFolder(String folderPath) {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) return [];
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.xlsx'))
        .toList();
    return files.map((f) => f.path).toList();
  }
}
