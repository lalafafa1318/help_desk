import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:help_desk/model/notification_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/routeDistinction/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/notification_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:http/http.dart';

// 알림 목록 Page 입니다.
class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  // topView 입니다.
  Widget topView() {
    return SizedBox(
      width: Get.width,
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

  // 새로 고침하는 View 입니다.
  Widget refreshView() {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () async {
          await NotificationController.to.getNotifcationFromUser(
              SettingsController.to.settingUser!.userUid);

          // 필요한 부분만 재랜더링 한다.
          NotificationController.to.update();
        },
        icon: const Icon(Icons.refresh_outlined),
      ),
    );
  }

  // 알림 목록 view 입니다.
  Widget notificationView() {
    return Expanded(
      flex: 1,
      child: FutureBuilder<List<NotificationModel>>(
          future: NotificationController.to.getNotifcationFromUser(
            SettingsController.to.settingUser!.userUid,
          ),
          builder: (context, snapshot) {
            // snapshot을 기다립니다.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return GetBuilder<NotificationController>(
              builder: (controller) {
                // snapshot이 도착했으나 데이터가 empty인 경우
                if (NotificationController.to.notificationModelList.isEmpty) {
                  return noNotificationData();
                }

                return ListView.builder(
                  itemCount:
                      NotificationController.to.notificationModelList.length,
                  itemBuilder: (BuildContext context, int index) =>
                      messageView(index),
                );
              },
            );
          }),
    );
  }

  // Notification Data가 없음을 보여주는 Widget
  Widget noNotificationData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          // 금지 아이콘
          Icon(
            Icons.info_outline,
            size: 60,
            color: Colors.grey,
          ),

          SizedBox(height: 10),

          // 검색 결과가 없다는 Text
          Text(
            '알림 데이터가 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
        ],
      ),
    );
  }

  // 알림 메시지 view 입니다.
  Widget messageView(int index) {
    // index를 통해 해당하는 NotificationModel을 가져온다.
    NotificationModel notificationModel =
        NotificationController.to.notificationModelList[index];

    // PostListController.to.postDatas를 간단하게 명명한다.
    List<PostModel> postDatas = PostListController.to.postDatas;

    // Notification을 Tap하면 SpecificPostPage로 Routing 할 때 0번쨰 argument
    int idx = -1;

    // notification에 따른 게시물(post) 데이터와 그에 따른 사용자(user) 데이터의 index를 찾는다.
    for (int i = 0; i < postDatas.length; i++) {
      if (postDatas[i].postUid == notificationModel.belongNotiPostUid) {
        idx = i;
        break;
      }
    }

    return Column(
      children: [
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              // Notification 삭제 버튼
              SlidableAction(
                onPressed: (BuildContext context) async {
                  // NotificationModelList에 있는 element를 삭제한다.
                  NotificationController.to.notificationModelList
                      .remove(notificationModel);

                  // Notifcation과 관련된 게시물이 Server에 삭제되었는지 확인한다.
                  bool isDeletePostResult = await PostListController.to
                      .isDeletePost(notificationModel.belongNotiPostUid);

                  // Notification과 관련된 게시물이 삭제되었다면?
                  if (isDeletePostResult) {
                    // Notification과 관련된 게시물 Uid가 notiPost Array의 몇번째 index에 있는지 확인한다.
                    int index = NotificationController.to.notiPost
                        .indexOf(notificationModel.belongNotiPostUid);

                    // 실시간으로 Listen 하는 것을 중지하는 것을 넘어서 삭제한다.
                    NotificationController.to.listenList[index].cancel();

                    // NotificationController의 notifPost Array에 게시물 uid를 삭제한다.
                    NotificationController.to.notiPost.removeAt(index);

                    // NotificationController의 commentCount Array에 element를 remove한다.
                    NotificationController.to.commentCount.removeAt(index);

                    // NotificationController의 listenList Array에 element을 remove한다.
                    NotificationController.to.listenList.removeAt(index);

                    // Server의 post가 삭제되어 없을 떄
                    // Server의 user - notiPost 속성
                    // 알림과 관련된 게시물 Uid를 삭제한다.
                    await NotificationController.to.deleteNotiPostFromUser(
                      notificationModel.belongNotiPostUid,
                      SettingsController.to.settingUser!.userUid,
                    );
                  }

                  // Server의 notification을 삭제하는 코드
                  await NotificationController.to.deleteNotification(
                    notificationModel.notiUid,
                    SettingsController.to.settingUser!.userUid,
                  );

                  // GetBuilder 있는데만 화면 재랜더링 한다.
                  NotificationController.to.update();
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              if (idx == -1) {
                ToastUtil.showToastMessage('게시물이 삭제되어 이동할 수 없습니다 :)');
              }
              //
              else {
                // SpecificPostPage로 Routing
                // argument 0번쨰 : PostListController의 PostData와 UserData들을 담고 있는 배열의 index
                // argument 1번쨰 : NotificationPage에서 Routing 되었다는 것을 알려준다.
                Get.to(
                  () => const SpecificPostPage(),
                  arguments: [
                    idx,
                    RouteDistinction.notificationPage_to_specifcPostPage,
                  ],
                );
              }
            },

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Title
                Text(
                  notificationModel.title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 20),
                ),

                const SizedBox(height: 5),

                // Notification Body
                Text(notificationModel.body),

                const SizedBox(height: 5),
              ],
            ),
            // Notification Time
            subtitle: Text(
              notificationModel.notiTime.substring(0, 16),
              style: const TextStyle(color: Colors.black, fontSize: 10),
            ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),

          // topView 입니다.
          topView(),

          const SizedBox(height: 5),

          // 새로 고침을 나타내는 View 입니다.
          refreshView(),

          // 알림 목록 View 입니다.
          notificationView(),
        ],
      ),
    );
  }
}
