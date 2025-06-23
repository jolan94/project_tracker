import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracker/app/theme/app_theme.dart';
import 'package:project_tracker/app/routes/app_routes.dart';
import 'package:project_tracker/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Project Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.rightToLeft,
    );
  }
}
