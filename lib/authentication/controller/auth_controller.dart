import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:help_desk/bindingController/binding_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/departmentClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/notification_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/utils/connect_util.dart';
import 'package:help_desk/utils/toast_util.dart';

class AuthController extends GetxController {
  // User 정보를 관리하는 Field
  Rx<UserModel> user = UserModel(
    userType: UserClassification.GENERALUSER,
    department: DepartmentClassification.ETHICALMANAGEMENT,
    userName: '',
    image: '',
    userUid: '',
    commentNotificationPostUid: [],
    phoneNumber: '',
  ).obs;

  // AuthController를 쉽게 사용할 수 있도록 하는 method
  static AuthController get to => Get.find();

  // MainPage로 가기 전에 해야 하는 작업을 수행하는 method
  void taskPriorMainPage(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> innerSnapshot) {
    // innerSnapshot에서 Database에 저장된 Map 형식 User를 가져온다.
    Map<String, dynamic> mapUser = innerSnapshot.data!.docs.first.data();

    // Map 형식의 mapUser를 일반 클래스 형식의 user로 바꾼다.
    UserModel classUser = UserModel.fromMap(mapUser);

    // 일반 클래스 형식의 user를 대입한다.
    user(classUser);

    // BottomNavigationBar, Posting, PostList, Notification, SettingsController를 등록한다.
    BindingController.addServalController();

    // 회원가입을 이미 했다는 의미로 false를 대입한다.
    SettingsController.to.didSignUp = false;

    // 로그
    print('SettingsController- didSignUp : ${SettingsController.to.didSignUp}');
  }

  // DataBase에서 userUid가 있는지 확인하는 method
  Future<QuerySnapshot<Map<String, dynamic>>> getFireBaseUserUid(String uid) async {
    QuerySnapshot<Map<String, dynamic>> userData =
        await CommunicateFirebase.getFireBaseUserUid(uid);
    return userData;
  }

  // Google Login 진행하는 method
  Future<void> googleLogin() async {
    // Loading 한다.
    EasyLoading.show(
        status: 'Google\n로고인 중 입니다.', maskType: EasyLoadingMaskType.black);

    //Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // 사용자가 GoogleLogin 페이지에서 취소를 누를 떄
    if (googleUser == null) {
      EasyLoading.dismiss();

      print('사용자가 Google Login 페이지를 나갔습니다.');
    }
    // 사용자가 Google Login을 할 때
    else {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential googleAuthCredential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('GoogleUserUid : $googleAuthCredential}');

      // Once signed in, return the UserCredential
      await CommunicateFirebase.login(googleAuthCredential);

      print('Google 로고인 성공');
    }
  }

  // Facebook Login 진행하는 method
  Future<void> facebookLogin() async {
    // Loading Bar를 띄운다.
    EasyLoading.show(
        status: 'Facebook\n로고인 중 입니다.', maskType: EasyLoadingMaskType.black);

    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Facebook 로고인 성공한 경우
    if (loginResult.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      print('FacebookUserUid : $facebookAuthCredential');

      // Once signed in, return the UserCredential
      await CommunicateFirebase.login(facebookAuthCredential);

      print('Facebook 로고인 성공');
    }
    // 사용자가 Facebook 로고인 페이지에서 나간 경우
    else if (loginResult.status == LoginStatus.cancelled) {
      EasyLoading.dismiss();

      print('사용자가 Facebook 로고인 페이지를 나갔습니다.');
    }
    // 알 수 없는 이유로 Facebook 로고인이 되지 않은 경우
    else if (loginResult.status == LoginStatus.failed) {
      EasyLoading.dismiss();

      ToastUtil.showToastMessage('알 수 없는 이유로 Facebook 로고인이 취소되었습니다.');
    }
  }

  // Google, Facebook Logout 진행하는 method
  Future<void> logout() async {
    // Widget Tree 상에서 이전 페이지가 SignUpPage인 경우
    if (SettingsController.to.didSignUp == true) {
      // 기존 controller들을 메모리에서 내리고 계정을 Logout하는 method
      await initControllerAndLogout();

      // 이전 페이지로 가기
      Get.back();
    }
    // Widget Tree 상에서 이전 페이지가 SignUpPage가 아닌 경우
    else {
      // 기존 controller들을 메모리에서 내리고 계정을 Logout하는 method
      await initControllerAndLogout();
    }
  }

  // 기존 controller들을 메모리에서 내리고 계정을 Logout하는 method
  Future<void> initControllerAndLogout() async {
    // controller를 메모리에서 내리기 전 해야 할 작업을 명시한다.
    BottomNavigationBarController.to.onClose();
    PostListController.to.onClose();
    PostingController.to.onClose();
    NotificationController.to.onClose();
    SettingsController.to.onClose();

    // controller를 삭제하여 메모리에서 내린다.
    await Get.delete<BottomNavigationBarController>();
    await Get.delete<PostListController>();
    await Get.delete<PostingController>();
    await Get.delete<NotificationController>();
    await Get.delete<SettingsController>();

    // 최종 logout
    await CommunicateFirebase.logout();
  }

  // AuthController가 메모리에 처음 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    // 연결 상태가 변경되었는지 확인하는 method
    ConnectUtil.listen();

    print('AuthController - onInit() 호출되었습니다.');
  }

  // AuthController를 메모리에서 제거될 떄 호출되는 method
  @override
  void onClose() {
    print('AuthController - onClose() 호출되었습니다.');

    super.onClose();
  }
}
