import 'invoice.dart';

class AcceptanceAct {
  final String id;
  String name;
  String category;
  double sum;
  int quantity;
  List<Invoice> invoices;

  AcceptanceAct({
    required this.id,
    required this.name,
    required this.category,
    required this.sum,
    required this.quantity,
    required this.invoices,
  });

  void recalc() {
    quantity = invoices.fold(0, (a, b) => a + b.quantity);
    sum = invoices.fold(0.0, (a, b) => a + b.total);

    final cats = invoices.map((e) => e.category).toSet();
    if (cats.isEmpty) {
      category = '';
    } else if (cats.length == 1) {
      category = cats.first;
    } else {
      category = 'mixed';
    }
  }

  factory AcceptanceAct.fromJson(Map<String, dynamic> json) => AcceptanceAct(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        sum: (json['sum'] as num).toDouble(),
        quantity: json['quantity'],
        invoices:
            (json['invoices'] as List).map((e) => Invoice.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sum': sum,
        'quantity': quantity,
        'invoices': invoices.map((e) => e.toJson()).toList(),
      };
}
