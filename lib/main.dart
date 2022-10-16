import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:help_desk/bindingController/binding_controller.dart';
import 'package:help_desk/screen/beforeBottomNavigationBar/splash_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/utils/variable_util.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:oktoast/oktoast.dart';

void main() async {
  // kakao.KakaoSdk.init(nativeAppKey: VariableUtil.KAKAO_NATIVE_KEY);

  // Firebase 설정 준비
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    OKToast(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: BindingController(),
        getPages: [
          GetPage(name: '/PostListPage', page: () => const PostListPage())
        ],
        home: const Splash(),
        builder: EasyLoading.init(),
      ),
    ),
  );
}
