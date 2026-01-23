class Expense {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? description;

  Expense({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.description,
  });

  /// 🔄 Da Supabase (DB → App)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'] as String?,
    );
  }

  /// 🔼 Verso Supabase (App → DB)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
