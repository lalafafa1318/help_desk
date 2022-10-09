import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/utils/showDialog_util.dart';
import 'package:help_desk/utils/toast_util.dart';

class BottomNavigationBarController extends GetxController {
  // Field
  // BottomNavigationBar selectedIndex
  RxInt selectedIndex = 0.obs;

  // BottomNaviagtionBar History 적용
  List<int> bottomNaviBarHistory = [0];

  // Method
  // BottomNavigationBar controller를 쉽게 사용할 수 있는 get method
  static BottomNavigationBarController get to => Get.find();

  // BottomNavigationBar History 처리을 어떻게 할 지 판단하는 method
  void checkBottomNaviState(int index) {
    // 같은 페이지를 click할 떄 처리
    if (bottomNaviBarHistory.last == index) {
      // 토스트 메시지를 띄운다.
      ToastUtil.showToastMessage('같은 페이지를 click 했습니다.');
    }
    // 최신 BottomNavigationBar History가 "Post List"인 경우 처리
    else if (bottomNaviBarHistory.last == 0) {
      // 검색창에 Keyword를 입력했으면 빈칸으로 만든다.
      if (PostListController.to.keywordController!.text.isNotEmpty) {
        PostListController.to.keywordController!.text = '';
      }

      // 다음 페이지를 BottomNavigationBar History에 기록한다.
      addBottomNaviBarHistory(index);
    }
    // 최신 BottomNavigationBar History가 "Posting"인 경우 처리
    else if (bottomNaviBarHistory.last == 1) {
      // PostingController에 관리되고 있는 상태 변수 초기화 한다.
      PostingController.to.initPostingElement();

      // 다음 페이지를 BottomNavigationBar History에 기록한다.
      addBottomNaviBarHistory(index);
    }
    // 나머지 처리
    else {
      // 다음 페이지를 BottomNavigationBar History에 기록한다.
      addBottomNaviBarHistory(index);
    }
  }

  // 다음 페이지를 BottomNavigationBar History에 기록하는 method
  void addBottomNaviBarHistory(int index) {
    // 다음 페이지 BottomNavigationBar History에 기록한다.
    bottomNaviBarHistory.add(index);

    print('BottomNaviBarHistory : ${bottomNaviBarHistory}');

    // selectedIndex 상태 변화 감지 -> Obx 호출
    selectedIndex(index);
  }

  // BottomNavigationBar History를 적용하는 method (Element Delete)
  bool deleteBottomNaviBarHistory() {
    if (bottomNaviBarHistory.length == 1) {
      // 종료 or cancel를 나타내는 Dialog를 띄운다.
      ShowDialogUtil.showDialog();

      return true;
    } else {
      bottomNaviBarHistory.removeLast();

      print('BottomNaviBarHistory : ${bottomNaviBarHistory}');

      // selectedIndex 상태 변화 감지
      selectedIndex(bottomNaviBarHistory.last);

      return false;
    }
  }

  // BottomNaviagtionBar Controller가 메모리에 처음 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    print('BottomNavigationBar onInit() 호출');
  }

  // BottomNavigationBar Controller가 메모리에서 제거되기 전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    // 로그
    print('BottomNavigationBarController onClose() 호출');

    super.onClose();
  }
}
