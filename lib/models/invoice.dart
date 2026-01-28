class Invoice {
  final String category;
  final String unit;
  final double price;
  final int quantity;

  Invoice({
    required this.category,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    category: json['category'],
    unit: json['unit'],
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'category': category,
    'unit': unit,
    'price': price,
    'quantity': quantity,
  };
}
