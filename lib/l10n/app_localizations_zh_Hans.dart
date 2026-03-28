// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '外汇百科';

  @override
  String get settings_language => '语言';

  @override
  String get language_english => '英文';

  @override
  String get language_simplified_chinese => '简体中文';

  @override
  String get language_traditional_chinese => '繁体中文';

  @override
  String get converter_title => '转换器';

  @override
  String get encyclopedia_title => '百科';

  @override
  String get settings_title => '设置';

  @override
  String get settings_theme => '主题';

  @override
  String get settings_app_version => '应用版本';

  @override
  String get settings_check_updates => '检查更新';

  @override
  String get settings_changelogs => '更新日志';

  @override
  String get settings_changelogs_subtitle => '查看所有版本的简明变更记录';

  @override
  String get settings_license => '许可';

  @override
  String get settings_select_theme => '选择主题';

  @override
  String get settings_system => '系统';

  @override
  String get settings_light => '浅色';

  @override
  String get settings_dark => '深色';

  @override
  String get settings_language_dialog_title => '选择语言';

  @override
  String get settings_language_dialog_subtitle => '选择应用语言。';

  @override
  String get converter_currency_title => '货币转换器';

  @override
  String get converter_refresh_rates => '刷新汇率';

  @override
  String get converter_favorites => '收藏';

  @override
  String get converter_from => '从';

  @override
  String get converter_to => '到';

  @override
  String get converter_from_hint => '来源货币...';

  @override
  String get converter_to_hint => '目标货币...';

  @override
  String get converter_swap => '交换货币';

  @override
  String get converter_choose_pair => '请选择来源和目标货币以开始转换。';

  @override
  String get converter_choose_currencies => '选择货币';

  @override
  String get converter_currency_prompt => '要将这枚货币填入哪个字段？';

  @override
  String get converter_cancel => '取消';

  @override
  String get converter_from_field => '从';

  @override
  String get converter_to_field => '到';

  @override
  String get converter_continue => '继续';

  @override
  String get amount_label => '金额';

  @override
  String get encyclopedia_currency_title => '货币百科';

  @override
  String get encyclopedia_search => '搜索货币...';

  @override
  String get encyclopedia_not_found => '未找到货币。';

  @override
  String get favorites_add => '加入收藏';

  @override
  String get favorites_remove => '移出收藏';

  @override
  String get detail_cancel => '取消';

  @override
  String get detail_from_field => '从';

  @override
  String get detail_to_field => '到';

  @override
  String get detail_currency_prompt => '要将这枚货币填入哪个字段？';

  @override
  String get detail_remove_favorite => '移出收藏';

  @override
  String get detail_add_favorite => '加入收藏';

  @override
  String get detail_iso_code => 'ISO 代码';

  @override
  String get detail_name => '名称';

  @override
  String get detail_symbol => '符号';

  @override
  String get detail_regions => '地区';

  @override
  String get detail_description => '说明';

  @override
  String get detail_convert => '转换';

  @override
  String get update_available => '有可用更新';

  @override
  String get update_cancel => '取消';

  @override
  String get update_download => '下载';

  @override
  String get update_latest => '当前已是最新版本';

  @override
  String settings_latest_version(Object version) {
    return '您当前已是最新版本（$version）。';
  }

  @override
  String get rate_info_refreshing => '正在刷新汇率...';

  @override
  String get rate_info_cached => '缓存';

  @override
  String get rate_info_live => '实时';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');
}
