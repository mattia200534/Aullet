import 'package:applicazione/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:applicazione/models/category.dart';

class CategoryViewModel extends ChangeNotifier {
  final _repo = CategoryRepository();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
