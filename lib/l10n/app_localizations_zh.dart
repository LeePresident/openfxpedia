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
  String get settings_exchange_api_source => '汇率 API';

  @override
  String get settings_select_exchange_api_source => '选择汇率 API';

  @override
  String get settings_exchange_api_source_auto => '自动';

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
  String get converter_currency_prompt => '要将这枚货币填入哪个字段？';

  @override
  String get converter_cancel => '取消';

  @override
  String get converter_from_field => '从';

  @override
  String get converter_to_field => '到';

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
  String update_download_prompt(String version, String assetName) {
    return '已有 $version 版本可用。\n\n要从 GitHub Releases 下载适用于此设备的 $assetName 吗？';
  }

  @override
  String get update_latest_release_unavailable => '无法从 GitHub 判断最新的稳定版本。';

  @override
  String get update_asset_not_found => 'GitHub Releases 上找不到适用于此设备的发布文件。';

  @override
  String get update_open_download_failed => '无法打开 GitHub 发布下载链接。';

  @override
  String get update_direct_download_unsupported => '此设备不支持直接下载发布版本。';

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
  String get rate_info_source_prefix => '来源：';

  @override
  String get provider_frankfurter => 'Frankfurter';

  @override
  String get provider_exchange_api => 'Exchange API';

  @override
  String get rate_info_disclaimer => '汇率仅供参考，请以实际报价为准。';

  @override
  String get error_network_unavailable => '网络错误—无法连接到服务器。请检查您的网络连接后重试。';

  @override
  String get error_service_unavailable => '无法连接更新服务，请稍后再试。';

  @override
  String get error_generic => '发生错误，请重试。';

  @override
  String get pick => '选择';
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
  String get settings_exchange_api_source => '汇率 API';

  @override
  String get settings_select_exchange_api_source => '选择汇率 API';

  @override
  String get settings_exchange_api_source_auto => '自动';

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
  String get converter_currency_prompt => '要将这枚货币填入哪个字段？';

  @override
  String get converter_cancel => '取消';

  @override
  String get converter_from_field => '从';

  @override
  String get converter_to_field => '到';

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
  String update_download_prompt(String version, String assetName) {
    return '已有 $version 版本可用。\n\n要从 GitHub Releases 下载适用于此设备的 $assetName 吗？';
  }

  @override
  String get update_latest_release_unavailable => '无法从 GitHub 判断最新的稳定版本。';

  @override
  String get update_asset_not_found => 'GitHub Releases 上找不到适用于此设备的发布文件。';

  @override
  String get update_open_download_failed => '无法打开 GitHub 发布下载链接。';

  @override
  String get update_direct_download_unsupported => '此设备不支持直接下载发布版本。';

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
  String get rate_info_source_prefix => '来源：';

  @override
  String get provider_frankfurter => 'Frankfurter';

  @override
  String get provider_exchange_api => 'Exchange API';

  @override
  String get rate_info_disclaimer => '汇率仅供参考，请以实际报价为准。';

  @override
  String get error_network_unavailable => '网络错误—无法连接到服务器。请检查您的网络连接后重试。';

  @override
  String get error_service_unavailable => '无法连接更新服务，请稍后再试。';

  @override
  String get error_generic => '发生错误，请重试。';

  @override
  String get pick => '选择';
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
  String get settings_exchange_api_source => '匯率 API';

  @override
  String get settings_select_exchange_api_source => '選擇匯率 API';

  @override
  String get settings_exchange_api_source_auto => '自動';

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
  String get converter_currency_prompt => '要將這個貨幣填入哪個欄位？';

  @override
  String get converter_cancel => '取消';

  @override
  String get converter_from_field => '從';

  @override
  String get converter_to_field => '到';

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
  String update_download_prompt(String version, String assetName) {
    return '已有 $version 版本可用。\n\n要從 GitHub Releases 下載適用於此裝置的 $assetName 嗎？';
  }

  @override
  String get update_latest_release_unavailable => '無法從 GitHub 判斷最新的穩定版本。';

  @override
  String get update_asset_not_found => 'GitHub Releases 上找不到適用於此裝置的發行檔案。';

  @override
  String get update_open_download_failed => '無法開啟 GitHub 發行下載連結。';

  @override
  String get update_direct_download_unsupported => '此裝置不支援直接下載發行版本。';

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
  String get rate_info_source_prefix => '來源：';

  @override
  String get provider_frankfurter => 'Frankfurter';

  @override
  String get provider_exchange_api => 'Exchange API';

  @override
  String get rate_info_disclaimer => '匯率僅供參考，請以實際報價為準。';

  @override
  String get error_network_unavailable => '網絡錯誤—無法連線到伺服器。請檢查您的網路連線後重試。';

  @override
  String get error_service_unavailable => '無法連線更新服務，請稍後再試。';

  @override
  String get error_generic => '發生錯誤，請重試。';

  @override
  String get pick => '選擇';
}
