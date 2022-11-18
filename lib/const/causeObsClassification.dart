// 장애원인 분류 코드를 구분하는 enum
enum CauseObsClassification {
  // 사용자
  USER,
  // 프로그램
  PROGRAM,
  // 네트워크
  NETWORK,
  // 서버
  SERVER,
  // 데이터
  DATA,
  // 콜장비
  CALL_EQUIPMENT,
  // 연동
  PERISTALSIS,
  // 고객사
  CUSTOMER,
  // 협력업체
  PARTNERS,
  // PC
  PC,
  //NONE
  NONE,
}

// 장애원인 분류 코드를 판별해 화면에 표시하는 Text로 변환하는 확장 Method
extension CauseObsClassificationExtension on CauseObsClassification {
  String get asText {
    switch (this) {
      case CauseObsClassification.USER:
        return '사용자';
      case CauseObsClassification.PROGRAM:
        return '프로그램';
      case CauseObsClassification.NETWORK:
        return '네트워크';
      case CauseObsClassification.SERVER:
        return '서버';
      case CauseObsClassification.DATA:
        return '데이터';
      case CauseObsClassification.CALL_EQUIPMENT:
        return '콜장비';
      case CauseObsClassification.PERISTALSIS:
        return '연동';
      case CauseObsClassification.CUSTOMER:
        return '고객사';
      case CauseObsClassification.PARTNERS:
        return '협력업체';
      case CauseObsClassification.PC:
        return 'PC';
      default:
        return 'NONE';
    }
  }
}
