
import 'package:flutter/cupertino.dart';

import '../l10n.dart';

enum ThemeType { auto, light, dark, black }

ThemeType themeFromString(String? type) {
  if (type == null) return ThemeType.auto;
  switch (type) {
    case "auto":
      return ThemeType.auto;
    case "light":
      return ThemeType.light;
    case "dark":
      return ThemeType.dark;
    case "black":
      return ThemeType.black;
    default:
      return ThemeType.auto;
  }
}

extension ThemeTypeStr on ThemeType? {
  String? get stringify {
    switch (this) {
      case ThemeType.auto:
        return "auto";
      case ThemeType.light:
        return "light";
      case ThemeType.dark:
        return "dark";
      case ThemeType.black:
        return "black";
      default:
        return null;
    }
  }

  String? display(BuildContext context) {
    switch (this) {
      case ThemeType.auto:
        return L10N.of(context).tr.auto;
      case ThemeType.light:
        return L10N.of(context).tr.light;
      case ThemeType.dark:
        return L10N.of(context).tr.dark;
      case ThemeType.black:
        return L10N.of(context).tr.black;
      default:
        return null;
    }
  }
}
