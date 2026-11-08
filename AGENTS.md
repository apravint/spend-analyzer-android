# AGENTS.md - Developer & AI Agent Guide for spend-analyzer-android 🤖

## 🎯 Repository Overview
**spend-analyzer-android**: 🌐 Try it Live in Your Browser: Launch SpendAnalyzer AI Flutter Web Edition SpendAnalyzer AI is an offline, privacy-first mobile & web financial dashboard built with Flutter 3.x / Dart 3.x. It parses incoming Indian bank SMS notifications and UPI payment alerts entirely on-device, categorizes expenditure, and presents real-time cashflow intelligence without transmitting any personal data over the internet.

---

## 🏗️ Repository Architecture
Key directories and entrypoints: `.github/, LICENSE, README.md, analysis_options.yaml, android/, docs/, index.html, ios/, lib/, linux/, macos/, pubspec.lock`.

### Tech Stack & Runtime
- **Framework:** Flutter / Dart (Cross-Platform Android, iOS, Web & Desktop)
- **Configuration:** `pubspec.yaml`, `analysis_options.yaml`

## ⚙️ Executable Verification Commands

### 1. Static Analysis & Linting
```bash
flutter analyze || dart analyze
```

### 2. Unit & Widget Tests
```bash
flutter test
```

### 3. Build Verification
```bash
flutter build apk --debug --no-pub
```

---

## 🛡️ Coding & Safety Guidelines for Autonomous Agents

1. **Documentation Integrity:** Preserve all existing docstrings, header comments, and licensing banners. Never delete context unless specifically instructed.
2. **Zero Hardcoded Secrets:** Never embed API keys, OAuth tokens, personal access tokens, or sensitive credentials in committed files. Read credentials exclusively from environment variables or secure credential paths.
3. **Git Hygiene:**
   - Do not force-push (`git push --force`) or execute destructive resets.
   - Never modify root git configurations or harness infrastructure outside task scope.
   - Keep git diffs atomic, focused, and verified before committing.
4. **Agent Workflow Protocol:**
   - **Plan:** Inspect codebase architecture and dependencies before editing.
   - **Act:** Make minimal, clean, high-precision changes.
   - **Verify:** Run the appropriate verification commands listed above.
   - **Reflect:** Confirm zero regressions and review `git diff`.

---
*Maintained by Ayyappa Pravin • Built for Antigravity, Claude, Cursor & Autonomous AI Agents.*
