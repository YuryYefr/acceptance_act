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

  Future<void> _loadActs() async {
    final loaded = await widget.storage.loadActs();
    if (!mounted) return;
    setState(() => acts = loaded);
  }

  Future<void> _createAct() async {
    final now = DateTime.now();
    final defaultName =
        'act_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

    final controller = TextEditingController(text: defaultName);
    bool autoName = true;
    final localizations = AppLocalizations.of(context);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
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
              TextField(
                controller: controller,
                enabled: !autoName,
                autofocus: !autoName,
                decoration: InputDecoration(labelText: localizations.actName),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(localizations.create),
            ),
          ],
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    final act = AcceptanceAct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: result,
      category: '',
      sum: 0,
      quantity: 0,
      invoices: [],
    );

    await widget.storage.saveAct(act);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcceptanceActScreen(act: act, storage: widget.storage),
      ),
    );

    await _loadActs();
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
                          widget.onLocaleChanged?.call(const Locale('en'));
                        },
                      ),
                      ListTile(
                        title: const Text('Українська'),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onLocaleChanged?.call(const Locale('uk'));
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
              final deleted = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AcceptanceActScreen(act: act, storage: widget.storage),
                ),
              );
              if (deleted == true) _loadActs();
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
