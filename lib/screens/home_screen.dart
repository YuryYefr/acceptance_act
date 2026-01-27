import 'package:flutter/material.dart';
import '../models/acceptance_act.dart';
import '../screens/acceptance_act_screen.dart';
import '../services/storage_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  final Function(Locale)? onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.storage,
    this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AcceptanceAct> acts = [];

  @override
  void initState() {
    super.initState();
    _loadActs();
  }

  // Correct async handling
  Future<void> _loadActs() async {
    final loaded = await widget.storage.loadActs();
    setState(() {
      acts = loaded;
    });
  }

  Future<void> _createAct() async {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final defaultName = 'act_${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}';

    String? actName;
    bool autoName = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: defaultName);
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(localizations.newAcceptanceAct),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: autoName,
                      onChanged: (v) {
                        setState(() {
                          autoName = v ?? true;
                          controller.text = autoName ? defaultName : '';
                        });
                      },
                    ),
                    Text(localizations.autoName),
                  ],
                ),
                TextFormField(
                  controller: controller,
                  enabled: !autoName,
                  autofocus: !autoName,
                  decoration: InputDecoration(labelText: localizations.actName),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(localizations.cancel)),
              ElevatedButton(
                  onPressed: () {
                    actName =
                        controller.text.isEmpty ? defaultName : controller.text;
                    Navigator.pop(context, true);
                  },
                  child: Text(localizations.create)),
            ],
          ),
        );
      },
    );

    if (result != true || actName == null) return;

    final act = AcceptanceAct(
      id: now.microsecondsSinceEpoch.toString(),
      name: actName!,
      category: '',
      sum: 0,
      quantity: 0,
      invoices: [],
    );

    setState(() => acts.add(act));

    // Navigate to AcceptanceActScreen
    final deletedOrUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              AcceptanceActScreen(act: act, storage: widget.storage)),
    );

    if (deletedOrUpdated == true) {
      // Act was deleted inside AcceptanceActScreen
      _loadActs();
    } else {
      // Otherwise, reload to catch updates
      _loadActs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // Show language selection dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(localizations.chooseLanguage),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        onTap: () {
                          Navigator.pop(context);
                          // Change locale to English
                          if (widget.onLocaleChanged != null) {
                            widget.onLocaleChanged!(const Locale('en'));
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Language changed to English')),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Українська'),
                        onTap: () {
                          Navigator.pop(context);
                          // Change locale to Ukrainian
                          if (widget.onLocaleChanged != null) {
                            widget.onLocaleChanged!(const Locale('uk'));
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Мову змінено на українську')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            tooltip: 'Language',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: acts.length,
        itemBuilder: (context, i) {
          final act = acts[i];
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(act.name),
            ),
            onTap: () async {
              final deletedOrUpdated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        AcceptanceActScreen(act: act, storage: widget.storage)),
              );
              if (deletedOrUpdated == true) _loadActs();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
