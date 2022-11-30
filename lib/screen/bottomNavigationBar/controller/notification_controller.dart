import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/model/notification_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/utils/uuid_util.dart';
import 'package:intl/intl.dart';

// 알림 목록을 관리하는 controller 입니다.
class NotificationController extends GetxController {
  // 사용자가 알림 신청한 게시물 Uid를 담는 배열 (장애 처리현황, 문의 처리현황 게시물 모두 한곳에 저장)
  List<String> notiPost = [];

  // 사용자가 알림 신청한 게시물(Post)에 대한 댓글 개수를 담는 배열 (장애 처리현황, 문의 처리현황 게시물 댓글 개수 모두 한곳에 저장)
  List<int> commentCount = [];

  // 사용자가 알림 신청한 게시물을 실시간으로 Listen 하는 배열
  List<StreamSubscription<QuerySnapshot>> listenList = [];

  // Database에 저장된 Notification을 저장하는 배열
  List<NotificationModel> notificationModelList = [];

  // Flutter Local Notification에 필요한 변수
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool initListen = true;

  // Method
  // Controller를 더 쉽게 사용할 수 있도록 하는 get method
  static NotificationController get to => Get.find();

  // 사용자가 게시물에 대한 알림을 해제할 떄, 알림 받기 위해 했던 여러 설정을 해제한다.
  Future<void> clearNotificationSetting(String postUid) async {
    // 해당 게시물 Uid가 notiPost Array의 몇번째 index에 있는지 확인한다.
    int index = notiPost.indexOf(postUid);

    // 실시간으로 Listen 하는 것을 중지하는 것을 넘어서 취소한다.
    listenList[index].cancel();

    // NotificationController의 listenList Array에 element을 remove한다.
    listenList.removeAt(index);

    // NotificationController의 notifPost Array에 게시물 uid를 삭제한다.
    notiPost.removeAt(index);

    // NotificationController의 commentCount Array에 element를 remove한다.
    commentCount.removeAt(index);

    // Database에 User의 notiPost 속성에 게시물 uid를 삭제한다.
    await deleteNotiPostFromUser(
      postUid,
      SettingsController.to.settingUser!.userUid,
    );

    // update()를 실행행 notifyButton Widget만 재랜더링 한다.
    update(['notifyButton']);
  }

  // 사용자가 게시물에 대한 알림을 등록할 떄, 알림 받기 위한 여러 설정을 등록하는 method
  Future<void> enrollNotificationSetting(String postUid) async {
    // NotificationControler의 notiPost Array에 게시물 uid를 추가한다.
    notiPost.add(postUid);

    // 해당 게시물 Uid가 notiPost Array의 몇번째 index에 있는지 확인한다.
    int index = notiPost.indexOf(postUid);

    // 사용자가 알림 신청한 게시물(Post)에 대한 댓글 개수를 NotificationController의 commentCount Array에 추가한다.
    commentCount.add(
      await CommunicateFirebase.getCountFromComments(postUid),
    );

    // Database에서 게시물(post)의 변동사항을 추가로 listen 한다.
    await addListen(index);

    // DataBase에 User의 notiPost 속성에 게시물 uid를 추가한다.
    await addNotiPostFromUser(
      postUid,
      SettingsController.to.settingUser!.userUid,
    );

    // update()를 실행해 notifyButton Widget만 재랜더링 한다.
    update(['notifyButton']);
  }

  // Database에 User의 notiPost 속성에 게시물 uid를 추가한다.
  Future<void> addNotiPostFromUser(String postUid, String userUid) async {
    await CommunicateFirebase.addNotiPostFromUser(postUid, userUid);
  }

  // Database에 User의 notiPost 속성에 게시물 uid를 삭제한다.
  Future<void> deleteNotiPostFromUser(String postUid, String userUid) async {
    await CommunicateFirebase.deleteNotiPostFromUser(postUid, userUid);
  }

  // Database에 User의 notiPost 속성을 가져와 notiPost Array에 값을 대입한다.
  Future<void> getNotiPostFromUser() async {
    List<String> localNotiPost = await CommunicateFirebase.getNotiPostFromUser(
      AuthController.to.user.value.userUid,
    );

    notiPost.addAll(localNotiPost);
  }

  // Database에 장애 처리현황 또는 문의 처리현황 게시물에 대한 댓글(comment)의 개수를 찾아
  // commentCount Array에 값을 대입하는 method
  Future<void> getCountFromComments() async {
    for (int i = 0; i < notiPost.length; i++) {
      int count = await CommunicateFirebase.getCountFromComments(notiPost[i]);

      commentCount.add(count);
    }
  }

  // Database에 Notificaion을 모두 가져오는 method
  Future<List<NotificationModel>> getNotifcationFromUser(String userUid) async {
    notificationModelList.clear();

    notificationModelList
        .addAll(await CommunicateFirebase.getNotificationFromUser(userUid));

    return notificationModelList;
  }

  // Databse에 Notification을 삭제하는 method
  Future<void> deleteNotification(String notiUid, String userUid) async {
    await CommunicateFirebase.deleteNotification(notiUid, userUid);
  }

  // Flutter Local Notification을 setting 하는 method
  Future<void> localNotificationInitialize() async {
    var androidIntialize =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidIntialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Flutter Loal Notification을 show하는 method
  Future<void> showBigTextNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'you_can_name_it_whatever1',
      'channel_name',
      playSound: false,
      ongoing: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    var not = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      not,
    );
  }

  // Database에서 장애 처리현황 또는 문의 처리현황 게시물에 대한 댓글 변동 사항을 listen한다.
  Future<void> setListen() async {
    // 오직 하나의 Instnace만 쓰도록 하기 위해 설정했다.
    FirebaseFirestore firebaseFirestore =
        CommunicateFirebase.getFirebaseFirestoreInstnace();

    for (int i = 0; i < notiPost.length; i++) {
      // 장애 처리현황 또는 문의 처리현황 게시물에 접근 하기 위한 background
      DocumentReference<Map<String, dynamic>> postPath;
      // 사용자 정보에 접근하기 위한 background
      CollectionReference<Map<String, dynamic>> userPath =
          firebaseFirestore.collection('users');

      // 알림 신청한 게시물이 장애 처리현황인지 문의 처리현황인지 확인한다.
      DocumentSnapshot<Map<String, dynamic>> whichBelongPostUid =
          await firebaseFirestore.collection('obsPosts').doc(notiPost[i]).get();

      // 알림 신청한 게시물이 장애 처리현황에 속한다면?
      if (whichBelongPostUid.data() != null) {
        postPath = firebaseFirestore.collection('obsPosts').doc(notiPost[i]);
      }
      // 알림 신청한 게시물이 장애 처리현황에 속하지 않는다면?
      else {
        postPath = firebaseFirestore.collection('inqPosts').doc(notiPost[i]);
      }

      // 사용자가 알림 신청한 게시물을 실시간으로 Listen 하는 배열에 추가한다.
      listenList.add(
        postPath.collection('comments').snapshots().listen(
          (QuerySnapshot<Map<String, dynamic>> event) async {
            // 앱이 처음 시작하면 개발자 의도에 맞지 않게 listen() 이하 내용이 호출된다.
            // 이하 내용이 호출되지만, if문을 실행하지 않게 하여 무효화 시킨다.
            if (initListen == false) {
              // Database에 있는 댓글(comment) 개수와
              // commentCount의 댓글(comment)개수를 비교한다.

              // Database에 있는 댓글(comment) 개수가
              // commentCount의 댓글(comment)개수보다 크다
              // -> 사용자가 알림 신청한 장애 처리현황 또는 문의 처리현황 게시물에 댓글이 추가됐다는 것을 의미한다.
              if (commentCount[i] < event.size) {
                // Database에 있는 댓글(comment)에 uploadTime 속성이 가장 최근인 데이터를 가져온다.
                QuerySnapshot<Map<String, dynamic>> lastComment = await postPath
                    .collection('comments')
                    .orderBy('uploadTime', descending: false)
                    .get();
                Map<String, dynamic> lastCommentData =
                    lastComment.docs.last.data();

                // 사용자가
                // 알림 신청한 게시물에 댓글을 작성할 떄는 Flutter Local Notification을 보내지 않도록 한다.
                if (lastCommentData['whoWriteUserUid'].toString() !=
                    SettingsController.to.settingUser!.userUid) {
                  // Database에 장애 처리현황 또는 문의 처리현황 게시물을 가져온다.
                  DocumentSnapshot<Map<String, dynamic>> post =
                      await postPath.get();

                  // 게시물 작성한 사람(UserName) 데이터를 가져온다.
                  String userUid = post['userUid'].toString();
                  DocumentSnapshot<Map<String, dynamic>> user =
                      await userPath.doc(userUid).get();
                  String userName = user['userName'].toString();

                  // 게시물 제목 데이터를 가져온다.
                  String postTitle = post['postTitle'].toString();

                  // 댓글 내용 데이터를 가져온다.
                  String content = lastCommentData['content'].toString();

                  // 게시물이 장애 처리현황인지 문의 처리현황인지 관련된 정보를 가져온다.
                  ObsOrInqClassification belongNotiObsOrInq =
                      ObsOrInqClassification.values.firstWhere(
                    (element) =>
                        element.toString() == post['obsOrInq'].toString(),
                  );

                  // Flutter Local Notification 전송
                  await showBigTextNotification(
                    title: '$userName - $postTitle',
                    body: '새로운 댓글이 달렸어요 : $content',
                  );

                  // NotificationModel을 만든다.
                  NotificationModel noti = NotificationModel(
                    title: '$userName - $postTitle',
                    body: '새로운 댓글이 달렸어요 : $content',
                    notiUid: UUidUtil.getUUid(),
                    belongNotiPostUid: notiPost[i],
                    notiTime: DateFormat('yy/MM/dd - HH:mm:ss').format(
                      DateTime.now(),
                    ),
                    belongNotiObsOrInq: belongNotiObsOrInq,
                  );

                  // Database에 Notification을 저장한다.
                  await userPath
                      .doc(SettingsController.to.settingUser!.userUid)
                      .collection('notifications')
                      .doc(noti.notiUid)
                      .set(NotificationModel.toMap(noti));
                }
              }
              // Database에 있는 댓글(comment) 개수를 commentCount 배열에 업데이트한다.
              commentCount[i] = event.size;
            }
          },
        ),
      );
    }
  }

  // Database에서 장애 처리현황 또는 문의 처리현황 게시물에 대한 댓글 변동 사항을 listen한다.
  Future<void> addListen(int index) async {
    // 오직 하나의 Instnace만 쓰도록 하기 위해 설정했다.
    FirebaseFirestore firebaseFirestore =
        CommunicateFirebase.getFirebaseFirestoreInstnace();

    // 장애 처리현황 또는 문의 처리현황 게시물에 접근 하기 위한 background
    DocumentReference<Map<String, dynamic>> postPath;
    // 사용자 정보에 접근하기 위한 background
    CollectionReference<Map<String, dynamic>> userPath =
        firebaseFirestore.collection('users');

    // 알림 신청한 게시물이 장애 처리현황인지 문의 처리현황인지 확인한다.
    DocumentSnapshot<Map<String, dynamic>> whichBelongPostUid =
        await firebaseFirestore
            .collection('obsPosts')
            .doc(notiPost[index])
            .get();

    // 알림 신청한 게시물이 장애 처리현황에 속한다면?
    if (whichBelongPostUid.data() != null) {
      postPath = firebaseFirestore.collection('obsPosts').doc(notiPost[index]);
    }
    // 알림 신청한 게시물이 장애 처리현황에 속하지 않는다면?
    else {
      postPath = firebaseFirestore.collection('inqPosts').doc(notiPost[index]);
    }

    // 사용자가 알림 신청한 게시물을 실시간으로 Listen 하는 배열에 추가한다.
    listenList.add(
      postPath.collection('comments').snapshots().listen(
        (QuerySnapshot<Map<String, dynamic>> event) async {
          // Database에 있는 댓글(comment) 개수와
          // commentCount의 댓글(comment)개수를 비교한다.

          // Database에 있는 댓글(comment) 개수가
          // commentCount의 댓글(comment)개수보다 크다
          // -> 사용자가 알림 신청한 장애 처리현황 또는 문의 처리현황 게시물에 댓글이 추가됐다는 것을 의미한다.
          if (commentCount[index] < event.size) {
            // Database에 있는 댓글(comment)에 uploadTime 속성이 가장 최근인 데이터를 가져온다.
            QuerySnapshot<Map<String, dynamic>> lastComment = await postPath
                .collection('comments')
                .orderBy('uploadTime', descending: false)
                .get();
            Map<String, dynamic> lastCommentData = lastComment.docs.last.data();

            // 사용자가
            // 알림신청을 한 게시물에 댓글을 작성할 떄는 Flutter Local Notification을 보내지 않도록 한다.
            if (lastCommentData['whoWriteUserUid'].toString() !=
                SettingsController.to.settingUser!.userUid) {
              // Database에 게시물(Post)를 가져온다.
              DocumentSnapshot<Map<String, dynamic>> post =
                  await postPath.get();

              // 게시물 작성한 사람(userName) 데이터를 가져온다.
              String userUid = post['userUid'].toString();
              DocumentSnapshot<Map<String, dynamic>> user =
                  await firebaseFirestore
                      .collection('users')
                      .doc(userUid)
                      .get();
              String userName = user['userName'].toString();

              // 게시물 제목(postTitle) 데이터를 가져온다.
              String postTitle = post['postTitle'].toString();

              // 댓글 내용 데이터를 가져온다.
              String content = lastCommentData['content'].toString();

              // 게시물이 장애 처리현황인지 문의 처리현황인지 관련된 정보를 가져온다.
              ObsOrInqClassification belongNotiObsOrInq =
                  ObsOrInqClassification.values.firstWhere(
                (element) => element.toString() == post['obsOrInq'].toString(),
              );

              // Flutter Local Notification 전송
              await showBigTextNotification(
                title: '$userName - $postTitle',
                body: '새로운 댓글이 달렸어요 : $content',
              );

              // NotificationModel을 만든다.
              NotificationModel noti = NotificationModel(
                title: '$userName - $postTitle',
                body: '새로운 댓글이 달렸어요 : $content',
                notiUid: UUidUtil.getUUid(),
                belongNotiPostUid: notiPost[index],
                notiTime:
                    DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now()),
                belongNotiObsOrInq: belongNotiObsOrInq,
              );

              // Database에 Notification을 저장한다.
              await userPath
                  .doc(SettingsController.to.settingUser!.userUid)
                  .collection('notifications')
                  .doc(noti.notiUid)
                  .set(NotificationModel.toMap(noti));
            }
          }
          // Database에 있는 댓글(comment) 개수를 commentCount 배열에 업데이트한다.
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

    // Database에서 user의 notiPost 속성에 값을 가져와 notiPost Array에 값을 대입한다.
    getNotiPostFromUser().then(
      (_) async {
        print('notiPostLength : ${notiPost.length}');

        // Database에 장애 처리현황 또는 문의 처리현황 게시물에 대한 댓글(comment)의 개수를 찾아
        // commentCount Array에 값을 대입하는 method
        await getCountFromComments();

        print('commentCountLength : ${commentCount.length}');

        // Flutter Local Notification Setting
        await localNotificationInitialize();

        print('Flutter Local Notification Setting 완료');

        // Database에서 장애 처리현황 또는 문의 처리현황 게시물에 대한 댓글 변동사항을 listen한다.
        await setListen();

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
