// Dialog를 쉽게 제공하는 Util class 입니다.
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';

class ShowDialogUtil {
  static void showDialog() {
    AwesomeDialog(
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.warning,
      dismissOnBackKeyPress: true,
      dismissOnTouchOutside: false,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Text(
            '맨 마지막 페이지 입니다. Help_Desk 앱을 종료하시겠습니까?',
            style: TextStyle(fontStyle: FontStyle.normal),
          ),
        ),
      ),
      btnOkText: '종료',
      btnCancelText: '취소',
      btnOkOnPress: () {
        print('Ok을 눌렀습니다.');
        exit(0);
      },
      btnCancelOnPress: () {
        print('Cancel을 눌렀습니다.');
        Get.back();
      },
    ).show();
  }
}
