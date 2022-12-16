import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/utils/toast_util.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  // Google Login Button
  Widget googleLoginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80.0.w),
      child: ElevatedButton.icon(
        onPressed: () async {
          await AuthController.to.googleLogin();
        },
        icon: Image.asset(
          'assets/images/google.png',
        ), //icon data for elevated button
        label:
            const Text('Google Login', style: TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          primary: Colors.white, //elevated btton background color
        ),
      ),
    );
  }

  // Facebook Login Button
  Widget facebookLoginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80.0.w),
      child: ElevatedButton.icon(
        onPressed: () async {
          await AuthController.to.facebookLogin();
        },
        icon: Image.asset(
            'assets/images/facebook-logo-2019.png'), //icon data for elevated button
        label:
            const Text('Facebook Login', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.blueAccent, //elevated btton background color
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        // 뒤로 가기 허용 X
        onWillPop: () async {
          ToastUtil.showToastMessage('이전가기가 불가능합니다.');
          return false;
        },

        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title:
                const Text('Login Page', style: TextStyle(color: Colors.black)),
            elevation: 0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 구글 로고인
              googleLoginButton(),

              SizedBox(height: 100.0.h),

              // 페이스북 로고인
              facebookLoginButton(),

              SizedBox(height: 50.0.h),
            ],
          ),
        ),
      ),
    );
  }
}
