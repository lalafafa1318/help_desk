import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/notificationClassification.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/notification_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:help_desk/utils/uuid_util.dart';
import 'package:intl/intl.dart';

// 알림 목록을 관리하는 controller 입니다.
class NotificationController extends FullLifeCycleController {
  /* 일반 요청자, IT 담당자(IT 1실, 2실)가 댓글 알림 신청했을 떄 바탕이 되는 데이터 */

  // 사용자가 알림 신청한 게시물 Uid를 담는 배열
  List<String> commentNotificationPostUidList = [];
  // 사용자가 알림 신청한 게시물에 대한 댓글 개수를 담는 배열
  List<int> commentCount = [];
  // 사용자가 알림 신청한 게시물을 실시간으로 Listen 하는 배열
  List<StreamSubscription<QuerySnapshot>> commentNotificationListenList = [];
  // Database에 저장된 commentNotifications에 있는 데이터를 가져와 저장하는 배열
  List<NotificationModel> commentNotificationModelList = [];

  /* IT 담당자(IT 1실, 2실)가 담당하는 시스템이 명시된 게시물이 업로드 됐을 떄 알림 받기 위해 바탕이 되는 데이터 */

  // DataBase에 저장된 requestNotifications에 있는 데이터를 가져와 저장하는 배열
  List<NotificationModel> requestNotificationModelList = [];

  // 장애 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물이 업로드 되는지 확인하는 변수
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> it1UserListen;
  // IT 1실 관리자가 담당하는 시스템을 가진 게시물 총 개수
  int it1UserProcessITRequestPostsSize = 0;

  // 장애 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물이 업로드 되는지 확인하는 변수
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> it2UserListen;
  // IT 2실 관리자가 담당하는 시스템을 가진 게시물 총 개수
  int it2UserProcessITRequestPostsSize = 0;

  /* Flutter Local Notification과 관련된 부분 */

  // Flutter Local Notification initalize를 위해 필요한 변수
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // 요청 알림 또는 댓글 알림이 왔을 떄 가장 최근 시간에 온 알림을 저장하는 변수
  late NotificationModel allNotificationModel;

  /* 각종 기타 설정 */

  // IT 담당자의 경우, 알림 페이지에서 요청 알림 목록을 클릭했는지, 댓글 알림 목록을 클릭했는지 판별하는 변수
  NotificationClassification notificationClassification =
      NotificationClassification.REQUESTNOTIFICATION;
  // FirebaseFiresStore과 관련된 하나의 객체만 쓰기 위해서 설정했다.
  final FirebaseFirestore firebaseFirestore =
      CommunicateFirebase.getFirebaseFirestoreInstnace();

  // Method
  // Controller를 더 쉽게 사용할 수 있도록 하는 get method
  static NotificationController get to => Get.find();

  // Database에 User의 commentNotificationPostUid 속성을 가져와 위 필드인 commentNotificationPostUidList에 값을 대입한다.
  Future<void> getCommentNotificationPostUid() async {
    commentNotificationPostUidList.addAll(
      await CommunicateFirebase.getCommentNotificationPostUid(
          AuthController.to.user.value.userUid),
    );
  }

  /* 위 필드의 commentNotificationPostUidList의 성분,즉 사용자가 알림 신청한 게시물 uid를 이용한다.
     게시물 uid를 이용하여 DataBase에 게시물에 대한 댓글 개수를 찾는다. 다음으로 위 필드인 commentCount에 값을 대입한다 */
  Future<void> getPostCommentCount() async {
    for (int i = 0; i < commentNotificationPostUidList.length; i++) {
      int count = await CommunicateFirebase.getPostCommentCount(
          commentNotificationPostUidList[i]);

      commentCount.add(count);
    }
  }

  // DataBase에서 사용자가 알림 신청한 게시물에 대한 댓글 변동 사항을 listen한다.
  Future<void> setCommentNotificationListen() async {
    for (int i = 0; i < commentNotificationPostUidList.length; i++) {
      await commentNotificationListenMainCode(i);
    }
  }

  // DataBase에서 사용자가 알림 신청한 게시물에 대한 댓글 변동 사항을 listen한다.
  Future<void> addCommentNotificationListen(int index) async {
    await commentNotificationListenMainCode(index);
  }

  // 사용자가 알림 신청한 게시물에 대해서 댓글 변동 사항을 listen 하는 메인 내용을 담은 method
  Future<void> commentNotificationListenMainCode(int index) async {
    // DataBase에서 IT 요청건 게시물 정보를 받아온다.
    DocumentSnapshot<Map<String, dynamic>> postPath = await firebaseFirestore
        .collection('itRequestPosts')
        .doc(commentNotificationPostUidList[index])
        .get();

    /* 사용자가 알림 신청한 게시물 Uid를 이용하여
       댓글에 대한 변동 사항을 실시간으로 Listen하는 위 필드 commentNotificationListenList에 추가한다. */
    commentNotificationListenList.add(
      postPath.reference.collection('comments').snapshots().listen(
        (QuerySnapshot<Map<String, dynamic>> event) async {
          // 로컬에서 댓글 개수를 저장해 두었다가 DataBase에 댓글 개수가 더 큰가를 판단한다.
          if (commentCount[index] < event.size) {
            // Database에 있는 댓글(comment)에 uploadTime 속성이 가장 최근인 데이터를 가져온다.
            QuerySnapshot<Map<String, dynamic>> comments = await postPath
                .reference
                .collection('comments')
                .orderBy('uploadTime', descending: false)
                .get();
            // 사용자가 알림 신청한 게시물에 댓글을 작성할 떄는 Flutter Local Notification을 보내지 않도록 한다.
            if (comments.docs.last.data()['whoWriteUserUid'].toString() !=
                SettingsController.to.settingUser!.userUid) {
              // 사용자 정보를 받아온다.
              DocumentSnapshot<Map<String, dynamic>> user =
                  await firebaseFirestore
                      .collection('users')
                      .doc(postPath.data()!['userUid'].toString())
                      .get();

              // NotificationModel을 만든다.
              NotificationModel noti = NotificationModel(
                title:
                    '${user.data()!['userName'].toString()} - ${postPath.data()!['postTitle'].toString()}',
                body:
                    '새로운 댓글이 달렸어요 : ${comments.docs.last.data()['content'].toString()}',
                notiUid: UUidUtil.getUUid(),
                belongNotiPostUid: commentNotificationPostUidList[index],
                notiTime: DateFormat('yy/MM/dd - HH:mm:ss').format(
                  DateTime.now(),
                ),
              );

              // 요청 알림 또는 댓글 알림이 왔을 떄 가장 최근 시간에 온 알림을 저장하는 변수
              allNotificationModel = noti;

              // Flutter Local Notification 전송
              await showGroupNotifications(
                // 댓글이 작성된 게시물 작성자 - 댓글이 작성된 게시물 제목
                title:
                    '${user.data()!['userName'].toString()} - ${postPath.data()!['postTitle'].toString()}',
                // 댓글 내용
                body:
                    '새로운 댓글이 달렸어요 : ${comments.docs.last.data()['content'].toString()}',
              );

              // Database에 Notification을 저장한다.
              await firebaseFirestore
                  .collection('users')
                  .doc(SettingsController.to.settingUser!.userUid)
                  .collection('commentNotifications')
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

  // DataBase에서 IT 1실 담당자가 처리해야 하는 시스템이 명시된 IT 요청건 게시물 총 개수를 가져오는 method
  Future<void> getIT1UserProcessITRequestPostsSize() async {
    // DataBase에서 IT 1실 관리자가 처리해야 하는 시스템이 명시된 IT 요청거 게시물 총 개수를 가져온다.
    QuerySnapshot<Map<String, dynamic>> result =
        await firebaseFirestore.collection('itRequestPosts').where(
      'sysClassficationCode',
      whereIn: [
        'SysClassification.WICS',
        'SysClassification.ICMS',
        'SysClassification.SALES',
        'SysClassification.EXPENSIVE',
        'SysClassification.NGOS',
        'SysClassification.NCCS',
        'SysClassification.NCCSSB',
      ],
    ).get();

    it1UserProcessITRequestPostsSize = result.size;

    // log
    print(
        'it1UserProcessITRequestPostsSize : $it1UserProcessITRequestPostsSize');
  }

  // DataBase에서 IT 2실 담당자가 처리해야 하는 시스템이 명시된 IT 요청건 게시물 총 개수를 가져오는 method
  Future<void> getIT2UserProcessITRequestPostsSize() async {}

  /* 사용자 자격이 IT 1실 관리자이다.
     일반 요청자가 IT 1실 관리자가 담당하는 시스템을 적용한 게시물을 업로드할 떄 listen한다. */
  Future<void> it1UserListenITRequestPosts() async {
    it1UserListen = firebaseFirestore
        .collection('itRequestPosts')
        .where('sysClassficationCode', whereIn: [
          'SysClassification.WICS',
          'SysClassification.ICMS',
          'SysClassification.SALES',
          'SysClassification.EXPENSIVE',
          'SysClassification.NGOS',
          'SysClassification.NCCS',
          'SysClassification.NCCSSB',
        ])
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> event) async {
          // 일반 요청자가 IT 1실이 담당하는 시스템을 적용한 게시물을 업로드할 떄 알림을 보낸다.
          if (it1UserProcessITRequestPostsSize < event.size) {
            // sort를 하기 위해 데이터 타입을 List<QueryDocumentSnapshot<Map<String, dynamic>>> 으로 만든다.
            List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = event.docs;

            /* DataBase에 있는 obsPosts에 대한 postTime 속성을 오름차순으로 정렬한다.
               즉, 가장 오래된 postTime은 맨 앞에, 가장 최근 postTime은 맨 뒤에 배치될 것이다. */
            docs.sort(
              (
                QueryDocumentSnapshot<Map<String, dynamic>> a,
                QueryDocumentSnapshot<Map<String, dynamic>> b,
              ) =>
                  a.data()['postTime'].toString().compareTo(
                        b.data()['postTime'].toString(),
                      ),
            );

            // 가장 최근 postTime을 가진 게시물을 가져온다.
            QueryDocumentSnapshot<Map<String, dynamic>> recentObsPost =
                docs.last;

            /* 그럴 일은 가능성이 낮겠지만 IT 1실 담당자 자격의 자신이 IT 1실 담당자가 관리하는 시스템 관련 게시물을 올렸을 떄는 이하 if문을 실행하지 않도록 한다.
               즉 나 자신 말고 다른 사람이 IT 1실 담당자가 관리하는 시스템 관련 게시물을 올렸을 때, 이하 if문을 실행한다. */
            if (recentObsPost.data()['userUid'] !=
                SettingsController.to.settingUser!.userUid) {
              // Flutter Local Notification을 띄울 떄 title에 게시물 업로드한 사용자를 보여주기 위해서 DataBase에 사용자 정보를 가져온다.
              String userUid = recentObsPost.data()['userUid'].toString();
              DocumentSnapshot<Map<String, dynamic>> user =
                  await firebaseFirestore
                      .collection('users')
                      .doc(userUid)
                      .get();

              // NotificationModel을 만든다.
              NotificationModel noti = NotificationModel(
                title:
                    '${user.data()!['userName'].toString()} - ${recentObsPost.data()['postTitle'].toString()}',
                body:
                    'IT1실 담당자가 처리해야 할 요청건이 게시되었습니다.\n시스템은 ${SysClassification.values.firstWhere((element) => element.toString() == recentObsPost.data()['sysClassficationCode'].toString()).asText} 입니다.',
                notiUid: UUidUtil.getUUid(),
                belongNotiPostUid: recentObsPost.data()['postUid'].toString(),
                notiTime:
                    DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now()),
              );

              // 요청 알림 또는 댓글 알림이 왔을 떄 가장 최근 시간에 온 알림을 저장하는 변수
              allNotificationModel = noti;

              // Flutter Local Notification을 띄운다.
              await showGroupNotifications(
                // 게시물 작성자 - 댓글이 작성된 게시물 제목
                title:
                    '${user.data()!['userName'].toString()} - ${recentObsPost.data()['postTitle'].toString()}',
                // 게시물 시스템 분류 코드를 나타낸다.
                body:
                    'IT1실 담당자가 처리해야 할 요청건이 게시되었습니다.\n시스템은 ${SysClassification.values.firstWhere((element) => element.toString() == recentObsPost.data()['sysClassficationCode'].toString()).asText} 입니다.',
              );

              // Database에 requestNotifications에 알림 데이터를 저장한다.
              await firebaseFirestore
                  .collection('users')
                  .doc(SettingsController.to.settingUser!.userUid)
                  .collection('requestNotifications')
                  .doc(noti.notiUid)
                  .set(NotificationModel.toMap(noti));
            }
          }
          // it1UserProcessITRequestPostsSize의 값을 최신의 값으로 업데이트 한다.
          it1UserProcessITRequestPostsSize = event.size;
        });
  }

  /* 사용자 자격이 IT 2실 관리자이다.
     일반 요청자가 IT 2실 관리자가 담당하는 시스템과 관련된 게시물을 업로드할 떄 listen한다. */
  Future<void> it2UserListenITRequestPosts() async {}

  /* Database에 User의 commentNotificationPostUid 속성에
     사용자가 알림 신청한 게시물 uid를 추가한다. */
  Future<void> addCommentNotificationPostUid(
      String postUid, String userUid) async {
    await CommunicateFirebase.addCommentNotificationPostUid(postUid, userUid);
  }

  /* Database에 User의 commentNotificationPostUid 속성에
     사용자가 알림 신청한 게시물 uid를 삭제한다. */
  Future<void> deleteCommentNotificationPostUid(
      String postUid, String userUid) async {
    await CommunicateFirebase.deleteCommentNotificationPostUid(
        postUid, userUid);
  }

  // DataBase에 requestNotifications에 있는 알림 기록을 가져올지, commentNotifications에 있는 알림 기록을 가져올지 결정하는 method
  Future<List<NotificationModel>> getRequestORCommentNotificationModelList(
      String userUid) async {
    /* 사용자 자격이 일반 요청자인지, IT 담당자인지 확인한다.
       일반 요청자는 무조건 DataBase에 commentNotifications에 있는 알림 기록을 가져온다.
       IT 담당자는 DataBase에 requestNotifications에 있는 알림 기록을 가져오기도 하고, DataBase에 commentNotifications을 가져오기도 한다. */
    SettingsController.to.settingUser!.userType ==
            UserClassification.GENERALUSER
        ? await getCommentNotificationModelList(userUid)
        : notificationClassification ==
                NotificationClassification.REQUESTNOTIFICATION
            ? await getRequestNotificationModelList(userUid)
            : await getCommentNotificationModelList(userUid);

    return SettingsController.to.settingUser!.userType ==
            UserClassification.GENERALUSER
        ? commentNotificationModelList
        : notificationClassification ==
                NotificationClassification.REQUESTNOTIFICATION
            ? requestNotificationModelList
            : commentNotificationModelList;
  }

  // Database에 commentNotificaions에 있는 알림 기록를 모두 가져오는 method
  Future<void> getCommentNotificationModelList(String userUid) async {
    commentNotificationModelList.clear();

    commentNotificationModelList.addAll(
        await CommunicateFirebase.getCommentNotificationModelList(userUid));
  }

  // Database에 requestNotificaions에 있는 알림 기록를 모두 가져오는 method
  Future<void> getRequestNotificationModelList(String userUid) async {
    requestNotificationModelList.clear();

    requestNotificationModelList.addAll(
        await CommunicateFirebase.getRequestNotificationModelList(userUid));
  }

  // Databse에 commentNotifications에 있는 어떤 알림을 삭제하는 method
  Future<void> deleteCommentNotification(String notiUid, String userUid) async {
    await CommunicateFirebase.deleteCommentNotification(notiUid, userUid);
  }

  // Databse에 requestNotifications에 있는 어떤 알림을 삭제하는 method
  Future<void> deleteRequestNotification(String notiUid, String userUid) async {
    await CommunicateFirebase.deleteRequestNotification(notiUid, userUid);
  }

  // 사용자가 게시물에 대한 댓글 알림을 신청할 떄, 위 게시물에 대해서 알림 받기 위한 여러 설정을 등록한다
  Future<void> enrollCommentNotificationSettings(String postUid) async {
    // NotificationControler의 commentNotificationPostUidList에 게시물 uid를 추가한다.
    commentNotificationPostUidList.add(postUid);

    // 해당 게시물 Uid가 commentNotificationPostUidList의 몇번째 index에 있는지 확인한다.
    int index = commentNotificationPostUidList.indexOf(postUid);

    // DataBase에서 사용자가 알림 신청한 게시물에 대한 댓글 개수를 받아와서 NotificationController의 commentCount에 추가한다.
    commentCount.add(
      await CommunicateFirebase.getPostCommentCount(postUid),
    );

    // Database에서 사용자가 알림 신청한 게시물의 댓글 변동 사항을 실시간으로 listen한다.
    await addCommentNotificationListen(index);

    // DataBase에 User의 commentNotificationPostUid 속성에 사용자가 알림 신청한 게시물 uid를 추가한다.
    await addCommentNotificationPostUid(
      postUid,
      SettingsController.to.settingUser!.userUid,
    );
  }

  // 사용자가 게시물에 대한 댓글 알림을 해제할 떄, 위 게시물에 대해서 알림 받기 위해 했던 여러 설정을 해제한다.
  Future<void> clearCommentNotificationSettings(String postUid) async {
    // 사용자가 알림 신청했던 게시물 Uid를 가지고
    // 위 필드 commentNotificationPostUidList의 몇번쨰 index에 있는지 확인한다.
    int index = commentNotificationPostUidList.indexOf(postUid);

    // 사용자가 알림 신청 했던 게시물의 변동 사항을 실시간으로 listen 하던 것을 취소한다.
    commentNotificationListenList[index].cancel();

    // 사용자가 알림 신청 했던 게시물 변동 사항을 실시간으로 listen 하고 있던 element을 clear 한다.
    commentNotificationListenList.removeAt(index);

    // 위 필드 commentNotificationPostUidList에 사용자가 알림 신청 했었던 게시물 uid를 찾아 clear 한다.
    commentNotificationPostUidList.removeAt(index);

    // 위 필드 commentCount에 사용자가 알림 신청 했었던 게시물의 댓글 개수를 저장해뒀던 것을 삭제한다.
    commentCount.removeAt(index);

    // DataBase에 User의 commentNotifictionPostUid 속성에 사용자가 알림 신청했었던 게시물 uid를 삭제한다.
    await deleteCommentNotificationPostUid(
      postUid,
      SettingsController.to.settingUser!.userUid,
    );
  }

  // Flutter Local Notification을 setting 하는 method
  Future<void> localNotificationInitialize() async {
    // 안드로이드 세팅
    AndroidInitializationSettings androidIntialize =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    // iOS 세팅
    IOSInitializationSettings iOSInitialize = const IOSInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidIntialize,
      iOS: iOSInitialize,
    );

    // Flutter Local Notification 설정 완료
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 사용자 스마트폰에 있는 알림을 선택할 떄 호출되는 callBack Method
      onSelectNotification: ((String? payload) async {
        if (payload != null && payload.isNotEmpty) {
          /* 사용자가 SpecificPostPage에 있고, 알림을 클릭했을 떄 알림과 관련된 게시물이 나오지 않는 것을 대비해서
             Get.back()을 사용하고 다시 SpecificPostPage로 전환되는 방향으로 기조를 가진다. */
          Get.back();

          // payload를 log로 찍는다.
          print('payload : $payload');

          /* 알림과 관련있는 SpecificPostPage로 Routing한다.
             callBack Method의 매개변수 payload에는 알림이 어떤 게시물과 관련되어 있는지 확인하는 belongNotiPostUid가 있다. 
             해당 속성을 이용하여 SpecificPostPage로 Routing 한다. */
          DocumentSnapshot<Map<String, dynamic>> postData =
              await firebaseFirestore
                  .collection('itRequestPosts')
                  .doc(payload)
                  .get();

          // 게시물에 따른 사용자 정보도 뽑아낸다.
          DocumentSnapshot<Map<String, dynamic>> userData =
              await firebaseFirestore
                  .collection('users')
                  .doc(postData.data()?['userUid'].toString())
                  .get();
          // 장애 처리현황 게시물 정보가 삭제되지 않았다면?
          if (postData.data() != null) {
            // 일반 클래스 형식으로 전환하기 위해 fromMap를 쓴다.
            PostModel postModel = PostModel.fromMap(postData.data()!);
            UserModel userModel = UserModel.fromMap(userData.data()!);

            /* SpecificPostPage로 Routing한다.
                 argument 0번쨰 : 의미 없는 값이다.
                 argument 1번쨰 : 스마트폰 환경의 알림에서 SpecificPostPage로 Routing 되었다는 것을 알린다.
                 argument 2번쨰 : 알림과 관련된 게시물 정보(일반 클래스 형식)을 전달한다.
                 argument 3번째 : 알림과 관련된 게시물에 따른 사용자 정보(일반 클래스 형식)을 전달한다. */
            Get.to(
              () => const SpecificPostPage(),
              arguments: [
                0,
                RouteDistinction.SMARTPHONENOTIFICATION_TO_SPECIFICPOSTPAGE,
                postModel,
                userModel,
              ],
            );
          }
          // 장애 처리현황 게시물이 삭제되었다면?
          else {
            ToastUtil.showToastMessage('알림과 관련된 게시물이 삭제되었습니다.');
          }
        }
        //
        else {
          print('payload가 없습니다.');
        }
      }),
    );
  }

  // Flutter Loal Notification을 show하는 method
  Future<void> showGroupNotifications({required String title, required String body}) async {
    /* 그룹 알림으로 띄우기 위해서 필요한 변수 설정 */
    const String groupKey = 'com.android.example.help_Desk';
    const String groupChannelId = 'help_Desk ID';
    const String groupChannelName = 'help_Desk Name';
    const String groupChannelDescription = 'help_Desk Description';

    // AndroidNotificationDetails를 설정한다.
    const AndroidNotificationDetails notificationAndroidSpecifics =
        AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      channelDescription: groupChannelDescription,
      groupKey: groupKey,
      importance: Importance.max,
      priority: Priority.high,
    );

    // IOSNotificationDetails를 합쳐서 NotificationDetails를 완성한다.
    NotificationDetails notificationPlatformSpecifics =
        const NotificationDetails(
      android: notificationAndroidSpecifics,
      iOS: IOSNotificationDetails(threadIdentifier: 'iOSGroup'),
    );

    // 알림을 보여준다.
    await flutterLocalNotificationsPlugin.show(
      // id -> 랜덤값을 줘서 id를 결정한다.
      Random().nextInt(1000000),
      // title
      allNotificationModel.title,
      // body
      allNotificationModel.body,
      // notificationDetails
      notificationPlatformSpecifics,
      // payload
      // 스마트폰에 표시된 알림에서 알림이 어디 게시물과 연관되어있는지 알 수 있는 belongNotiPostUid으로 전달한다.
      payload: allNotificationModel.belongNotiPostUid,
    );

    /* 그룹화된 알림을 설정하고 보여준다. */
    InboxStyleInformation inboxStyleInformation = const InboxStyleInformation(
      [],
      contentTitle: '',
      summaryText: '요청 및 댓글 알림',
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      channelDescription: groupChannelDescription,
      groupKey: groupKey,
      styleInformation: inboxStyleInformation,
      setAsGroupSummary: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const IOSNotificationDetails(threadIdentifier: 'iOSGroup'));

    flutterLocalNotificationsPlugin.show(
      -1,
      '',
      '',
      platformChannelSpecifics,
    );
  }

  // NotificationController가 처음 메모리에 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    // Database에 User의 commentNotificationPostUid 속성을 가져와 위 필드인 commentNotificationPostUidList에 값을 대입한다.
    getCommentNotificationPostUid().then(
      (_) async {
        print(
            'commentNotificationPostUidListLength : ${commentNotificationPostUidList.length}');

        /* 위 필드의 commentNotificationPostUidList의 성분, 즉 사용자가 알림 신청한 게시물 uid를 이용한다.
           게시물 uid를 이용하여 DataBase에 IT 요청건 게시물에 대한 댓글 개수를 찾는다.
           다음으로 위 필드인 commentCount에 값을 대입한다. */
        await getPostCommentCount();
        print('commentCountLength : ${commentCount.length}');

        // Flutter Local Notification Setting //
        await localNotificationInitialize();
        print('Flutter Local Notification Setting 완료');

        // DataBase에서 사용자가 알림 신청한 IT 요청건 게시물에 대한 댓글 변동 사항을 listen한다.
        await setCommentNotificationListen();

        /* 사용자 자격이 IT 1실, 2실 관리자 일 떄
           DataBase에서 IT 1실 담당자가 처리해야 하는 시스템이 명시된 IT 요청건 게시물 총 개수를 가져온다.
           DataBase에서 IT 2실 담당자가 처리해야 하는 시스템이 명시된 IT 요청건 게시물 총 개수를 가져온다. */
        AuthController.to.user.value.userType == UserClassification.GENERALUSER
            ? null
            : AuthController.to.user.value.userType ==
                    UserClassification.IT1USER
                ? await getIT1UserProcessITRequestPostsSize()
                : await getIT2UserProcessITRequestPostsSize();

        /* 사용자 자격이 IT 1실, 2실 관리자이고
          일반 요청자가 IT 1실, 2실 관리자가 담당하는 시스템과 관련된 게시물을 업로드할 떄 listen한다. */
        AuthController.to.user.value.userType == UserClassification.GENERALUSER
            ? null
            : AuthController.to.user.value.userType ==
                    UserClassification.IT1USER
                ? await it1UserListenITRequestPosts()
                : await it2UserListenITRequestPosts();
      },
    );
  }

  // NotificationController가 메모리에 내려갈 떄 호출되는 method
  @override
  void onClose() {
    /* 사용자 자격이 IT 1실 담당자이면,
       IT 요청건 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물이 업로드 되는지 listen 하던 것을 cancel 한다. */
    if (AuthController.to.user.value.userType == UserClassification.IT1USER) {
      it1UserListen.cancel();
    }

    /* 사용자 자격이 IT 2실 담당자이면,
       장애 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물이 업로드 되는지 listen 하던 것을 cancel 한다. */
    if (AuthController.to.user.value.userType == UserClassification.IT2USER) {}

    // 사용자가 알림 신청 했던 게시물의 변동 사항을 실시간으로 listen 하던 것을 취소한다.
    commentNotificationListenList.map(
      (commentNotificationListenElement) =>
          commentNotificationListenElement.cancel(),
    );

    // 데이터 clear
    commentNotificationPostUidList.clear();
    commentCount.clear();
    commentNotificationListenList.clear();

    super.onClose();
  }
}
