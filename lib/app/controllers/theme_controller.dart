import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  final GetStorage _storage = GetStorage();
  
  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.dark.obs;
  
  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
  bool get isLightMode => _themeMode.value == ThemeMode.light;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }
  
  /// Load theme preference from storage
  void _loadThemeFromStorage() {
    final savedTheme = _storage.read(_themeKey);
    if (savedTheme != null) {
      _themeMode.value = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
    } else {
      // Default to dark mode
      _themeMode.value = ThemeMode.dark;
    }
    
    // Update GetX theme
    Get.changeThemeMode(_themeMode.value);
  }
  
  /// Toggle between light and dark theme
  void toggleTheme() {
    _themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeToStorage();
    Get.changeThemeMode(_themeMode.value);
  }
  
  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _saveThemeToStorage();
    Get.changeThemeMode(_themeMode.value);
  }
  
  /// Set to light theme
  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }
  
  /// Set to dark theme
  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }
  
  /// Save theme preference to storage
  void _saveThemeToStorage() {
    _storage.write(_themeKey, isDarkMode ? 'dark' : 'light');
  }
  
  /// Get current theme data
  ThemeData get currentTheme {
    return isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
  
  /// Get theme name for display
  String get themeName {
    return isDarkMode ? 'Dark Mode' : 'Light Mode';
  }
  
  /// Get theme icon
  IconData get themeIcon {
    return isDarkMode ? Icons.dark_mode : Icons.light_mode;
  }
}