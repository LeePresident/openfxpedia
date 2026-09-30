# OpenFXpedia — 貨幣換算與百科

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

## 概述

OpenFXpedia 是一款輕量級 Flutter 應用程式，結合貨幣換算與可搜尋的貨幣百科，提供旗幟、貨幣符號、地區和說明等資訊。應用程式支援 Windows 桌面版和 Android。

目前版本：`1.0.5`

## 快速連結

- 規格說明與任務：`specs/master`

## 架構

應用程式透過 Provider 協調介面邏輯，透過服務處理領域邏輯和資料：

- `CurrencyCatalogService` 建立貨幣百科使用的本地化 `Currency` 模型。
- `CurrencyCatalogRepository` 負責遠端貨幣目錄擷取、快取持久化、快取有效期限（TTL）管理和離線備援。
- `CurrencyMetadataLoader` 從 `assets/data/fiat_currencies.json` 載入應用程式內建的法定貨幣白名單和中繼資料。
- `CurrencyOverlayLoader` 從 `assets/data/fiat_currency_overlays/` 載入特定語言的百科覆寫資料。
- `CurrencyLocalizer` 套用覆寫資料，並記錄個別欄位回退至英語的事件。
- `CacheService` 透過 Hive 持久化儲存匯率、貨幣目錄資料、收藏和偏好設定。

目錄載入器在各自的服務執行個體中快取資料。目錄服務僅保留目前語言的貨幣清單，而儲存庫層保留現有的快取和離線行為。

## 功能

- 使用即時匯率快速換算貨幣，支援本機快取和離線使用。
- 可在設定中選擇匯率 API 來源，支援自動使用主要及備用資料來源。
- 法定貨幣百科：名稱、符號、地區、說明和使用地區旗幟。
- 提供主幣與輔幣單位、硬幣與紙鈔面額，並可快速換算所選面額。
- 依名稱、貨幣代碼或 ISO 4217 數字代碼搜尋，支援一鍵清除搜尋。
- 可選擇淺色、深色或跟隨系統的佈景主題，並儲存至應用程式設定。
- 可在設定中選擇英語、簡體中文或繁體中文。
- 提供收藏、快速交換來源貨幣與目標貨幣，以及來源貨幣和目標貨幣選擇對話方塊。
- 應用程式內檢查更新會開啟適用於目前裝置的 GitHub 發行檔案：Windows 為 `openfxpedia_<version>_setup.exe`，Android 為 `openfxpedia_<version>.apk`。

## 環境需求

- Flutter SDK（穩定通道）
- Windows：安裝 Visual Studio Build Tools 及「使用 C++ 的桌面開發」工作負載；使用 `flutter config --enable-windows-desktop` 啟用桌面支援
- Windows 發行版安裝程式：NSIS（`makensis` 必須在 PATH 中）
- Android：Android SDK，以及模擬器或實體裝置
- 建議執行 `flutter doctor` 檢查環境

## 快速開始（Windows）

1. 在儲存庫根目錄執行：

```powershell
flutter pub get
flutter run -d windows
```

## 快速開始（Android 模擬器或實體裝置）

```powershell
flutter pub get
flutter run
```

## 建置發行版本

```powershell
# Windows
./scripts/build_windows.ps1

# 可攜版 EXE 輸出（發行版）
# build/windows/portable/openfxpedia_<version>.exe
# 用於散佈的可攜版壓縮檔
# build/windows/openfxpedia_<version>_portable.zip

# NSIS 安裝程式輸出（發行版）
# build/windows/installer/openfxpedia_<version>_setup.exe

# Android（Windows PowerShell）
./scripts/build_android.ps1
./scripts/build_android.ps1 -Mode debug

# APK 輸出（發行版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 輸出（發行版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

```bash
# Windows（Git Bash）
bash ./scripts/build_windows.sh
bash ./scripts/build_windows.sh debug

# 可攜版 EXE 輸出（發行版）
# build/windows/portable/openfxpedia_<version>.exe

# 建置 NSIS 安裝程式請使用上面的 PowerShell 指令碼。

# Android（macOS/Linux/Git Bash）
bash ./scripts/build_android.sh
bash ./scripts/build_android.sh debug

# APK 輸出（發行版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 輸出（發行版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

## 效能基準測試

```powershell
dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000
```

## API 與資料來源

- 匯率（主要資料來源）：https://github.com/lineofflight/frankfurter
- 匯率（備用資料來源）：https://github.com/fawazahmed0/exchange-api
- 貨幣清單（ISO 4217）：https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json

應用程式優先從 Frankfurter 取得即時匯率，僅在主要資料來源無法使用、逾時或無法提供所需匯率時改用 exchange-api。CDN JSON 仍是貨幣中繼資料的權威來源。儲存庫也維護了經過整理的白名單資源 `assets/data/fiat_currencies.json`，隨應用程式提供更豐富的百科中繼資料。

使用者可以在設定中選擇自動選擇、Frankfurter 或 exchange-api，以切換匯率 API 來源。

## 隱私

OpenFXpedia 無需註冊帳號，不收集姓名、電子郵件地址、付款資訊、聯絡人、位置、相機或麥克風資料，也不收集廣告識別碼。應用程式不包含分析、廣告、當機回報或使用者追蹤 SDK。

應用程式透過 HTTPS 向上述已設定的匯率和貨幣目錄提供者傳送請求。這些請求包含取得匯率和目錄資料所需的所選貨幣代碼。使用者檢查更新時，應用程式也會連線至 OpenFXpedia 的 GitHub 儲存庫。外部提供者和 GitHub 可能會依據各自的隱私權政策接收 IP 位址等一般連線中繼資料。

匯率和貨幣目錄資料快取於本機，供離線使用。收藏和應用程式偏好設定也儲存在本機。這些 Hive 資料儲存盒使用隨機產生的金鑰加密，金鑰存放在應用程式支援目錄中。加密可防止儲存資料被隨意查看，但金鑰儲存在本機，而非硬體支援的安全儲存空間中，因此無法保護已遭入侵或被攻擊者解鎖的裝置上的資料。

若要刪除本機儲存的匯率、目錄資料、收藏和偏好設定，請開啟**設定**並選擇**清除本機資料**。清除本機資料會保留加密金鑰，以便後續快取的資料繼續受到加密保護。解除安裝應用程式時，作業系統會依其正常解除安裝機制移除應用程式資料。

Android 應用程式僅要求 `INTERNET` 權限。網路通訊使用 HTTPS，只有在 GitHub 發行檔案的 URL 和 SHA-256 摘要通過 GitHub 發行中繼資料驗證後，才會下載更新檔案。這可偵測錯誤或損壞的下載，但並非獨立的發行者簽章，因此發行來源遭到入侵的情況仍不在應用程式的信任保障範圍內。匯率請求和更新檢查不會主動包含個人資料。

## 資源

- 應用程式品牌資源存放在 `assets/branding/`，百科資料存放在 `assets/encyclopedia/`。
- 百科使用 `country_flags` 顯示國家和地區旗幟。歐元使用歐盟旗幟。
- XAF、XCD、XCG、XOF 和 XPF 繼續使用專案原創並隨應用程式封裝的圓形專用貨幣圖示。
- 執行應用程式前，請確保 `pubspec.yaml` 中已宣告相應資源。

百科中的國家旗幟使用 [`country_flags`](https://pub.dev/packages/country_flags) Flutter 套件（MIT 授權條款）。該套件註明其內建的 SVG 旗幟圖案來自 [`flag-icons`](https://github.com/lipis/flag-icons) 專案。

## 測試

- 執行單元測試和元件測試：

```powershell
flutter test
```

- 執行靜態分析：

```powershell
flutter analyze
```

- 執行針對貨幣目錄和換算的測試：

```powershell
flutter test test/widget/encyclopedia_locale_test.dart
flutter test test/integration/encyclopedia_flow_test.dart
flutter test test/unit/conversion_test.dart
```

## 本地化說明

- 新增文字時，先更新 `lib/l10n/app_en.arb`。
- 保持 `lib/l10n/app_zh_Hans.arb` 和 `lib/l10n/app_zh_Hant.arb` 的鍵集合與英語版本一致。
- `lib/l10n/app_zh.arb` 是 `zh` 語言地區系列的通用中文回退來源。
- `OpenFXpedia` 是產品名稱，在所有語言中均保持不變。
- 修改 ARB 後，執行 `flutter gen-l10n` 重新產生納入版本控制的本地化輸出，然後執行 `dart format lib/l10n`。

啟動畫面由 Flutter 繪製，因此載入狀態和啟動錯誤可以使用所選語言顯示。在 Windows 上，應用程式初始化期間會持續顯示此 Flutter 啟動畫面；Android 則先顯示原生啟動畫面，待 Flutter 就緒後將其移除。

## VS Code

- 儲存庫在 `.vscode` 中提供啟動和工作設定，方便在 Windows 和 Android 上執行及偵錯應用程式。
- 使用 VS Code 時，請開啟工作區根目錄，並透過「執行」檢視啟動應用程式。

## 疑難排解

- 桌面建置失敗：確認已啟用 Windows 桌面支援，並安裝了 Visual Studio 及 C++ 工作負載。
- 安裝程式建置失敗：確認已安裝 NSIS，且 `makensis` 可透過 PATH 存取。
- Flutter 找不到裝置：執行 `flutter doctor -v`，確認 Android SDK、模擬器或 Windows 桌面環境已正確設定。
- 相依套件問題：執行 `flutter pub get`，並解決 pub 回報的錯誤。

## 參與貢獻

- 為修改建立分支並提交 PR。功能設計和任務請見 `specs/master`。
- 新增或更新貨幣中繼資料時，請同步更新 `assets/data/fiat_currencies.json`，並在 `specs/master/data/` 中新增簡短的驗證說明。

## 授權條款

- 本儲存庫採用 MIT 授權條款（見 `LICENSE`）。

## 聯絡與致謝

- 維護者：專案團隊（如有問題，請提交 GitHub issue 或 PR）。
- 資料來源：感謝 `@fawazahmed0/exchange-api` 專案和 `@fawazahmed0/currency-api` CDN。

---

**注意：** 新增品牌、旗幟或專用貨幣圖示資源時，請保持 `pubspec.yaml` 與 `assets/` 同步。