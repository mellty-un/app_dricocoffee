class Product {
  final int productId;
  final String name;
  final int price;
  final int categoryId;
  final int stock;
  final String image;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.stock,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      name: json['name'] as String,
      price: json['price'] as int,
      categoryId: json['category_id'] as int,
      stock: json['stock'] as int,
      image: json['image'] as String? ?? '',
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) => Product.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'category_id': categoryId,
      'stock': stock,
      'image': image,
    };
  }
}