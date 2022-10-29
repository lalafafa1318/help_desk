// 알림 목록에 대한 Model class 입니다.
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

  // constructor
  NotificationModel({
    required this.title,
    required this.body,
    required this.notiUid,
    required this.belongNotiPostUid,
    required this.notiTime,
  });

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(NotificationModel noti) {
    return {
      'title': noti.title,
      'body': noti.body,
      'notiUid': noti.notiUid,
      'belongNotiPostUid': noti.belongNotiPostUid,
      'notiTime': noti.notiTime,
    };
  }

  // Map을 Model class로 바꾸는 method
  // map을 Model class로 변환하는 method
  factory NotificationModel.fromMap(Map<String, dynamic> noti) =>
      NotificationModel(
        title: noti['title'].toString(),
        body: noti['body'].toString(),
        notiUid: noti['notiUid'].toString(),
        belongNotiPostUid: noti['belongNotiPostUid'].toString(),
        notiTime: noti['notiTime'].toString(),
      );
}
