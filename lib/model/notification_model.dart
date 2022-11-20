// 알림 목록에 대한 Model class 입니다.
import 'package:help_desk/const/obsOrInqClassification.dart';

class NotificationModel {
  // 알림 title
  String title;

  // 알림 body
  String body;

  // NotificationUid
  String notiUid;

  // Notification이 속한 게시물 uid
  String belongNotiPostUid;

  // Notification 시간
  String notiTime;

  // Notification과 관련된 게시물이 장애 처리현황인지 문의 처리현황인지 확인
  ObsOrInqClassification belongNotiObsOrInq;

  // constructor
  NotificationModel({
    required this.title,
    required this.body,
    required this.notiUid,
    required this.belongNotiPostUid,
    required this.notiTime,
    required this.belongNotiObsOrInq,
  });

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(NotificationModel noti) {
    return {
      'title': noti.title,
      'body': noti.body,
      'notiUid': noti.notiUid,
      'belongNotiPostUid': noti.belongNotiPostUid,
      'notiTime': noti.notiTime,
      'belongNotiObsOrInq': noti.belongNotiObsOrInq.toString(),
    };
  }

  // Map을 Model class로 변환하는 method
  factory NotificationModel.fromMap(Map<String, dynamic> noti) =>
      NotificationModel(
        title: noti['title'].toString(),
        body: noti['body'].toString(),
        notiUid: noti['notiUid'].toString(),
        belongNotiPostUid: noti['belongNotiPostUid'].toString(),
        notiTime: noti['notiTime'].toString(),
        belongNotiObsOrInq: ObsOrInqClassification.values.firstWhere(
          (element) => element.toString() == noti['belongNotiObsOrInq'].toString(),
        ),
      );
}
