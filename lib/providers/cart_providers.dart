import 'package:flutter/material.dart';
import 'package:application_pos_dricocoffee/models/product_models.dart';
import 'package:application_pos_dricocoffee/providers/category_providers.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int productId;
  final String name;
  final int price;
  final String image;
  final String categoryName;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryName,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      image: image,
      categoryName: categoryName,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'image': image,
        'categoryName': categoryName,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        image: json['image'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
      );
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  int _discountAmount = 0;  
  int _discountPercent = 0;  

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get total {
    if (_discountPercent > 0) {
      final disc = (subtotal * _discountPercent) ~/ 100;
      return subtotal - disc;
    }
    return subtotal - _discountAmount;
  }

  int get appliedDiscount {
    if (_discountPercent > 0) {
      return (subtotal * _discountPercent) ~/ 100;
    }
    return _discountAmount;
  }

  int get discountPercent => _discountPercent;
  int get discountAmount => _discountAmount;

  CartProvider() {
    _loadFromPrefs();
  }

  // ================== DISKON ==================
  void setDiscountAmount(int amount) {
    _discountAmount = amount < 0 ? 0 : amount;
    _discountPercent = 0;
    _saveToPrefs();
    notifyListeners();
  }

  void setDiscountPercent(int percent) {
    _discountPercent = percent.clamp(0, 100);
    _saveToPrefs();
    notifyListeners();
  }

  void clearDiscount() {
    _discountAmount = 0;
    _discountPercent = 0;
    _saveToPrefs();
    notifyListeners();
  }

  // ================== CART OPERATIONS ==================
  void add(Product product, BuildContext context) {
    final categoryName = Provider.of<CategoryProvider>(context, listen: false)
        .getCategoryNameById(product.categoryId);

    final existingIndex = _items.indexWhere((item) => item.productId == product.productId);

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(
        productId: product.productId,
        name: product.name,
        price: product.price,
        image: product.image ?? '',
        categoryName: categoryName,
      ));
    }

    _saveToPrefs();
    notifyListeners();
  }

  void remove(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
      } else {
        _items.removeAt(index);
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void delete(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discountAmount = 0;
    _discountPercent = 0;
    _saveToPrefs();
    notifyListeners();
  }

  // ================== SHARED PREFERENCES ==================
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonItems = _items.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList('cart_items', jsonItems);
    await prefs.setInt('discount_amount', _discountAmount);
    await prefs.setInt('discount_percent', _discountPercent);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList('cart_items');
    if (saved != null) {
      _items.clear();
      for (var jsonStr in saved) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _items.add(CartItem.fromJson(map));
      }
    }

    _discountAmount = prefs.getInt('discount_amount') ?? 0;
    _discountPercent = prefs.getInt('discount_percent') ?? 0;

    notifyListeners();
  }
}