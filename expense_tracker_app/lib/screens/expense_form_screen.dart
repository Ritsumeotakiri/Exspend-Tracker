import 'package:expense_tracker_app/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseForm extends StatefulWidget {
  final DateTime selectedDate;
  final ExpenseModel? existingExpense;

  const ExpenseForm({
    super.key,
    required this.selectedDate,
    this.existingExpense,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.existingExpense?.date != null
            ? DateTime.parse(widget.existingExpense!.date)
            : widget.selectedDate;

    if (widget.existingExpense != null) {
      _categoryController.text = widget.existingExpense!.category;
      _amountController.text = widget.existingExpense!.amount.toString();
      _notesController.text = widget.existingExpense!.notes;
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final updated = ExpenseModel(
        id: widget.existingExpense?.id,
        category: _categoryController.text,
        amount: double.parse(_amountController.text),
        notes: _notesController.text,
        date: _selectedDate.toIso8601String().substring(0, 10),
      );

      Navigator.pop(context, updated);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExpense != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2956),
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Text(
            isEditing ? 'Edit Expense' : 'Add Expense',
            style: const TextStyle(fontSize: 26, color: Colors.white),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                const Text(
                  "Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 3,
                  width: 60,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                label: 'Category',
                controller: _categoryController,
                validator:
                    (value) => value!.isEmpty ? 'Enter a category' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Amount',
                controller: _amountController,
                inputType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(label: 'Notes', controller: _notesController),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date: ${DateFormat.yMMMd().format(_selectedDate)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton(onPressed: _pickDate, child: const Text("Change")),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0B2956),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? "Update Expense" : "Save Expense",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
