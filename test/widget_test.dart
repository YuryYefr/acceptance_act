import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acceptance_act/main.dart';
import 'package:acceptance_act/services/storage_service.dart';
import 'package:acceptance_act/models/acceptance_act.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// --------------------
// Mock Storage Service
// --------------------
class MockStorageService implements StorageService {
  final List<AcceptanceAct> _acts = [];

  @override
  Future<List<AcceptanceAct>> loadActs() async {
    return List.from(_acts);
  }

  @override
  Future<void> saveAct(AcceptanceAct act) async {
    _acts.removeWhere((a) => a.id == act.id);
    _acts.add(act);
  }

  @override
  Future<void> deleteAct(AcceptanceAct act) async {
    _acts.removeWhere((a) => a.id == act.id);
  }

  @override
  Future<String> exportAct(AcceptanceAct act) async {
    return '/tmp/test_export.xlsx';
  }
}

// --------------------
// Mock path_provider
// --------------------
class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory.systemTemp;
  }

  @override
  Future<Directory?> getDownloadsDirectory() async {
    return Directory.systemTemp;
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return Directory.systemTemp;
  }

  @override
  Future<Directory?> getExternalStorageDirectory() async {
    return Directory.systemTemp;
  }
}

void main() {
  late StorageService storage;

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    storage = MockStorageService();
  });

  Future<void> _createAct(WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
  }

  Future<void> _addInvoice(
      WidgetTester tester, {
        required String category,
        required String unit,
        required String price,
        required String quantity,
      }) async {
    await tester.tap(find.byKey(const Key('add_invoice_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('category_field')), category);
    await tester.enterText(find.byKey(const Key('unit_field')), unit);
    await tester.enterText(find.byKey(const Key('price_field')), price);
    await tester.enterText(find.byKey(const Key('quantity_field')), quantity);

    await tester.tap(find.byKey(const Key('save_invoice_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('Create Acceptance Act, add invoice, edit, validate',
          (tester) async {
        await tester.pumpWidget(AcceptanceActApp(
          storage: storage,
          initialLocale: const Locale('en'),
        ));
        await tester.pumpAndSettle();

        await _createAct(tester);

        await _addInvoice(
          tester,
          category: 'Widgets',
          unit: 'pcs',
          price: '12.5',
          quantity: '4',
        );

        expect(find.byKey(const Key('invoice_total_0')), findsOneWidget);
        expect(find.text('50.00'), findsOneWidget);

        // Edit invoice
        await tester.tap(find.byKey(const Key('edit_invoice_0')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('price_field')), '15');
        await tester.enterText(find.byKey(const Key('quantity_field')), '3');

        await tester.tap(find.byKey(const Key('save_invoice_button')));
        await tester.pumpAndSettle();

        expect(find.text('45.00'), findsOneWidget);
      });

  testWidgets('Invoice validation works', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    await _createAct(tester);

    await tester.tap(find.byKey(const Key('add_invoice_button')));
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const Key('save_invoice_button'));

    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);

    await tester.enterText(find.byKey(const Key('price_field')), 'abc');
    await tester.enterText(find.byKey(const Key('quantity_field')), 'xyz');

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Invalid'), findsNWidgets(2));
  });

  testWidgets('Export functionality button exists', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    await _createAct(tester);

    await _addInvoice(
      tester,
      category: 'Test',
      unit: 'pcs',
      price: '10',
      quantity: '5',
    );

    expect(find.byIcon(Icons.download), findsOneWidget);
  });

  testWidgets('Delete invoice works', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    await _createAct(tester);

    await _addInvoice(
      tester,
      category: 'Test',
      unit: 'pcs',
      price: '10',
      quantity: '5',
    );

    expect(find.byKey(const Key('delete_invoice_0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete_invoice_0')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('invoice_total_0')), findsNothing);
  });

  testWidgets('Home screen loads correctly', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Acceptance Acts'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Invoice summary calculation is correct', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    await _createAct(tester);

    await _addInvoice(
      tester,
      category: 'Item 1',
      unit: 'pcs',
      price: '10',
      quantity: '5',
    );

    await _addInvoice(
      tester,
      category: 'Item 2',
      unit: 'pcs',
      price: '15',
      quantity: '3',
    );

    expect(find.text('8'), findsOneWidget);
    expect(find.text('95.00'), findsOneWidget);
  });
}
