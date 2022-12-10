import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/screen/beforeBottomNavigationBar/login_page.dart';
import 'package:help_desk/screen/beforeBottomNavigationBar/sign_up_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/main_page.dart';

class Auth extends GetView<AuthController> {
  const Auth({Key? key}) : super(key: key);

  // 회원 확인을 위한 LoadingBar를 나타내는 Widget
  Widget authVerifyLodaingBar() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitCircle(
            color: Colors.red,
          ),
          SizedBox(height: 15.h),
          Text(
            '회원 확인 중입니다.',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        // FirebaseAuth 상태가 로고인인지 확인하는 stream이다.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot)  {
          // Loading Bar를 멈춘다.
          EasyLoading.dismiss();

          // Firebase Auth 상태가 로고인이 아닐 떄
          if (snapshot.data == null) {
            return const LoginPage();
          }

          // Firebase Auth 상태가 로고인일 떄
          else {
            return FutureBuilder(
              future: controller.getFireBaseUserUid(snapshot.data!.uid),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                    innerSnapshot,
              )  {
                // snapshot data가 아직 오지 않았다면 Circular Indicator을 작동시킨다.
                if (innerSnapshot.connectionState == ConnectionState.waiting) {
                  return authVerifyLodaingBar();
                }

                // snapshot data가 왔을 떄
                else {
                  /* Firebase Auth 상태가 로고인이고
                     DataBase에서 useruid가 있는 경우 */
                  if (innerSnapshot.data!.size != 0) {
                    // MainPage로 가기 위해 해야 할 작업 method 호출
                    AuthController.to.taskPriorMainPage(innerSnapshot);

                    return MainPage();
                  }

                  /* Firebase Auth 상태가 로고인이나
                     DataBase에서 UserUid가 없는 경우 */
                  else {
                    return SignUpPage(userUid: snapshot.data!.uid);
                  }
                }
              },
            );
          }
        },
      ),
    );
  }
}
