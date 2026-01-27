import 'invoice.dart';

class AcceptanceAct {
  String id;
  String name;
  String category;
  int quantity;
  double sum;
  List<Invoice> invoices;

  AcceptanceAct({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.sum,
    required this.invoices,
  });

  void recalc() {
    quantity = invoices.fold(0, (prev, inv) => prev + inv.quantity);
    sum = invoices.fold(0.0, (prev, inv) => prev + inv.total);

    final categories = invoices.map((e) => e.category).toSet();
    category = categories.isEmpty
        ? ''
        : categories.length == 1
            ? categories.first
            : 'Mixed';
  }
}
