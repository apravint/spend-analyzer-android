import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/spend_storage.dart';
import '../widgets/cashflow_hero.dart';
import '../widgets/glass_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToTransactions;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final storage = SpendStorage();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return ListenableBuilder(
      listenable: storage,
      builder: (context, _) {
        final transactions = storage.transactions;
        final recentTransactions = transactions.take(4).toList();
        final categoryExpenses = storage.categoryExpenses;
        final categoryPercentages = storage.categoryPercentages;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Balance Card
              CashflowHero(
                netCashflow: storage.netCashflow,
                totalIncome: storage.totalIncome,
                totalExpense: storage.totalExpense,
                transactionCount: transactions.length,
              ),
              const SizedBox(height: 24),

              // Category Spend Breakdown Section
              Text(
                'Top Expense Categories',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (categoryExpenses.isEmpty)
                GlassCard(
                  child: Center(
                    child: Text(
                      'No expense transactions recorded yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: categoryExpenses.entries.map((entry) {
                      final cat = entry.key;
                      final amount = entry.value;
                      final pct = categoryPercentages[cat] ?? 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(cat.icon, size: 16, color: cat.color),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cat.displayName,
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  currencyFmt.format(amount),
                                  style: GoogleFonts.firaCode(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${pct.toStringAsFixed(1)}%)',
                                  style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (pct / 100.0).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: isDark ? const Color(0xFF1E2D45) : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToTransactions,
                    child: Text(
                      'View All',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Transaction List
              if (recentTransactions.isEmpty)
                GlassCard(
                  child: Center(
                    child: Text('No transactions available.', style: theme.textTheme.bodyMedium),
                  ),
                )
              else
                ...recentTransactions.map((tx) => TransactionTile(transaction: tx)),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
