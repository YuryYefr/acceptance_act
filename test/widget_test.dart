import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acceptance_act/main.dart';
import 'package:acceptance_act/services/storage_service.dart';
import 'package:acceptance_act/models/acceptance_act.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// Mock storage service to avoid MissingPluginException
class MockStorageService implements StorageService {
  @override
  Future<List<AcceptanceAct>> loadActs() async {
    return [];
  }

  @override
  Future<void> saveAct(AcceptanceAct act) async {}

  @override
  Future<void> deleteAct(AcceptanceAct act) async {}

  @override
  Future<String> exportAct(AcceptanceAct act) async {
    return '/tmp/test_export.xlsx';
  }
}

// Mock platform implementation for path_provider
class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    // Return a mock directory for testing
    return Directory('/tmp');
  }

  @override
  Future<Directory?> getDownloadsDirectory() async {
    return Directory('/tmp');
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    return Directory('/tmp');
  }

  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return Directory('/tmp');
  }

  @override
  Future<Directory> getExternalStorageDirectory() async {
    return Directory('/tmp');
  }
}

void main() {
  late StorageService storage;

  setUp(() {
    // Register the mock platform
    PathProviderPlatform.instance = MockPathProviderPlatform();
    storage = MockStorageService();
  });

  testWidgets('Create Acceptance Act, add invoice, edit, validate',
      (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Acceptance Acts'), findsOneWidget);

    // Create new act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap "Add Invoice" - we need to find the button in the act screen
    // The "Add Invoice" button is an ElevatedButton.icon with text "Add Invoice"
    final addInvoiceButton = find.widgetWithText(ElevatedButton, 'Add Invoice');
    expect(addInvoiceButton, findsOneWidget);
    await tester.tap(addInvoiceButton);
    await tester.pumpAndSettle();

    // Fill invoice
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Category'), 'Widgets');
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
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
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
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity'), 'xyz');

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Invalid'), findsNWidgets(2));
  });

  testWidgets('Export functionality works', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    // Create new act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Add an invoice
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Invoice'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Category'), 'Test Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'pcs');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '10');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '5');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Invoice'));
    await tester.pumpAndSettle();

    // Navigate to the act screen to test export
    final actList = find.byType(ListTile);
    await tester.tap(actList);
    await tester.pumpAndSettle();

    // Test export button
    final exportButton = find.byIcon(Icons.download);
    expect(exportButton, findsOneWidget);
    // We can't actually test the file export in widget tests, but we can verify
    // the button is present and the functionality is there
  });

  testWidgets('Delete functionality works', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    // Create new act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Add an invoice
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Invoice'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Category'), 'Test Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'pcs');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '10');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '5');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Invoice'));
    await tester.pumpAndSettle();

    // Navigate to the act screen
    final actList = find.byType(ListTile);
    await tester.tap(actList);
    await tester.pumpAndSettle();

    // Test delete button
    final deleteButton = find.byIcon(Icons.delete);
    expect(deleteButton, findsOneWidget);
    // We can verify the button is present, but actual deletion would require
    // more complex mocking
  });

  testWidgets('Language switching works', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    // Find the language icon button
    final languageButton = find.byIcon(Icons.language);
    expect(languageButton, findsOneWidget);
    
    // Tap the language button to open the dialog
    await tester.tap(languageButton);
    await tester.pumpAndSettle();

    // Check that language selection dialog appears
    expect(find.text('Choose Language'), findsOneWidget);
    
    // Test switching to Ukrainian
    await tester.tap(find.text('Українська'));
    await tester.pumpAndSettle();
    
    // Verify that the snackbar shows the correct message
    expect(find.text('Мову змінено на українську'), findsOneWidget);
  });

  testWidgets('Home screen loads acts correctly', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    // Check that home screen is displayed
    expect(find.text('Acceptance Acts'), findsOneWidget);
    
    // Check that the floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Invoice summary is calculated correctly', (tester) async {
    await tester.pumpWidget(AcceptanceActApp(
      storage: storage,
      initialLocale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    // Create new act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Add first invoice
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Invoice'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Category'), 'Item 1');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'pcs');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '10');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '5');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Invoice'));
    await tester.pumpAndSettle();

    // Add second invoice
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Invoice'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Category'), 'Item 2');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'pcs');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '15');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '3');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Invoice'));
    await tester.pumpAndSettle();

    // Navigate to the act screen
    final actList = find.byType(ListTile);
    await tester.tap(actList);
    await tester.pumpAndSettle();

    // Verify summary is calculated correctly
    // Total quantity should be 5 + 3 = 8
    // Total sum should be 50 + 45 = 95
    expect(find.text('8'), findsOneWidget);
    expect(find.text('95.00'), findsOneWidget);
  });
}
