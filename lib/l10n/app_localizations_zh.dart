// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get history_title => '历史汇率';

  @override
  String get history_week => '1周';

  @override
  String get history_month => '1月';

  @override
  String get history_quarter => '3月';

  @override
  String get history_unavailable => '此时间范围内没有可用的历史汇率。请尝试其他日期或汇率来源。';

  @override
  String history_available(int available, int total) {
    return '采样报价：$available/$total';
  }

  @override
  String get converter_date => '换算日期';

  @override
  String get converter_latest => '最新';

  @override
  String get converter_use_latest => '使用最新汇率';

  @override
  String get error_historical_unavailable =>
      '无法加载此货币对和日期的历史汇率。请检查网络连接，或尝试其他日期或汇率来源。';

  @override
  String rate_info_requested_date(String date) {
    return '所选日期：$date';
  }

  @override
  String rate_info_effective_date(String date) {
    return '汇率日期：$date';
  }

  @override
  String get appTitle => 'OpenFXpedia';

  @override
  String get startup_loading => '正在加载货币和缓存汇率';

  @override
  String get startup_error_title => '启动失败';

  @override
  String get settings_language => '语言';

  @override
  String get clear_search => '清除搜索';

  @override
  String get language_english => '英文';

  @override
  String get language_simplified_chinese => '简体中文';

  @override
  String get language_traditional_chinese => '繁体中文';

  @override
  String get converter_title => '转换器';

  @override
  String get calculator_title => '计算器';

  @override
  String get calculator_amount => '金额';

  @override
  String get calculator_currency => '货币';

  @override
  String get calculator_result_currency => '结果货币';

  @override
  String get calculator_total => '总计';

  @override
  String get calculator_add_entry => '添加金额';

  @override
  String get calculator_remove_entry => '移除金额';

  @override
  String calculator_entry(int number) {
    return '金额 $number';
  }

  @override
  String get calculator_no_entries => '添加金额以计算总计。';

  @override
  String get calculator_date => '汇率日期';

  @override
  String get calculator_latest => '最新汇率';

  @override
  String get calculator_use_latest => '使用最新汇率';

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
  String get settings_license => '许可证';

  @override
  String get settings_privacy => '隐私声明';

  @override
  String get privacy_statement_no_account =>
      'OpenFXpedia 无需注册账号，不会收集姓名、电子邮件地址、付款信息、联系人、位置、相机、麦克风或广告标识符。应用不包含分析、广告、崩溃报告或用户追踪 SDK。';

  @override
  String get privacy_statement_network =>
      '应用通过 HTTPS 向已配置的汇率和货币目录提供方发送请求。这些请求会包含获取汇率和目录数据所需的所选货币代码。你检查更新时，应用也会连接到 OpenFXpedia 的 GitHub 仓库。外部提供方和 GitHub 可能会根据各自的隐私政策接收 IP 地址等常规连接元数据。';

  @override
  String get privacy_statement_local_storage =>
      '汇率和货币目录数据会缓存在本地以供离线使用。收藏和应用偏好设置也保存在本地。这些 Hive 数据盒使用随机生成的密钥加密，密钥存放在应用支持目录中。加密可防止存储的数据被随意查看，但密钥存储在本地而非硬件支持的安全保险库中，因此无法保护已遭入侵或被攻击者解锁的设备上的数据。';

  @override
  String get privacy_statement_data_deletion =>
      '如需删除本地存储的汇率、目录数据、收藏和偏好设置，请打开“设置”并选择“清除本地数据”。清除本地数据会保留加密密钥，使之后缓存的数据仍可加密。卸载应用时，操作系统会按照正常的卸载流程移除应用数据。';

  @override
  String get privacy_statement_android =>
      'Android 应用仅请求 INTERNET 权限。网络通信使用 HTTPS；只有在 GitHub 发布文件的 URL 和 SHA-256 摘要经过 GitHub 发布元数据验证后，才会下载更新文件。这可以检测错误或损坏的下载，但并非独立的发布者签名，因此发布源遭到入侵的情形不在应用的信任保障范围内。汇率请求和更新检查不会主动包含个人数据。';

  @override
  String get settings_clear_local_data => '清除本地数据';

  @override
  String get settings_clear_local_data_subtitle => '删除缓存汇率、货币目录、收藏和偏好设置';

  @override
  String get settings_clear_local_data_title => '清除本地数据？';

  @override
  String get settings_clear_local_data_message => '这将从此设备删除缓存汇率、货币目录、收藏和偏好设置。';

  @override
  String get settings_clear_local_data_confirm => '清除数据';

  @override
  String get settings_clear_local_data_done => '本地数据已清除';

  @override
  String get settings_clear_local_data_failed => '无法清除本地数据';

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
  String get converter_currency_prompt => '将此货币设为来源货币还是目标货币？';

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
  String get encyclopedia_sort => '排序货币';

  @override
  String get encyclopedia_sort_code_ascending => '代码（A-Z）';

  @override
  String get encyclopedia_sort_code_descending => '代码（Z-A）';

  @override
  String get encyclopedia_sort_name_ascending => '名称（A-Z）';

  @override
  String get encyclopedia_sort_name_descending => '名称（Z-A）';

  @override
  String get encyclopedia_favorites_only => '仅显示收藏';

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
  String get detail_currency_prompt => '将此货币设为来源货币还是目标货币？';

  @override
  String get detail_remove_favorite => '移出收藏';

  @override
  String get detail_add_favorite => '加入收藏';

  @override
  String get detail_iso_code => 'ISO 代码';

  @override
  String get detail_iso_numeric => 'ISO 数字代码';

  @override
  String get detail_name => '名称';

  @override
  String get detail_symbol => '符号';

  @override
  String get detail_regions => '地区';

  @override
  String get detail_show_more_regions => '显示更多';

  @override
  String get detail_show_less_regions => '收起';

  @override
  String get detail_description => '说明';

  @override
  String get detail_coins => '硬币';

  @override
  String get detail_banknotes => '纸币';

  @override
  String get detail_units => '货币单位';

  @override
  String detail_unit_summary(String majorUnit, String minorUnit, int ratio) {
    return '$majorUnit / $minorUnit（1:$ratio）';
  }

  @override
  String detail_unit_summary_no_minor(String majorUnit) {
    return '$majorUnit（无辅币单位）';
  }

  @override
  String get detail_pab_no_banknotes => '巴波亚不设纸币；使用美元纸币';

  @override
  String get detail_sos_no_coins => '索马里先令硬币目前已不再流通';

  @override
  String get detail_vnd_no_coins => '越南盾硬币目前已不再流通';

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
    return '新版本 $version 已发布。\n\n要从 GitHub Releases 下载适用于此设备的 $assetName 吗？';
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
  String get rate_info_live => '在线';

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
  String get error_service_unavailable => '无法连接远程服务，请稍后再试。';

  @override
  String get error_generic => '发生错误，请重试。';

  @override
  String get pick => '选择';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get history_title => '历史汇率';

  @override
  String get history_week => '1周';

  @override
  String get history_month => '1月';

  @override
  String get history_quarter => '3月';

  @override
  String get history_unavailable => '此时间范围内没有可用的历史汇率。请尝试其他日期或汇率来源。';

  @override
  String history_available(int available, int total) {
    return '采样报价：$available/$total';
  }

  @override
  String get converter_date => '换算日期';

  @override
  String get converter_latest => '最新';

  @override
  String get converter_use_latest => '使用最新汇率';

  @override
  String get error_historical_unavailable =>
      '无法加载此货币对和日期的历史汇率。请检查网络连接，或尝试其他日期或汇率来源。';

  @override
  String rate_info_requested_date(String date) {
    return '所选日期：$date';
  }

  @override
  String rate_info_effective_date(String date) {
    return '汇率日期：$date';
  }

  @override
  String get appTitle => 'OpenFXpedia';

  @override
  String get startup_loading => '正在加载货币和缓存汇率';

  @override
  String get startup_error_title => '启动失败';

  @override
  String get settings_language => '语言';

  @override
  String get clear_search => '清除搜索';

  @override
  String get language_english => '英文';

  @override
  String get language_simplified_chinese => '简体中文';

  @override
  String get language_traditional_chinese => '繁体中文';

  @override
  String get converter_title => '转换器';

  @override
  String get calculator_title => '计算器';

  @override
  String get calculator_amount => '金额';

  @override
  String get calculator_currency => '货币';

  @override
  String get calculator_result_currency => '结果货币';

  @override
  String get calculator_total => '总计';

  @override
  String get calculator_add_entry => '添加金额';

  @override
  String get calculator_remove_entry => '移除金额';

  @override
  String calculator_entry(int number) {
    return '金额 $number';
  }

  @override
  String get calculator_no_entries => '添加金额以计算总计。';

  @override
  String get calculator_date => '汇率日期';

  @override
  String get calculator_latest => '最新汇率';

  @override
  String get calculator_use_latest => '使用最新汇率';

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
  String get settings_license => '许可证';

  @override
  String get settings_privacy => '隐私声明';

  @override
  String get privacy_statement_no_account =>
      'OpenFXpedia 无需注册账号，不会收集姓名、电子邮件地址、付款信息、联系人、位置、相机、麦克风或广告标识符。应用不包含分析、广告、崩溃报告或用户追踪 SDK。';

  @override
  String get privacy_statement_network =>
      '应用通过 HTTPS 向已配置的汇率和货币目录提供方发送请求。这些请求会包含获取汇率和目录数据所需的所选货币代码。你检查更新时，应用也会连接到 OpenFXpedia 的 GitHub 仓库。外部提供方和 GitHub 可能会根据各自的隐私政策接收 IP 地址等常规连接元数据。';

  @override
  String get privacy_statement_local_storage =>
      '汇率和货币目录数据会缓存在本地以供离线使用。收藏和应用偏好设置也保存在本地。这些 Hive 数据盒使用随机生成的密钥加密，密钥存放在应用支持目录中。加密可防止存储的数据被随意查看，但密钥存储在本地而非硬件支持的安全保险库中，因此无法保护已遭入侵或被攻击者解锁的设备上的数据。';

  @override
  String get privacy_statement_data_deletion =>
      '如需删除本地存储的汇率、目录数据、收藏和偏好设置，请打开“设置”并选择“清除本地数据”。清除本地数据会保留加密密钥，使之后缓存的数据仍可加密。卸载应用时，操作系统会按照正常的卸载流程移除应用数据。';

  @override
  String get privacy_statement_android =>
      'Android 应用仅请求 INTERNET 权限。网络通信使用 HTTPS；只有在 GitHub 发布文件的 URL 和 SHA-256 摘要经过 GitHub 发布元数据验证后，才会下载更新文件。这可以检测错误或损坏的下载，但并非独立的发布者签名，因此发布源遭到入侵的情形不在应用的信任保障范围内。汇率请求和更新检查不会主动包含个人数据。';

  @override
  String get settings_clear_local_data => '清除本地数据';

  @override
  String get settings_clear_local_data_subtitle => '删除缓存汇率、货币目录、收藏和偏好设置';

  @override
  String get settings_clear_local_data_title => '清除本地数据？';

  @override
  String get settings_clear_local_data_message => '这将从此设备删除缓存汇率、货币目录、收藏和偏好设置。';

  @override
  String get settings_clear_local_data_confirm => '清除数据';

  @override
  String get settings_clear_local_data_done => '本地数据已清除';

  @override
  String get settings_clear_local_data_failed => '无法清除本地数据';

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
  String get converter_currency_prompt => '将此货币设为来源货币还是目标货币？';

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
  String get encyclopedia_sort => '排序货币';

  @override
  String get encyclopedia_sort_code_ascending => '代码（A-Z）';

  @override
  String get encyclopedia_sort_code_descending => '代码（Z-A）';

  @override
  String get encyclopedia_sort_name_ascending => '名称（A-Z）';

  @override
  String get encyclopedia_sort_name_descending => '名称（Z-A）';

  @override
  String get encyclopedia_favorites_only => '仅显示收藏';

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
  String get detail_currency_prompt => '将此货币设为来源货币还是目标货币？';

  @override
  String get detail_remove_favorite => '移出收藏';

  @override
  String get detail_add_favorite => '加入收藏';

  @override
  String get detail_iso_code => 'ISO 代码';

  @override
  String get detail_iso_numeric => 'ISO 数字代码';

  @override
  String get detail_name => '名称';

  @override
  String get detail_symbol => '符号';

  @override
  String get detail_regions => '地区';

  @override
  String get detail_show_more_regions => '显示更多';

  @override
  String get detail_show_less_regions => '收起';

  @override
  String get detail_description => '说明';

  @override
  String get detail_coins => '硬币';

  @override
  String get detail_banknotes => '纸币';

  @override
  String get detail_units => '货币单位';

  @override
  String detail_unit_summary(String majorUnit, String minorUnit, int ratio) {
    return '$majorUnit / $minorUnit（1:$ratio）';
  }

  @override
  String detail_unit_summary_no_minor(String majorUnit) {
    return '$majorUnit（无辅币单位）';
  }

  @override
  String get detail_pab_no_banknotes => '巴波亚不设纸币；使用美元纸币';

  @override
  String get detail_sos_no_coins => '索马里先令硬币目前已不再流通';

  @override
  String get detail_vnd_no_coins => '越南盾硬币目前已不再流通';

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
    return '新版本 $version 已发布。\n\n要从 GitHub Releases 下载适用于此设备的 $assetName 吗？';
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
  String get rate_info_live => '在线';

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
  String get error_service_unavailable => '无法连接远程服务，请稍后再试。';

  @override
  String get error_generic => '发生错误，请重试。';

  @override
  String get pick => '选择';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get history_title => '歷史匯率';

  @override
  String get history_week => '1週';

  @override
  String get history_month => '1月';

  @override
  String get history_quarter => '3月';

  @override
  String get history_unavailable => '此時間範圍內沒有可用的歷史匯率。請嘗試其他日期或匯率來源。';

  @override
  String history_available(int available, int total) {
    return '抽樣報價：$available/$total';
  }

  @override
  String get converter_date => '換算日期';

  @override
  String get converter_latest => '最新';

  @override
  String get converter_use_latest => '使用最新匯率';

  @override
  String get error_historical_unavailable =>
      '無法載入此貨幣對和日期的歷史匯率。請檢查網絡連線，或嘗試其他日期或匯率來源。';

  @override
  String rate_info_requested_date(String date) {
    return '所選日期：$date';
  }

  @override
  String rate_info_effective_date(String date) {
    return '匯率日期：$date';
  }

  @override
  String get appTitle => 'OpenFXpedia';

  @override
  String get startup_loading => '正在載入貨幣和緩存匯率';

  @override
  String get startup_error_title => '啟動失敗';

  @override
  String get settings_language => '語言';

  @override
  String get clear_search => '清除搜尋';

  @override
  String get language_english => '英文';

  @override
  String get language_simplified_chinese => '簡體中文';

  @override
  String get language_traditional_chinese => '繁體中文';

  @override
  String get converter_title => '轉換器';

  @override
  String get calculator_title => '計算機';

  @override
  String get calculator_amount => '金額';

  @override
  String get calculator_currency => '貨幣';

  @override
  String get calculator_result_currency => '結果貨幣';

  @override
  String get calculator_total => '總計';

  @override
  String get calculator_add_entry => '新增金額';

  @override
  String get calculator_remove_entry => '移除金額';

  @override
  String calculator_entry(int number) {
    return '金額 $number';
  }

  @override
  String get calculator_no_entries => '新增金額以計算總計。';

  @override
  String get calculator_date => '匯率日期';

  @override
  String get calculator_latest => '最新匯率';

  @override
  String get calculator_use_latest => '使用最新匯率';

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
  String get settings_license => '許可證';

  @override
  String get settings_privacy => '隱私權聲明';

  @override
  String get privacy_statement_no_account =>
      'OpenFXpedia 無需註冊帳號，不會收集姓名、電子郵件地址、付款資訊、聯絡人、位置、相機、麥克風或廣告識別碼。應用程式不包含分析、廣告、當機回報或使用者追蹤 SDK。';

  @override
  String get privacy_statement_network =>
      '應用程式透過 HTTPS 向已設定的匯率和貨幣目錄提供者傳送請求。這些請求包含取得匯率和目錄資料所需的所選貨幣代碼。使用者檢查更新時，應用程式也會連線至 OpenFXpedia 的 GitHub 儲存庫。外部提供者和 GitHub 可能會依據各自的隱私權政策接收 IP 位址等一般連線中繼資料。';

  @override
  String get privacy_statement_local_storage =>
      '匯率和貨幣目錄資料會快取於本機供離線使用。收藏和應用程式偏好設定也儲存在本機。這些 Hive 資料儲存盒使用隨機產生的金鑰加密，金鑰存放在應用程式支援目錄中。加密可防止儲存資料被隨意查看，但金鑰儲存在本機而非硬體支援的安全儲存空間中，因此無法保護已遭入侵或被攻擊者解鎖的裝置上的資料。';

  @override
  String get privacy_statement_data_deletion =>
      '若要刪除本機儲存的匯率、目錄資料、收藏和偏好設定，請開啟「設定」並選擇「清除本機資料」。清除本機資料會保留加密金鑰，讓之後快取的資料繼續受到加密保護。解除安裝應用程式時，作業系統會依其正常解除安裝機制移除應用程式資料。';

  @override
  String get privacy_statement_android =>
      'Android 應用程式僅要求 INTERNET 權限。網路通訊使用 HTTPS，只有在 GitHub 發行檔案的 URL 和 SHA-256 摘要通過 GitHub 發行中繼資料驗證後，才會下載更新檔案。這可偵測錯誤或損壞的下載，但並非獨立的發行者簽章，因此發行來源遭到入侵的情況仍不在應用程式的信任保障範圍內。匯率請求和更新檢查不會主動包含個人資料。';

  @override
  String get settings_clear_local_data => '清除本地資料';

  @override
  String get settings_clear_local_data_subtitle => '刪除緩存匯率、貨幣目錄、收藏和偏好設定';

  @override
  String get settings_clear_local_data_title => '清除本地資料？';

  @override
  String get settings_clear_local_data_message => '這將從此裝置刪除緩存匯率、貨幣目錄、收藏和偏好設定。';

  @override
  String get settings_clear_local_data_confirm => '清除資料';

  @override
  String get settings_clear_local_data_done => '本地資料已清除';

  @override
  String get settings_clear_local_data_failed => '無法清除本地資料';

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
  String get converter_currency_prompt => '要將此貨幣設為來源貨幣還是目標貨幣？';

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
  String get encyclopedia_sort => '排序貨幣';

  @override
  String get encyclopedia_sort_code_ascending => '代碼（A-Z）';

  @override
  String get encyclopedia_sort_code_descending => '代碼（Z-A）';

  @override
  String get encyclopedia_sort_name_ascending => '名稱（A-Z）';

  @override
  String get encyclopedia_sort_name_descending => '名稱（Z-A）';

  @override
  String get encyclopedia_favorites_only => '僅顯示收藏';

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
  String get detail_currency_prompt => '要將此貨幣設為來源貨幣還是目標貨幣？';

  @override
  String get detail_remove_favorite => '移出收藏';

  @override
  String get detail_add_favorite => '加入收藏';

  @override
  String get detail_iso_code => 'ISO 代碼';

  @override
  String get detail_iso_numeric => 'ISO 數字代碼';

  @override
  String get detail_name => '名稱';

  @override
  String get detail_symbol => '符號';

  @override
  String get detail_regions => '地區';

  @override
  String get detail_show_more_regions => '顯示更多';

  @override
  String get detail_show_less_regions => '收起';

  @override
  String get detail_description => '簡介';

  @override
  String get detail_coins => '硬幣';

  @override
  String get detail_banknotes => '紙幣';

  @override
  String get detail_units => '貨幣單位';

  @override
  String detail_unit_summary(String majorUnit, String minorUnit, int ratio) {
    return '$majorUnit / $minorUnit（1:$ratio）';
  }

  @override
  String detail_unit_summary_no_minor(String majorUnit) {
    return '$majorUnit（無輔幣單位）';
  }

  @override
  String get detail_pab_no_banknotes => '巴波亞不設紙幣；使用美元紙幣';

  @override
  String get detail_sos_no_coins => '索馬里先令硬幣目前已不再流通';

  @override
  String get detail_vnd_no_coins => '越南盾硬幣目前已不再流通';

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
    return '新版本 $version 已發布。\n\n要從 GitHub Releases 下載適用於此裝置的 $assetName 嗎？';
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
  String get rate_info_cached => '緩存';

  @override
  String get rate_info_live => '在線';

  @override
  String get rate_info_source_prefix => '來源：';

  @override
  String get provider_frankfurter => 'Frankfurter';

  @override
  String get provider_exchange_api => 'Exchange API';

  @override
  String get rate_info_disclaimer => '匯率僅供參考，請以實際報價為準。';

  @override
  String get error_network_unavailable => '網絡錯誤，無法連接至服務器。請檢查您的網絡連接後重試。';

  @override
  String get error_service_unavailable => '無法連接至遠端服務，請稍後再試。';

  @override
  String get error_generic => '發生錯誤，請重試。';

  @override
  String get pick => '選擇';
}
