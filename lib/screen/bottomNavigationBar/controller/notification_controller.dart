import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:http/http.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 알림 목록을 관리하는 controller 입니다.
class NotificationController extends GetxController {
  // 사용자가 알림 신청한 게시물 Uid를 담는 배열
  List<String> notiPost = [];

  // 사용자가 알림 신청한 게시물(Post)에 대한 댓글 개수를 담는 배열
  List<int> commentCount = [];

  // 실시간으로 Listen 하는 배열
  List<StreamSubscription<QuerySnapshot>> listenList = [];

  // Flutter Local Notification에 필요한 변수
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool initListen = true;

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
    List<String> localNotiPost = await CommunicateFirebase.getNotiPostFromUser(
      AuthController.to.user.value.userUid,
    );

    notiPost.addAll(localNotiPost);
  }

  // Server에 게시물(Post)에 대한 댓글(comment)의 개수를 찾아 commentCount Array에 값을 대입하는 method
  Future<void> getCountFromComments() async {
    for (int i = 0; i < notiPost.length; i++) {
      int count = await CommunicateFirebase.getCountFromComments(notiPost[i]);

      commentCount.add(count);
    }
  }

  // Flutter Local Notification을 setting 하는 method
  Future<void> initialize() async {
    var androidIntialize = AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidIntialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Flutter Loal Notification을 show하는 method
  Future<void> showBigTextNotification({var id = 0, required String title, required String body,  var payload}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'you_can_name_it_whatever1',
      'channel_name',
      playSound: false,
      ongoing: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    var not = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      not,
    );
  }

  // Server에서 게시물(post)의 변동 사항을 listen한다.
  void setListen() {
    for (int i = 0; i < notiPost.length; i++) {
      // FirebaseFirestore.instance.collection('posts).doc(notiPost[i])를 간단하게 명명한다.
      var path =
          FirebaseFirestore.instance.collection('posts').doc(notiPost[i]);

      listenList.add(
        path.collection('comments').snapshots().listen(
          (event) async {
            // 앱이 처음 시작하면 개발자 의도에 맞지 않게 listen() 이하 내용이 호출된다.
            // 이하 내용이 호출되지만, if문을 실행하지 않게 하여 무효화 시킨다.
            if (initListen == false) {
              // Server에 있는 댓글(comment) 개수와
              // commentCount의 댓글(comment)개수를 비교한다.

              // Server에 있는 댓글(comment) 개수가
              // commentCount의 댓글(comment)개수보다 크다
              // -> 사용자가 알림 신청한 게시물(Post)에 댓글이 추가됐다는 것을 의미한다.
              if (commentCount[i] < event.size) {
                // Server에 있는 댓글(comment)에 uploadTime 속성이 가장 최근인 데이터를 가져온다.
                QuerySnapshot<Map<String, dynamic>> lastComment = await path
                    .collection('comments')
                    .orderBy('uploadTime', descending: false)
                    .get();

                Map<String, dynamic> data = lastComment.docs.last.data();

                // 사용자가 알림 신청한 게시물에 댓글을 작성할 떄는 Flutter Local Notification을 보내지 않도록 한다.
                if (data['whoWriteUserUid'].toString() !=
                    SettingsController.to.settingUser!.userUid) {
                  // Server에 게시물(Post)를 가져온다.
                  DocumentSnapshot<Map<String, dynamic>> post =
                      await path.get();

                  // 글 작성한 사람(UserName) 데이터를 가져온다.
                  String userUid = post['userUid'].toString();

                  DocumentSnapshot<Map<String, dynamic>> user =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userUid)
                          .get();

                  String userName = user['userName'].toString();

                  // 글 제목 데이터를 가져온다.
                  String postTitle = post['postTitle'].toString();

                  // 댓글 내용 데이터를 가져온다.
                  String content = data['content'].toString();

                  // Flutter Local Notification 전송
                  await showBigTextNotification(
                    title: '${userName} - ${postTitle}',
                    body: '새로운 댓글이 달렸어요 : ${content}',
                  );

                  // Server에 Notification을 추가한다.
                  // 속성 : 게시물 Uid, 댓글 Uid, 알림 시간 







                }
              }
              // Server에 있는 댓글(comment) 개수를 배열에 업데이트한다.
              commentCount[i] = event.size;
            }
          },
        ),
      );
    }
  }

  // Server에서 게시물(post)의 변동 사항을 추가로 listen 한다.
  void addListen(int index) {
    // FirebaseFirestore.instance.collection('posts).doc(postUid)를 간단하게 명명한다.
    var path =
        FirebaseFirestore.instance.collection('posts').doc(notiPost[index]);

    listenList.add(
      path.collection('comments').snapshots().listen(
        (event) async {
          // Server에 있는 댓글(comment) 개수와
          // commentCount의 댓글(comment)개수를 비교한다.

          // Server에 있는 댓글(comment) 개수가
          // commentCount의 댓글(comment)개수보다 크다
          // -> 사용자가 알림 신청한 게시물(Post)에 댓글이 추가됐다는 것을 의미한다.
          if (commentCount[index] < event.size) {
            // Server에 있는 댓글(comment)에 uploadTime 속성이 가장 최근인 데이터를 가져온다.
            QuerySnapshot<Map<String, dynamic>> lastComment = await path
                .collection('comments')
                .orderBy('uploadTime', descending: false)
                .get();

            Map<String, dynamic> data = lastComment.docs.last.data();

            // 사용자가 알림신청을 한 게시물에 댓글을 작성할 떄는 Flutter Local Notification을 보내지 않도록 한다.
            if (data['whoWriteUserUid'].toString() !=
                SettingsController.to.settingUser!.userUid) {
              // Server에 게시물(Post)를 가져온다.
              DocumentSnapshot<Map<String, dynamic>> post = await path.get();

              // 글 작성한 사람(userName) 데이터를 가져온다.
              String userUid = post['userUid'].toString();

              DocumentSnapshot<Map<String, dynamic>> user =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userUid)
                      .get();

              String userName = user['userName'].toString();

              // 글 제목(postTitle) 데이터를 가져온다.
              String postTitle = post['postTitle'].toString();

              // 댓글 내용 데이터를 가져온다.
              String content = data['content'].toString();

              // Flutter Local Notification 전송
              await showBigTextNotification(
                title: '${userName} - ${postTitle}',
                body: '새로운 댓글이 달렸어요 : ${content}',
              );
            }
          }
          // Server에 있는 댓글(comment) 개수를 배열에 업데이트한다.
          commentCount[index] = event.size;
        },
      ),
    );
  }

  // 게시물에 대해서 
  // NotificationController가 처음 메모리에 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    // Server에서 user의 notiPost 속성에 값을 가져와 notiPost Array에 값을 대입한다.
    getNotiPostFromUser().then(
      (value) async {
        print('notiPostLength : ${notiPost.length}');

        // Server에 게시물(Post)에 대한 댓글(comment)의 개수를 찾아 commentCount Array에 값을 대입하는 method
        await getCountFromComments();

        print('commentCountLength : ${commentCount.length}');

        // Flutter Local Notification Setting
        await initialize();

        print('Flutter Local Notification Setting 완료');

        // Server에서 게시물(post)의 변동사항을 listen한다.
        setListen();

        await Future.delayed(const Duration(seconds: 5));

        initListen = false;

        print('알림 신청에 대한 게시물 변동사항을 확인하고 있습니다!!!!');
      },
    );
  }

  // NotificationController가 메모리에 내려갈 떄 호출되는 method
  @override
  void onClose() {
    // 실시간으로 Listen 하는 것을 중지하는 것을 넘어서 삭제한다.
    listenList.map(
      (listenElement) => listenElement.cancel(),
    );

    // 배열 clear
    notiPost.clear();

    commentCount.clear();

    listenList.clear();

    super.onClose();
  }
}
