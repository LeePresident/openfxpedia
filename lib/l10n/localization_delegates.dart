import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

import 'app_localizations.dart';

const List<LocalizationsDelegate<dynamic>> appLocalizationDelegates = [
  ...AppLocalizations.localizationsDelegates,
  ...material_ui.GlobalMaterialLocalizations.delegates,
];
