import 'package:flutter/material.dart';
import '../models/acceptance_act.dart';
import '../models/invoice.dart';
import '../services/storage_service.dart';
import '../widgets/invoice_table.dart';
import 'invoice_editor_screen.dart';
import '../l10n/app_localizations.dart';

class AcceptanceActScreen extends StatefulWidget {
  final AcceptanceAct act;
  final StorageService storage;
  final Locale? locale;

  const AcceptanceActScreen({
    super.key,
    required this.act,
    required this.storage,
    this.locale,
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
      MaterialPageRoute(
          builder: (_) => InvoiceEditorScreen(locale: widget.locale)),
    );
    if (invoice == null) return;
    _act.invoices.add(invoice);
    await _persist();
  }

  Future<void> _editInvoice(int index) async {
    final updated = await Navigator.push<Invoice>(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceEditorScreen(
            invoice: _act.invoices[index], locale: widget.locale),
      ),
    );
    if (updated == null) return;
    _act.invoices[index] = updated;
    await _persist();
  }

  Future<void> _deleteAct() async {
    final localizations = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmDeletion),
        content: Text(localizations.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

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
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_act.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _persist,
            tooltip: localizations.save,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAct,
            tooltip: localizations.download,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAct,
            tooltip: localizations.delete,
          ),
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
                    _summaryItem(localizations.category, _act.category),
                    _summaryItem(
                        localizations.quantity, _act.quantity.toString()),
                    _summaryItem(
                        localizations.sum, _act.sum.toStringAsFixed(2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.invoices,
                    style: const TextStyle(fontSize: 18)),
                ElevatedButton.icon(
                  key: const Key('add_invoice_button'),
                  onPressed: _addInvoice,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addInvoice),
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
