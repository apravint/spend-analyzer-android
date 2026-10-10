# SpendAnalyzer AI - Offline SMS Income & Spend Analyzer 💳📊

> **SpendAnalyzer AI** is an offline, privacy-first mobile and web application that reads Indian banking & UPI transaction SMS notifications, parses them locally on-device, and presents financial insights in a clean, dashboard-driven interface.

---

## 🔒 100% Offline & Private by Design

- **Zero Cloud Tracking**: The app has **NO internet dependency**. All parsing, regex evaluation, and storage happen strictly on your device.
- **Masked Account Numbers**: Financial account and card numbers are masked (e.g., `HDFC XX1234`) for functional security.
- **Anti-OTP & Anti-Spam Guard**: Explicitly ignores OTPs, verification codes, and promotional spam.

---

## ⚡ 4 Core Engine Modules

1. **SMS READ & Background Receiver**:
   - Background BroadcastReceiver for incoming bank SMS.
   - One-tap inbox history sync.
   - Filters sender IDs matching alphanumeric bank tags (`HDFCBK`, `SBIUPI`, `ICICIB`, `AXISBK`, `PAYTM`, etc.).
2. **Local Regex Parsing Engine**:
   - Extracts: Transaction Type (`DEBIT` vs. `CREDIT`), Amount (`₹`), Merchant/Payee, Masked Account, and Timestamp.
   - Supports Indian banking and UPI templates (HDFC, SBI, ICICI, Axis, Kotak, Paytm).
3. **Intelligent Local Categorizer**:
   - Automatically buckets transactions into standard categories:
     - 🍔 **Food & Dining**: Zomato, Swiggy, Restaurants, Cafes
     - 🛍️ **Shopping**: Amazon, Flipkart, Myntra, Ajio
     - 🚗 **Travel & Commute**: Uber, Ola, Metro, Fuel, IRCTC
     - 🥦 **Groceries**: Blinkit, Zepto, BigBasket, Instamart
     - 💡 **Bills & Utilities**: Airtel, Jio, Electricity, Water
     - 📈 **Investment**: Zerodha, Groww, Mutual Funds
     - 💰 **Salary & Income**: Payroll, Employer, Interest
4. **Dashboard & Financial UI**:
   - **Dashboard**: Net Cashflow, Total Inflow (Income), Total Outflow (Spends), active bank accounts.
   - **Transaction History**: Searchable list with green/red amount indicators and category badges.
   - **Insights**: Category expenditure breakdown with visual progress bars.
   - **Interactive SMS Tester**: Test and validate regex on custom SMS templates.

---

## 📱 Building & Installation

### Android APK (`SpendAnalyzer.apk`)

`SpendAnalyzer.apk` is compiled with:
- `minSdkVersion="24"` and `targetSdkVersion="34"`
- 4-byte ZipAlignment & V1/V2/V3 signatures for universal installation across Android 7.0 - 15+.

Download the latest APK from [GitHub Releases](https://github.com/apravint/spend-analyzer-android/releases/tag/v1.0.0).

---

## 📄 License

Created by **Ayyappa Pravin** ([@apravint](https://github.com/apravint)). Open source under the MIT License.
