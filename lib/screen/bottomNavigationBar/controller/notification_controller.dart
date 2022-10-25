import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';

// 알림 목록을 관리하는 controller 입니다.
class NotificationController extends GetxController {
  // 사용자가 알림 신청한 게시물 Uid를 담는 배열
  List<String> notiPost = [];

  var stream;

  // Method
  // Controller를 더 쉽게 사용할 수 있도록 하는 get method
  static NotificationController get to => Get.find();

  // Server에 User의 notiPost 속성에 게시물 uid를 추가한다.
  Future<void> addNotiPostFromUser(String postUid, String userUid) async {
    await CommunicateFirebase.addNotiPostFromUser(postUid, userUid);
  }

  // Server에 User의 notiPost 속성에 게시물 uid를 삭제한다.
  Future<void> deleteNotiPostFromUser(String postUid, String userUid) async {
    await CommunicateFirebase.deleteNotiPostFromUser(postUid, userUid);
  }

  // Server에 User의 notiPost 속성을 가져와 notiPost Array에 값을 대입한다.
  Future<void> getNotiPostFromUser() async {
    notiPost.addAll(
      await CommunicateFirebase.getNotiPostFromUser(
        AuthController.to.user.value.userUid,
      ),
    );
  }

 

  // NotificationController가 처음 메모리에 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    // Server에서 user의 notiPost 속성에 값을 가져와 notiPost Array에 값을 대입한다.
    getNotiPostFromUser().then(
      (value) {
        print('notiPostLength : ${notiPost.length}');

      },
    );
  }

  // NotificationController가 메모리에 내려갈 떄 호출되는 method
  @override
  void onClose() {
    notiPost.clear();

    super.onClose();
  }
}
