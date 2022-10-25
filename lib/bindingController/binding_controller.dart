import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/notification_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';

class BindingController implements Bindings {
  // 앱이 처음부터 시작할 떄 AuthController를 등록하는 method
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
  }

  // BottomNavigationBar controller 등록하는 method
  // PostList controller를 등록하는 method
  // Posting controller를 등록하는 method
  // Settings controller를 등록하는 method
  static addServalController() {
    Get.put(BottomNavigationBarController());
    Get.put(PostListController());
    Get.put(PostingController());
    Get.put(NotificationController());
    Get.put(SettingsController());

    // Get.lazyPut(() => BottomNavigationBarController(), fenix: true);
    // Get.lazyPut(() => PostListController(), fenix: true);
    // Get.lazyPut(() => PostingController(), fenix: true);
    // Get.lazyPut(() => SettingsController());
  }
}
