import 'package:expense_tracker_app/models/expense_model.dart';
import 'package:flutter/material.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap; // Add this line

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap, // Add this too
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.category),
      subtitle: Text('\$${expense.amount.toStringAsFixed(2)}'),
      trailing: Text(expense.date),
      onTap: onTap, 
    );
  }
}
