import 'package:application_pos_dricocoffee/models/category_models.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  void setCategories(List<Category> cats) {
    _categories = cats;
    notifyListeners();
  }

  String getCategoryNameById(int categoryId) {
    if (categoryId == 0) return "All";
    final cat = _categories.firstWhere(
      (c) => c.categoryId == categoryId,
      orElse: () => Category(categoryId: -1, name: "Lainnya"),
    );
    return cat.name;
  }
}