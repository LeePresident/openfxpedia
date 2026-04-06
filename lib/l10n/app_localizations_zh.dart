// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'OpenFXpedia';

  @override
  String get settings_language => 'Language';

  @override
  String get language_english => 'English';

  @override
  String get language_simplified_chinese => 'Simplified Chinese';

  @override
  String get language_traditional_chinese => 'Traditional Chinese';

  @override
  String get converter_title => 'Converter';

  @override
  String get encyclopedia_title => 'Encyclopedia';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_check_updates => 'Check updates';

  @override
  String get settings_changelogs => 'Changelogs';

  @override
  String get settings_changelogs_subtitle =>
      'View concise changelogs for all versions';

  @override
  String get settings_license => 'License';

  @override
  String get settings_select_theme => 'Select theme';

  @override
  String get settings_system => 'System';

  @override
  String get settings_light => 'Light';

  @override
  String get settings_dark => 'Dark';

  @override
  String get settings_language_dialog_title => 'Select language';

  @override
  String get settings_language_dialog_subtitle => 'Choose the app language.';

  @override
  String get converter_currency_title => 'Currency Converter';

  @override
  String get converter_refresh_rates => 'Refresh rates';

  @override
  String get converter_favorites => 'Favorites';

  @override
  String get converter_from => 'From';

  @override
  String get converter_to => 'To';

  @override
  String get converter_from_hint => 'From currency…';

  @override
  String get converter_to_hint => 'To currency…';

  @override
  String get converter_swap => 'Swap currencies';

  @override
  String get converter_choose_pair =>
      'Choose a from and to currency to begin converting.';

  @override
  String get converter_choose_currencies => 'Choose your currencies';

  @override
  String get converter_currency_prompt =>
      'Which field should be filled with this currency?';

  @override
  String get converter_cancel => 'Cancel';

  @override
  String get converter_from_field => 'From';

  @override
  String get converter_to_field => 'To';

  @override
  String get converter_continue => 'Continue';

  @override
  String get amount_label => 'Amount';

  @override
  String get encyclopedia_currency_title => 'Currency Encyclopedia';

  @override
  String get encyclopedia_search => 'Search currencies…';

  @override
  String get encyclopedia_not_found => 'No currencies found.';

  @override
  String get favorites_add => 'Add to favorites';

  @override
  String get favorites_remove => 'Remove from favorites';

  @override
  String get detail_cancel => 'Cancel';

  @override
  String get detail_from_field => 'From';

  @override
  String get detail_to_field => 'To';

  @override
  String get detail_currency_prompt =>
      'Which field should be filled with this currency?';

  @override
  String get detail_remove_favorite => 'Remove favorite';

  @override
  String get detail_add_favorite => 'Add to favorites';

  @override
  String get detail_iso_code => 'ISO Code';

  @override
  String get detail_name => 'Name';

  @override
  String get detail_symbol => 'Symbol';

  @override
  String get detail_regions => 'Regions';

  @override
  String get detail_description => 'Description';

  @override
  String get detail_convert => 'Convert';

  @override
  String get update_available => 'Update available';

  @override
  String get update_cancel => 'Cancel';

  @override
  String get update_download => 'Download';

  @override
  String get update_latest => 'You are on the latest version';

  @override
  String settings_latest_version(String version) {
    return 'You are on the latest version ($version).';
  }

  @override
  String get rate_info_refreshing => 'Refreshing rates…';

  @override
  String get rate_info_cached => 'cached';

  @override
  String get rate_info_live => 'live';

  @override
  String get rate_info_disclaimer => 'Exchange rates are for reference only.';

  @override
  String get error_network_unavailable =>
      'Network error—unable to connect to the server. Please check your internet connection and try again.';

  @override
  String get error_service_unavailable =>
      'Unable to connect to the update service. Please try again later.';

  @override
  String get error_generic => 'An error occurred. Please try again.';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

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
  String get settings_system => '跟随系统';

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
  String get converter_from_hint => '来源货币…';

  @override
  String get converter_to_hint => '目标货币…';

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
  String get encyclopedia_search => '搜索货币…';

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
  String settings_latest_version(String version) {
    return '您当前已是最新版本（$version）。';
  }

  @override
  String get rate_info_refreshing => '正在刷新汇率…';

  @override
  String get rate_info_cached => '缓存';

  @override
  String get rate_info_live => '实时';

  @override
  String get rate_info_disclaimer => '汇率仅供参考，请以实际报价为准。';

  @override
  String get error_network_unavailable => '网络错误—无法连接到服务器。请检查您的网络连接后重试。';

  @override
  String get error_service_unavailable => '无法连接更新服务，请稍后再试。';

  @override
  String get error_generic => '发生错误，请重试。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '外匯百科';

  @override
  String get settings_language => '語言';

  @override
  String get language_english => '英文';

  @override
  String get language_simplified_chinese => '簡體中文';

  @override
  String get language_traditional_chinese => '繁體中文';

  @override
  String get converter_title => '轉換器';

  @override
  String get encyclopedia_title => '百科';

  @override
  String get settings_title => '設定';

  @override
  String get settings_theme => '主題';

  @override
  String get settings_app_version => '應用程式版本';

  @override
  String get settings_check_updates => '檢查更新';

  @override
  String get settings_changelogs => '更新紀錄';

  @override
  String get settings_changelogs_subtitle => '查看所有版本的簡短更新紀錄';

  @override
  String get settings_license => '授權';

  @override
  String get settings_select_theme => '選擇主題';

  @override
  String get settings_system => '跟隨系統';

  @override
  String get settings_light => '淺色';

  @override
  String get settings_dark => '深色';

  @override
  String get settings_language_dialog_title => '選擇語言';

  @override
  String get settings_language_dialog_subtitle => '選擇應用程式語言。';

  @override
  String get converter_currency_title => '貨幣轉換器';

  @override
  String get converter_refresh_rates => '更新匯率';

  @override
  String get converter_favorites => '收藏';

  @override
  String get converter_from => '從';

  @override
  String get converter_to => '到';

  @override
  String get converter_from_hint => '來源貨幣…';

  @override
  String get converter_to_hint => '目標貨幣…';

  @override
  String get converter_swap => '交換貨幣';

  @override
  String get converter_choose_pair => '請選擇來源與目標貨幣以開始轉換。';

  @override
  String get converter_choose_currencies => '選擇貨幣';

  @override
  String get converter_currency_prompt => '要將這個貨幣填入哪個欄位？';

  @override
  String get converter_cancel => '取消';

  @override
  String get converter_from_field => '從';

  @override
  String get converter_to_field => '到';

  @override
  String get converter_continue => '繼續';

  @override
  String get amount_label => '金額';

  @override
  String get encyclopedia_currency_title => '貨幣百科';

  @override
  String get encyclopedia_search => '搜尋貨幣…';

  @override
  String get encyclopedia_not_found => '找不到貨幣。';

  @override
  String get favorites_add => '加入收藏';

  @override
  String get favorites_remove => '移出收藏';

  @override
  String get detail_cancel => '取消';

  @override
  String get detail_from_field => '從';

  @override
  String get detail_to_field => '到';

  @override
  String get detail_currency_prompt => '要將這個貨幣填入哪個欄位？';

  @override
  String get detail_remove_favorite => '移出收藏';

  @override
  String get detail_add_favorite => '加入收藏';

  @override
  String get detail_iso_code => 'ISO 代碼';

  @override
  String get detail_name => '名稱';

  @override
  String get detail_symbol => '符號';

  @override
  String get detail_regions => '地區';

  @override
  String get detail_description => '簡介';

  @override
  String get detail_convert => '轉換';

  @override
  String get update_available => '有可用更新';

  @override
  String get update_cancel => '取消';

  @override
  String get update_download => '下載';

  @override
  String get update_latest => '目前已是最新版本';

  @override
  String settings_latest_version(String version) {
    return '您目前已是最新版本（$version）。';
  }

  @override
  String get rate_info_refreshing => '正在更新匯率…';

  @override
  String get rate_info_cached => '快取';

  @override
  String get rate_info_live => '即時';

  @override
  String get rate_info_disclaimer => '匯率僅供參考，請以實際報價為準。';

  @override
  String get error_network_unavailable => '網絡錯誤—無法連線到伺服器。請檢查您的網路連線後重試。';

  @override
  String get error_service_unavailable => '無法連線更新服務，請稍後再試。';

  @override
  String get error_generic => '發生錯誤，請重試。';
}
