import 'package:shared_preferences/shared_preferences.dart';

/// Small typed wrapper around SharedPreferences
class AppPrefs {
  AppPrefs._();

  static late SharedPreferences _prefs;

  static const _kSkippedLogin = 'skipped_login';
  static const _kReminderEnabled = 'reminder_enabled';
  static const _kReminderHour = 'reminder_hour';
  static const _kReminderMinute = 'reminder_minute';
  static const _kDarkMode = 'dark_mode';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// User chose to use the app offline without signing in
  static bool get skippedLogin => _prefs.getBool(_kSkippedLogin) ?? false;
  static set skippedLogin(bool value) => _prefs.setBool(_kSkippedLogin, value);

  /// Daily "you have to pay" reminder
  static bool get reminderEnabled => _prefs.getBool(_kReminderEnabled) ?? true;
  static set reminderEnabled(bool value) =>
      _prefs.setBool(_kReminderEnabled, value);

  /// Dark mode is the default look; light is opt-in
  static bool get darkMode => _prefs.getBool(_kDarkMode) ?? true;
  static set darkMode(bool value) => _prefs.setBool(_kDarkMode, value);

  static int get reminderHour => _prefs.getInt(_kReminderHour) ?? 20;
  static int get reminderMinute => _prefs.getInt(_kReminderMinute) ?? 0;

  static Future<void> setReminderTime(int hour, int minute) async {
    await _prefs.setInt(_kReminderHour, hour);
    await _prefs.setInt(_kReminderMinute, minute);
  }
}
