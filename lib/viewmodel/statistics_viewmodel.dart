import 'package:applicazione/models/category.dart';
import 'package:applicazione/models/expense.dart';
import 'package:applicazione/repositories/category_repository.dart';
import 'package:applicazione/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsViewModel extends ChangeNotifier {
  final _repo = ExpenseRepository();
  final _catRepo = CategoryRepository();
  List<Expense> _allExpenses = [];
  List<Category> _allCategories = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _monthFilter;
  List<Expense> get allExpenses => _allExpenses;
  List<Category> get allCategories => _allCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get monthFilter => _monthFilter;

  Future<void> LoadAllExpenses() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Utente non autenticato");
      _allExpenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void setMonthFilter(int? month) {
    _monthFilter = month;
    notifyListeners();
  }

  Map<int, double> calculateMonthlyExpenses(int year) {
    final Map<int, double> totals = {for (var m = 1; m <= 12; m++) m: 0.0};
    for (var expense in _allExpenses) {
      if (expense.date.year == year) {
        totals[expense.date.month] =
            totals[expense.date.month]! + expense.amount;
      }
    }
    return totals;
  }

  Map<Category, double> calculateCategoryExpenses(int year) {
    final Map<String, double> temp = {};
    for (final exp in _allExpenses) {
      if (exp.date.year == year &&
          (_monthFilter == null || exp.date.month == _monthFilter)) {
        temp.update(
          exp.categoryId,
          (v) => v + exp.amount,
          ifAbsent: () => exp.amount,
        );
      }
    }

    final result = <Category, double>{};
    for (final cat in _allCategories) {
      final val = temp[cat.id] ?? 0.0;
      if (val > 0) result[cat] = val;
    }
    return result;
  }

  Future<double> calculateTotalForPeriod(int year, int? month) async {
    double total = 0.0;
    for (final exp in _allExpenses) {
      if (exp.date.year == year && (month == null || exp.date.month == month)) {
        total += exp.amount;
      }
    }
    return total;
  }

  Future<Map<String, dynamic>> comparePeriods(
    int year1,
    int? month1,
    int year2,
    int? month2,
  ) async {
    final total1 = await calculateTotalForPeriod(year1, month1);
    final total2 = await calculateTotalForPeriod(year2, month2);
    final difference = total2 - total1;
    final percent = total2 != 0 ? (difference / total2) * 100 : 0.0;
    return {
      'period1': total1,
      'period2': total2,
      'difference': difference,
      'percent': percent,
    };
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
