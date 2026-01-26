import 'package:flutter/material.dart';
import '../models/acceptance_act.dart';
import '../models/invoice.dart';
import '../services/storage_service.dart';
import '../widgets/invoice_table.dart';
import 'invoice_editor_screen.dart';

class AcceptanceActScreen extends StatefulWidget {
  final AcceptanceAct act;
  final StorageService storage;

  const AcceptanceActScreen({
    super.key,
    required this.act,
    required this.storage,
  });

  @override
  State<AcceptanceActScreen> createState() => _AcceptanceActScreenState();
}

class _AcceptanceActScreenState extends State<AcceptanceActScreen> {
  late AcceptanceAct _act;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _act = widget.act;
  }

  Future<void> _persist() async {
    if (_busy) return;
    _busy = true;

    try {
      _act.recalc();
      await widget.storage.saveAct(_act);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved')));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      _busy = false;
    }
  }

  Future<void> _addInvoice() async {
    final invoice = await Navigator.push<Invoice>(
      context,
      MaterialPageRoute(builder: (_) => const InvoiceEditorScreen()),
    );
    if (invoice == null) return;
    _act.invoices.add(invoice);
    await _persist();
  }

  Future<void> _editInvoice(int index) async {
    final updated = await Navigator.push<Invoice>(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceEditorScreen(invoice: _act.invoices[index]),
      ),
    );
    if (updated == null) return;
    _act.invoices[index] = updated;
    await _persist();
  }

  Future<void> _deleteAct() async {
    await widget.storage.deleteAct(_act);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _exportAct() async {
    try {
      final path = await widget.storage.exportAct(_act);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Exported to $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_act.name),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _persist),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportAct),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteAct),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('Category', _act.category),
                    _summaryItem('Quantity', _act.quantity.toString()),
                    _summaryItem('Sum', _act.sum.toStringAsFixed(2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Invoices', style: TextStyle(fontSize: 18)),
                ElevatedButton.icon(
                  onPressed: _addInvoice,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Invoice'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: InvoiceTable(
                invoices: _act.invoices,
                onEdit: _editInvoice,
                onDelete: (i) async {
                  _act.invoices.removeAt(i);
                  await _persist();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}
