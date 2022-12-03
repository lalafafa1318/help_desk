// 일반 사용자와 IT 담당자를 구별하는 enum
enum UserClassification {
  // 일반 사용자
  GENERALUSER,

  // IT 1실 담당자
  IT1USER,

  // IT 2실 담당자
  IT2USER,
}

//enum의 값을 판별해 화면에 Text로 변환하는 확장 Method
extension UserClassificationExtension on UserClassification {
  String get asText {
    switch (this) {
      case UserClassification.GENERALUSER:
        return '일반 사용자';
      case UserClassification.IT1USER:
        return 'IT 1실 담당자';
      default:
        return 'IT 2실 담당자';
    }
  }
}
