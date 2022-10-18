import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';

class WhatIWrotePage extends StatelessWidget {
  const WhatIWrotePage({super.key});

  // 내가 쓴 게시물에 대한 목록을 가져오는 Widget
  Widget getWhatIWroteThePost() {
    return FutureBuilder(
      future: SettingsController.to.getWhatIWroteThePost(SettingsController.to.settingUser!.userUid),
      builder: (context, snapshot) {
        return 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        child: Center(
            child: Column(
          children: [
            // 내가 쓴 게시물에 대한 목록을 가져온다.
            getWhatIWroteThePost(),
          ],
        )),
      ),
    );
  }
}
