import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/notification/notification_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/settings/settings_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainPage extends GetView<BottomNavigationBarController> {
  MainPage({Key? key}) : super(key: key);

  // 페이지
  List<Widget> _widgetOptions = [
    // PostList page
    PostListPage(),

    // Posting page
    PostingPage(),

    // Notification page
    NotificationPage(),

    // Settings page
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return controller.deleteBottomNaviBarHistory();
        },
        child: Obx(
          () => Scaffold(
            // 키보드가 위로 올라왔을 떄 Overhead가 되는 것을 방지한다.
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: BottomNavyBar(
              selectedIndex: controller.selectedIndex.value,
              showElevation: true, // use this to remove appBar's elevation

              onItemSelected: (int index) {
                controller.checkBottomNaviState(index);
              },
              items: [
                // PostList ItemBar
                BottomNavyBarItem(
                  icon: const Icon(Icons.search),
                  title: const Text('PostList'),
                  activeColor: Colors.red,
                ),

                // Posting ItemBar
                BottomNavyBarItem(
                    icon: const Icon(PhosphorIcons.pencil),
                    title: const Text('Posting'),
                    activeColor: Colors.purpleAccent),

                // Notifications ItemBar
                BottomNavyBarItem(
                    icon: const Icon(Icons.message),
                    title: const Text('Notifications'),
                    activeColor: Colors.pink),

                // Settings ItemBar
                BottomNavyBarItem(
                    icon: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    activeColor: Colors.blue),
              ],
            ),
            body: _widgetOptions.elementAt(controller.selectedIndex.value),
          ),
        ),
      ),
    );
  }
}
