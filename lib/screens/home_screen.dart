import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../services/spend_storage.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'insights_screen.dart';
import 'sms_tester_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _shareSummary() {
    HapticFeedback.lightImpact();
    final storage = SpendStorage();
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    final summary = '''
💳 SpendAnalyzer AI Financial Summary
Net Cashflow: ${currencyFmt.format(storage.netCashflow)}
Total Inflow (Income): ${currencyFmt.format(storage.totalIncome)}
Total Outflow (Spends): ${currencyFmt.format(storage.totalExpense)}
Total Transactions: ${storage.transactions.length}

Parsed 100% locally on-device. Zero cloud dependencies.
https://github.com/apravint/spend-analyzer-android
''';

    // ignore: deprecated_member_use
    Share.share(summary, subject: 'SpendAnalyzer AI Summary');
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset to Seed Transactions?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: Text(
            'This will restore the original demo banking transactions from SBI, HDFC, ICICI, Axis, and Paytm.',
            style: GoogleFonts.outfit(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
              onPressed: () {
                SpendStorage().resetToSeeds();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transactions reset to seed data!')),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF00E5FF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
                children: const [
                  TextSpan(text: 'SpendAnalyzer '),
                  TextSpan(text: 'AI', style: TextStyle(color: Color(0xFF10B981))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'v1.2.0',
                style: GoogleFonts.firaCode(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onToggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Reset to Seeds',
            onPressed: _confirmReset,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'Share Summary',
            onPressed: _shareSummary,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onNavigateToTransactions: () => setState(() => _currentIndex = 1),
          ),
          const TransactionsScreen(),
          const InsightsScreen(),
          SmsTesterScreen(
            onTransactionAdded: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal_rounded),
            label: 'SMS Tester',
          ),
        ],
      ),
    );
  }
}
