// 부서명을 구분하는 enum
enum DepartmentClassification {
  // 윤리경영실
  ETHICALMANAGEMENT,

  // DX추진단
  DXPROPULSIONGROUP,

  // 기획실
  PLANNINGOFFICE,

  // 경영관리실
  BUSINESSMANAGEMENTOFFICE,

  // IT 1실
  IT1OFFICE,

  // IT 2실
  IT2OFFICE,

  // 자산관리1실
  ASSETMANAGEMENT1OFFICE,

  // 자산관리2실
  ASSETMANAGEMENT2OFFICE,

  // CRM사업1실
  CRMBUSINESS1OFFICE,

  // CRM사업2실
  CRMBUSINESS2OFFICE,

  // 코웨이 사업팀
  COWAYBUSINESSTEAM,

  // 전략사업1실
  STRATEGICBUSINESS1OFFICE,

  // 전략사업2실
  STRATEGICBUSINESS2OFFICE,
}

// 장애원인 분류 코드를 판별해 화면에 표시하는 Text로 변환하는 확장 Method
extension DepartmentClassificationExtension on DepartmentClassification {
  String get asText {
    switch (this) {
      case DepartmentClassification.ETHICALMANAGEMENT:
        return '윤리경영실';
      case DepartmentClassification.DXPROPULSIONGROUP:
        return 'DX추진단';
      case DepartmentClassification.PLANNINGOFFICE:
        return '기획실';
      case DepartmentClassification.BUSINESSMANAGEMENTOFFICE:
        return '경영관리실';
      case DepartmentClassification.IT1OFFICE:
        return 'IT1실';
      case DepartmentClassification.IT2OFFICE:
        return 'IT2실';
      case DepartmentClassification.ASSETMANAGEMENT1OFFICE:
        return '자산관리1실';
      case DepartmentClassification.ASSETMANAGEMENT2OFFICE:
        return '자산관리2실';
      case DepartmentClassification.CRMBUSINESS1OFFICE:
        return 'CRM사업1실';
      case DepartmentClassification.CRMBUSINESS2OFFICE:
        return 'CRM사업2실';
      case DepartmentClassification.COWAYBUSINESSTEAM:
        return '코웨이사업팀';
      case DepartmentClassification.STRATEGICBUSINESS1OFFICE:
        return '전략사업1실';
      default:
        return '전략사업2실';
    }
  }
}
