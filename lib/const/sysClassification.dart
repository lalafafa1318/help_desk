// 시스템 분류 코드를 판별하는 enum

enum SysClassification {
  // 시스템 전체
  ALL,
  // 사무기기(PC) (IT2실 담당)
  OFFICEEQUIPMENT_PC,
  // 사무기기(복합기) (IT2실 담당)
  OFFICEEQUIPMENT_ALLINONE,
  // NBUS(통합업무지원) (IT2실 담당)
  NBUS,
  // NEOS-C(일반채권) (IT2실 담당)
  NEOSC,
  // NEOS-K(금융채권) (IT2실 담당)
  NEOSK,
  // NEOS-A(상사채권) (IT2실 담당)
  NEOSA,
  // NIS(주문접수) (IT2실 담당)
  NIS,
  // NIS_NSCS(퍼미션) (IT2실 담당)
  NIS_NSCS,
  // NIS_SCM(홈쇼핑) (IT2실 담당)
  NIS_SCM,
  // NSCS(2차콜) (IT2실 담당)
  NSCS,
  // NCIP(고객사보안점검대행) (IT2실 담당)
  NCIP_IN,
  // NCCS(서류접수대행) (IT2실 담당)
  NCCS,
  // N-GOS(채권자소개) (IT2실 담당)
  NGOS,
  // WICS(채권관리) (IT2실 담당)
  WICS,
  // ICMS(채권관리지원) (IT2실 담당)
  ICMS,
  // 문서중앙화 (IT1실 담당)
  CDOC,
  // 그룹메일 (IT1실 담당)
  MAIL,
  // S-NAC(네트워크 접근제어) (IT1실 담당)
  SNAC,
  // NetHelper(PC 보안) (IT1실 담당)
  NETH,
  // SSL-VPN(재택원격접속) (IT1실 담당)
  SSLVPN,
  // N-Talk(사내메신저) (IT1실 담당)
  TALK,
  // NCS(코드스캐너) (IT2실 담당)
  VSCN,
}

// 처리상태 분류 코드를 판별해 화면에 표시하는 Text로 변환하는 확장 Method
extension SysclassificationExtension on SysClassification {
  String get asText {
    switch (this) {
      case SysClassification.ALL:
        return '시스템 전체';
      case SysClassification.OFFICEEQUIPMENT_PC:
        return '사무기기(PC)';
      case SysClassification.OFFICEEQUIPMENT_ALLINONE:
        return '사무기기(복합기)';
      case SysClassification.NBUS:
        return 'NBUS(통합업무지원)';
      case SysClassification.NEOSC:
        return 'NEOS-C(일반채권)';
      case SysClassification.NEOSK:
        return 'NEOS-K(금융채권)';
      case SysClassification.NEOSA:
        return 'NEOS-A(상사채권)';
      case SysClassification.NIS:
        return 'NIS(주문접수)';
      case SysClassification.NIS_NSCS:
        return 'NIS_NSCS(퍼미션)';
      case SysClassification.NIS_SCM:
        return 'NIS_SCM(홈쇼핑)';
      case SysClassification.NSCS:
        return 'NSCS(2차콜)';
      case SysClassification.NCIP_IN:
        return 'NCIP(고객사보안점검대행)';
      case SysClassification.NCCS:
        return 'NCCS(서류접수대행)';
      case SysClassification.NGOS:
        return 'N-GOS(채권자소개)';
      case SysClassification.WICS:
        return 'WICS(채권관리)';
      case SysClassification.ICMS:
        return 'ICMS(채권관리지원)';
      case SysClassification.CDOC:
        return '문서중앙화';
      case SysClassification.MAIL:
        return '그룹메일';
      case SysClassification.SNAC:
        return 'S-NAC(네트워크 접근제어)';
      case SysClassification.NETH:
        return 'NetHelper(PC 보안)';
      case SysClassification.SSLVPN:
        return 'SSL-VPN(재택원격접속)';
      case SysClassification.TALK:
        return 'N-Talk(사내메신저)';
      default:
        return 'NCS(코드스캐너)';
    }
  }
}
