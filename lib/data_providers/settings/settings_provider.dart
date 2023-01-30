
import 'package:flutter/widgets.dart';

import '../../models/theme_type.dart';

abstract class SettingsProvider {
  bool? getBool(String key);
  Future<void> setBool(String key, bool? value);
  int? getInt(String key);
  Future<void> setInt(String key, int value);

  ThemeType? getTheme();
  void setTheme(ThemeType? theme);

  Locale? getLocale();
  void setLocale(Locale? locale);
}
