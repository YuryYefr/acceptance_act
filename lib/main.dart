import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/file_storage_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storage = await FileStorageService.create();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final StorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acceptance Acts',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(storage: storage),
    );
  }
}
