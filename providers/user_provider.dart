// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/shared_prefs_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  DateTime? _lastLoginTime;
  Map<String, dynamic> _preferences = {};
  List<String> _recentSearches = [];
  Map<String, dynamic> _userStats = {};
  List<String> _healthInterests = [];
  Map<String, bool> _notificationSettings = {};

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  DateTime? get lastLoginTime => _lastLoginTime;
  Map<String, dynamic> get preferences => _preferences;
  List<String> get recentSearches => _recentSearches;
  Map<String, dynamic> get userStats => _userStats;
  List<String> get healthInterests => _healthInterests;
  Map<String, bool> get notificationSettings => _notificationSettings;

  // Convenience getters
  String get userName => _user?.name ?? 'User';
  String get userEmail => _user?.email ?? '';
  String get userPhone => _user?.phone ?? '';
  int get userAge => _user?.age ?? 0;
  String get userCondition => _user?.condition ?? '';
  String get emergencyContact => _user?.emergencyContact ?? '';
  List<String> get userAllergies => _user?.allergies ?? [];
  bool get medicationRemindersEnabled => _user?.medicationReminders ?? true;

  // Theme and UI preferences
  bool get isDarkMode => _preferences['isDarkMode'] ?? false;
  bool get notificationsEnabled => _preferences['notificationsEnabled'] ?? true;
  bool get dailyLogReminderEnabled =>
      _preferences['dailyLogReminderEnabled'] ?? true;
  String get preferredLanguage => _preferences['preferredLanguage'] ?? 'en';
  String get dateFormat => _preferences['dateFormat'] ?? 'MM/dd/yyyy';
  String get timeFormat => _preferences['timeFormat'] ?? '12h';
  double get fontSize => _preferences['fontSize'] ?? 16.0;

  // Health tracking preferences
  bool get trackVitals => _preferences['trackVitals'] ?? true;
  bool get trackSymptoms => _preferences['trackSymptoms'] ?? true;
  bool get trackMood => _preferences['trackMood'] ?? true;
  bool get trackExercise => _preferences['trackExercise'] ?? false;
  bool get trackSleep => _preferences['trackSleep'] ?? false;
  List<String> get preferredMedicationTimes => List<String>.from(
    _preferences['preferredMedicationTimes'] ?? ['08:00', '20:00'],
  );

  // Notification preferences
  bool get medicationReminders =>
      _notificationSettings['medicationReminders'] ?? true;
  bool get appointmentReminders =>
      _notificationSettings['appointmentReminders'] ?? true;
  bool get healthLogReminders =>
      _notificationSettings['healthLogReminders'] ?? true;
  bool get healthTipsNotifications =>
      _notificationSettings['healthTipsNotifications'] ?? true;
  bool get emergencyAlerts => _notificationSettings['emergencyAlerts'] ?? true;
  int get defaultReminderMinutes =>
      _preferences['defaultReminderMinutes'] ?? 30;

  // User statistics
  int get totalMedications => _userStats['totalMedications'] ?? 0;
  int get totalHealthLogs => _userStats['totalHealthLogs'] ?? 0;
  int get totalAppointments => _userStats['totalAppointments'] ?? 0;
  int get streakDays => _userStats['streakDays'] ?? 0;
  double get adherenceRate => _userStats['adherenceRate'] ?? 0.0;
  DateTime? get lastActiveDate => _userStats['lastActiveDate'] != null
      ? DateTime.parse(_userStats['lastActiveDate'])
      : null;

  // Initialize user data
  Future<void> initializeUser() async {
    _setLoading(true);
    try {
      await _loadUserData();
      await _loadUserPreferences();
      await _loadUserStats();
      await _loadNotificationSettings();
      await _loadHealthInterests();
      await _loadRecentSearches();

      _isLoggedIn = _user != null;
      if (_isLoggedIn) {
        _lastLoginTime = DateTime.now();
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize user: ${e.toString()}';
    }
    _setLoading(false);
  }

  // User data operations
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _user = updatedUser;
      await SharedPrefsService.saveUserData(updatedUser);
      await _updateUserStats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update user: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateUserField(String field, dynamic value) async {
    if (_user == null) return;

    try {
      UserModel updatedUser;
      switch (field) {
        case 'name':
          updatedUser = UserModel(
            name: value as String,
            age: _user!.age,
            condition: _user!.condition,
            medicationReminders: _user!.medicationReminders,
            email: _user!.email,
            phone: _user!.phone,
            allergies: _user!.allergies,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        case 'age':
          updatedUser = UserModel(
            name: _user!.name,
            age: value as int,
            condition: _user!.condition,
            medicationReminders: _user!.medicationReminders,
            email: _user!.email,
            phone: _user!.phone,
            allergies: _user!.allergies,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        case 'email':
          updatedUser = UserModel(
            name: _user!.name,
            age: _user!.age,
            condition: _user!.condition,
            medicationReminders: _user!.medicationReminders,
            email: value as String,
            phone: _user!.phone,
            allergies: _user!.allergies,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        case 'phone':
          updatedUser = UserModel(
            name: _user!.name,
            age: _user!.age,
            condition: _user!.condition,
            medicationReminders: _user!.medicationReminders,
            email: _user!.email,
            phone: value as String,
            allergies: _user!.allergies,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        case 'condition':
          updatedUser = UserModel(
            name: _user!.name,
            age: _user!.age,
            condition: value as String,
            medicationReminders: _user!.medicationReminders,
            email: _user!.email,
            phone: _user!.phone,
            allergies: _user!.allergies,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        case 'emergencyContact':
          updatedUser = UserModel(
            name: _user!.name,
            age: _user!.age,
            condition: _user!.condition,
            medicationReminders: _user!.medicationReminders,
            email: _user!.email,
            phone: _user!.phone,
            allergies: _user!.allergies,
            emergencyContact: value as String,
          );
          break;
        case 'allergies':
          updatedUser = UserModel(
            name: _user!.name,
            age: _user!.age,
            condition: _user!.condition,
            medicationReminders: _user!.medicationReminders,
            email: _user!.email,
            phone: _user!.phone,
            allergies: value as List<String>,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        case 'medicationReminders':
          updatedUser = UserModel(
            name: _user!.name,
            age: _user!.age,
            condition: _user!.condition,
            medicationReminders: value as bool,
            email: _user!.email,
            phone: _user!.phone,
            allergies: _user!.allergies,
            emergencyContact: _user!.emergencyContact,
          );
          break;
        default:
          return;
      }

      await updateUser(updatedUser);
    } catch (e) {
      _error = 'Failed to update user field: ${e.toString()}';
      notifyListeners();
    }
  }

  // Preferences management
  Future<void> updatePreference(String key, dynamic value) async {
    _preferences[key] = value;
    await _saveUserPreferences();
    notifyListeners();
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    _notificationSettings[key] = value;
    await _saveNotificationSettings();
    notifyListeners();
  }

  Future<void> addHealthInterest(String interest) async {
    if (!_healthInterests.contains(interest)) {
      _healthInterests.add(interest);
      await _saveHealthInterests();
      notifyListeners();
    }
  }

  Future<void> removeHealthInterest(String interest) async {
    _healthInterests.remove(interest);
    await _saveHealthInterests();
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    _recentSearches.remove(query); // Remove if already exists
    _recentSearches.insert(0, query); // Add to beginning
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList(); // Keep only last 10
    }
    await _saveRecentSearches();
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    await _saveRecentSearches();
    notifyListeners();
  }

  // User statistics updates
  Future<void> incrementMedicationCount([int increment = 1]) async {
    _userStats['totalMedications'] =
        (_userStats['totalMedications'] ?? 0) + increment;
    await _saveUserStats();
    notifyListeners();
  }

  Future<void> incrementHealthLogCount([int increment = 1]) async {
    _userStats['totalHealthLogs'] =
        (_userStats['totalHealthLogs'] ?? 0) + increment;
    await _saveUserStats();
    notifyListeners();
  }

  Future<void> incrementAppointmentCount([int increment = 1]) async {
    _userStats['totalAppointments'] =
        (_userStats['totalAppointments'] ?? 0) + increment;
    await _saveUserStats();
    notifyListeners();
  }

  Future<void> updateAdherenceRate(double rate) async {
    _userStats['adherenceRate'] = rate;
    await _saveUserStats();
    notifyListeners();
  }

  Future<void> updateStreak(int days) async {
    _userStats['streakDays'] = days;
    await _saveUserStats();
    notifyListeners();
  }

  Future<void> recordActivity() async {
    _userStats['lastActiveDate'] = DateTime.now().toIso8601String();
    await _saveUserStats();
    notifyListeners();
  }

  // Authentication methods
  Future<void> login(UserModel user) async {
    _user = user;
    _isLoggedIn = true;
    _lastLoginTime = DateTime.now();
    await SharedPrefsService.saveUserData(user);
    await _updateUserStats();
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    _lastLoginTime = null;
    await _clearUserData();
    await _clearAllData();
    notifyListeners();
  }

  // NEW: Forceful logout that completely clears everything
  Future<void> forcefulLogout() async {
    try {
      // Clear everything including user data
      _user = null;
      _isLoggedIn = false;
      _lastLoginTime = null;

      // Clear all SharedPreferences data
      await SharedPrefsService.clearAll();

      // Clear all in-memory data
      _preferences.clear();
      _recentSearches.clear();
      _userStats.clear();
      _healthInterests.clear();
      _notificationSettings.clear();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to perform forceful logout: ${e.toString()}';
      notifyListeners();
    }
  }

  // Account management
  Future<void> deleteAccount() async {
    try {
      await _clearUserData();
      await _clearAllData();
      _user = null;
      _isLoggedIn = false;
      _lastLoginTime = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete account: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> resetAccount() async {
    try {
      await _clearAllData();
      _preferences.clear();
      _recentSearches.clear();
      _userStats.clear();
      _healthInterests.clear();
      _notificationSettings.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset account: ${e.toString()}';
      notifyListeners();
    }
  }

  // Data export/import
  Map<String, dynamic> exportUserData() {
    return {
      'user': _user?.toJson(),
      'preferences': _preferences,
      'recentSearches': _recentSearches,
      'userStats': _userStats,
      'healthInterests': _healthInterests,
      'notificationSettings': _notificationSettings,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      if (data['user'] != null) {
        _user = UserModel.fromJson(data['user']);
        await SharedPrefsService.saveUserData(_user!);
      }

      if (data['preferences'] != null) {
        _preferences = Map<String, dynamic>.from(data['preferences']);
        await _saveUserPreferences();
      }

      if (data['recentSearches'] != null) {
        _recentSearches = List<String>.from(data['recentSearches']);
        await _saveRecentSearches();
      }

      if (data['userStats'] != null) {
        _userStats = Map<String, dynamic>.from(data['userStats']);
        await _saveUserStats();
      }

      if (data['healthInterests'] != null) {
        _healthInterests = List<String>.from(data['healthInterests']);
        await _saveHealthInterests();
      }

      if (data['notificationSettings'] != null) {
        _notificationSettings = Map<String, bool>.from(
          data['notificationSettings'],
        );
        await _saveNotificationSettings();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to import user data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Validation methods
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}').hasMatch(phone);
  }

  bool isValidAge(int age) {
    return age > 0 && age <= 120;
  }

  // Helper methods
  bool hasAllergy(String allergen) {
    return userAllergies.any(
      (allergy) => allergy.toLowerCase().contains(allergen.toLowerCase()),
    );
  }

  List<String> getSearchSuggestions(String query) {
    return _recentSearches
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  bool isFirstTimeUser() {
    return _userStats['firstLoginDate'] == null;
  }

  int getDaysSinceFirstLogin() {
    if (_userStats['firstLoginDate'] == null) return 0;
    final firstLogin = DateTime.parse(_userStats['firstLoginDate']);
    return DateTime.now().difference(firstLogin).inDays;
  }

  // Private methods
  Future<void> _loadUserData() async {
    try {
      _user = SharedPrefsService.getUserData();
    } catch (e) {
      _error = 'Failed to load user data: ${e.toString()}';
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      if (prefsJson != null) {
        _preferences = Map<String, dynamic>.from(jsonDecode(prefsJson));
      }
    } catch (e) {
      _error = 'Failed to load preferences: ${e.toString()}';
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_preferences', jsonEncode(_preferences));
    } catch (e) {
      _error = 'Failed to save preferences: ${e.toString()}';
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('user_stats');
      if (statsJson != null) {
        _userStats = Map<String, dynamic>.from(jsonDecode(statsJson));
      }
    } catch (e) {
      _error = 'Failed to load user stats: ${e.toString()}';
    }
  }

  Future<void> _saveUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_stats', jsonEncode(_userStats));
    } catch (e) {
      _error = 'Failed to save user stats: ${e.toString()}';
    }
  }

  Future<void> _updateUserStats() async {
    if (_userStats['firstLoginDate'] == null) {
      _userStats['firstLoginDate'] = DateTime.now().toIso8601String();
    }
    _userStats['lastLoginDate'] = DateTime.now().toIso8601String();
    await _saveUserStats();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');
      if (settingsJson != null) {
        _notificationSettings = Map<String, bool>.from(
          jsonDecode(settingsJson),
        );
      } else {
        // Default notification settings
        _notificationSettings = {
          'medicationReminders': true,
          'appointmentReminders': true,
          'healthLogReminders': true,
          'healthTipsNotifications': true,
          'emergencyAlerts': true,
        };
      }
    } catch (e) {
      _error = 'Failed to load notification settings: ${e.toString()}';
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'notification_settings',
        jsonEncode(_notificationSettings),
      );
    } catch (e) {
      _error = 'Failed to save notification settings: ${e.toString()}';
    }
  }

  Future<void> _loadHealthInterests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interestsJson = prefs.getString('health_interests');
      if (interestsJson != null) {
        _healthInterests = List<String>.from(jsonDecode(interestsJson));
      }
    } catch (e) {
      _error = 'Failed to load health interests: ${e.toString()}';
    }
  }

  Future<void> _saveHealthInterests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_interests', jsonEncode(_healthInterests));
    } catch (e) {
      _error = 'Failed to save health interests: ${e.toString()}';
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchesJson = prefs.getStringList('recent_searches');
      if (searchesJson != null) {
        _recentSearches = searchesJson;
      }
    } catch (e) {
      _error = 'Failed to load recent searches: ${e.toString()}';
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recent_searches', _recentSearches);
    } catch (e) {
      _error = 'Failed to save recent searches: ${e.toString()}';
    }
  }

  Future<void> _clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_preferences');
      await prefs.remove('user_stats');
      await prefs.remove('notification_settings');
      await prefs.remove('health_interests');
      await prefs.remove('recent_searches');
    } catch (e) {
      _error = 'Failed to clear data: ${e.toString()}';
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      _error = 'Failed to clear user data: ${e.toString()}';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Utility getters for UI
  String get userInitials {
    if (_user?.name == null || _user!.name.isEmpty) return 'U';
    final nameParts = _user!.name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return _user!.name[0].toUpperCase();
  }

  String get userDisplayName {
    if (_user?.name == null || _user!.name.isEmpty) return 'User';
    final nameParts = _user!.name.split(' ');
    return nameParts.isNotEmpty ? nameParts[0] : 'User';
  }

  String get userFullName => _user?.name ?? 'Unknown User';

  bool get hasCompleteProfile {
    return _user != null &&
        _user!.name.isNotEmpty &&
        _user!.email.isNotEmpty &&
        _user!.phone.isNotEmpty &&
        _user!.age > 0 &&
        _user!.emergencyContact.isNotEmpty;
  }

  double get profileCompleteness {
    if (_user == null) return 0.0;

    int completed = 0;
    int total = 7;

    if (_user!.name.isNotEmpty) completed++;
    if (_user!.email.isNotEmpty) completed++;
    if (_user!.phone.isNotEmpty) completed++;
    if (_user!.age > 0) completed++;
    if (_user!.condition.isNotEmpty) completed++;
    if (_user!.emergencyContact.isNotEmpty) completed++;
    if (_user!.allergies.isNotEmpty) completed++;

    return completed / total;
  }

  // Activity tracking
  Future<void> trackActivity(String activity) async {
    try {
      final now = DateTime.now();
      _userStats['lastActiveDate'] = now.toIso8601String();

      // Track activity count
      final todayKey = 'activities_${now.year}_${now.month}_${now.day}';
      _userStats[todayKey] = (_userStats[todayKey] ?? 0) + 1;

      // Track specific activity
      final activityKey = 'activity_${activity}_count';
      _userStats[activityKey] = (_userStats[activityKey] ?? 0) + 1;

      await _saveUserStats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to track activity: ${e.toString()}';
    }
  }
}
