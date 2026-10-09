# OpenFXpedia — 货币换算与百科

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

## 概述

OpenFXpedia 是一款轻量级 Flutter 应用，集货币换算与可搜索的货币百科于一体，提供旗帜、货币符号、地区和说明等信息。应用支持 Windows 桌面端和 Android。

当前版本：`1.0.5`

## 快速链接

- 项目文档与设计记录：`specs/master`

## 架构

应用通过 Provider 协调界面逻辑，通过服务处理领域逻辑和数据：

- `CurrencyCatalogService` 构建货币百科使用的本地化 `Currency` 模型。
- `CurrencyCatalogRepository` 负责远程货币目录获取、缓存持久化、缓存有效期（TTL）管理和离线回退。
- `CurrencyMetadataLoader` 从 `assets/data/fiat_currencies.json` 加载应用内置的法定货币白名单和元数据。
- `CurrencyOverlayLoader` 从 `assets/data/fiat_currency_overlays/` 加载特定语言的百科覆盖数据。
- `CurrencyLocalizer` 应用覆盖数据，并记录字段级别回退到英语的事件。
- `CacheService` 通过 Hive 持久化保存汇率、货币目录数据、收藏和偏好设置。

目录加载器在各自的服务实例中缓存数据。目录服务仅保留当前语言的货币列表，而仓库层保留现有的缓存和离线行为。

## 功能

- 使用实时汇率快速换算货币，支持本地缓存和离线使用。
- 按指定日期使用历史汇率换算，显示所选日期与实际汇率日期，并可快速切回最新汇率。
- 可在设置中选择汇率 API 来源，支持自动使用主数据源及备用数据源。
- 法定货币百科：名称、符号、地区、说明和使用地区旗帜。
- 提供主币与辅币单位、硬币与纸币面额，并可快捷换算所选面额。
- 按名称、货币代码或 ISO 4217 数字代码搜索，支持一键清空搜索。
- 可选择浅色、深色或跟随系统的主题，并保存到应用设置。
- 可在设置中选择英语、简体中文或繁体中文。
- 提供收藏、快速交换源货币与目标货币，以及源货币和目标货币选择对话框。
- 应用内检查更新会打开适用于当前设备的 GitHub 发布文件：Windows 为 `openfxpedia_<version>_setup.exe`，Android 为 `openfxpedia_<version>.apk`。

## 环境要求

- Flutter SDK（稳定通道）
- Windows：安装 Visual Studio Build Tools 及“使用 C++ 的桌面开发”工作负载；使用 `flutter config --enable-windows-desktop` 启用桌面支持
- Windows 发布版安装程序：NSIS（`makensis` 必须在 PATH 中）
- Android：Android SDK，以及模拟器或实体设备
- 建议运行 `flutter doctor` 检查环境

## 快速开始（Windows）

1. 在仓库根目录运行：

```powershell
flutter pub get
flutter run -d windows
```

## 快速开始（Android 模拟器或实体设备）

```powershell
flutter pub get
flutter run
```

## 构建发布版本

```powershell
# Windows
./scripts/build_windows.ps1

# 便携版 EXE 输出（发布版）
# build/windows/portable/openfxpedia_<version>.exe
# 用于分发的便携版压缩包
# build/windows/openfxpedia_<version>_portable.zip

# NSIS 安装程序输出（发布版）
# build/windows/installer/openfxpedia_<version>_setup.exe

# Android（Windows PowerShell）
./scripts/build_android.ps1
./scripts/build_android.ps1 -Mode debug

# APK 输出（发布版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 输出（发布版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

```bash
# Windows（Git Bash）
bash ./scripts/build_windows.sh
bash ./scripts/build_windows.sh debug

# 便携版 EXE 输出（发布版）
# build/windows/portable/openfxpedia_<version>.exe

# 构建 NSIS 安装程序请使用上面的 PowerShell 脚本。

# Android（macOS/Linux/Git Bash）
bash ./scripts/build_android.sh
bash ./scripts/build_android.sh debug

# APK 输出（发布版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 输出（发布版）
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

## 性能基准测试

```powershell
dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000
```

## API 与数据来源

- 汇率（主数据源）：https://github.com/lineofflight/frankfurter
- 汇率（备用数据源）：https://github.com/fawazahmed0/exchange-api
- 货币列表（ISO 4217）：https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json

应用优先从 Frankfurter 获取实时汇率，仅在主数据源不可用、超时或无法提供所需汇率时回退到 exchange-api。CDN JSON 仍是货币元数据的权威来源。仓库还维护了经过整理的白名单资源 `assets/data/fiat_currencies.json`，随应用提供更丰富的百科元数据。

用户可以在设置中选择自动选择、Frankfurter 或 exchange-api，以切换汇率 API 来源。

### 历史汇率换算

打开换算结果下方的**历史汇率**，可查看截至所选换算日期的 1 周、1 月或 3 月图表；最新模式下截至今天。每个范围最多使用八个均匀分布的日期样本，并非完整的每日汇率序列。悬停或点击数据点可查看实际报价日期、每单位基础货币的汇率、提供方和缓存状态。缺失报价会留下断点；同一连续线段内不会重复绘制相同的报价日期。图表的刷新按钮会重新获取样本，不改变换算结果。图表同样遵循所选来源设置，并使用现有的加密历史缓存。

在换算器中选择**换算日期**，即可选择 1948 年至今天之间的日期。数据是否可用取决于货币对和提供方，日期选择器中的部分日期可能没有对应数据。选择**使用最新汇率**可恢复默认模式，金额和所选货币保持不变。

历史汇率请求使用 Frankfurter 的指定日期货币对接口或 Exchange API 的按日期归档数据。自动回退时会保留所选日期；手动指定来源时则不会切换提供方。应用会拒绝日期晚于所选日期的报价；如果提供方返回较早的报价，则会同时显示所选日期和实际汇率日期。历史汇率获取失败时，绝不会用今天的汇率替代。

历史汇率快照保存在现有的加密本地缓存中，按货币对、所选日期和来源设置分别存储。过去日期的快照可供离线重复使用。**刷新汇率**会重新获取所选日期的数据；如果请求失败，则使用与该请求匹配的缓存快照。**清除本地数据**也会删除历史快照。汇率仅供参考，不代表银行保证报价或官方会计汇率。

## 隐私

OpenFXpedia 无需注册账户，不收集姓名、电子邮箱地址、支付信息、联系人、位置、相机或麦克风数据，也不收集广告标识符。应用不包含分析、广告、崩溃报告或用户跟踪 SDK。

应用通过 HTTPS 向上述已配置的汇率和货币目录提供方发送请求。这些请求包含获取汇率和目录数据所需的所选货币代码。用户检查更新时，应用也会连接 OpenFXpedia 的 GitHub 仓库。外部提供方和 GitHub 可能会根据各自的隐私政策接收 IP 地址等常规连接元数据。

汇率和货币目录数据缓存在本地，供离线使用。收藏和应用偏好设置也保存在本地。这些 Hive 数据存储盒使用随机生成的密钥加密，密钥存放在应用支持目录中。加密可防止存储数据被随意查看，但密钥保存在本地，而非硬件支持的安全存储中，因此无法保护已被入侵或被攻击者解锁的设备上的数据。

要删除本地存储的汇率、目录数据、收藏和偏好设置，请打开**设置**并选择**清除本地数据**。清除本地数据会保留加密密钥，以便后续缓存的数据继续受到加密保护。卸载应用时，操作系统会按其正常卸载机制移除应用数据。

Android 应用仅请求 `INTERNET` 权限。网络通信使用 HTTPS，只有在 GitHub 发布文件的 URL 和 SHA-256 摘要通过 GitHub 发布元数据校验后，才会下载更新文件。这可检测错误或损坏的下载，但并非独立的发布者签名，因此发布来源遭到入侵的情况仍不在应用的信任保障范围内。汇率请求和更新检查不会主动包含个人数据。

## 资源

- 应用品牌资源存放在 `assets/branding/`，百科数据存放在 `assets/encyclopedia/`。
- 百科使用 `country_flags` 显示国家和地区旗帜。欧元使用欧盟旗帜。
- XAF、XCD、XCG、XOF 和 XPF 继续使用项目原创并随应用打包的圆形专用货币图标。
- 运行应用前，请确保 `pubspec.yaml` 中已声明相应资源。

百科中的国家旗帜使用 [`country_flags`](https://pub.dev/packages/country_flags) Flutter 包（MIT 许可证）。该包注明其内置的 SVG 旗帜图案来自 [`flag-icons`](https://github.com/lipis/flag-icons) 项目。

## 测试

- 运行单元测试和组件测试：

```powershell
flutter test
```

- 运行静态分析：

```powershell
flutter analyze
```

- 运行针对货币目录和换算的测试：

```powershell
flutter test test/widget/encyclopedia_locale_test.dart
flutter test test/integration/encyclopedia_flow_test.dart
flutter test test/unit/conversion_test.dart
flutter test test/widget/converter_history_test.dart
```

## 本地化说明

- 添加新文本时，先更新 `lib/l10n/app_en.arb`。
- 保持 `lib/l10n/app_zh_Hans.arb` 和 `lib/l10n/app_zh_Hant.arb` 的键集合与英语版本一致。
- `lib/l10n/app_zh.arb` 是 `zh` 语言区域系列的通用中文回退来源。
- `OpenFXpedia` 是产品名称，在所有语言中均保持不变。
- 修改 ARB 后，运行 `flutter gen-l10n` 重新生成纳入版本控制的本地化输出，然后运行 `dart format lib/l10n`。

启动界面由 Flutter 渲染，因此加载状态和启动错误可以使用所选语言显示。在 Windows 上，应用初始化期间会持续显示此 Flutter 启动界面；Android 则先显示原生启动画面，待 Flutter 就绪后将其移除。

## VS Code

- 仓库在 `.vscode.example/` 中提供 VS Code 配置示例；将该文件夹复制为 `.vscode/` 即可使用。本地 `.vscode/` 文件夹已加入 Git 忽略，个人设置不会被提交。
- 打开工作区根目录，然后通过“运行”视图在 Windows 或 Android 上启动应用。

## 故障排查

- 桌面构建失败：确认已启用 Windows 桌面支持，并安装了 Visual Studio 及 C++ 工作负载。
- 安装程序构建失败：确认已安装 NSIS，且 `makensis` 可通过 PATH 访问。
- Flutter 找不到设备：运行 `flutter doctor -v`，确认 Android SDK、模拟器或 Windows 桌面环境已正确配置。
- 依赖问题：运行 `flutter pub get`，并解决 pub 报告的错误。

## 参与贡献

- 为修改创建分支并提交 PR。项目设计背景和实现记录见 `specs/master`；该目录存放文档，不是当前使用的任务工作流。
- 添加或更新货币元数据时，请同步更新 `assets/data/fiat_currencies.json`，并在 `specs/master/data/` 中添加简短的验证说明。

## 许可证

- 本仓库采用 MIT 许可证（见 `LICENSE`）。

## 联系与致谢

- 维护者：项目团队（如有问题，请提交 GitHub issue 或 PR）。
- 数据来源：感谢 `@fawazahmed0/exchange-api` 项目和 `@fawazahmed0/currency-api` CDN。

---

**注意：** 添加品牌、旗帜或专用货币图标资源时，请保持 `pubspec.yaml` 与 `assets/` 同步。