import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acceptance_act/main.dart';
import 'package:acceptance_act/services/file_storage_service.dart';
import 'package:acceptance_act/services/storage_service.dart';

void main() {
  late StorageService storage;

  setUp(() async {
    storage = await FileStorageService.create();
  });

  testWidgets('Create Acceptance Act, add invoice, edit, validate', (tester) async {
    await tester.pumpWidget(MyApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('Acceptance Acts'), findsOneWidget);

    // Create new act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap "Add Invoice"
    final addInvoiceButton = find.widgetWithText(ElevatedButton, 'Add Invoice');
    expect(addInvoiceButton, findsOneWidget);
    await tester.tap(addInvoiceButton);
    await tester.pumpAndSettle();

    // Fill invoice
    await tester.enterText(find.widgetWithText(TextFormField, 'Category'), 'Widgets');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'pcs');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '12.5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '4');

    // Save
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Invoice'));
    await tester.pumpAndSettle();

    // Validate invoice in list
    expect(find.textContaining('Widgets'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('50.00'), findsOneWidget);

    // Edit invoice
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '15');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '3');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Invoice'));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('45.00'), findsOneWidget);
  });

  testWidgets('Invoice validation works', (tester) async {
    await tester.pumpWidget(MyApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Invoice'));
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Save Invoice');

    // Save empty invoice
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);

    // Invalid numbers
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), 'abc');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), 'xyz');

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Invalid'), findsNWidgets(2));
  });
}
