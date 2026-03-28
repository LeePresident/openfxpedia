// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_zh_Hans.dart';

// ignore_for_file: type=lint

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
  String get settings_changelogs => '更新日誌';

  @override
  String get settings_changelogs_subtitle => '查看所有版本的簡明變更記錄';

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
  String get converter_refresh_rates => '重新整理匯率';

  @override
  String get converter_favorites => '收藏';

  @override
  String get converter_from => '從';

  @override
  String get converter_to => '到';

  @override
  String get converter_from_hint => '來源貨幣...';

  @override
  String get converter_to_hint => '目標貨幣...';

  @override
  String get converter_swap => '交換貨幣';

  @override
  String get converter_choose_pair => '請選擇來源與目標貨幣以開始轉換。';

  @override
  String get converter_choose_currencies => '選擇貨幣';

  @override
  String get converter_currency_prompt => '要將這個幣別填入哪個欄位？';

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
  String get encyclopedia_search => '搜尋貨幣...';

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
  String get detail_currency_prompt => '要將這個幣別填入哪個欄位？';

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
  String get detail_description => '說明';

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
  String settings_latest_version(Object version) {
    return '您目前已是最新版本（$version）。';
  }

  @override
  String get rate_info_refreshing => '正在重新整理匯率...';

  @override
  String get rate_info_cached => '快取';

  @override
  String get rate_info_live => '即時';
}
