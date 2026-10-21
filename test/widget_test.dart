import 'package:flutter_test/flutter_test.dart';
import 'package:spend_analyzer/main.dart';
import 'package:spend_analyzer/models/transaction.dart';
import 'package:spend_analyzer/services/sms_parser.dart';
import 'package:spend_analyzer/services/spend_storage.dart';

void main() {
  testWidgets('SpendAnalyzerApp renders navigation and balance hero', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendAnalyzerApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('SMS Tester'), findsOneWidget);
    expect(find.text('NET CASHFLOW BALANCE'), findsOneWidget);
  });

  test('SmsParserService correctly parses HDFC Debit SMS', () {
    const raw = 'Your a/c no. XX1234 is debited for Rs. 540.00 on 10-Oct-26 by Zomato UPI ref 4289102482.';
    final res = SmsParserService.parseSms(body: raw, sender: 'VK-HDFCBK');

    expect(res.isTransaction, isTrue);
    expect(res.type, TransactionType.debit);
    expect(res.amount, 540.00);
    expect(res.merchant, 'Zomato');
    expect(res.category, SpendCategory.food);
    expect(res.bankName, 'HDFC');
  });

  test('SmsParserService correctly filters spam and OTP messages', () {
    const otp = '482910 is your secret OTP for Myntra order verification. Do not share this OTP.';
    final res = SmsParserService.parseSms(body: otp, sender: 'VM-MYNTRA');

    expect(res.isTransaction, isFalse);
    expect(res.isSpamOrOtp, isTrue);
  });

  test('SpendStorage calculates totals correctly', () {
    final storage = SpendStorage();
    expect(storage.transactions.isNotEmpty, isTrue);
    expect(storage.totalIncome > 0, isTrue);
    expect(storage.totalExpense > 0, isTrue);
    expect(storage.netCashflow, storage.totalIncome - storage.totalExpense);
  });
}
