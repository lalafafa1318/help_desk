import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/utils/toast_util.dart';

class PostingFailurePage extends StatelessWidget {
  const PostingFailurePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ToastUtil.showToastMessage('이전 가기가 불가능합니다 :)');

        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 업로드 실패 image
              Image.asset('assets/images/failure.png', width: 80),

              const SizedBox(height: 20),

              // 업로드 실패 text
              const Text('업로드가 실패했습니다.',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              // 이전 페이지로 이동하는 Button
              GFButton(
                onPressed: () {
                  // 이전 페이지로 이동한다.
                  Get.back();

                  BottomNavigationBarController.to.deleteBottomNaviBarHistory();
                },
                text: '이전 페이지로 돌아가기',
                type: GFButtonType.outline2x,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
