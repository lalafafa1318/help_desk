import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

// Toast Message를 쉽게 제공하는 Util class 입니다.
class ToastUtil {
  static void showToastMessage(String msg) {
    showToast(
      msg,
      duration: const Duration(seconds: 2),
      radius: 15.r,
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      textStyle: TextStyle(fontSize: 20.sp),
    );
  }
}
