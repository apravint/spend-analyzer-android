import 'package:flutter/material.dart';

enum TransactionType {
  debit,
  credit;

  String get displayName => this == TransactionType.debit ? 'DEBIT' : 'CREDIT';
}

enum SpendCategory {
  food,
  shopping,
  travel,
  groceries,
  bills,
  investment,
  salary,
  other;

  String get displayName {
    switch (this) {
      case SpendCategory.food:
        return 'Food & Dining';
      case SpendCategory.shopping:
        return 'Shopping';
      case SpendCategory.travel:
        return 'Travel & Commute';
      case SpendCategory.groceries:
        return 'Groceries';
      case SpendCategory.bills:
        return 'Bills & Utilities';
      case SpendCategory.investment:
        return 'Investments';
      case SpendCategory.salary:
        return 'Salary & Income';
      case SpendCategory.other:
        return 'General / Other';
    }
  }

  IconData get icon {
    switch (this) {
      case SpendCategory.food:
        return Icons.restaurant_rounded;
      case SpendCategory.shopping:
        return Icons.shopping_bag_rounded;
      case SpendCategory.travel:
        return Icons.directions_car_rounded;
      case SpendCategory.groceries:
        return Icons.local_grocery_store_rounded;
      case SpendCategory.bills:
        return Icons.receipt_long_rounded;
      case SpendCategory.investment:
        return Icons.trending_up_rounded;
      case SpendCategory.salary:
        return Icons.account_balance_wallet_rounded;
      case SpendCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SpendCategory.food:
        return const Color(0xFFF97316); // Vibrant Orange
      case SpendCategory.shopping:
        return const Color(0xFF8B5CF6); // Purple
      case SpendCategory.travel:
        return const Color(0xFF3B82F6); // Blue
      case SpendCategory.groceries:
        return const Color(0xFF10B981); // Emerald
      case SpendCategory.bills:
        return const Color(0xFFF59E0B); // Amber
      case SpendCategory.investment:
        return const Color(0xFF06B6D4); // Cyan
      case SpendCategory.salary:
        return const Color(0xFF22C55E); // Green
      case SpendCategory.other:
        return const Color(0xFF94A3B8); // Slate
    }
  }
}

class BankTransaction {
  final String id;
  final String sender;
  final String bankName;
  final String accountMasked;
  final double amount;
  final TransactionType type;
  final String merchant;
  final SpendCategory category;
  final DateTime timestamp;
  final String rawBody;

  const BankTransaction({
    required this.id,
    required this.sender,
    required this.bankName,
    required this.accountMasked,
    required this.amount,
    required this.type,
    required this.merchant,
    required this.category,
    required this.timestamp,
    required this.rawBody,
  });

  bool get isDebit => type == TransactionType.debit;
  bool get isCredit => type == TransactionType.credit;
}
