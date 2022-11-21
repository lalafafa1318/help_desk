// 일반 사용자와 IT 담당자를 구별하는 enum
enum UserClassification {
  // 일반 사용자
  GENERALUSER,

  // IT 담당자
  ITUSER,
}

// 장애원인 분류 코드를 판별해 화면에 표시하는 Text로 변환하는 확장 Method
extension UserClassificationExtension on UserClassification {
  String get asText {
    switch (this) {
      case UserClassification.GENERALUSER:
        return '일반 사용자';
      default:
        return 'IT 담당자';
    }
  }
}
