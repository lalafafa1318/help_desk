import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConnectUtil {
  static Connectivity connectivity = Connectivity();
  static StreamSubscription<ConnectivityResult>? networkListener;
  // 연결 상태가 변경될 떄마다 저장하는 변수
  static ConnectivityResult? connectivityResult;

  // 최초 연결 상태를 확인하는 method
  static Future<ConnectivityResult> check() async {
    ConnectivityResult result = await connectivity.checkConnectivity();

    return result;
  }

  // 연결 상태가 변경되었을 떄 호출되는 method
  static void listen() {
    networkListener = connectivity.onConnectivityChanged.listen(
      (result) {
        connectivityResult = result;

        switch (result) {
          case ConnectivityResult.wifi:
            print('----- wi-fi');
            break;
          case ConnectivityResult.mobile:
            print('------ mobile');
            break;
          case ConnectivityResult.none:
            Future.delayed(
              const Duration(seconds: 5),
              () {
                // 네트워크 연결 상태가 곧바로 Wi-Fi나 Mobile에 되었을 경우...
                if (connectivityResult != ConnectivityResult.none) {
                  print('----- 잠시 none이었으나 곧 네트워크 연결 되었습니다.');
                }
                // 그렇지 않으면 네트워크 연결 상태가 none이라고 판단...
                else {
                  print('------ 최종 네트워크 상태 none 입니다.');

                  // 연결 상태가 none일 떄 화면에 보여주는 Dialog를 띄운다.
                  connectNoneDialog();
                }
              },
            );
            break;
        }
      },
    );
  }

  // 연결 상태가 none일 떄 화면에 보여주는 dialog
  static void connectNoneDialog() {
    showDialog(
      context: Get.context!,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierColor: Colors.black38,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 이전 가기 버튼을 누른다 해도 AlertDialog는 꺼지지 않는다.
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0.r)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('네트워크가 연결되어 있지 않으므로 앱을 종료합니다 :)'),
              ],
            ),
            actions: [
              // 돌아가기 버튼
              TextButton(
                child: const Text(
                  '앱 종료하기',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  cancel();

                  exit(0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void cancel() {
    networkListener!.cancel();
  }
}
