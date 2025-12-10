class Category {
  final int categoryId;
  final String name;

  Category({required this.categoryId, required this.name});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['category_id'] is int
          ? map['category_id']
          : (map['category_id'] as num).toInt(),
      name: map['name']?.toString() ?? 'Unknown',
    );
  }

  static Category get all => Category(categoryId: 0, name: 'All');

  @override
  String toString() => name;
}