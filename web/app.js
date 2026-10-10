/**
 * SpendAnalyzer AI - Offline SMS Income & Spend Analyzer
 * Local Regex Parsing Engine & Financial Dashboard
 */

// Preset Templates for Interactive SMS Tester
const SMS_PRESETS = {
    hdfc_debit: {
        sender: "VK-HDFCBK",
        body: "Your a/c no. XX1234 is debited for Rs. 540.00 on 10-Oct-26 by Zomato UPI ref 4289102482. Avl Bal: Rs. 24,150.00"
    },
    sbi_credit: {
        sender: "AD-SBIUPI",
        body: "Your a/c XX5678 has been credited with INR 75,000.00 on 01-Oct-26 by Salary/Employer. Avl Bal: INR 1,12,400.00"
    },
    icici_debit: {
        sender: "AX-ICICIB",
        body: "Acct XX9012 debited with INR 2,499.00 on 08-Oct-26 towards Amazon India. UPI Ref: 981240182. Call 18001080 if not done by you."
    },
    axis_debit: {
        sender: "BZ-AXISBK",
        body: "ALERT: Rs 340.50 debited from Axis Bank a/c XX3456 on 09-Oct-26 at Uber India. Avl Bal: Rs 15,200.00"
    },
    paytm_debit: {
        sender: "BP-PAYTMB",
        body: "Paid Rs. 420.00 to Blinkit using Paytm Bank Account XX7890. UPI Ref: 3192048201. Bal: Rs 8,300.00"
    },
    kotak_credit: {
        sender: "VM-KOTAKB",
        body: "Dear Customer, INR 3,500.00 credited to Kotak Bank A/c XX4321 on 05-Oct-26 via UPI transfer from Ramesh Kumar."
    },
    spam_otp: {
        sender: "VM-MYNTRA",
        body: "482910 is your secret OTP for Myntra order verification. Do not share this OTP with anyone including delivery partners."
    }
};

// Seed Transactions for Immediate Out-of-the-Box Experience
const DEFAULT_TRANSACTIONS = [
    {
        id: "tx-seed-1",
        sender: "AD-SBIUPI",
        bankName: "SBI",
        accountMasked: "SBI XX5678",
        amount: 75000.00,
        type: "CREDIT",
        merchant: "Monthly Salary",
        category: "Salary & Income",
        timestamp: Date.now() - 9 * 86400000,
        rawBody: "Your a/c XX5678 has been credited with INR 75,000.00 on 01-Oct-26 by Salary/Employer."
    },
    {
        id: "tx-seed-2",
        sender: "VK-HDFCBK",
        bankName: "HDFC",
        accountMasked: "HDFC XX1234",
        amount: 540.00,
        type: "DEBIT",
        merchant: "Zomato",
        category: "Food & Dining",
        timestamp: Date.now() - 2 * 86400000,
        rawBody: "Your a/c no. XX1234 is debited for Rs. 540.00 on 08-Oct-26 by Zomato UPI ref 4289102482."
    },
    {
        id: "tx-seed-3",
        sender: "AX-ICICIB",
        bankName: "ICICI",
        accountMasked: "ICICI XX9012",
        amount: 2499.00,
        type: "DEBIT",
        merchant: "Amazon India",
        category: "Shopping",
        timestamp: Date.now() - 3 * 86400000,
        rawBody: "Acct XX9012 debited with INR 2,499.00 on 07-Oct-26 towards Amazon India."
    },
    {
        id: "tx-seed-4",
        sender: "BZ-AXISBK",
        bankName: "AXIS",
        accountMasked: "AXIS XX3456",
        amount: 380.00,
        type: "DEBIT",
        merchant: "Uber India",
        category: "Travel & Commute",
        timestamp: Date.now() - 4 * 86400000,
        rawBody: "ALERT: Rs 380.00 debited from Axis Bank a/c XX3456 on 06-Oct-26 at Uber India."
    },
    {
        id: "tx-seed-5",
        sender: "BP-PAYTMB",
        bankName: "PAYTM",
        accountMasked: "PAYTM XX7890",
        amount: 620.00,
        type: "DEBIT",
        merchant: "Blinkit",
        category: "Groceries",
        timestamp: Date.now() - 5 * 86400000,
        rawBody: "Paid Rs. 620.00 to Blinkit using Paytm Bank Account XX7890."
    },
    {
        id: "tx-seed-6",
        sender: "VK-HDFCBK",
        bankName: "HDFC",
        accountMasked: "HDFC XX1234",
        amount: 1199.00,
        type: "DEBIT",
        merchant: "Airtel Broadband",
        category: "Bills & Utilities",
        timestamp: Date.now() - 6 * 86400000,
        rawBody: "A/c XX1234 debited for Rs. 1,199.00 on 04-Oct-26 for Airtel Broadband recharge."
    },
    {
        id: "tx-seed-7",
        sender: "AD-SBIUPI",
        bankName: "SBI",
        accountMasked: "SBI XX5678",
        amount: 5000.00,
        type: "DEBIT",
        merchant: "Zerodha Broking",
        category: "Investment",
        timestamp: Date.now() - 7 * 86400000,
        rawBody: "Rs 5,000.00 debited from a/c XX5678 towards Zerodha UPI on 03-Oct-26."
    }
];

// In-Memory Database (Synced with LocalStorage)
let transactions = [];
let activeFilter = "all";
let activeModalTx = null;

document.addEventListener("DOMContentLoaded", () => {
    loadTransactions();
    initTheme();
    initTabs();
    initDashboard();
    initTransactionsView();
    initInsightsView();
    initTesterView();
    initNativeBridge();
});

/* Local Storage Manager */
function loadTransactions() {
    const saved = localStorage.getItem("spend_analyzer_txs");
    if (saved) {
        try {
            transactions = JSON.parse(saved);
        } catch (e) {
            transactions = [...DEFAULT_TRANSACTIONS];
        }
    } else {
        transactions = [...DEFAULT_TRANSACTIONS];
        saveTransactions();
    }
}

function saveTransactions() {
    localStorage.setItem("spend_analyzer_txs", JSON.stringify(transactions));
}

/* Theme Handler */
function initTheme() {
    const btn = document.getElementById("themeToggleBtn");
    const theme = localStorage.getItem("spend_theme") || "dark";
    document.body.setAttribute("data-theme", theme);

    btn.addEventListener("click", () => {
        const isDark = document.body.getAttribute("data-theme") === "dark";
        const next = isDark ? "light" : "dark";
        document.body.setAttribute("data-theme", next);
        localStorage.setItem("spend_theme", next);
        triggerHaptic();
    });
}

/* Tabs Navigation */
function initTabs() {
    const navBtns = document.querySelectorAll(".nav-btn");
    const panes = document.querySelectorAll(".tab-pane");

    navBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            const target = btn.getAttribute("data-tab");
            navBtns.forEach(b => b.classList.remove("active"));
            panes.forEach(p => p.classList.remove("active"));

            btn.classList.add("active");
            document.getElementById(`${target}Tab`).classList.add("active");

            if (target === "dashboard") refreshDashboard();
            if (target === "transactions") refreshTransactionsList();
            if (target === "insights") refreshInsights();
            triggerHaptic();
        });
    });

    document.getElementById("seeAllTxBtn").addEventListener("click", () => {
        document.querySelector('.nav-btn[data-tab="transactions"]').click();
    });
}

/* ---------------- LOCAL REGEX PARSER ENGINE ---------------- */
function parseSms(sender, body, timestamp = Date.now()) {
    const cleanSender = sender.trim().toUpperCase();
    const lowerBody = body.toLowerCase();

    // 1. Anti-OTP & Spam Guard
    const spamKeywords = ["otp", "verification code", "one time password", "do not share", "loan approved", "congratulations", "claim", "apply now"];
    if (spamKeywords.some(w => lowerBody.includes(w))) {
        return { error: "Ignored: Message identified as OTP or Promotional Broadcast." };
    }

    // 2. Identify Transaction Type
    let type = null;
    if (/debited|spent|paid|withdrawn|transferred to|sent/.test(lowerBody)) {
        type = "DEBIT";
    } else if (/credited|received|deposited|refund/.test(lowerBody)) {
        type = "CREDIT";
    } else {
        return { error: "Ignored: No financial debit or credit trigger detected." };
    }

    // 3. Extract Amount
    const amountRegex = /(?:rs\.?|inr|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)/i;
    const amountMatch = body.match(amountRegex);
    if (!amountMatch) return { error: "Could not extract transaction amount." };
    const amount = parseFloat(amountMatch[1].replace(/,/g, ""));

    // 4. Extract Account Info & Mask
    const accRegex = /(?:a\/c|acct|account|card)\s*(?:no\.?)?\s*[*xX]*([0-9]{3,4})/i;
    const accMatch = body.match(accRegex);
    const last4 = accMatch ? accMatch[1] : "XXXX";

    let bankName = "BANK";
    if (cleanSender.includes("HDFC")) bankName = "HDFC";
    else if (cleanSender.includes("SBI")) bankName = "SBI";
    else if (cleanSender.includes("ICICI")) bankName = "ICICI";
    else if (cleanSender.includes("AXIS")) bankName = "AXIS";
    else if (cleanSender.includes("KOTAK")) bankName = "KOTAK";
    else if (cleanSender.includes("PAYTM")) bankName = "PAYTM";
    else {
        const parts = cleanSender.split("-");
        bankName = parts.length > 1 ? parts[1].substring(0, 4) : cleanSender.substring(0, 4);
    }
    const maskedAccount = `${bankName} XX${last4}`;

    // 5. Extract Payee / Merchant
    let merchant = "Direct Transfer";
    const merchantRegex = /(?:to|by|at|vpa|info\/|towards)\s+([A-Za-z0-9@._&\s-]{2,25}?)(?:\s+(?:on|ref|upi|avl|bal|val|thru|using|via)|\.|,|$)/i;
    const merchMatch = body.match(merchantRegex);
    if (merchMatch && merchMatch[1]) {
        merchant = merchMatch[1].trim().split(" ").slice(0, 3).join(" ").replace(/[^A-Za-z0-9 ]/g, "").trim();
    }
    if (!merchant || merchant.length < 2) merchant = type === "CREDIT" ? "Bank Credit" : "Bank Debit";

    // 6. Intelligent Local Categorization
    const category = categorize(merchant, lowerBody, type);

    return {
        id: `tx-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
        sender: cleanSender,
        bankName,
        accountMasked: maskedAccount,
        amount,
        type,
        merchant,
        category,
        timestamp,
        rawBody: body
    };
}

function categorize(merchant, body, type) {
    if (type === "CREDIT" && (/salary|payroll|dividend|stipend/.test(body) || /salary|employer/.test(merchant.toLowerCase()))) {
        return "Salary & Income";
    }

    const text = `${merchant} ${body}`.toLowerCase();
    if (/zomato|swiggy|mcdonald|starbucks|kfc|restaurant|cafe|domino|pizza|baker|burger/.test(text)) return "Food & Dining";
    if (/amazon|flipkart|myntra|ajio|meesho|zara|h&m|retail|mall|store/.test(text)) return "Shopping";
    if (/uber|ola|rapido|metro|irctc|flight|indigo|petrol|fuel|hpcl|bpcl|shell|toll/.test(text)) return "Travel & Commute";
    if (/blinkit|zepto|bigbasket|instamart|grocery|supermarket|kirana|vegetable/.test(text)) return "Groceries";
    if (/airtel|jio|vi|electricity|bescom|tneb|gas|water|broadband|recharge|billdesk|cred/.test(text)) return "Bills & Utilities";
    if (/zerodha|groww|angelone|upstox|mutual fund|sip|sebi|nse|bse/.test(text)) return "Investment";

    return type === "CREDIT" ? "Salary & Income" : "Miscellaneous";
}

/* ---------------- DASHBOARD TAB ---------------- */
function initDashboard() {
    refreshDashboard();
}

function refreshDashboard() {
    let income = 0;
    let expense = 0;
    const accountsSet = new Set();

    transactions.forEach(t => {
        if (t.type === "CREDIT") income += t.amount;
        if (t.type === "DEBIT") expense += t.amount;
        accountsSet.add(t.accountMasked);
    });

    const net = income - expense;
    const netEl = document.getElementById("heroNetBalance");
    netEl.textContent = formatCurrency(net);
    netEl.style.color = net >= 0 ? "var(--color-income)" : "var(--color-expense)";

    document.getElementById("heroTotalIncome").textContent = formatCurrency(income);
    document.getElementById("heroTotalExpense").textContent = formatCurrency(expense);

    // Render Account Chips
    const accContainer = document.getElementById("bankAccountsList");
    accContainer.innerHTML = "";
    if (accountsSet.size === 0) {
        accContainer.innerHTML = `<span style="color:var(--text-secondary);font-size:0.85rem;">No bank accounts detected yet.</span>`;
    } else {
        accountsSet.forEach(acc => {
            const chip = document.createElement("span");
            chip.className = "bank-chip";
            chip.innerHTML = `🏦 ${acc}`;
            accContainer.appendChild(chip);
        });
    }

    // Render Recent 5 Transactions
    const recentList = document.getElementById("recentTransactionsList");
    recentList.innerHTML = "";
    const recent = [...transactions].sort((a, b) => b.timestamp - a.timestamp).slice(0, 5);
    
    if (recent.length === 0) {
        recentList.innerHTML = `<p style="color:var(--text-secondary);font-size:0.85rem;padding:12px;">No transactions found. Sync or test SMS.</p>`;
    } else {
        recent.forEach(t => recentList.appendChild(createTxElement(t)));
    }
}

/* ---------------- TRANSACTIONS TAB ---------------- */
function initTransactionsView() {
    const searchInput = document.getElementById("txSearchInput");
    const pills = document.querySelectorAll(".filter-pill");
    const clearBtn = document.getElementById("clearDataBtn");

    searchInput.addEventListener("input", refreshTransactionsList);

    pills.forEach(pill => {
        pill.addEventListener("click", () => {
            pills.forEach(p => p.classList.remove("active"));
            pill.classList.add("active");
            activeFilter = pill.getAttribute("data-type");
            refreshTransactionsList();
            triggerHaptic();
        });
    });

    clearBtn.addEventListener("click", () => {
        if (confirm("Reset transaction data back to demo defaults?")) {
            transactions = [...DEFAULT_TRANSACTIONS];
            saveTransactions();
            refreshDashboard();
            refreshTransactionsList();
            refreshInsights();
            triggerHaptic();
        }
    });

    refreshTransactionsList();
}

function refreshTransactionsList() {
    const container = document.getElementById("allTransactionsList");
    const query = document.getElementById("txSearchInput").value.toLowerCase().trim();
    container.innerHTML = "";

    const filtered = transactions.filter(t => {
        const matchesFilter = activeFilter === "all" || t.type === activeFilter;
        const matchesQuery = !query || 
            t.merchant.toLowerCase().includes(query) || 
            t.accountMasked.toLowerCase().includes(query) || 
            t.category.toLowerCase().includes(query) ||
            t.amount.toString().includes(query);
        return matchesFilter && matchesQuery;
    }).sort((a, b) => b.timestamp - a.timestamp);

    document.getElementById("txCountHeading").textContent = `Logged Transactions (${filtered.length})`;

    if (filtered.length === 0) {
        container.innerHTML = `<p style="color:var(--text-secondary);font-size:0.88rem;text-align:center;padding:24px;">No transactions match the selected criteria.</p>`;
        return;
    }

    filtered.forEach(t => container.appendChild(createTxElement(t)));
}

function createTxElement(t) {
    const el = document.createElement("div");
    el.className = "tx-item";
    const isDebit = t.type === "DEBIT";
    const dateStr = formatDate(t.timestamp);

    el.innerHTML = `
        <div class="tx-main">
            <span class="tx-merchant">${t.merchant}</span>
            <div class="tx-meta">
                <span>${dateStr}</span>
                <span class="tx-tag-account">${t.accountMasked}</span>
                <span class="tx-tag-cat">${t.category}</span>
            </div>
        </div>
        <span class="tx-amount ${isDebit ? 'debit' : 'credit'}">
            ${isDebit ? '-' : '+'} ${formatCurrency(t.amount)}
        </span>
    `;

    el.addEventListener("click", () => openTxModal(t));
    return el;
}

/* ---------------- INSIGHTS TAB ---------------- */
function initInsightsView() {
    refreshInsights();
}

function refreshInsights() {
    const container = document.getElementById("categoryBreakdownList");
    container.innerHTML = "";

    const debits = transactions.filter(t => t.type === "DEBIT");
    const totalSpent = debits.sum(t => t.amount);
    document.getElementById("insightsTotalSpent").textContent = formatCurrency(totalSpent);

    const categoryMap = {};
    debits.forEach(t => {
        categoryMap[t.category] = (categoryMap[t.category] || 0) + t.amount;
    });

    const sortedCats = Object.entries(categoryMap).sort((a, b) => b[1] - a[1]);

    if (sortedCats.length === 0) {
        container.innerHTML = `<p style="color:var(--text-secondary);font-size:0.88rem;text-align:center;padding:20px;">No expense records found to generate insights.</p>`;
        return;
    }

    sortedCats.forEach(([cat, amount]) => {
        const pct = totalSpent > 0 ? Math.round((amount / totalSpent) * 100) : 0;
        const barItem = document.createElement("div");
        barItem.className = "cat-bar-item";
        barItem.innerHTML = `
            <div class="cat-bar-header">
                <span>${cat}</span>
                <span>${formatCurrency(amount)} (${pct}%)</span>
            </div>
            <div class="progress-track">
                <div class="progress-fill" style="width: ${pct}%;"></div>
            </div>
        `;
        container.appendChild(barItem);
    });
}

// Utility sum helper
Array.prototype.sum = function(fn) {
    return this.reduce((acc, item) => acc + (fn ? fn(item) : item), 0);
};

/* ---------------- SMS TESTER TAB ---------------- */
function initTesterView() {
    const presetSelect = document.getElementById("smsPresetSelect");
    const senderInput = document.getElementById("rawSenderInput");
    const bodyInput = document.getElementById("rawSmsInput");
    const testBtn = document.getElementById("testParseBtn");
    const resultBox = document.getElementById("parseResultBox");
    const outputDetails = document.getElementById("parseOutputDetails");

    presetSelect.addEventListener("change", () => {
        const val = presetSelect.value;
        if (SMS_PRESETS[val]) {
            senderInput.value = SMS_PRESETS[val].sender;
            bodyInput.value = SMS_PRESETS[val].body;
        }
    });

    testBtn.addEventListener("click", () => {
        const sender = senderInput.value.trim();
        const body = bodyInput.value.trim();

        if (!sender || !body) {
            alert("Please enter both Sender ID and SMS Body.");
            return;
        }

        const res = parseSms(sender, body);
        resultBox.classList.remove("hidden");

        if (res.error) {
            outputDetails.innerHTML = `<div style="grid-column: span 2; color: var(--color-expense); font-weight:600;">❌ ${res.error}</div>`;
        } else {
            outputDetails.innerHTML = `
                <div class="parse-detail-item"><span>Status:</span> <strong style="color:var(--color-income)">Parsed & Added</strong></div>
                <div class="parse-detail-item"><span>Type:</span> <strong>${res.type}</strong></div>
                <div class="parse-detail-item"><span>Amount:</span> <strong>${formatCurrency(res.amount)}</strong></div>
                <div class="parse-detail-item"><span>Merchant:</span> <strong>${res.merchant}</strong></div>
                <div class="parse-detail-item"><span>Account:</span> <strong>${res.accountMasked}</strong></div>
                <div class="parse-detail-item"><span>Category:</span> <strong>${res.category}</strong></div>
            `;

            transactions.unshift(res);
            saveTransactions();
            refreshDashboard();
            triggerHaptic();
        }
    });
}

/* ---------------- MODAL DETAIL ---------------- */
function openTxModal(t) {
    activeModalTx = t;
    const modal = document.getElementById("txModal");
    const typeTag = document.getElementById("modalTypeTag");
    typeTag.textContent = t.type;
    typeTag.className = `tag ${t.type === 'DEBIT' ? 'text-danger' : ''}`;

    document.getElementById("modalMerchant").textContent = t.merchant;
    document.getElementById("modalAmount").textContent = (t.type === 'DEBIT' ? '-' : '+') + ' ' + formatCurrency(t.amount);
    document.getElementById("modalAmount").style.color = t.type === 'DEBIT' ? 'var(--color-expense)' : 'var(--color-income)';
    document.getElementById("modalAccount").textContent = t.accountMasked;
    document.getElementById("modalCategory").textContent = t.category;
    document.getElementById("modalDate").textContent = formatDate(t.timestamp);
    document.getElementById("modalRawBody").textContent = t.rawBody;

    modal.classList.remove("hidden");
    triggerHaptic();
}

document.getElementById("closeModalBtn").addEventListener("click", () => document.getElementById("txModal").classList.add("hidden"));
document.getElementById("closeModalBtn2").addEventListener("click", () => document.getElementById("txModal").classList.add("hidden"));

document.getElementById("deleteTxBtn").addEventListener("click", () => {
    if (activeModalTx) {
        transactions = transactions.filter(x => x.id !== activeModalTx.id);
        saveTransactions();
        document.getElementById("txModal").classList.add("hidden");
        refreshDashboard();
        refreshTransactionsList();
        refreshInsights();
        triggerHaptic();
    }
});

/* ---------------- ANDROID NATIVE BRIDGE INTEGRATION ---------------- */
function initNativeBridge() {
    const syncBtn = document.getElementById("syncSmsBtn");

    syncBtn.addEventListener("click", () => {
        triggerHaptic();
        if (window.AndroidBridge && window.AndroidBridge.syncDeviceSms) {
            window.AndroidBridge.syncDeviceSms();
        } else {
            // Browser Simulation of Native SMS Sync
            const demoSync = [
                { sender: "VK-HDFCBK", body: "Rs. 1,420.00 debited from HDFC a/c XX1234 on 10-Oct-26 at Swiggy UPI. Bal: Rs. 22,730.00" },
                { sender: "AX-ICICIB", body: "Acct XX9012 debited with INR 899.00 on 09-Oct-26 towards Myntra Shopping." }
            ];

            let added = 0;
            demoSync.forEach(s => {
                const parsed = parseSms(s.sender, s.body);
                if (!parsed.error) {
                    transactions.unshift(parsed);
                    added++;
                }
            });

            saveTransactions();
            refreshDashboard();
            refreshTransactionsList();
            refreshInsights();
            alert(`Inbox Sync Complete: ${added} new financial transactions parsed locally.`);
        }
    });

    // Native callback invoked by Android Java BroadcastReceiver when an incoming SMS arrives
    window.onSmsReceived = function(sender, body, timestamp) {
        const parsed = parseSms(sender, body, timestamp || Date.now());
        if (!parsed.error) {
            transactions.unshift(parsed);
            saveTransactions();
            refreshDashboard();
            refreshTransactionsList();
            refreshInsights();
        }
    };
}

function triggerHaptic() {
    if (window.AndroidBridge && window.AndroidBridge.vibrate) {
        window.AndroidBridge.vibrate(30);
    }
}

function formatCurrency(val) {
    return '₹' + Math.abs(val).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function formatDate(ts) {
    const d = new Date(ts);
    return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}
