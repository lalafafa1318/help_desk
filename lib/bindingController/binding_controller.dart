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

  /* BottomNavigationBarConntroller,
     PostListController,
     PostingController,
     NotificationController,
     SettingsController를 등록하는 method */
  static addServalController() {
    Get.put(BottomNavigationBarController());
    Get.put(PostListController());
    Get.put(PostingController());
    Get.put(NotificationController());
    Get.put(SettingsController());
  }
}
