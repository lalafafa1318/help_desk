import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/notificationClassification.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/notification_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/utils/uuid_util.dart';
import 'package:intl/intl.dart';

// 알림 목록을 관리하는 controller 입니다.
class NotificationController extends GetxController {
  // **** 일반 요청자, IT 담당자(IT 1실, 2실)가 자의적으로 알림 신청했을 떄 바탕이 되는 데이터 **** //
  // 사용자가 알림 신청한 게시물 Uid를 담는 배열
  List<String> commentNotificationPostUidList = [];
  // 사용자가 알림 신청한 게시물에 대한 댓글 개수를 담는 배열
  List<int> commentCount = [];
  // 사용자가 알림 신청한 게시물을 실시간으로 Listen 하는 배열
  List<StreamSubscription<QuerySnapshot>> commentNotificationListenList = [];
  // Database에 저장된 commentNotifications에 있는 데이터를 가져와 저장하는 배열
  List<NotificationModel> commentNotificationModelList = [];

  // **** IT 담당자(IT 1실, 2실)가 담당하는 시스템이 명시된 게시물이 업로드 됐을 떄 알림 받기 위해 바탕이 되는 데이터 **** //
  // DataBase에 저장된 requestNotifications에 있는 데이터를 가져와 저장하는 배열
  List<NotificationModel> requestNotificationModelList = [];
  // 장애 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물이 업로드 되는지 확인하는 변수
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      it1UserObsPostListen;
  // 장애 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물 총 개수
  int obsPostsIT1Count = 0;
  // 문의 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물이 업로드 되는지 확인하는 변수
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      it1UserInqPostListen;
  // 문의 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물 총 개수
  int inqPostsIT1Count = 0;
  // 장애 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물이 업로드 되는지 확인하는 변수
  // 장애 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물 총 개수
  int obsPostsIT2Count = 0;
  // 문의 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물이 업로드 되는지 확인하는 변수
  // 문의 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물 총 개수
  int inqPostsIT2Count = 0;

  // **** 각종 기타 설정 **** //
  // 오직 하나의 Instnace만 쓰도록 하기 위해 설정했다.
  final FirebaseFirestore firebaseFirestore =
      CommunicateFirebase.getFirebaseFirestoreInstnace();
  // Flutter Local Notification에 필요한 변수
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // IT 담당자의 경우, 알림 페이지에서 요청 알림 목록을 클릭했는지, 댓글 알림 목록을 클릭했는지 판별하는 변수
  NotificationClassification notificationClassification =
      NotificationClassification.REQUESTNOTIFICATION;

  // Method
  // Controller를 더 쉽게 사용할 수 있도록 하는 get method
  static NotificationController get to => Get.find();

  // Database에 User의 commentNotificationPostUid 속성을 가져와 위 필드인 commentNotificationPostUidList에 값을 대입한다.
  Future<void> getCommentNotificationPostUid() async {
    commentNotificationPostUidList.addAll(
      await CommunicateFirebase.getCommentNotificationPostUid(
        AuthController.to.user.value.userUid,
      ),
    );
  }

  // 위 필드의 commentNotificationPostUidList의 성분,즉 사용자가 알림 신청한 게시물 uid를 이용한다.
  // 게시물 uid를 이용하여 DataBase에 게시물에 대한 댓글 개수를 찾는다. 다음으로 위 필드인 commentCount에 값을 대입한다.
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
    // 사용자가 알림 신청한 게시물에 대한 정보
    DocumentSnapshot<Map<String, dynamic>> postPath;

    // 알림 신청한 게시물이 장애 처리현황인지 문의 처리현황인지 확인한다.
    DocumentSnapshot<Map<String, dynamic>> whichBelongPostUid =
        await firebaseFirestore
            .collection('obsPosts')
            .doc(commentNotificationPostUidList[index])
            .get();

    // 알림 신청한 게시물이 장애 처리현황에 속한다면?
    // 알림 신청한 게시물이 장애 처리현황에 속하지 않는다면?
    whichBelongPostUid.data() != null
        ? postPath = await firebaseFirestore
            .collection('obsPosts')
            .doc(commentNotificationPostUidList[index])
            .get()
        : postPath = await firebaseFirestore
            .collection('inqPosts')
            .doc(commentNotificationPostUidList[index])
            .get();

    // 사용자가 알림 신청한 게시물 Uid를 이용하여
    // 댓글에 대한 변동 사항을 실시간으로 Listen하는 위 필드 commentNotificationListenList에 추가한다.
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

              // Flutter Local Notification 전송
              await showBigTextNotification(
                // 댓글이 작성된 게시물 작성자 - 댓글이 작성된 게시물 제목
                title:
                    '${user.data()!['userName'].toString()} - ${postPath.data()!['postTitle'].toString()}',
                // 댓글 내용
                body:
                    '새로운 댓글이 달렸어요 : ${comments.docs.last.data()['content'].toString()}',
              );

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
                belongNotiObsOrInq: ObsOrInqClassification.values.firstWhere(
                  (element) =>
                      element.toString() ==
                      postPath.data()!['obsOrInq'].toString(),
                ),
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

  // 사용자가 알림 신청한 게시물
  // DataBase에서
  // IT 1실 담당자가 처리해야 하는 시스템이 명시된 장애 처리현황 게시물 총 개수
  // IT 1실 담당자가 처리해야 하는 시스템이 명시된 문의 처리현황 게시물 총 개수를 가져오는 method
  Future<void> getIT1ObsAndInqPostSize() async {
    // DataBase에서 IT 1실 담당자가 처리해야 하는 시스템이 명시된 장애 처리현황 게시물 총 개수를 가져온다.
    QuerySnapshot<Map<String, dynamic>> obsPostsIT1Size =
        await firebaseFirestore
            .collection('obsPosts')
            .where('sysClassficationCode', whereIn: [
      'SysClassification.WICS',
      'SysClassification.ICMS',
      'SysClassification.SALES',
      'SysClassification.EXPENSIVE',
      'SysClassification.NGOS',
      'SysClassification.NCCS',
      'SysClassification.NCCSSB',
    ]).get();

    // DataBase에서 IT 1실 담당자가 처리해야 하는 시스템이 명시된 문의 처리현황 게시물 총 개수를 가져온다.
    QuerySnapshot<Map<String, dynamic>> inqPostsIT1Size =
        await firebaseFirestore
            .collection('inqPosts')
            .where('sysClassficationCode', whereIn: [
      'SysClassification.WICS',
      'SysClassification.ICMS',
      'SysClassification.SALES',
      'SysClassification.EXPENSIVE',
      'SysClassification.NGOS',
      'SysClassification.NCCS',
      'SysClassification.NCCSSB',
    ]).get();

    // NotificationController의 상태 변수 obsPostsIT1Count, inqPostsIT1Count에 값을 대입한다.
    obsPostsIT1Count = obsPostsIT1Size.size;
    inqPostsIT1Count = inqPostsIT1Size.size;

    // log
    print('obsPostsIT1Count : $obsPostsIT1Count');
    print('inqPostsIT1Count : $inqPostsIT1Count');
  }

  // DataBase에서
  // IT 2실 담당자가 처리해야 하는 시스템이 명시된 장애 처리현황 게시물 총 개수
  // IT 2실 담당자가 처리해야 하는 시스템이 명시된 문의 처리현황 게시물 총 개수를 가져오는 method
  Future<void> getIT2ObsAndInqPostSize() async {}

  // 사용자 자격이 IT 1실 관리자이다.
  // 일반 요청자가 IT 1실 관리자가 담당하는 시스템을 적용한 게시물을 업로드할 떄 listen한다.
  Future<void> it1UserListen() async {
    // 사용자가 업로드한 장애 처리현황 게시물에 대해서 listen한다.
    // 그중에서 IT 1실이 담당하는 시스템(WICS, ICMS, SALES, EXPENSIVE, NGOS, NCCS, NCCSB로 가정한다.)
    // 을 적은 게시물만 분류하여, IT 1실 담당자에게 알림을 보낸다.
    await it1UserObsListen();

    // 사용자가 업로드한 문의 처리현황 게시물에 대해서 listen한다.
    // 그중에서 IT 1실이 담당하는 시스템(WICS, ICMS, SALES, EXPENSIVE, NGOS, NCCS, NCCSB로 가정한다.)
    // 을 적은 게시물만 분류하여, IT 1실 담당자에게 알림을 보낸다.
    await it1UserInqListen();
  }

  // 일반 요청자가 IT 1실 관리자가 담당하는 시스템을 적용한 장애 처리 현황 게시물을 업로드할 떄 listen한다.
  Future<void> it1UserObsListen() async {
    it1UserObsPostListen = firebaseFirestore
        .collection('obsPosts')
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
          if (obsPostsIT1Count < event.size) {
            // sort를 하기 위해 데이터 타입을 List<QueryDocumentSnapshot<Map<String, dynamic>>> 으로 만든다.
            List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = event.docs;

            // DataBase에 있는 obsPosts에 대한 postTime 속성을 오름차순으로 정렬한다.
            // 즉, 가장 오래된 postTime은 맨 앞에, 가장 최근 postTime은 맨 뒤에 배치될 것이다.
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

            // Flutter Local Notification을 띄울 떄 title에 게시물 업로드한 사용자를 보여주기 위해서 DataBase에 사용자 정보를 가져온다.
            String userUid = recentObsPost.data()['userUid'].toString();
            DocumentSnapshot<Map<String, dynamic>> user =
                await firebaseFirestore.collection('users').doc(userUid).get();

            // Flutter Local Notification을 띄운다.
            // Flutter Local Notification 전송
            await showBigTextNotification(
              // 게시물 작성자 - 댓글이 작성된 게시물 제목
              title:
                  '${user.data()!['userName'].toString()} - ${recentObsPost.data()['postTitle'].toString()}',
              // 게시물 시스템 분류 코드를 나타낸다.
              body:
                  'IT1실 담당자가 처리해야 할 요청건이 게시되었습니다.\n시스템은 ${SysClassification.values.firstWhere((element) => element.toString() == recentObsPost.data()['sysClassficationCode'].toString()).asText} 입니다.',
            );

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
              belongNotiObsOrInq: ObsOrInqClassification.values.firstWhere(
                (element) =>
                    element.toString() ==
                    recentObsPost.data()['obsOrInq'].toString(),
              ),
            );

            // Database에 Notification을 저장한다.
            await firebaseFirestore
                .collection('users')
                .doc(SettingsController.to.settingUser!.userUid)
                .collection('requestNotifications')
                .doc(noti.notiUid)
                .set(NotificationModel.toMap(noti));
          }
          // obsPostIT1Count의 갑을 최신의 값으로 업데이트 한다.
          obsPostsIT1Count = event.size;
        });
  }

  // 일반 요청자가 IT 1실 관리자가 담당하는 시스템을 적용한 문의  처리 현황 게시물을 업로드할 떄 listen한다.
  Future<void> it1UserInqListen() async {
    it1UserInqPostListen = firebaseFirestore
        .collection('inqPosts')
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
        .listen((QuerySnapshot<Map<String, dynamic>> event) {
          print('inqPosts - IT 1실 담당자에게 알림이 갑니다.');
        });
  }

  // 사용자 자격이 IT 2실 관리자이다.
  // 일반 요청자가 IT 2실 관리자가 담당하는 시스템과 관련된 게시물을 업로드할 떄 liste한다.
  Future<void> it2UserListen() async {
    await it2UserObsListen();

    await it2UserInqListen();
  }

  // 일반 요청자가 IT 2실 관리자가 담당하는 시스템을 적용한 장애 처리 현황 게시물을 업로드할 떄 listen한다.
  Future<void> it2UserObsListen() async {}

  // 일반 요청자가 IT 2실 관리자가 담당하는 시스템을 적용한 문의 처리 현황 게시물을 업로드할 떄 listen한다.
  Future<void> it2UserInqListen() async {}

  // Database에 User의 commentNotificationPostUid 속성에
  // 사용자가 알림 신청한 게시물 uid를 추가한다.
  Future<void> addCommentNotificationPostUid(
      String postUid, String userUid) async {
    await CommunicateFirebase.addCommentNotificationPostUid(postUid, userUid);
  }

  // Database에 User의 commentNotificationPostUid 속성에
  // 사용자가 알림 신청한 게시물 uid를 삭제한다.
  Future<void> deleteCommentNotificationPostUid(
      String postUid, String userUid) async {
    await CommunicateFirebase.deleteCommentNotificationPostUid(
        postUid, userUid);
  }

  // DataBase에 requestNotifications에 있는 알림 기록을 가져올지, commentNotifications에 있는 알림 기록을 가져올지 결정하는 method
  Future<List<NotificationModel>> getRequestORCommentNotificationModelList(String userUid) async {
    // 사용자 자격이 일반 요청자인지, IT 담당자인지 확인한다.
    // 일반 요청자는 무조건 DataBase에 commentNotifications에 있는 알림 기록을 가져온다.
    // IT 담당자는 DataBase에 requestNotifications에 있는 알림 기록을 가져오기도 하고, DataBase에 commentNotifications을 가져오기도 한다.
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


  // 사용자가 게시물에 대한 알림을 신청할 떄, 위 게시물에 대해서 알림 받기 위한 여러 설정을 등록하는 method
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

  // 사용자가 게시물에 대한 알림을 해제할 떄, 위 게시물에 대해서 알림 받기 위해 했던 여러 설정을 해제한다.
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

  // NotificationController가 처음 메모리에 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    // Database에 User의 commentNotificationPostUid 속성을 가져와 위 필드인 commentNotificationPostUidList에 값을 대입한다.
    getCommentNotificationPostUid().then(
      (_) async {
        print(
            'commentNotificationPostUidListLength : ${commentNotificationPostUidList.length}');

        // 위 필드의 commentNotificationPostUidList의 성분,즉 사용자가 알림 신청한 게시물 uid를 이용한다.
        // 게시물 uid를 이용하여 DataBase에 게시물에 대한 댓글 개수를 찾는다. 다음으로 위 필드인 commentCount에 값을 대입한다.
        await getPostCommentCount();
        print('commentCountLength : ${commentCount.length}');

        // Flutter Local Notification Setting //
        await localNotificationInitialize();
        print('Flutter Local Notification Setting 완료');

        // DataBase에서 사용자가 알림 신청한 게시물에 대한 댓글 변동 사항을 listen한다.
        await setCommentNotificationListen();

        // 사용자 자격이 IT 1실, 2실 관리자 일 떄
        // 장애 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물 총 개수
        // 문의 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물 총 개수
        // 장애 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물 총 개수
        // 문의 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물 총 개수를 DataBase에서 가져온다.
        AuthController.to.user.value.userType == UserClassification.GENERALUSER
            ? null
            : AuthController.to.user.value.userType ==
                    UserClassification.IT1USER
                ? await getIT1ObsAndInqPostSize()
                : await getIT2ObsAndInqPostSize();

        // 사용자 자격이 IT 1실, 2실 관리자이고
        // 일반 요청자가 IT 1실, 2실 관리자가 담당하는 시스템과 관련된 게시물을 업로드할 떄 listen한다.
        AuthController.to.user.value.userType == UserClassification.GENERALUSER
            ? null
            : AuthController.to.user.value.userType ==
                    UserClassification.IT1USER
                ? await it1UserListen()
                : await it2UserListen();
      },
    );
  }

  // NotificationController가 메모리에 내려갈 떄 호출되는 method
  @override
  void onClose() {
    // 사용자 자격이 IT 1실 담당자이면,
    // 장애 처리현황 게시물에서 IT 1실이 담당하는 시스템을 가진 게시물이 업로드 되는지 listen 하던 것을 cancel 한다.
    if (AuthController.to.user.value.userType == UserClassification.IT1USER) {
      it1UserObsPostListen.cancel();
      it1UserInqPostListen.cancel();
    }

    // 사용자 자격이 IT 2실 담당자이면,
    // 장애 처리현황 게시물에서 IT 2실이 담당하는 시스템을 가진 게시물이 업로드 되는지 listen 하던 것을 cancel 한다.
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
