// 장애 처리현황인지 문의 처리현황인지 판별하는 enum
enum ObsOrInqClassification {
  // 장애 처리현황
  obstacleHandlingStatus,

  // 문의 처리현황
  inqueryHandlingStatus,
}

extension ObsOrInqClassificationExtension on ObsOrInqClassification {
  String get asText {
    switch (this) {
      case ObsOrInqClassification.obstacleHandlingStatus:
        return '장애 처리현황';
      default:
        return '문의 처리현황';
    }
  }
}
