// 시스템 분류 코드를 판별하는 enum
enum SysClassification {
  // 시스템 전체
  ALL,
  // WICS (IT 1실이 담당하고 있다고 가정)
  WICS,
  // ICMS (IT 1실이 담당하고 있다고 가정)
  ICMS,
  // 매출  (IT 1실이 담당하고 있다고 가정)
  SALES,
  // 고액  (IT 1실이 담당하고 있다고 가정)
  EXPENSIVE,
  // NGOS  (IT 1실이 담당하고 있다고 가정)
  NGOS,
  // NCCS  (IT 1실이 담당하고 있다고 가정)
  NCCS,
  // NCCSSB  (IT 1실이 담당하고 있다고 가정)
  NCCSSB,
  // 홈페이지 (IT 2실이 담당하고 있다고 가정)
  HOMEPAGE,
  // NSCS   (IT 2실이 담당하고 있다고 가정)
  NSCS,
  // ARM    (IT 2실이 담당하고 있다고 가정)
  ARM,
  // 서버    (IT 2실이 담당하고 있다고 가정)
  SERVER,
  // 네트워크  (IT 2실이 담당하고 있다고 가정)
  NETWORK,
  // 콜인프라  (IT 2실이 담당하고 있다고 가정)
  CALL_INFRASTRUCTURE, 
  // 보안     (IT 2실이 담당하고 있다고 가정)
  SECURITY,
  // 문서중앙화  (IT 2실이 담당하고 있다고 가정)
  DOC_CENTRALIZATION,
  // 개인장비(PC등)  (IT 2실이 담당하고 있다고 가정)
  PERSONAL_EQUIPMENT,
  // 기타  (IT 2실이 담당하고 있다고 가정)
  ETC,
}

// 처리상태 분류 코드를 판별해 화면에 표시하는 Text로 변환하는 확장 Method
extension SysclassificationExtension on SysClassification {
  String get asText {
    switch (this) {
      case SysClassification.ALL:
        return '시스템 전체';
      case SysClassification.WICS:
        return 'WICS';
      case SysClassification.ICMS:
        return 'ICMS';
      case SysClassification.SALES:
        return '매출';
      case SysClassification.EXPENSIVE:
        return '고액';
      case SysClassification.NGOS:
        return 'NGOS';
      case SysClassification.NCCS:
        return 'NCCS';
      case SysClassification.NCCSSB:
        return 'NCCSSB';
      case SysClassification.HOMEPAGE:
        return '홈페이지';
      case SysClassification.NSCS:
        return 'NSCS';
      case SysClassification.ARM:
        return 'ARM';
      case SysClassification.SERVER:
        return '서버';
      case SysClassification.NETWORK:
        return '네트워크';
      case SysClassification.CALL_INFRASTRUCTURE:
        return '콜인프라';
      case SysClassification.SECURITY:
        return '보안';
      case SysClassification.DOC_CENTRALIZATION:
        return '문서중앙화';
      case SysClassification.PERSONAL_EQUIPMENT:
        return '개인장비';
      default:
        return '기타';
    }
  }
}
