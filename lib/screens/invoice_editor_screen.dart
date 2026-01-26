import 'package:flutter/material.dart';
import '../models/invoice.dart';

class InvoiceEditorScreen extends StatefulWidget {
  final Invoice? invoice;

  const InvoiceEditorScreen({super.key, this.invoice});

  @override
  State<InvoiceEditorScreen> createState() => _InvoiceEditorScreenState();
}

class _InvoiceEditorScreenState extends State<InvoiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _quantityCtrl;

  @override
  void initState() {
    super.initState();
    _categoryCtrl = TextEditingController(text: widget.invoice?.category ?? '');
    _unitCtrl = TextEditingController(text: widget.invoice?.unit ?? '');
    _priceCtrl = TextEditingController(text: widget.invoice?.price.toString() ?? '');
    _quantityCtrl = TextEditingController(text: widget.invoice?.quantity.toString() ?? '');
  }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _saveInvoice() {
    if (!_formKey.currentState!.validate()) return;

    final invoice = Invoice(
      category: _categoryCtrl.text.trim(),
      unit: _unitCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      quantity: int.parse(_quantityCtrl.text),
    );

    Navigator.pop(context, invoice);
  }

  String? _validateRequired(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return double.tryParse(value) == null ? 'Invalid' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.invoice == null ? 'Add Invoice' : 'Edit Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: _validateRequired,
              ),
              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator: _validateRequired,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              TextFormField(
                controller: _quantityCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveInvoice,
                child: const Text('Save Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
