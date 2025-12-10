class Customer {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final int totalOrder;
  final double totalPrice;

  Customer({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.totalOrder = 0,
    this.totalPrice = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['customer_id'],
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      totalOrder: json['total_order'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'total_order': totalOrder,
      'total_price': totalPrice,
    };
  }
}