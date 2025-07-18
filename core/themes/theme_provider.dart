import 'package:flutter/material.dart';
import '../../services/shared_prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    _isDarkMode = SharedPrefsService.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await SharedPrefsService.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    await SharedPrefsService.setThemeMode(isDarkMode);
    notifyListeners();
  }
}
