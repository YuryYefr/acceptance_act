import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/acceptance_act.dart';

class ExcelService {
  static Future<void> export({
    required AcceptanceAct act,
    required String filePath,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Acceptance Act'];

    int row = 0;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        TextCellValue(act.name);

    row = 2;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        TextCellValue('Category');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        TextCellValue('Quantity');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
        TextCellValue('Sum');

    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        TextCellValue(act.category);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        IntCellValue(act.quantity);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
        DoubleCellValue(act.sum);

    row += 2;

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

    final bytes = excel.encode();
    if (bytes == null) return;

    final file = File(filePath);
    await file.writeAsBytes(Uint8List.fromList(bytes));
  }
}
