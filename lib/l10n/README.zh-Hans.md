# 本地化支持

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

本项目在 `lib/main.dart` 中启用 Flutter 本地化委托，目前声明支持以下语言区域：
- `en`（英语）
- `zh`（繁体中文回退）
- `zh_Hans`（简体中文）
- `zh_Hant`（繁体中文，采用香港用语）

本地化文本由 `lib/l10n/app_localizations.dart` 提供统一入口，ARB 源文件位于本目录中。
纳入版本控制的生成实现文件为 `app_localizations_en.dart` 和 `app_localizations_zh.dart`；后者包含通用 `zh`、简体中文和繁体中文的实现。

后续扩展翻译时：
1. 先在 `app_en.arb` 中添加新键，再同步其他受支持语言的 ARB 文件。引入新语言区域时，添加相应的 ARB 文件。
2. 在仓库根目录运行 `flutter gen-l10n`，然后运行 `dart format lib/l10n`，重新生成并格式化纳入版本控制的本地化输出。请勿手动编辑生成的 Dart 文件。
3. 逐步将硬编码文本替换为本地化消息调用。

说明：
- `app_zh.arb` 是通用中文回退源文件，用于设备报告的语言区域为 `zh` 且不带文字代码的情况。
- `app_localizations_zh.dart` 包含通用中文回退实现，以及区分简繁体的中文实现。
- `app_zh_Hans.arb` 是简体中文源文件。
- `app_zh_Hant.arb` 是繁体中文源文件。