# 本地化支援

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

本專案在 `lib/main.dart` 中啟用 Flutter 本地化委派，目前宣告支援以下語言地區：
- `en`（英語）
- `zh`（繁體中文回退）
- `zh_Hans`（簡體中文）
- `zh_Hant`（繁體中文，採用香港用語）

本地化文字由 `lib/l10n/app_localizations.dart` 提供統一入口，ARB 原始檔位於本目錄中。
納入版本控制的產生實作檔案為 `app_localizations_en.dart` 和 `app_localizations_zh.dart`；後者包含通用 `zh`、簡體中文和繁體中文的實作。

日後擴充翻譯時：
1. 先在 `app_en.arb` 中新增鍵，再同步其他受支援語言的 ARB 檔案。引入新語言地區時，新增相應的 ARB 檔案。
2. 在儲存庫根目錄執行 `flutter gen-l10n`，然後執行 `dart format lib/l10n`，重新產生並格式化納入版本控制的本地化輸出。請勿手動編輯產生的 Dart 檔案。
3. 逐步將寫死的文字替換為本地化訊息呼叫。

說明：
- `app_zh.arb` 是通用中文回退原始檔，用於裝置回報的語言地區為 `zh` 且不帶文字代碼的情況。
- `app_localizations_zh.dart` 包含通用中文回退實作，以及區分簡繁體的中文實作。
- `app_zh_Hans.arb` 是簡體中文原始檔。
- `app_zh_Hant.arb` 是繁體中文原始檔。