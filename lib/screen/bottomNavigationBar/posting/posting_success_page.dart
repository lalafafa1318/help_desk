import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/utils/toast_util.dart';

// Posting 업로드 성공 시 보여주는 widget 입니다.
class PostingSuccessPage extends StatefulWidget {
  const PostingSuccessPage({Key? key}) : super(key: key);

  @override
  State<PostingSuccessPage> createState() => _PostingSuccessPageState();
}

class _PostingSuccessPageState extends State<PostingSuccessPage> {
  @override
  void initState() {
    super.initState();
    // 로그
    print('PostingSuccessPage - initState() 호출');

    // 업로드가 성공적임을 Toast Message로 알린다.
    // ToastUtil.showToastMessage('업로드 완료 :)');
  }

  @override
  void dispose() {
    super.dispose();

    // 로그
    print('PostingSuccessPage - dispose() 호출');
  }

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
              // 업로드 성공 image
              Image.asset('assets/images/success.png', width: 70.w),

              SizedBox(height: 40.h),

              // 업로드 성공 text
              Text(
                '업로드가 완료되었습니다.',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20.h),

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
