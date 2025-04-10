import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => _expenses;

  final String _baseUrl = 'https://ce40-175-100-11-25.ngrok-free.app/api';

  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔄 Fetch all expenses
  Future<void> fetchExpenses() async {
    try {
      final headers = await _headers;
      final res = await http.get(
        Uri.parse('$_baseUrl/expenses'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _expenses = data.map((e) => ExpenseModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        debugPrint('❌ Failed to fetch expenses: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Fetch error: $e');
    }
  }

  // ➕ Add a new expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final headers = await _headers;
      final res = await http.post(
        Uri.parse('$_baseUrl/expenses'),
        headers: headers,
        body: jsonEncode(expense.toJson()),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final inserted = ExpenseModel.fromJson({
          ...expense.toJson(),
          'id': jsonDecode(res.body)['expenseId'],
        });
        _expenses.add(inserted);
        notifyListeners();
      } else {
        debugPrint('❌ Add failed: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Add error: $e');
    }
  }

  // ✏️ Update an existing expense
  Future<void> updateExpense(ExpenseModel updatedExpense) async {
    try {
      final headers = await _headers;
      final res = await http.put(
        Uri.parse('$_baseUrl/expenses/${updatedExpense.id}'),
        headers: headers,
        body: jsonEncode(updatedExpense.toJson()),
      );

      if (res.statusCode == 200) {
        final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
        if (index != -1) {
          final updatedData = jsonDecode(res.body);
          _expenses[index] = ExpenseModel.fromJson(updatedData);
          notifyListeners(); // 👈 trigger UI update
        }
      } else {
        debugPrint('❌ Update failed [${res.statusCode}]: ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ Update error: $e');
    }
  }

  // ❌ Delete an expense
  Future<void> deleteExpense(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) {
      debugPrint('⚠️ Expense not found locally for delete: $id');
      return;
    }

    final removed = _expenses.removeAt(index);
    notifyListeners(); // Optimistic UI update

    try {
      final headers = await _headers;
      final res = await http.delete(
        Uri.parse('$_baseUrl/expenses/$id'),
        headers: headers,
      );

      if (res.statusCode != 200 && res.statusCode != 204) {
        debugPrint('❌ Backend delete failed [${res.statusCode}]: ${res.body}');
        _expenses.insert(index, removed); // rollback
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      _expenses.insert(index, removed); // rollback
      notifyListeners();
    }
  }

  // 🔧 Utility Methods
  void insertExpenseAt(ExpenseModel expense, int index) {
    _expenses.insert(index, expense);
    notifyListeners();
  }

  void removeExpenseLocally(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
