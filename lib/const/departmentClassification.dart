// 부서명을 구분하는 enum
import 'package:flutter/material.dart';
import 'package:help_desk/const/sysClassification.dart';

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

// 부서명을 판별해 화면에 표시하는 Text로 변환하는 확장 Method
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

// 부서명마다 PostListPage, KeywordPostListPage의 시스템 분류 코드를 나타내는 Dropdown에 시스템을 제한적으로 보여줘야 한다. 그에 대한 확장 method다
extension DepartmentClassificationExtension2 on DepartmentClassification {
  List<DropdownMenuItem<String>> get showSysDropdwon {
    // 사용자 소속이 윤리경영실, DX추진단, 기획실, 경영관리실이면 위 시스템 분류 코드를 보여준다.
    if (this == DepartmentClassification.ETHICALMANAGEMENT ||
        this == DepartmentClassification.DXPROPULSIONGROUP ||
        this == DepartmentClassification.PLANNINGOFFICE ||
        this == DepartmentClassification.BUSINESSMANAGEMENTOFFICE) {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }
    // 사용자 소속이 IT1실, IT2실이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.IT1OFFICE ||
        this == DepartmentClassification.IT2OFFICE) {
      return SysClassification.values.map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 자산관리1실이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.ASSETMANAGEMENT1OFFICE) {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.NEOSK,
        SysClassification.NEOSA,
        SysClassification.NCIP_IN,
        SysClassification.NGOS,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 자산관리2실이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.ASSETMANAGEMENT2OFFICE) {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.NEOSK,
        SysClassification.NEOSA,
        SysClassification.NGOS,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 CRM사업1실, CRM사업2실 이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.CRMBUSINESS1OFFICE ||
        this == DepartmentClassification.CRMBUSINESS2OFFICE) {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.NIS,
        SysClassification.NIS_NSCS,
        SysClassification.NIS_SCM,
        SysClassification.NSCS,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 코웨이 사업팀이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.COWAYBUSINESSTEAM) {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 전략사업1실팀이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.STRATEGICBUSINESS1OFFICE) {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSK,
        SysClassification.NEOSA,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 전략사업2실팀이면 위 시스템 분류 코드를 보여준다.
    else {
      return [
        SysClassification.ALL,
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NCCS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }
  }
}

// 부서명마다 PostingPage의 시스템 분류 코드를 나타내는 Dropdown에 시스템을 제한적으로 보여줘야 한다. 그에 대한 확장 method다.
extension DepartmentClassificationExtension3 on DepartmentClassification {
  List<DropdownMenuItem<String>> get showPostingSysDropdwon {
    // 사용자 소속이 윤리경영실, DX추진단, 기획실, 경영관리실이면 위 시스템 분류 코드를 보여준다.
    if (this == DepartmentClassification.ETHICALMANAGEMENT ||
        this == DepartmentClassification.DXPROPULSIONGROUP ||
        this == DepartmentClassification.PLANNINGOFFICE ||
        this == DepartmentClassification.BUSINESSMANAGEMENTOFFICE) {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }
    // 사용자 소속이 IT1실, IT2실이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.IT1OFFICE ||
        this == DepartmentClassification.IT2OFFICE) {
      return SysClassification.values.where((element) => element != SysClassification.ALL).map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 자산관리1실이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.ASSETMANAGEMENT1OFFICE) {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.NEOSK,
        SysClassification.NEOSA,
        SysClassification.NCIP_IN,
        SysClassification.NGOS,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 자산관리2실이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.ASSETMANAGEMENT2OFFICE) {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.NEOSK,
        SysClassification.NEOSA,
        SysClassification.NGOS,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 CRM사업1실, CRM사업2실 이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.CRMBUSINESS1OFFICE ||
        this == DepartmentClassification.CRMBUSINESS2OFFICE) {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.NIS,
        SysClassification.NIS_NSCS,
        SysClassification.NIS_SCM,
        SysClassification.NSCS,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 코웨이 사업팀이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.COWAYBUSINESSTEAM) {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSC,
        SysClassification.WICS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 전략사업1실팀이면 위 시스템 분류 코드를 보여준다.
    else if (this == DepartmentClassification.STRATEGICBUSINESS1OFFICE) {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NEOSK,
        SysClassification.NEOSA,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }

    // 사용자 소속이 전략사업2실팀이면 위 시스템 분류 코드를 보여준다.
    else {
      return [
        SysClassification.OFFICEEQUIPMENT_PC,
        SysClassification.OFFICEEQUIPMENT_ALLINONE,
        SysClassification.NBUS,
        SysClassification.NCCS,
        SysClassification.ICMS,
        SysClassification.CDOC,
        SysClassification.MAIL,
        SysClassification.SNAC,
        SysClassification.NETH,
        SysClassification.SSLVPN,
        SysClassification.TALK,
        SysClassification.VSCN
      ].map((element) {
        // enum의 값을 화면에 표시할 값으로 변환한다.
        String realText = element.asText;

        return DropdownMenuItem(
          value: element.name,
          child: Text(realText),
        );
      }).toList();
    }
  }
}
