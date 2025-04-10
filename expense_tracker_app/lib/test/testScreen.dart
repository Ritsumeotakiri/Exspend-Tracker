import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_app/provider/exspense_provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    await context.read<ExpenseProvider>().fetchExpenses();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 All Expenses (Raw View)'),
        backgroundColor: const Color(0xFF0B2956),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : expenses.isEmpty
              ? const Center(child: Text("No expenses found."))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: expenses.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final e = expenses[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text('''
ID: ${e.id}
Category: ${e.category}
Amount: \$${e.amount}
Notes: ${e.notes}
Date: ${e.date}
''', style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
                  );
                },
              ),
    );
  }
}
