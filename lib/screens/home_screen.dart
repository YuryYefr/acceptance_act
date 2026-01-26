import 'package:flutter/material.dart';
import '../models/acceptance_act.dart';
import '../screens/acceptance_act_screen.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  const HomeScreen({super.key, required this.storage});

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
    final now = DateTime.now();
    final defaultName =
        'act_${now.year.toString().padLeft(4, '0')}-'
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
            title: const Text('New Acceptance Act'),
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
                    const Text('Auto Name'),
                  ],
                ),
                TextFormField(
                  controller: controller,
                  enabled: !autoName,
                  autofocus: !autoName,
                  decoration: const InputDecoration(labelText: 'Act Name'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    actName = controller.text.isEmpty ? defaultName : controller.text;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Create')),
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
          builder: (_) => AcceptanceActScreen(act: act, storage: widget.storage)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Acceptance Acts')),
      body: ListView.builder(
        itemCount: acts.length,
        itemBuilder: (context, i) {
          final act = acts[i];
          return ListTile(
            title: Text(act.name),
            onTap: () async {
              final deletedOrUpdated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AcceptanceActScreen(act: act, storage: widget.storage)),
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
