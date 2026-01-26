class Invoice {
  String category;
  String unit;
  double price;
  int quantity;

  Invoice({
    required this.category,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
}
