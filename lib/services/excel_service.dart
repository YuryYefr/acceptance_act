import 'dart:io';
import 'package:excel/excel.dart';
import '../models/acceptance_act.dart';
import '../models/invoice.dart';

class ExcelService {
  static Future<void> export({
    required AcceptanceAct act,
    required String filePath,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Acceptance Act'];

    // ───────── STYLES ─────────
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: '#BBDEFB',
      // light blue
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
    );

    final cellStyle = CellStyle(
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
    );

    int row = 0;

    // ───────── TITLE ─────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row),
    );
    final titleCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    titleCell.value = 'ACCEPTANCE ACT';
    titleCell.cellStyle = titleStyle;
    row += 2;

    // ───────── METADATA ─────────
    _writeRow(sheet, row++, ['Name:', act.name], cellStyle);
    _writeRow(sheet, row++, ['Date:', _formatDate(DateTime.now())], cellStyle);
    row++;

    // ───────── SUMMARY ─────────
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'SUMMARY'
      ..cellStyle = CellStyle(bold: true, fontSize: 14);
    row++;

    final summary = _buildSummary(act.invoices);
    _writeHeader(sheet, row++, ['Category', 'Quantity', 'Total'], headerStyle);

    for (final s in summary) {
      _writeRow(
          sheet,
          row++,
          [
            s.category,
            s.quantity,
            s.total,
          ],
          cellStyle,
          isNumber: [false, true, true]);
    }

    row += 2;

    // ───────── INVOICES ─────────
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'INVOICES'
      ..cellStyle = CellStyle(bold: true, fontSize: 14);
    row++;

    _writeHeader(sheet, row++,
        ['Category', 'Unit', 'Price', 'Quantity', 'Total'], headerStyle);

    for (final inv in act.invoices) {
      _writeRow(
          sheet,
          row++,
          [
            inv.category,
            inv.unit,
            inv.price,
            inv.quantity,
            inv.total,
          ],
          cellStyle,
          isNumber: [false, false, true, true, true]);
    }

// ───────── GRAND TOTAL ─────────
    int totalQuantity = act.invoices.fold(0, (sum, inv) => sum + inv.quantity);
    double totalSum = act.invoices.fold(0.0, (sum, inv) => sum + inv.total);

    _writeRow(
        sheet,
        row++,
        [
          'TOTAL',
          '',
          '',
          totalQuantity,
          totalSum,
        ],
        CellStyle(
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
            bottomBorder: Border(borderStyle: BorderStyle.Thin),
            topBorder: Border(borderStyle: BorderStyle.Thin),
            leftBorder: Border(borderStyle: BorderStyle.Thin),
            rightBorder: Border(borderStyle: BorderStyle.Thin)),
        isNumber: [false, false, false, true, true]);

    // ───────── COLUMN WIDTHS ─────────
    sheet.getColAutoFits;

    // ───────── SAVE FILE ─────────
    final bytes = excel.encode()!;
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
  }

  // ───────── HELPERS ─────────
  static void _writeHeader(
      Sheet sheet, int row, List<String> values, CellStyle style) {
    for (int i = 0; i < values.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = values[i];
      cell.cellStyle = style;
    }
  }

  static void _writeRow(
      Sheet sheet, int row, List<dynamic> values, CellStyle style,
      {List<bool>? isNumber}) {
    for (int i = 0; i < values.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      final val = values[i];
      final number =
          isNumber != null && i < isNumber.length ? isNumber[i] : false;

      if (number) {
        cell.value = val is int ? val : val.toDouble();
      } else {
        cell.value = val.toString();
      }
      cell.cellStyle = style;
    }
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';

  static List<_SummaryRow> _buildSummary(List<Invoice> invoices) {
    final map = <String, _SummaryRow>{};

    for (final inv in invoices) {
      map.putIfAbsent(inv.category, () => _SummaryRow(inv.category));
      map[inv.category]!.quantity += inv.quantity;
      map[inv.category]!.total += inv.total;
    }

    return map.values.toList();
  }
}

class _SummaryRow {
  final String category;
  int quantity = 0;
  double total = 0;

  _SummaryRow(this.category);
}
