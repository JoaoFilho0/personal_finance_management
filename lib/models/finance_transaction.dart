enum TransactionType { income, expense }

class FinanceTransaction {
  const FinanceTransaction({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  final int? id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Map<String, Object?> toDatabaseMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
    };
  }

  factory FinanceTransaction.fromDatabaseMap(Map<String, Object?> map) {
    return FinanceTransaction(
      id: map['id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      type: TransactionType.values.byName(map['type'] as String),
    );
  }

  FinanceTransaction copyWith({int? id}) {
    return FinanceTransaction(
      id: id ?? this.id,
      title: title,
      category: category,
      amount: amount,
      date: date,
      type: type,
    );
  }
}
