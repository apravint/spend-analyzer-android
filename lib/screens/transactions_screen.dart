import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction.dart';
import '../services/spend_storage.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _filterType;
  SpendCategory? _filterCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = SpendStorage();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: storage,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();

        final filtered = storage.transactions.where((t) {
          if (_filterType != null && t.type != _filterType) return false;
          if (_filterCategory != null && t.category != _filterCategory) return false;
          if (query.isNotEmpty) {
            final matchMerchant = t.merchant.toLowerCase().contains(query);
            final matchBank = t.bankName.toLowerCase().contains(query);
            final matchAcc = t.accountMasked.toLowerCase().contains(query);
            if (!matchMerchant && !matchBank && !matchAcc) return false;
          }
          return true;
        }).toList();

        return Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.outfit(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search merchant, bank, or account...',
                      hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F1728) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF1E2D45) : const Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF1E2D45) : const Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips: All, Debits, Credits
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        FilterChip(
                          selected: _filterType == null,
                          label: const Text('All Types'),
                          onSelected: (_) => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _filterType == TransactionType.debit,
                          avatar: const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFFF43F5E)),
                          label: const Text('Debits (Spends)'),
                          onSelected: (_) => setState(() {
                            _filterType = _filterType == TransactionType.debit ? null : TransactionType.debit;
                          }),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _filterType == TransactionType.credit,
                          avatar: const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF10B981)),
                          label: const Text('Credits (Income)'),
                          onSelected: (_) => setState(() {
                            _filterType = _filterType == TransactionType.credit ? null : TransactionType.credit;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Transactions List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions match the selected criteria.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return TransactionTile(transaction: filtered[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
