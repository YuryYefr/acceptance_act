import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../l10n/app_localizations.dart';

class InvoiceTable extends StatelessWidget {
  final List<Invoice> invoices;
  final void Function(int index) onEdit;
  final void Function(int index) onDelete;

  const InvoiceTable({
    super.key,
    required this.invoices,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (invoices.isEmpty) {
      return Center(child: Text(localizations.invoices));
    }

    return ListView.separated(
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return ListTile(
          title: Text('${inv.category} - ${inv.unit}'),
          subtitle: Text(
              'Price: ${inv.price}, Qty: ${inv.quantity}, Total: ${inv.total.toStringAsFixed(2)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
