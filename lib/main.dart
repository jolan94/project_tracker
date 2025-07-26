import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/theme/app_theme.dart';
import 'app/data/services/hive_service.dart';
import 'app/controllers/app_controller.dart';
import 'app/controllers/ideas_controller.dart';
import 'app/controllers/projects_controller.dart';
import 'app/controllers/tasks_controller.dart';
import 'app/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  // Register controllers
  Get.put(AppController());
  Get.put(IdeasController());
  Get.put(ProjectsController());
  Get.put(TasksController());

  runApp(const BuildTrackApp());
}

class BuildTrackApp extends StatelessWidget {
  const BuildTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BuildTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      home: const MainScreen(),
    );
  }
}
