import 'package:get/get.dart';
import 'package:project_tracker/views/home/home_view.dart';
import 'package:project_tracker/views/add_project/add_project_view.dart';
import 'package:project_tracker/views/project_detail/project_detail_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String addProject = '/add';
  static const String projectDetail = '/project/:id';
  static const String editProject = '/project/:id/edit';

  static List<GetPage> get pages => [
        GetPage(
          name: home,
          page: () => const HomeView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: addProject,
          page: () => const AddProjectView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: projectDetail,
          page: () => ProjectDetailView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: editProject,
          page: () => const AddProjectView(isEditing: true),
          transition: Transition.rightToLeft,
        ),
      ];
}
