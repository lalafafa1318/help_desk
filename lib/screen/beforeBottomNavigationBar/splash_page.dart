import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/auth.dart';
import 'package:help_desk/utils/connect_util.dart';
import 'package:help_desk/utils/toast_util.dart';

// Splash 화면 입니다.
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // Splash 화면이 처음 불렸을 떄 호출되는 method
  @override
  void initState() {
    print('splash - initState() 호출');

    // Timer
    Timer(
      const Duration(milliseconds: 5000),
      () async {
        // 최초 연결 상태를 확인한다.
        ConnectivityResult result = await ConnectUtil.check();

        // Wi-Fi, Mobile 상태가 아니면
        if (result == ConnectivityResult.none) {
          // 더이상 앱 진행이 불가능하다는 message를 보낸다.
          ConnectUtil.connectNoneDialog();
        }
        // Wi-Fi 또는 Mobile 상태이면?
        else {
          // Splash 화면을 지우고, Auth 화면으로 이동
          Get.offAll(
            () => const Auth(),
          );
        }
      },
    );
  }

  // Auth 화면으로 Routing될 떄 호출되는 method
  @override
  void dispose() {
    // 로그
    print('splash 화면이 dispose 되었습니다.');

    super.dispose();
  }

  // Container의 배경색을 나타내는 method
  BoxDecoration boxDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.fromARGB(255, 232, 223, 97), Colors.white],
      ),
    );
  }

  // Container에 있는 원형 AvatarWidget
  CircleAvatar circleAvatar() {
    const String imageLogoName = 'assets/images/help.png';

    return CircleAvatar(
      radius: 70.0.r,
      backgroundImage: const AssetImage(imageLogoName),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtil().screenWidth;

    return SafeArea(
      child: WillPopScope(
        // 뒤로 가기 허용 x
        onWillPop: () async {
          ToastUtil.showToastMessage('이전가기가 불가능합니다.');
          return false;
        },

        child: Scaffold(
          body: Container(
            decoration: boxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 250.h),

                // Image 자리 잡는 곳
                Container(
                  child: circleAvatar(),
                ),

                const Expanded(child: SizedBox()),

                // 하단 글씨 부분
                Align(
                  child: Text(
                    "© Copyright 2022, 김영우(wwkler)",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * (14 / 360),
                      fontWeight: FontWeight.bold,
                      // color: Color.fromRGBO(255, 255, 255, 0.6),
                    ),
                  ),
                ),

                SizedBox(
                  height: ScreenUtil().screenHeight * 0.0625,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
