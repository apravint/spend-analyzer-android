# SpendAnalyzer AI 💳📊 (`v1.2.0 - Flutter Edition`)

[![Flutter Build & Release](https://github.com/apravint/spend-analyzer-android/actions/workflows/build-apk.yml/badge.svg)](https://github.com/apravint/spend-analyzer-android/actions/workflows/build-apk.yml)
[![Live Demo](https://img.shields.io/badge/Live%20Web%20Demo-GitHub%20Pages-10B981?style=flat&logo=flutter)](https://apravint.github.io/spend-analyzer-android/)
[![Target SDK](https://img.shields.io/badge/Target%20SDK-35%20(Android%2015)-green.svg)](https://developer.android.com/about/versions/15)
[![Flutter](https://img.shields.io/badge/Flutter-3.47+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

> 🌐 **Try it Live in Your Browser**: [Launch SpendAnalyzer AI Flutter Web Edition](https://apravint.github.io/spend-analyzer-android/)

**SpendAnalyzer AI** is an offline, privacy-first mobile & web financial dashboard built with **Flutter 3.x / Dart 3.x**. It parses incoming Indian bank SMS notifications and UPI payment alerts entirely on-device, categorizes expenditure, and presents real-time cashflow intelligence without transmitting any personal data over the internet.

---

## 🔒 100% Offline & Private by Design

- **Zero Cloud Tracking**: The application has **no internet dependencies**. All regex evaluation, string extraction, and ledger calculations occur locally.
- **Masked Account Numbers**: Financial account numbers and card tokens are automatically masked (e.g. `HDFC XX1234`).
- **Anti-OTP & Anti-Spam Guard**: Explicitly ignores verification OTPs, passwords, and promotional spam.

---

## ⚡ 4 Core Engine Modules

### 1. 📊 Net Cashflow & Financial Dashboard (`DashboardScreen`)
- **Net Cashflow Hero Card**: High-contrast balance card showing net position in Indian Rupees (`₹`), with Total Inflow (Credits) and Total Outflow (Debits).
- **Top Expense Categories**: Visual progress bars displaying spend share by category.
- **Recent Activity**: Quick list of the most recent debits and credits with merchant avatars.

### 2. 🧾 Searchable Transaction History (`TransactionsScreen`)
- Search by merchant name (e.g., Zomato, Amazon, Uber), bank tag (HDFC, SBI, ICICI, Axis), or account number.
- Filter by transaction type: **All Types**, **Debits (Spends)**, or **Credits (Income)**.
- Detailed modal view displaying raw SMS message body, sender tag, and exact timestamp.

### 3. 📈 Category Insights & Distribution (`InsightsScreen`)
- Comprehensive category breakdown:
  - 🍔 **Food & Dining**: Zomato, Swiggy, Cafes
  - 🛍️ **Shopping**: Amazon India, Flipkart, Myntra, Ajio
  - 🚗 **Travel & Commute**: Uber, Ola, Fuel, IRCTC, Flights
  - 🥦 **Groceries**: Blinkit, Zepto, BigBasket, Instamart
  - 💡 **Bills & Utilities**: Airtel, Jio, Electricity bills
  - 📈 **Investments**: Zerodha, Groww, Mutual Funds
  - 💰 **Salary & Income**: Payroll, Employer deposits
- Highlights highest spend category and average spend per transaction.

### 4. 🧪 Interactive SMS Regex Tester (`SmsTesterScreen`)
- Interactive tester allowing you to test regex against preset templates (HDFC, SBI, ICICI, Axis, Paytm, Kotak, or Spam OTP).
- Real-time diagnostic parser report:
  - Bank identifier
  - Masked account number
  - Currency amount in ₹
  - Transaction classification (Debit / Credit)
  - Extracted merchant / payee
  - Category assignment
- **"Add to My Ledger"** button to inject parsed transactions directly into the active ledger.

---

## 🎨 Impeccable Design System

- **Midnight Obsidian Palette**: Deep `#080C15` background tinted with emerald/teal undertones for wealth and financial clarity.
- **Electric Mint & Radiant Coral Accents**: Credits highlighted in vibrant green (`#10B981`) and debits in coral rose (`#F43F5E`).
- **Typography**: Google Fonts [`Outfit`](https://fonts.google.com/specimen/Outfit) for headings and [`Fira Code`](https://fonts.google.com/specimen/Fira+Code) for financial values.
- **Tactile Feedback**: Physics-based light haptics on taps and actions.
- **Android 15 Edge-to-Edge**: Immersive transparent status and navigation bars.

---

## 🚀 Building & Running Locally

### 1. Fetch Dependencies & Verify
```bash
git clone https://github.com/apravint/spend-analyzer-android.git
cd spend-analyzer-android
flutter pub get
flutter analyze
flutter test
```

### 2. Run the App
```bash
flutter run
# Or in Chrome:
flutter run -d chrome
```

### 3. Build Release Artifacts
```bash
# Android APK
flutter build apk --release

# Flutter Web
flutter build web --release --base-href "/spend-analyzer-android/"
```

---

## 📄 License

Created by **Ayyappa Pravin** ([@apravint](https://github.com/apravint)). Open source under the MIT License.
