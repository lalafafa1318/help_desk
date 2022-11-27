import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/model/notification_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/notification_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';

// 알림 목록 Page 입니다.
class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  // topView 입니다.
  Widget topView() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Row(
        children: [
          SizedBox(width: 5.h),

          // 이전 페이지로 가는 Button
          IconButton(
            onPressed: () {
              BottomNavigationBarController.to.deleteBottomNaviBarHistory();
            },
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // 알림 목록 text 입니다.
          Text(
            '알림 목록',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 새로 고침하는 View 입니다.
  Widget refreshView() {
    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 5.h),
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () async {
          // await NotificationController.to.getNotifcationFromUser(
          //     SettingsController.to.settingUser!.userUid);

          // GetBuilder를 통해 재랜더링 한다.
          NotificationController.to.update(['getNotificationData']);
        },
        icon: const Icon(Icons.refresh_outlined),
      ),
    );
  }

  // 알림 데이터를 준비하는 Widget 입니다.
  Widget prepareNotificationData() {
    return Expanded(
      flex: 1,
      child: GetBuilder<NotificationController>(
        id: 'getNotificationData',
        builder: (controller) {
          return FutureBuilder<List<NotificationModel>>(
            future: NotificationController.to.getNotifcationFromUser(
              SettingsController.to.settingUser!.userUid,
            ),
            builder: (context, snapshot) {
              // snapshot을 기다립니다.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

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
        },
      ),
    );
  }

  // Notification Data가 없음을 보여주는 Widget
  Widget noNotificationData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 금지 아이콘
          const Icon(
            Icons.info_outline,
            size: 60,
            color: Colors.grey,
          ),

          SizedBox(height: 10.h),

          // 검색 결과가 없다는 Text
          Text(
            '알림 데이터가 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 20.sp),
          ),
        ],
      ),
    );
  }

  // 알림 메시지 view 입니다.
  Widget messageView(int index) {
    // Notification을 Tap하면 SpecificPostPage로 Routing 할 때 0번쨰 argument
    int idx = -1;

    // index를 통해 해당하는 NotificationModel을 가져온다.
    NotificationModel notificationModel =
        NotificationController.to.notificationModelList[index];

    // NotifcationModel이 장애 처리현황 게시물과 관련이 있다.
    if (notificationModel.belongNotiObsOrInq ==
        ObsOrInqClassification.obstacleHandlingStatus) {
      // PostListController.to.obsPostData를 간단하게 명명한다.
      List<PostModel> obsPostDatas = PostListController.to.obsPostData;

      // NotificationModel과 관련된 장애 처리현황 게시물과 그에 따른 사용자(user) 데이터의 index를 찾는다.
      for (int i = 0; i < obsPostDatas.length; i++) {
        if (obsPostDatas[i].postUid == notificationModel.belongNotiPostUid) {
          idx = i;
          break;
        }
      }
    }
    // NotificationModel이 문의 처리현황 게시물과 관련이 있다.
    else {
      List<PostModel> inqPostDatas = PostListController.to.inqPostData;

      // NotificationModel과 관련된 문의 처리현황 게시물과 그에 따른 사용자(user) 데이터의 index를 찾는다.
      for (int i = 0; i < inqPostDatas.length; i++) {
        if (inqPostDatas[i].postUid == notificationModel.belongNotiPostUid) {
          idx = i;
          break;
        }
      }
    }

    return Column(
      children: [
        // 알림을 삭제하는 Slidable + 알림 내용
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              // Notification 삭제 버튼
              SlidableAction(
                onPressed: (BuildContext context) async {
                  // NotificationModelList에 있는 element를 삭제한다.
                  NotificationController.to.notificationModelList
                      .removeAt(index);

                  // Notifcation과 관련된 장애 처리현황 또는 문의 처리현황 게시물이 Database에 삭제되었는지 확인한다.
                  bool isDeletePostResult =
                      await PostListController.to.isDeletePost(
                    notificationModel.belongNotiObsOrInq,
                    notificationModel.belongNotiPostUid,
                  );

                  // Notification과 관련된 장애 처리현황 또는 문의 처리현황 게시물이 삭제되었다면?
                  // -> 더이상 알림 받을 필요성이 없다. -> 알림 받기 위해 설정했던 모든 것을 해제한다.
                  if (isDeletePostResult) {
                    // Notification과 관련된 게시물 Uid가 notiPost Array의 몇번째 index에 있는지 확인한다.
                    int notiPostIndex = NotificationController.to.notiPost
                        .indexOf(notificationModel.belongNotiPostUid);

                    // notiPostIndex == -1 이라면 이하 if문은 실행할 필요 없다.
                    if (notiPostIndex != -1) {
                      // NotificationController의 notifPost Array에 게시물 uid를 삭제한다.
                      NotificationController.to.notiPost
                          .removeAt(notiPostIndex);

                      // NotificationController의 commentCount Array에 element를 remove한다.
                      NotificationController.to.commentCount
                          .removeAt(notiPostIndex);

                      // 실시간으로 Listen 하는 것을 중지하는 것을 넘어서 삭제한다.
                      NotificationController.to.listenList[notiPostIndex]
                          .cancel();

                      // NotificationController의 listenList Array에 element을 remove한다.
                      NotificationController.to.listenList
                          .removeAt(notiPostIndex);

                      // Database의 장애 처리현황 또는 문의 처리현황 게시물이 삭제되어 없을 떄
                      // Database의 user - notiPost 속성
                      // 알림과 관련된 게시물 Uid를 삭제한다.
                      await NotificationController.to.deleteNotiPostFromUser(
                        notificationModel.belongNotiPostUid,
                        SettingsController.to.settingUser!.userUid,
                      );
                    }
                  }

                  // Database의 notification을 삭제하는 코드
                  await NotificationController.to.deleteNotification(
                    notificationModel.notiUid,
                    SettingsController.to.settingUser!.userUid,
                  );

                  // GetBuilder 있는데만 화면 재랜더링 한다.
                  NotificationController.to.update(['getNotificationData']);
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          // 알림에 대한 본 내용을 알리는 ListTile
          child: ListTile(
            onTap: () {
              if (idx == -1) {
                ToastUtil.showToastMessage('게시물이 삭제되어 이동할 수 없습니다 :)');
              }
              //
              else {
                // NotificationModel이 장애 처리현황과 관련이 있다.
                if (notificationModel.belongNotiObsOrInq ==
                    ObsOrInqClassification.obstacleHandlingStatus) {
                  // SpecificPostPage로 Routing
                  // argument 0번쨰 : PostListController의 obsPostData와 obsUserData들을 담고 있는 배열의 index
                  // argument 1번쨰 : NotificationPage에서 Routing 되었다는 것을 알려준다.
                  Get.to(
                    () => const SpecificPostPage(),
                    arguments: [
                      idx,
                      RouteDistinction.notificationPageObsToSpecifcPostPage,
                    ],
                  );
                }
                // NotificationModel이 문의 처리현황과 관련이 있다.
                else {
                  // SpecificPostPage로 Routing
                  // argument 0번쨰 : PostListController의 PostData와 UserData들을 담고 있는 배열의 index
                  // argument 1번쨰 : NotificationPage에서 Routing 되었다는 것을 알려준다.
                  Get.to(
                    () => const SpecificPostPage(),
                    arguments: [
                      idx,
                      RouteDistinction.notificationPageInqToSpecifcPostPage,
                    ],
                  );
                }
              }
            },

            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notificaiton과 관련된 게시물이 장애 처리현황인지 문의 처리현황인지 표시한다.
                Text(
                  notificationModel.belongNotiObsOrInq.asText,
                  style:
                      TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10.h),

                // Notification과 관련된 게시물 작성자 이름, 제목을 표시한다.
                Text(
                  notificationModel.title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 20.sp),
                ),

                SizedBox(height: 5.h),

                // 게시물에 대한 최신 댓글 내용을 표시한다.
                Text(notificationModel.body),

                SizedBox(height: 5.h),
              ],
            ),
            // Notification Time
            subtitle: Text(
              notificationModel.notiTime.substring(0, 16),
              style: TextStyle(color: Colors.black, fontSize: 10.sp),
            ),
          ),
        ),

        // 구분자
        Divider(height: 5.h, color: Colors.black26),
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
          SizedBox(height: 5.h),

          // topView 입니다.
          topView(),

          SizedBox(height: 5.h),

          // 새로 고침을 나타내는 View 입니다.
          refreshView(),

          // 알림 목록 View 입니다.
          prepareNotificationData(),
        ],
      ),
    );
  }
}
