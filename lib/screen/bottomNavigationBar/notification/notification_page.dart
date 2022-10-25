import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';

// 알림 목록 Page 입니다.
class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  // topView 입니다.
  Widget topView() {
    return SizedBox(
      child: Row(
        children: [
          const SizedBox(width: 5),

          // 이전 페이지로 가는 Button
          IconButton(
            onPressed: () {
              BottomNavigationBarController.to.deleteBottomNaviBarHistory();
            },
            icon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 알림 목록 text 입니다.
          const Text(
            '알림 목록',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 알림 목록 view 입니다.
  Widget notificationView() {
    return SizedBox(
      width: Get.width,
      height: 650,
      child: ListView.builder(
        itemCount: 100,
        itemBuilder: (BuildContext context, int index) => messageView(index),
      ),
    );
  }

  // 알림 메시지 view 입니다.
  Widget messageView(int index) {
    return Column(
      children: [
        // 알림 메시지
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  // Firebase에 저장된 알림 목록을 삭제하는 코드
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text('김영우님이 섭이님 글에 댓글을 올렸습니다.'),
            subtitle: Text('2022-09-26 13:29'),
          ),
        ),

        // 구분자
        const Divider(height: 5, color: Colors.black26),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // StreamBuilder을 통해 Firebase 알림 목록 변경 사항을 확인하는 method을 배치하여 Widget을 여러 번 업데이트할 예정이다.
      body: Column(
        children: [
          const SizedBox(height: 5),

          // topView 입니다.
          topView(),

          //구분자 입니다.
          const Divider(height: 0.5, color: Colors.black),

          const SizedBox(height: 20),

          // 알림 목록 View 입니다.
          notificationView(),
        ],
      ),
    );
  }
}
