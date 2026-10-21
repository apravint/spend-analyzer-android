import '../models/transaction.dart';

class SmsParseResult {
  final bool isTransaction;
  final bool isSpamOrOtp;
  final String? bankName;
  final String? accountMasked;
  final double? amount;
  final TransactionType? type;
  final String? merchant;
  final SpendCategory? category;
  final String rawBody;
  final String reason;

  const SmsParseResult({
    required this.isTransaction,
    this.isSpamOrOtp = false,
    this.bankName,
    this.accountMasked,
    this.amount,
    this.type,
    this.merchant,
    this.category,
    required this.rawBody,
    required this.reason,
  });

  BankTransaction? toTransaction(String sender) {
    if (!isTransaction || amount == null || type == null) return null;
    return BankTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}-${amount.hashCode}',
      sender: sender,
      bankName: bankName ?? 'BANK',
      accountMasked: accountMasked ?? 'XX0000',
      amount: amount!,
      type: type!,
      merchant: merchant ?? 'Merchant / Payee',
      category: category ?? SpendCategory.other,
      timestamp: DateTime.now(),
      rawBody: rawBody,
    );
  }
}

class SmsParserService {
  // Preset Templates for Interactive SMS Tester
  static const List<Map<String, String>> presets = [
    {
      'name': 'HDFC - Zomato Food Debit',
      'sender': 'VK-HDFCBK',
      'body': 'Your a/c no. XX1234 is debited for Rs. 540.00 on 10-Oct-26 by Zomato UPI ref 4289102482. Avl Bal: Rs. 24,150.00',
    },
    {
      'name': 'SBI - Monthly Salary Credit',
      'sender': 'AD-SBIUPI',
      'body': 'Your a/c XX5678 has been credited with INR 75,000.00 on 01-Oct-26 by Salary/Employer. Avl Bal: INR 1,12,400.00',
    },
    {
      'name': 'ICICI - Amazon Shopping Debit',
      'sender': 'AX-ICICIB',
      'body': 'Acct XX9012 debited with INR 2,499.00 on 08-Oct-26 towards Amazon India. UPI Ref: 981240182. Call 18001080 if not done by you.',
    },
    {
      'name': 'Axis - Uber Cab Debit',
      'sender': 'BZ-AXISBK',
      'body': 'ALERT: Rs 340.50 debited from Axis Bank a/c XX3456 on 09-Oct-26 at Uber India. Avl Bal: Rs 15,200.00',
    },
    {
      'name': 'Paytm - Blinkit Grocery Debit',
      'sender': 'BP-PAYTMB',
      'body': 'Paid Rs. 420.00 to Blinkit using Paytm Bank Account XX7890. UPI Ref: 3192048201. Bal: Rs 8,300.00',
    },
    {
      'name': 'Kotak - UPI Transfer Credit',
      'sender': 'VM-KOTAKB',
      'body': 'Dear Customer, INR 3,500.00 credited to Kotak Bank A/c XX4321 on 05-Oct-26 via UPI transfer from Ramesh Kumar.',
    },
    {
      'name': 'Spam / OTP Filter Test',
      'sender': 'VM-MYNTRA',
      'body': '482910 is your secret OTP for Myntra order verification. Do not share this OTP with anyone including delivery partners.',
    },
  ];

  static List<BankTransaction> getSeedTransactions() {
    final now = DateTime.now();
    return [
      BankTransaction(
        id: 'seed-1',
        sender: 'AD-SBIUPI',
        bankName: 'SBI',
        accountMasked: 'SBI XX5678',
        amount: 75000.00,
        type: TransactionType.credit,
        merchant: 'Monthly Salary',
        category: SpendCategory.salary,
        timestamp: now.subtract(const Duration(days: 9)),
        rawBody: 'Your a/c XX5678 has been credited with INR 75,000.00 on 01-Oct-26 by Salary/Employer.',
      ),
      BankTransaction(
        id: 'seed-2',
        sender: 'VK-HDFCBK',
        bankName: 'HDFC',
        accountMasked: 'HDFC XX1234',
        amount: 540.00,
        type: TransactionType.debit,
        merchant: 'Zomato',
        category: SpendCategory.food,
        timestamp: now.subtract(const Duration(days: 2)),
        rawBody: 'Your a/c no. XX1234 is debited for Rs. 540.00 on 08-Oct-26 by Zomato UPI ref 4289102482.',
      ),
      BankTransaction(
        id: 'seed-3',
        sender: 'AX-ICICIB',
        bankName: 'ICICI',
        accountMasked: 'ICICI XX9012',
        amount: 2499.00,
        type: TransactionType.debit,
        merchant: 'Amazon India',
        category: SpendCategory.shopping,
        timestamp: now.subtract(const Duration(days: 3)),
        rawBody: 'Acct XX9012 debited with INR 2,499.00 on 07-Oct-26 towards Amazon India.',
      ),
      BankTransaction(
        id: 'seed-4',
        sender: 'BZ-AXISBK',
        bankName: 'AXIS',
        accountMasked: 'AXIS XX3456',
        amount: 380.00,
        type: TransactionType.debit,
        merchant: 'Uber India',
        category: SpendCategory.travel,
        timestamp: now.subtract(const Duration(days: 4)),
        rawBody: 'ALERT: Rs 380.00 debited from Axis Bank a/c XX3456 on 06-Oct-26 at Uber India.',
      ),
      BankTransaction(
        id: 'seed-5',
        sender: 'BP-PAYTMB',
        bankName: 'PAYTM',
        accountMasked: 'PAYTM XX7890',
        amount: 620.00,
        type: TransactionType.debit,
        merchant: 'Blinkit',
        category: SpendCategory.groceries,
        timestamp: now.subtract(const Duration(days: 5)),
        rawBody: 'Paid Rs. 620.00 to Blinkit using Paytm Bank Account XX7890.',
      ),
      BankTransaction(
        id: 'seed-6',
        sender: 'VM-KOTAKB',
        bankName: 'KOTAK',
        accountMasked: 'KOTAK XX4321',
        amount: 3500.00,
        type: TransactionType.credit,
        merchant: 'UPI Transfer',
        category: SpendCategory.salary,
        timestamp: now.subtract(const Duration(days: 6)),
        rawBody: 'Dear Customer, INR 3,500.00 credited to Kotak Bank A/c XX4321 on 05-Oct-26 via UPI transfer from Ramesh Kumar.',
      ),
      BankTransaction(
        id: 'seed-7',
        sender: 'VK-HDFCBK',
        bankName: 'HDFC',
        accountMasked: 'HDFC XX1234',
        amount: 1450.00,
        type: TransactionType.debit,
        merchant: 'Airtel Broadband',
        category: SpendCategory.bills,
        timestamp: now.subtract(const Duration(days: 7)),
        rawBody: 'Your a/c XX1234 debited for Rs 1450.00 towards Airtel Broadband bill payment.',
      ),
    ];
  }

  static SmsParseResult parseSms({required String body, String sender = ''}) {
    final lower = body.toLowerCase();

    // 1. Check for OTP or Spam
    if (_isSpamOrOtp(lower)) {
      return SmsParseResult(
        isTransaction: false,
        isSpamOrOtp: true,
        rawBody: body,
        reason: 'Identified as OTP verification code or promotional spam.',
      );
    }

    // 2. Identify Transaction Type: Debit vs Credit
    TransactionType? type;
    if (lower.contains('debited') || lower.contains('paid') || lower.contains('sent') || lower.contains('withdrawn')) {
      type = TransactionType.debit;
    } else if (lower.contains('credited') || lower.contains('received') || lower.contains('refund') || lower.contains('deposited')) {
      type = TransactionType.credit;
    } else {
      return SmsParseResult(
        isTransaction: false,
        rawBody: body,
        reason: 'No clear debit or credit keywords found.',
      );
    }

    // 3. Extract Amount (Rs, INR, ₹)
    final amountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);
    final amtMatch = amountRegex.firstMatch(body);
    if (amtMatch == null) {
      return SmsParseResult(
        isTransaction: false,
        rawBody: body,
        reason: 'Could not extract numeric currency amount.',
      );
    }

    final rawAmountStr = amtMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(rawAmountStr);
    if (amount == null || amount <= 0) {
      return SmsParseResult(
        isTransaction: false,
        rawBody: body,
        reason: 'Invalid amount parsed: $rawAmountStr',
      );
    }

    // 4. Identify Bank Name
    String bankName = _detectBank(sender, body);

    // 5. Extract Masked Account (e.g. XX1234)
    final accRegex = RegExp(r'(?:a/c|acct|account|card)\s*(?:no\.?)?\s*([A-Za-z0-9*X]{4,10})', caseSensitive: false);
    final accMatch = accRegex.firstMatch(body);
    String maskedAccount = '$bankName ';
    if (accMatch != null) {
      final token = accMatch.group(1)!.toUpperCase();
      maskedAccount += token.startsWith('XX') ? token : 'XX${token.substring(token.length > 4 ? token.length - 4 : 0)}';
    } else {
      maskedAccount += 'XX0000';
    }

    // 6. Identify Merchant and Category
    final merchantCat = _detectMerchantAndCategory(body);

    return SmsParseResult(
      isTransaction: true,
      bankName: bankName,
      accountMasked: maskedAccount,
      amount: amount,
      type: type,
      merchant: merchantCat.key,
      category: merchantCat.value,
      rawBody: body,
      reason: 'Valid financial transaction parsed successfully.',
    );
  }

  static bool _isSpamOrOtp(String lower) {
    if (lower.contains('otp') ||
        lower.contains('one time password') ||
        lower.contains('verification code') ||
        lower.contains('do not share') ||
        lower.contains('secret code') ||
        lower.contains('congratulations') ||
        lower.contains('pre-approved') ||
        lower.contains('apply now')) {
      return true;
    }
    return false;
  }

  static String _detectBank(String sender, String body) {
    final combined = '$sender $body'.toUpperCase();
    if (combined.contains('HDFC')) return 'HDFC';
    if (combined.contains('SBI') || combined.contains('STATE BANK')) return 'SBI';
    if (combined.contains('ICICI')) return 'ICICI';
    if (combined.contains('AXIS')) return 'AXIS';
    if (combined.contains('PAYTM')) return 'PAYTM';
    if (combined.contains('KOTAK')) return 'KOTAK';
    if (combined.contains('PNB') || combined.contains('PUNJAB NATIONAL')) return 'PNB';
    if (combined.contains('BOB') || combined.contains('BANK OF BARODA')) return 'BOB';
    if (combined.contains('INDUSIND')) return 'INDUSIND';
    if (combined.contains('YES BANK') || combined.contains('YESB')) return 'YESBANK';
    return 'BANK';
  }

  static MapEntry<String, SpendCategory> _detectMerchantAndCategory(String text) {
    final lower = text.toLowerCase();

    // Food & Dining
    if (lower.contains('zomato')) return const MapEntry('Zomato', SpendCategory.food);
    if (lower.contains('swiggy')) return const MapEntry('Swiggy', SpendCategory.food);
    if (lower.contains('mcdonald') || lower.contains('starbucks') || lower.contains('restaurant') || lower.contains('cafe')) {
      return const MapEntry('Dining & Cafe', SpendCategory.food);
    }

    // Groceries
    if (lower.contains('blinkit')) return const MapEntry('Blinkit', SpendCategory.groceries);
    if (lower.contains('zepto')) return const MapEntry('Zepto', SpendCategory.groceries);
    if (lower.contains('bigbasket') || lower.contains('bb daily')) return const MapEntry('BigBasket', SpendCategory.groceries);
    if (lower.contains('instamart')) return const MapEntry('Swiggy Instamart', SpendCategory.groceries);
    if (lower.contains('supermarket') || lower.contains('grocery')) return const MapEntry('Supermarket', SpendCategory.groceries);

    // Shopping
    if (lower.contains('amazon')) return const MapEntry('Amazon India', SpendCategory.shopping);
    if (lower.contains('flipkart')) return const MapEntry('Flipkart', SpendCategory.shopping);
    if (lower.contains('myntra')) return const MapEntry('Myntra', SpendCategory.shopping);
    if (lower.contains('ajio')) return const MapEntry('Ajio', SpendCategory.shopping);

    // Travel
    if (lower.contains('uber')) return const MapEntry('Uber India', SpendCategory.travel);
    if (lower.contains('ola')) return const MapEntry('Ola Cabs', SpendCategory.travel);
    if (lower.contains('irctc') || lower.contains('railway')) return const MapEntry('IRCTC Train', SpendCategory.travel);
    if (lower.contains('indigo') || lower.contains('air india') || lower.contains('flight')) return const MapEntry('Airline Booking', SpendCategory.travel);
    if (lower.contains('fuel') || lower.contains('petrol') || lower.contains('hpcl') || lower.contains('bpcl') || lower.contains('ioc')) {
      return const MapEntry('Fuel Station', SpendCategory.travel);
    }

    // Bills
    if (lower.contains('airtel')) return const MapEntry('Airtel', SpendCategory.bills);
    if (lower.contains('jio')) return const MapEntry('Jio Telecom', SpendCategory.bills);
    if (lower.contains('electricity') || lower.contains('bescom') || lower.contains('tneb') || lower.contains('tata power')) {
      return const MapEntry('Electricity Bill', SpendCategory.bills);
    }

    // Investment
    if (lower.contains('zerodha')) return const MapEntry('Zerodha Broking', SpendCategory.investment);
    if (lower.contains('groww')) return const MapEntry('Groww Investment', SpendCategory.investment);
    if (lower.contains('mutual fund') || lower.contains('sip')) return const MapEntry('Mutual Funds SIP', SpendCategory.investment);

    // Salary
    if (lower.contains('salary') || lower.contains('payroll') || lower.contains('employer') || lower.contains('dividend')) {
      return const MapEntry('Salary / Payroll', SpendCategory.salary);
    }

    // Fallback: extract token after "to", "at", "by", "towards"
    final merchantRegex = RegExp(r'(?:to|at|by|towards|vpa)\s+([A-Za-z0-9\s&]{3,20})', caseSensitive: false);
    final m = merchantRegex.firstMatch(text);
    if (m != null) {
      final name = m.group(1)!.trim();
      if (!name.toLowerCase().contains('upi') && !name.toLowerCase().contains('ref')) {
        return MapEntry(name, SpendCategory.other);
      }
    }

    return const MapEntry('UPI Transfer', SpendCategory.other);
  }
}
