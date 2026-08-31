import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _syncAdThemeMode();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _syncAdThemeMode();
    notifyListeners();
  }

  void _syncAdThemeMode() {
    final adMode = _themeMode == ThemeMode.dark
        ? AdThemeMode.dark
        : (_themeMode == ThemeMode.light ? AdThemeMode.light : AdThemeMode.system);
    PreloadGoogleAds.instance.setThemeMode(adMode);
  }
}
