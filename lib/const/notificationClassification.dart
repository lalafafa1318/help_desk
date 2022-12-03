// 요청 알림인지 댓글 알림인지 판별하는 enum
enum NotificationClassification {
  // 요청 알림
  REQUESTNOTIFICATION,

  // 댓글 알림 
  COMMENTNOTIFICATION,
}

extension NotificationClassificationExtension on NotificationClassification {
  String get asText {
    switch (this) {
      case NotificationClassification.REQUESTNOTIFICATION:
        return '요청 알림';
      default:
        return '댓글 알림';
    }
  }
}