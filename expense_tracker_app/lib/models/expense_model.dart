class ExpenseModel {
  final String? id;
  final String category;
  final double amount;
  final String notes;
  final String date;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.notes,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['ID']?.toString(), 
      category: json['CATEGORY'],
      amount: (json['AMOUNT'] as num).toDouble(),
      notes: json['NOTES'] ?? '',
      date: json['DATE'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'notes': notes,
      'date': date,
    };
  }
}
