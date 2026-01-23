import 'package:applicazione/models/expense.dart';
import 'package:applicazione/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseViewmodel extends ChangeNotifier {
  final _repo = ExpenseRepository();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Utente non autenticato");

      _expenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense({
    required String categoryId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');
      final expense = Expense(
        id: '',
        userId: user.id,
        categoryId: categoryId,
        amount: amount,
        date: date,
        description: description,
      );
      await _repo.insertExpense(expense);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
