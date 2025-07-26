import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/hive_service.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  // App state
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxString _currentTheme = 'dark'.obs;
  final RxInt _selectedBottomNavIndex = 0.obs;

  // UI state
  final RxBool _isDarkMode = true.obs;
  final RxString _selectedLanguage = 'en'.obs;
  final RxInt _currentIndex = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  String get currentTheme => _currentTheme.value;
  int get selectedBottomNavIndex => _selectedBottomNavIndex.value;
  bool get isDarkMode => _isDarkMode.value;
  String get selectedLanguage => _selectedLanguage.value;
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      _isLoading.value = true;
      
      // Initialize Hive database
      await HiveService.init();
      
      // Load user preferences
      await loadUserPreferences();
      
      _isInitialized.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize app: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadUserPreferences() async {
    final theme = HiveService.getSetting<String>('theme', defaultValue: 'dark');
    _currentTheme.value = theme ?? 'dark';
  }

  void changeBottomNavIndex(int index) {
    _selectedBottomNavIndex.value = index;
  }

  Future<void> changeTheme(String theme) async {
    _currentTheme.value = theme;
    await HiveService.saveSetting('theme', theme);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _savePreferences();
  }

  void changeTab(int index) {
    _currentIndex.value = index;
  }

  void _savePreferences() {
    // Save preferences implementation
  }

  Map<String, dynamic> getAppAnalytics() {
    return HiveService.getAnalytics();
  }

  Future<void> exportData() async {
    try {
      final data = HiveService.exportData();
      // Here you could implement file saving or sharing
      Get.snackbar(
        'Success',
        'Data exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearAllData() async {
    try {
      await HiveService.clearAllData();
      Get.snackbar(
        'Success',
        'All data cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    HiveService.close();
    super.onClose();
  }
}