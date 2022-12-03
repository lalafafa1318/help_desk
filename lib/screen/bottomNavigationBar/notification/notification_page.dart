import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:help_desk/const/notificationClassification.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/const/userClassification.dart';
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
          GetBuilder<NotificationController>(
            id: 'topViewText',
            builder: (NotificationController controller) {
              return Text(
                SettingsController.to.settingUser!.userType ==
                        UserClassification.GENERALUSER
                    ? '댓글 알림 목록'
                    : controller.notificationClassification ==
                            NotificationClassification.REQUESTNOTIFICATION
                        ? '요청 알림 목록'
                        : '댓글 알림 목록',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
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
        onPressed: () {
          // GetBuilder를 통해 재랜더링 한다.
          NotificationController.to.update(['getNotifications']);
        },
        icon: const Icon(Icons.refresh_outlined),
      ),
    );
  }

  // 알림 데이터를 준비하는 Widget 입니다.
  Widget prepareNotifications() {
    return Expanded(
      flex: 1,
      child: GetBuilder<NotificationController>(
        id: 'getNotifications',
        builder: (NotificationController controller) {
          return FutureBuilder<List<NotificationModel>>(
            // DataBase에 requestNotifications에 있는 알림 기록을 가져올지, commentNotifications에 있는 알림 기록을 가져올지 결정한다.
            future: controller.getRequestORCommentNotificationModelList(
              SettingsController.to.settingUser!.userUid,
            ),
            builder: (context, snapshot) {
              // snapshot을 기다립니다.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // snapshot이 도착했으나 데이터가 empty인 경우
              if (snapshot.data!.isEmpty) {
                return noNotificationData();
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) =>
                    notificationMessageView(snapshot.data!, index),
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
  Widget notificationMessageView(
      List<NotificationModel> notificationModelList, int index) {
    // 알림을 Tap하면 SpecificPostPage로 Routing 할 때 0번쨰 argument
    int idx = -1;

    // index를 통해 해당하는 NotificationModel을 가져온다.
    NotificationModel notificationModel = notificationModelList[index];

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
                  SettingsController.to.settingUser!.userType ==
                          UserClassification.GENERALUSER
                      ? NotificationController.to.commentNotificationModelList
                          .removeAt(index)
                      : NotificationController.to.notificationClassification ==
                              NotificationClassification.REQUESTNOTIFICATION
                          ? NotificationController
                              .to.requestNotificationModelList
                              .removeAt(index)
                          : NotificationController
                              .to.commentNotificationModelList
                              .removeAt(index);

                  // 알림 메시지 view가 댓글 알림 목록일 떄만 이하 if문 작업을 한다.
                  // 일반 요청자의 경우 항상 댓글 알림 목록이므로 이하 if문을 타게 된다.
                  // IT 담당자의 경우, 댓글 알림 목록이면 이하 if문을 타게 된다.
                  if (SettingsController.to.settingUser!.userType ==
                          UserClassification.GENERALUSER ||
                      NotificationController.to.notificationClassification ==
                          NotificationClassification.COMMENTNOTIFICATION) {
                    // 댓글 알림과 관련된 장애 처리현황 또는 문의 처리현황 게시물이 Database에 삭제되었는지 확인한다.
                    bool isDeletePostResult =
                        await PostListController.to.isDeletePost(
                      notificationModel.belongNotiObsOrInq,
                      notificationModel.belongNotiPostUid,
                    );

                    // 댓글 알림과 관련된 장애 처리현황 또는 문의 처리현황 게시물이 삭제되었다면?
                    // -> 더이상 알림 받을 필요성이 없다.
                    // -> 해당 게시물에 대해서 알림 받기 위해 설정했던 모든 것을 해제한다.
                    if (isDeletePostResult == true) {
                      // 댓글 알림과 관련된 게시물 Uid가 commentNotificationPostUidList의 몇번째 index에 있는지 확인한다.
                      int notiPostIndex = NotificationController
                          .to.commentNotificationPostUidList
                          .indexOf(notificationModel.belongNotiPostUid);

                      // notiPostIndex == -1 이라면 이하 if문은 실행할 필요 없다.
                      // ex) 사용자가 알림 신청한 게시물에 대한 알림을 2개 이상 받았다고 하자...
                      // 그런데, 알림 신청한 게시물 작성자가 게시물을 삭제했다고 하자..
                      // 그 다음 사용자가 알림 신청한 게시물(2개로 가정한다.)를 삭제하려고 한다...
                      // 첫번쨰 알림 게시물을 삭제할 떄는 이하 if문을 타고가서 해당 게시물에 대해 알림 받기 위해 했던 여러 설정을 해제한다.
                      // 두번쨰 알림 게시물을 삭제할 떄는 해당 게시물에 대한 알림 받기 위해 했던 여러 설정을 해제한 상태이므로
                      // 이하 if문을 수행하지 않는다.
                      notiPostIndex != -1
                          ? NotificationController.to
                              .clearCommentNotificationSettings(
                                  notificationModel.belongNotiPostUid)
                          : null;
                    }

                    // Database의 commentNotifications에 알림 데이터를 삭제하는 코드
                    await NotificationController.to.deleteCommentNotification(
                      notificationModel.notiUid,
                      SettingsController.to.settingUser!.userUid,
                    );
                  }
                  // 알림 메시지 view가 요청 알림 목록일 떄만 이하 else문 작업을 한다.
                  // 이는 IT 담당자가 요청 알림 목록을 띄울 떄에만 이하 else문 작업을 한다.
                  else {
                    // Database의 requestNotifications에 알림 데이터를 삭제하는 코드
                    await NotificationController.to.deleteRequestNotification(
                      notificationModel.notiUid,
                      SettingsController.to.settingUser!.userUid,
                    );
                  }

                  // GetBuilder 있는데만 화면 재랜더링 한다.
                  NotificationController.to.update(['getNotifications']);
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
                SettingsController.to.settingUser!.userType ==
                        UserClassification.GENERALUSER
                    ? ToastUtil.showToastMessage('게시물이 삭제되어\n이동할 수 없습니다 :)')
                    : NotificationController.to.notificationClassification ==
                            NotificationClassification.REQUESTNOTIFICATION
                        ? ToastUtil.showToastMessage(
                            'PostListPage로 가서\n데이터를 업데이트한 후\n다시 접근해보세요 :)')
                        : ToastUtil.showToastMessage(
                            '게시물이 삭제되어\n이동할 수 없습니다 :)');
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
                  style: TextStyle(color: Colors.grey[500], fontSize: 19.sp),
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
      // 일반 요청자는 댓글 알림 목록만 보인다.
      // IT 담당자는 요청 알림 목록과 댓글 알림 목록 총 2가지를 FlatingActionButton를 통해 볼 수 있다.
      floatingActionButton: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? null
          : Align(
              alignment: Alignment(
                  Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),
              child: FloatingActionButton(
                backgroundColor: Colors.grey,
                // IT 담당자가 요청 알림 목록을 보고 있다가 FloatingButton을 클릭하면 댓글 알림 목록으로 전환된다.
                // 그 반대도 똑같이 적용된다.
                onPressed: () {
                  NotificationController.to.notificationClassification ==
                          NotificationClassification.REQUESTNOTIFICATION
                      ? NotificationController.to.notificationClassification =
                          NotificationClassification.COMMENTNOTIFICATION
                      : NotificationController.to.notificationClassification =
                          NotificationClassification.REQUESTNOTIFICATION;

                  NotificationController.to.update(['topViewText']);
                  NotificationController.to.update(['getNotifications']);
                },
                child: const Icon(Icons.change_circle_outlined, size: 40),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),

          // topView 입니다.
          topView(),

          SizedBox(height: 5.h),

          // 새로 고침을 나타내는 View 입니다.
          refreshView(),

          // 요청 알림 목록 또는 댓글 알림 목록을 보여주는 view 입니다.
          prepareNotifications(),
        ],
      ),
    );
  }
}
