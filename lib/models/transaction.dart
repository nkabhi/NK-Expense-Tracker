enum TxnType { income, expense }

enum TxnSource { sms, manual }

class Transaction {
  final String id;
  final double amount;
  final TxnType type;
  final String category;
  final String note;
  final TxnSource source;
  final DateTime date;
  final double? balanceAfter;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.source,
    required this.date,
    this.balanceAfter,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'category': category,
        'note': note,
        'source': source.name,
        'date': date.toIso8601String(),
        'balanceAfter': balanceAfter,
      };

  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
        id: m['id'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: TxnType.values.byName(m['type'] as String),
        category: m['category'] as String,
        note: m['note'] as String,
        source: TxnSource.values.byName(m['source'] as String),
        date: DateTime.parse(m['date'] as String),
        balanceAfter: m['balanceAfter'] == null
            ? null
            : (m['balanceAfter'] as num).toDouble(),
      );
}

class Investment {
  final String id;
  final String name;
  final String kind; // SIP, PPF, FD, etc.
  final double invested;
  final double currentValue;
  final DateTime lastUpdated;

  Investment({
    required this.id,
    required this.name,
    required this.kind,
    required this.invested,
    required this.currentValue,
    required this.lastUpdated,
  });

  double get returnPct =>
      invested == 0 ? 0 : ((currentValue - invested) / invested) * 100;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'kind': kind,
        'invested': invested,
        'currentValue': currentValue,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Investment.fromMap(Map<String, dynamic> m) => Investment(
        id: m['id'] as String,
        name: m['name'] as String,
        kind: m['kind'] as String,
        invested: (m['invested'] as num).toDouble(),
        currentValue: (m['currentValue'] as num).toDouble(),
        lastUpdated: DateTime.parse(m['lastUpdated'] as String),
      );
}
