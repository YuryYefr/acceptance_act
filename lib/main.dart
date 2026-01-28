import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/file_storage_service.dart';
import 'services/storage_service.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storage = await FileStorageService.create();
  final prefs = await SharedPreferences.getInstance();
  final String? savedLocale = prefs.getString('locale');

  runApp(AcceptanceActApp(
    storage: storage,
    initialLocale:
    savedLocale != null ? Locale(savedLocale) : const Locale('en'),
  ));
}

class AcceptanceActApp extends StatefulWidget {
  final StorageService storage;
  final Locale initialLocale;

  const AcceptanceActApp({
    super.key,
    required this.storage,
    required this.initialLocale,
  });

  @override
  State<AcceptanceActApp> createState() => _AcceptanceActAppState();
}

class _AcceptanceActAppState extends State<AcceptanceActApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('locale', locale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acceptance Acts',
      theme: appTheme,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('uk'),
      ],
      locale: _locale,
      home: HomeScreen(
        storage: widget.storage,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}
