import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SharedPrefsService {
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _themeKey = 'theme_mode';
  static const String _notificationKey = 'notification_enabled';
  static const String _dailyLogReminderKey = 'daily_log_reminder';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Data
  static Future<bool> saveUserData(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    return await _prefs?.setString(_userKey, jsonString) ?? false;
  }

  static UserModel? getUserData() {
    final jsonString = _prefs?.getString(_userKey);
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return UserModel.fromJson(jsonMap);
    }
    return null;
  }

  // Onboarding Status
  static Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs?.setBool(_onboardingKey, completed) ?? false;
  }

  static bool isOnboardingCompleted() {
    return _prefs?.getBool(_onboardingKey) ?? false;
  }

  // App Settings
  static Future<bool> setThemeMode(bool isDarkMode) async {
    return await _prefs?.setBool(_themeKey, isDarkMode) ?? false;
  }

  static bool getThemeMode() {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  static Future<bool> setNotificationEnabled(bool enabled) async {
    return await _prefs?.setBool(_notificationKey, enabled) ?? false;
  }

  static bool getNotificationEnabled() {
    return _prefs?.getBool(_notificationKey) ?? true;
  }

  static Future<bool> setDailyLogReminder(bool enabled) async {
    return await _prefs?.setBool(_dailyLogReminderKey, enabled) ?? false;
  }

  static bool getDailyLogReminder() {
    return _prefs?.getBool(_dailyLogReminderKey) ?? true;
  }

  // Clear all data
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
