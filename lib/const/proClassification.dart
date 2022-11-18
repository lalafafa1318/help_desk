// 처리상태 분류 코드를 판별하는 enum
enum ProClassification {
  // 처리상태 전체
  ALL,
  // 접수
  // RECEIPT,
  // 처리중
  INPROGRESS,
  // 처리완료
  PROCESSCOMPLETED,
  // 보류
  HOLD,
}

// 처리상태 분류 코드를 판별해 화면에 표시하는 Text로 변환하는 확장 Method
extension ProclassificationExtension on ProClassification {
  String get asText {
    switch (this) {
      case ProClassification.ALL:
        return '처리상태 전체';
      // case ProClassification.RECEIPT:
      //   return '접수';
      case ProClassification.INPROGRESS:
        return '처리중';
      case ProClassification.PROCESSCOMPLETED:
        return '처리완료';
      default:
        return '보류';
    }
  }
}
