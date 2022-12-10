import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:help_desk/bindingController/binding_controller.dart';
import 'package:help_desk/screen/beforeBottomNavigationBar/splash_page.dart';
import 'package:help_desk/firebase_options.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  // Firebase 설정 준비
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ScreenUtilInit(
      // 기종이 다른 스마트폰에서 화면 사이즈를 (360 * 690)으로 통일한다.
      designSize: const Size(360, 690),
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (context, child) {
        return OKToast(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialBinding: BindingController(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: const Splash(),
            builder: EasyLoading.init(),
          ),
        );
      },
    ),
  );
}
