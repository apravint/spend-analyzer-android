import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'sms_parser.dart';

class SpendStorage extends ChangeNotifier {
  static final SpendStorage _instance = SpendStorage._internal();
  factory SpendStorage() => _instance;

  final List<BankTransaction> _transactions = [];

  SpendStorage._internal() {
    _transactions.addAll(SmsParserService.getSeedTransactions());
  }

  List<BankTransaction> get transactions => List.unmodifiable(_transactions);

  double get totalIncome {
    return _transactions
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.isDebit)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netCashflow => totalIncome - totalExpense;

  Map<SpendCategory, double> get categoryExpenses {
    final map = <SpendCategory, double>{};
    for (final t in _transactions.where((t) => t.isDebit)) {
      map[t.category] = (map[t.category] ?? 0.0) + t.amount;
    }
    return map;
  }

  Map<SpendCategory, double> get categoryPercentages {
    final totals = categoryExpenses;
    final total = totalExpense;
    if (total == 0) return {};
    return totals.map((cat, amount) => MapEntry(cat, (amount / total) * 100));
  }

  void addTransaction(BankTransaction tx) {
    _transactions.insert(0, tx);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void resetToSeeds() {
    _transactions.clear();
    _transactions.addAll(SmsParserService.getSeedTransactions());
    notifyListeners();
  }
}
