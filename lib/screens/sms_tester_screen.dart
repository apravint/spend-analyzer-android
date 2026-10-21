import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../services/sms_parser.dart';
import '../services/spend_storage.dart';
import '../widgets/glass_card.dart';

class SmsTesterScreen extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  const SmsTesterScreen({
    super.key,
    required this.onTransactionAdded,
  });

  @override
  State<SmsTesterScreen> createState() => _SmsTesterScreenState();
}

class _SmsTesterScreenState extends State<SmsTesterScreen> {
  late final TextEditingController _senderController;
  late final TextEditingController _bodyController;
  SmsParseResult? _parseResult;

  @override
  void initState() {
    super.initState();
    final first = SmsParserService.presets.first;
    _senderController = TextEditingController(text: first['sender']);
    _bodyController = TextEditingController(text: first['body']);
  }

  @override
  void dispose() {
    _senderController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _loadPreset(Map<String, String> preset) {
    HapticFeedback.lightImpact();
    setState(() {
      _senderController.text = preset['sender']!;
      _bodyController.text = preset['body']!;
      _parseResult = null;
    });
  }

  void _parse() {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;
    HapticFeedback.mediumImpact();
    final res = SmsParserService.parseSms(
      body: body,
      sender: _senderController.text.trim(),
    );
    setState(() => _parseResult = res);
  }

  void _addToLedger() {
    if (_parseResult == null || !_parseResult!.isTransaction) return;
    HapticFeedback.lightImpact();
    final tx = _parseResult!.toTransaction(_senderController.text.trim());
    if (tx != null) {
      SpendStorage().addTransaction(tx);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added to ledger successfully!')),
      );
      widget.onTransactionAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Intro
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.code_rounded, color: Color(0xFF00E5FF), size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive SMS Tester',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Validate local regex patterns on Indian bank SMS',
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Preset Selection Chips
          Text(
            'Load Preset Bank SMS Template:',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: SmsParserService.presets.map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(preset['name']!),
                    labelStyle: GoogleFonts.outfit(fontSize: 12),
                    onPressed: () => _loadPreset(preset),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Input GlassCard
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sender Header / Tag (Optional):',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _senderController,
                  style: GoogleFonts.firaCode(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. VK-HDFCBK or AD-SBIUPI',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF080C15) : const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF1E2D45) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'SMS Message Body:',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _bodyController,
                  maxLines: 4,
                  style: GoogleFonts.firaCode(fontSize: 13, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Paste incoming bank SMS here...',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF080C15) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF1E2D45) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bolt_rounded, color: Colors.black),
                    label: Text(
                      'Parse with Local Regex',
                      style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _parse,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Parse Results Section
          if (_parseResult != null) ...[
            Text(
              'PARSER EVALUATION REPORT',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00E5FF),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _parseResult!.isTransaction
                                ? Icons.check_circle_rounded
                                : (_parseResult!.isSpamOrOtp ? Icons.block_rounded : Icons.warning_rounded),
                            color: _parseResult!.isTransaction
                                ? const Color(0xFF10B981)
                                : (_parseResult!.isSpamOrOtp ? const Color(0xFFF43F5E) : const Color(0xFFEAB308)),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _parseResult!.isTransaction
                                ? 'Valid Transaction Detected'
                                : (_parseResult!.isSpamOrOtp ? 'OTP / Spam Filtered' : 'Non-Financial SMS'),
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      if (_parseResult!.isTransaction)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _parseResult!.type == TransactionType.credit
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : const Color(0xFFF43F5E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _parseResult!.type!.displayName,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _parseResult!.type == TransactionType.credit
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF43F5E),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  if (_parseResult!.isTransaction) ...[
                    _ParseRow(label: 'Bank Identifier', value: _parseResult!.bankName ?? 'Unknown'),
                    _ParseRow(label: 'Masked Account', value: _parseResult!.accountMasked ?? 'N/A'),
                    _ParseRow(label: 'Extracted Amount', value: currencyFmt.format(_parseResult!.amount ?? 0)),
                    _ParseRow(label: 'Identified Merchant', value: _parseResult!.merchant ?? 'N/A'),
                    _ParseRow(label: 'Assigned Category', value: _parseResult!.category?.displayName ?? 'N/A'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_task_rounded, size: 18),
                        label: Text('Add to My Ledger', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _addToLedger,
                      ),
                    ),
                  ] else ...[
                    Text(
                      _parseResult!.reason,
                      style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }
}

class _ParseRow extends StatelessWidget {
  final String label;
  final String value;

  const _ParseRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF94A3B8))),
          Text(value, style: GoogleFonts.firaCode(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
