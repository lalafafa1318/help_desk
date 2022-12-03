import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/const/causeObsClassification.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/comment_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/notification_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_photo_view_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:tap_to_expand/tap_to_expand.dart';

// 게시한 글과 comment을 보여주는 Page 입니다.
class SpecificPostPage extends StatefulWidget {
  const SpecificPostPage({super.key});

  @override
  State<SpecificPostPage> createState() => _SpecificPostPageState();
}

class _SpecificPostPageState extends State<SpecificPostPage> {
  // PostListPage에서
  // KeywordPostListPage에서
  // WhatIWrotePage에서
  // WhatICommentPage에서 Routing 됐는지 파악하는 변수
  RouteDistinction? whereRoute;

  // copy(clone)된 PostData와 UserData를 참조하는 변수
  PostModel? postData;
  UserModel? userData;

  // 게시물에 대한 댓글 데이터를 저장하는 배열
  List<CommentModel> commentArray = [];
  // 댓글 데이터에 대한 사용자 정보를 저장하는 배열
  List<UserModel> commentUserArray = [];

  // Database에 Comment 데이터를 호출하는 것을 허락할지, 불허할지 판별하는 변수
  bool isCallServerAboutCommentData = false;

  // 일반 사용자인지 IT 담당자인지 구별하는 변수
  UserClassification userType = SettingsController.to.settingUser!.userType;

  // 이전 가기, 알림, 새로 고침, 삭제 버튼을 제공하는 Widget이다.
  Widget topView() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: 50.h,
      child: Row(
        children: [
          // 이전 가기 버튼을 제공하는 Widget이다.
          backButton(),

          // 알림, 새로 고침, 삭제 버튼을 제공하는 Widget이다.
          notifyAndRefreshAndDeleteButton(),
        ],
      ),
    );
  }

  // 이전 가기 버튼을 제공하는 Widget이다.
  Widget backButton() {
    return Container(
      margin: EdgeInsets.only(left: 5.w, top: 20.h),
      child: IconButton(
        onPressed: () async {
          // 키보드 내리기
          FocusManager.instance.primaryFocus!.unfocus();

          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 알림, 새로 고침, 삭제 버튼을 제공하는 Widget이다.
  Widget notifyAndRefreshAndDeleteButton() {
    return Container(
      width: ScreenUtil().screenWidth / 1.2,
      margin: EdgeInsets.only(top: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 알림 버튼 입니다.
          notifyButton(),

          // 새로 고침 버튼 입니다.
          refreshButton(),

          // 삭제 버튼 입니다.
          deleteButton(),
        ],
      ),
    );
  }

  // 알림 버튼 입니다.
  Widget notifyButton() {
    return GetBuilder<NotificationController>(
      id: 'notifyButton',
      builder: (controller) {
        print('SpecificPostPage - notifyButton 호출');
        // 사용자가 게시물(post)에 대해서 알림 신청을 했는지 하지 않았는지 여부를 판별한다.
        bool isResult =
            NotificationController.to.commentNotificationPostUidList.contains(postData!.postUid);

        return IconButton(
          onPressed: () async {
            // 키보드 내리기
            FocusManager.instance.primaryFocus!.unfocus();

            // 게시글이 삭제됐는지 확인한다.
            bool isDeletePostResult = await isDeletePost(
              postData!.obsOrInq,
              postData!.postUid,
            );

            // 게시글이 삭제됐으면?
            if (isDeletePostResult == true) {
              // 게시글이 사라졌다는 AlertDailog를 표시한다.
              await deletePostDialog();

              // 이전 페이지로 돌아가기
              Get.back();
            }
            // 게시글이 삭제되지 않았으면?
            else {
              // 사용자가 게시물(post)에 대해서 알림 신청을 했었다면?
              isResult == true
                  // 사용자가 게시물에 대한 알림을 해제할 떄, 알림 받기 위해 했던 여러 설정을 해제한다.
                  ? await NotificationController.to
                      .clearCommentNotificationSettings(postData!.postUid)
                  // 사용자가 게시물에 대한 알림을 등록할 떄, 알림 받기 위한 여러 설정을 등록한다.
                  : await NotificationController.to
                      .enrollCommentNotificationSettings(postData!.postUid);

              // update()를 실행해 notifyButton Widget만 재랜더링 한다.
              NotificationController.to.update(['notifyButton']);

              // 하단 SnackBar 알림
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 500),
                  content: Text(isResult == true ? '댓글 알림을 off' : '댓글 알림을 on'),
                  backgroundColor: Colors.black87,
                ),
              );
            }
          },

          // 사용자가 게시물(post)에 대해서 알림 신청을 했는지 하지 않았는지 판별해 서로 다른 아이콘을 보여준다.
          icon: isResult == true
              ? const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.red,
                )
              : const Icon(
                  Icons.notifications_off_outlined,
                  color: Colors.grey,
                ),
        );
      },
    );
  }

  // 새로 고침 버튼 입니다.
  Widget refreshButton() {
    return IconButton(
      onPressed: () async {
        // 키보드 내리기
        FocusManager.instance.primaryFocus!.unfocus();

        // 게시글이 삭제됐는지 확인한다.
        bool isDeletePostResult = await isDeletePost(
          postData!.obsOrInq,
          postData!.postUid,
        );

        // 게시글이 삭제됐으면?
        if (isDeletePostResult == true) {
          // 게시글이 사라졌다는 AlertDailog를 표시한다.
          await deletePostDialog();

          // 이전 페이지로 돌아가기
          Get.back();
        }
        // 게시글이 삭제되지 않았으면?
        else {
          // SpecificPostPage에서 변경 가능성이 존재하는 데이터를 업데이트하는 method
          await updateData();

          // Toast Message로 게시물이 새로고침 됐다는 것을 알린다.
          ToastUtil.showToastMessage('게시물이 새로고침 되었습니다 :)');
        }
      },
      icon: const Icon(Icons.refresh_outlined),
    );
  }

  // 삭제 버튼 입니다. (자신이 업로드한 게시물이 아니면 삭제 버튼이 보이지 않습니다.)
  Widget deleteButton() {
    return postData!.userUid == SettingsController.to.settingUser!.userUid
        ? IconButton(
            onPressed: () async {
              // 키보드 내리기
              FocusManager.instance.primaryFocus!.unfocus();

              // AlertDialog를 통해 삭제할 것인지 묻는다.
              bool? isDeletePostResult = await clickDeletePostDialog(postData!);

              // 작성자가 게시물을 삭제한다면?
              if (isDeletePostResult == true) {
                // 이전 가기로 돌아가기
                Get.back();
              }
            },
            icon: const Icon(Icons.delete_outline_outlined),
          )
        : const Visibility(
            visible: false,
            child: Text('업로드한 게시물이 자신의 게시물이 아니기 떄문에 표시하지 않습니다.'),
          );
  }

  // 장애 처리현황 또는 문의 처리현황 분류 코드, 시스템 분류 코드를 제공하는 Widget 입니다.
  Widget showObsOrInqAndSysClassification() {
    return Row(
      children: [
        SizedBox(width: 20.w),

        // 장애 처리현황 또는 문의 처리현황 분류 코드
        obsOrInqClassification(),

        SizedBox(width: 20.w),

        // 시스템 분류 코드
        sysClassification(),
      ],
    );
  }

  // 장애 처리현황 또는 문의 처리현황 분류 코드를 제공하는 Widget
  Widget obsOrInqClassification() {
    return Row(
      children: [
        // 시스템 Text
        const Text('장애/문의'),

        SizedBox(width: 6.w),

        // 시스템 분류 코드
        Container(
          width: 100.w,
          height: 20.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.grey[300],
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(postData!.obsOrInq.asText),
          ),
        ),
      ],
    );
  }

  // 시스템 분류 코드를 제공하는 Widget
  Widget sysClassification() {
    return Row(
      children: [
        // 시스템 Text
        const Text('시스템'),

        SizedBox(width: 6.w),

        // 시스템 분류 코드
        Container(
          width: 100.w,
          height: 20.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.grey[300],
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(postData!.sysClassficationCode.asText),
          ),
        ),
      ],
    );
  }

  // 처리상태 분류 코드와 전화번호를 제공하는 Widget 입니다.
  Widget proClassficationAndTel() {
    return Row(
      children: [
        SizedBox(width: 20.w),

        // 처리상태 분류 코드
        proClassification(),

        SizedBox(width: 20.w),

        // 전화번호 분류 코드
        tel(),
      ],
    );
  }

  // 처리상태 분류 코드를 제공하는 Widget
  Widget proClassification() {
    return Row(
      children: [
        // 처리상태 Text
        const Text('처리상태'),

        SizedBox(width: 10.w),

        // 시스템 분류 코드
        GetBuilder<PostListController>(
          id: 'showProclassification',
          builder: (controller) {
            print('showProclssification - 재랜더링 호출');

            return Container(
              width: 100.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: Colors.grey[300],
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(postData!.proStatus.asText),
                // child: Text(),
              ),
            );
          },
        ),
      ],
    );
  }

  // 전화번호를 제공하는 Widget
  Widget tel() {
    return Row(
      children: [
        // 전화번호 Text
        const Text('휴대폰'),

        SizedBox(width: 6.w),

        // 전화번호를 표시한다.
        GetBuilder<PostListController>(
          id: 'showTel',
          builder: (controller) {
            print('showTel - 재랜더링 호출');
            return GestureDetector(
              onTap: () async {
                // 전화 걸기
                await FlutterPhoneDirectCaller.callNumber(
                    postData!.phoneNumber);
              },
              child: Container(
                width: 100.w,
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  color: Colors.grey[300],
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(postData!.phoneNumber),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  // Avatar와 UserName 그리고 PostTime을 제공하는 Widget 입니다.
  Widget showAvatarAndUserNameAndPostTime() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Row(
        children: [
          // Avatar을 제공하는 Wiget 입니다.
          showAvatar(),

          // UserName과 PostTime을 제공하는 Widget 입니다.
          showUserNameAndPostTime(),
        ],
      ),
    );
  }

  // Avatar을 제공하는 Wiget 입니다.
  Widget showAvatar() {
    return GetBuilder<PostListController>(
      id: 'showAvatar',
      builder: (controller) {
        print('showAvatar - 재랜더링 호출');
        return Padding(
          padding: EdgeInsets.all(16.0.w),
          child: GFAvatar(
            radius: 30.r,
            backgroundImage: CachedNetworkImageProvider(userData!.image),
          ),
        );
      },
    );
  }

  // UserName과 PostTime을 제공하는 Widget 입니다.
  Widget showUserNameAndPostTime() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UserName을 제공하는 Widget 입니다.
          showUserName(),

          SizedBox(height: 5.h),

          // PostTime을 제공하는 Widget 입니다.
          showPostTime(),
        ],
      ),
    );
  }

  // UserName을 제공하는 Widget 입니다.
  Widget showUserName() {
    return GetBuilder<PostListController>(
      id: 'showUserName',
      builder: (controller) {
        print('showUserName - 재랜더링 호출');
        return SizedBox(
          width: 300.w,
          child: Text(
            userData!.userName,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  // PostTime을 제공하는 Widget 입니다.
  Widget showPostTime() {
    return Text(
      // postTime은 원래 초(Second)까지 존재하나
      // 화면에서는 분(Minute)까지 표시한다.
      postData!.postTime.substring(0, 16),
      style: TextStyle(fontSize: 13.sp),
    );
  }

  // PostTitle, PostContent, PostPhoto(있으면 보여주고 없으면 보여주지 않기), PostLikeNum, PostCommentNum를 보여주는 Widget 입니다.
  Widget showTitleAndContentAndPhotoAndCommentNum() {
    return Container(
      margin: EdgeInsets.only(left: 5.w),
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.all(16.0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PostTitle을 제공하는 Widget 입니다.
          showTextTitle(),

          SizedBox(height: 10.h),

          // PostConent을 제공하는 Widget 입니다.
          showTextContent(),

          SizedBox(height: 30.h),

          // PostPhoto을 보여주는 Widget 입니다.
          checkPhoto(),

          SizedBox(height: 10.h),

          //PostLikeNum, PostCommentNum을 제공하는 Widget 입니다.
          showCommentNum(),
        ],
      ),
    );
  }

  // PostTitle을 제공하는 Widget 입니다.
  Widget showTextTitle() {
    return Text(
      postData!.postTitle,
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
    );
  }

  // PostConent을 제공하는 Widget 입니다.
  Widget showTextContent() {
    return Container(
      margin: EdgeInsets.only(left: 3.w),
      child: Text(
        postData!.postContent,
        style: TextStyle(
            color: Colors.grey, fontSize: 15.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  // PostPhoto을 보여주는 Widget 입니다.
  Widget checkPhoto() {
    return postData!.imageList.isNotEmpty
        ? SizedBox(
            width: ScreenUtil().screenWidth,
            height: 250.h,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: postData!.imageList.length,
              itemBuilder: (context, imageIndex) => showPhotos(imageIndex),
            ),
          )
        : const Visibility(
            visible: false,
            child: Text('Visibility 테스트'),
          );
  }

  // PostPhoto을 보여주는 Widget 입니다.
  Widget showPhotos(int imageIndex) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r), // Image border
      child: Container(
        width: 250.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        // 사진을 Tap하면?
        child: GestureDetector(
          onTap: () {
            // SpecificPhotoViewPage로 Routing한다.
            // argument 0번쨰 : PostData이다.
            // argument 1번쨰 : PostData의 imageList 속성이 있고 그 중에서 몇번째 사진인지 알려주는 imageIndex이다.
            Get.to(
              () => const SpecificPhotoViewPage(),
              arguments: [postData, imageIndex],
            );
          },
          child: CachedNetworkImage(
            imageUrl: postData!.imageList[imageIndex],
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  // PostCommentNum을 제공하는 Widget 입니다.
  Widget showCommentNum() {
    return GetBuilder<PostListController>(
      id: 'showCommentNum',
      builder: (controller) {
        print('showCommentNum - 재랜더링 호출');

        return Padding(
          padding: EdgeInsets.all(5.r),
          child: Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: Colors.blue[300],
                size: 20,
              ),
              SizedBox(width: 5.w),
              Text(
                postData!.whoWriteCommentThePost.length.toString(),
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  // 여러 comment를 보여주기 위해 ListView로 나타내는 Widget 입니다.
  Widget showCommentListView() {
    return GetBuilder<PostListController>(
      id: 'showCommentListView',
      builder: (controller) {
        // DataBase에서 여러 comment를 호출하기 위한 설정이 되었는지 확인한다.
        // 설정과 관련된 변수는 isCallServerAboutCommentData 이다.
        // 이 값이 true 상태이면 Database에서 여러 comment 를 받아서 commentArray 배열에 넣고, 화면에 뿌린다.
        // false 상태이면, 기존에 존재하는 commentArray를 가지고 화면에 뿌린다. 즉 Database 호출을 하지 않는다.
        print('showCommentListView - 재랜더링 호출');

        return isCallServerAboutCommentData == true
            ? FutureBuilder<Map<String, dynamic>>(
                future: PostListController.to.getCommentAndUser(postData!),
                builder: (context, snapshot) {
                  // 데이터를 기다리고 있다.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: ScreenUtil().screenWidth,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // 데이터가 왔다.
                  // 하지만 빈 값이다.
                  if (List<CommentModel>.from(
                    snapshot.data!['commentArray'] as List,
                  ).isEmpty) {
                    return const Visibility(
                        visible: false, child: Text('댓글이 없어서 화면에 표시하지 않습니다.'));
                  }

                  // 데이터가 왔다.
                  // 댓글 데이터가 있다.

                  // 기존에 존재하는 CommentArray를 clear()한다.
                  // 기존에 존재하는 CommentUserArray를 clear() 한다.
                  commentArray.clear();
                  commentUserArray.clear();

                  // CommentArray와 CommentUserArray에 값을 업데이트 한다.
                  commentArray.addAll(
                    List<CommentModel>.from(
                        snapshot.data!['commentArray'] as List),
                  );
                  commentUserArray.addAll(
                    List<UserModel>.from(
                        snapshot.data!['commnetUserArray'] as List),
                  );

                  print('comment 데이터, 사용자 데이터 서버 호출해서 가져왔음!!!!!');

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const PageScrollPhysics(),
                    itemCount: commentArray.length,
                    itemBuilder: (context, index) => showComment(index),
                  );
                },
              )
            : const Visibility(
                visible: false,
                child: Text('댓글을 가져오는 설정을 하지 않았으므로 가져오지 않습니다.'),
              );
      },
    );
  }

  // comment을 보여주는 Widget 입니다.
  Widget showComment(int index) {
    // 로그
    print('SpecificPostPage - showComment() - 댓글 데이터를 가져옵니다.');

    return Container(
      color: Colors.grey[100],
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      width: ScreenUtil().screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar와 UserName 그리고 처리상태를 제공하는 Widget 입니다.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar와 UserName을 제공하는 Widget 입니다.
              commentAvatarAndName(index),

              // 처리상태를 제공하는 Widget 입니다. (IT 담당자가 댓글을 쓴 경우에만 보여준다.)
              commentProclassification(index),
            ],
          ),

          // CommentContent을 제공하는 Widget 입니다.
          commentContent(index),

          // 장애원인을 보여주는 Widget 입니다.
          commentCauseOfDisability(index),

          // 실제 장애처리일시를 보여주는 Widget 입니다.
          commentFailureProcessingdDateAndTime(index),

          SizedBox(height: 5.h),

          // CommentPostTime를 제공하는 Widget 입니다.
          commentUploadTime(index),

          SizedBox(height: 5.h),

          // Comment에 대한 삭제 버튼을 제공하는 Widget 입니다.
          commentDeleteButton(index),

          SizedBox(height: 10.h),

          // 구분선
          Divider(height: 1.h, thickness: 2, color: Colors.grey),
        ],
      ),
    );
  }

  // Avatar와 UserName을 제공하는 Widget 입니다.
  Widget commentAvatarAndName(int index) {
    // 댓글과 관련된 게시물이
    // commentUserArray[index].userName과 commentUserArray[index].image를 간단하게 명명한다.
    String whoWriteUserUid = commentArray[index].whoWriteUserUid;
    String userName = commentUserArray[index].userName;
    String userImage = commentUserArray[index].image;

    return Row(
      children: [
        // Avatar를 제공하는 Widget 입니다.
        commentAvatar(userImage),

        // UserName을 제공하는 Widget 입니다.
        commentName(whoWriteUserUid, userName),
      ],
    );
  }

  // Avatar를 제공하는 Widget 입니다.
  Widget commentAvatar(String userImage) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GFAvatar(
        radius: 15.r,
        backgroundImage: CachedNetworkImageProvider(userImage),
      ),
    );
  }

  // UserName을 제공하는 Widget 입니다.
  Widget commentName(String whoWriteUserUid, String userName) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      child: whoWriteUserUid == postData!.userUid
          ? Text(
              '$userName(글쓴이)',
              style: TextStyle(
                color: Colors.blue[300],
                fontWeight: FontWeight.bold,
              ),
            )
          : Text(
              userName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  // comment 처리상태를 제공하는 Widget 입니다. (IT 담당자가 작성한 댓글인 경우에만 보여진다.)
  Widget commentProclassification(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.h, right: 20.w),
      // IT 담당자가 작성한 댓글에서 처리상태가 보이도록 한다.
      child: Text(
        commentArray[index].proStatus != ProClassification.NONE
            ? commentArray[index].proStatus.asText
            : '',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  // CommentContent을 제공하는 Widget 입니다.
  Widget commentContent(int index) {
    return Container(
      margin: EdgeInsets.only(left: 20.w),
      child: Text(commentArray[index].content),
    );
  }

  // 장애 처리현황 게시물에 해당하는 댓글인 경우
  // 장애원인을 보여주는 Widget 입니다.
  Widget commentCauseOfDisability(int index) {
    String text = CauseObsClassification.values
        .firstWhere(
          (element) =>
              element.toString() ==
              commentArray[index].causeOfDisability.toString(),
        )
        .asText;

    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 20.w),
      // IT 담당자가 장애 처리현황 댓글을 작성했을 떄 장애 원인을 표시한다.
      child: text != 'NONE'
          ? Text('* 장애원인 : $text', style: TextStyle(fontSize: 12.sp))
          : const Visibility(
              visible: false,
              child: Text('일반 사용자는 장애 원인을 표시하지 않습니다.'),
            ),
    );
  }

  // 장애 처리현황 게시물에 해당하는 댓글인 경우
  // 실제 장애처리일시를 보여주는 Widget 입니다.
  Widget commentFailureProcessingdDateAndTime(int index) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 20.w, bottom: 10.h),
      child: commentArray[index].actualProcessDate == null &&
              commentArray[index].actualProcessTime == null
          ? const Visibility(
              visible: false,
              child: Text('일반 사용자는 실제 장애처리일시를 표시하지 않습니다.'),
            )
          : Text(
              '* 실제 장애처리일시 : ${commentArray[index].actualProcessDate}  ${commentArray[index].actualProcessTime}',
              style: TextStyle(fontSize: 12.sp),
            ),
    );
  }

  // CommentPostTime를 제공하는 Widget 입니다.
  Widget commentUploadTime(int index) {
    // commentArray[index].uploadTime를  간단하게 명명한다.
    String uploadTime = commentArray[index].uploadTime;

    return Container(
      margin: EdgeInsets.only(left: 20.w),
      child: Text(
        // uploadTime은 원래 초(Second)까지 존재하나
        // 화면에서는 분(Minute)까지 표시한다.
        uploadTime.substring(0, 16),
        style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
      ),
    );
  }

  // Comment에 대한 삭제 버튼을 제공하는 Widget 입니다.
  Widget commentDeleteButton(int index) {
    // comment를 쓴 사용자 uid와 계정 사용자 uid를 비교해서
    // 일치하면 삭제 버튼을 표시한다.
    return commentArray[index].whoWriteUserUid ==
            SettingsController.to.settingUser!.userUid
        ? Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(right: 10.w),
              width: 30.w,
              height: 25.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.r)),
                color: Colors.grey,
              ),
              child: IconButton(
                padding: EdgeInsets.only(top: 1.h),
                onPressed: () async {
                  // 키보드 내리기
                  FocusManager.instance.primaryFocus!.unfocus();

                  // 게시글이 삭제됐는지 확인한다.
                  bool isDeletePostResult = await isDeletePost(
                    postData!.obsOrInq,
                    postData!.postUid,
                  );

                  // 게시글이 삭제됐으면?
                  if (isDeletePostResult == true) {
                    // 게시글이 사라졌다는 AlertDailog를 표시한다.
                    await deletePostDialog();

                    // 이전 페이지로 돌아가기
                    Get.back();
                  }
                  // 게시글이 삭제되지 않으면
                  else {
                    // 이 comment을 삭제하시겠습니까? AlertDialog 표시하기
                    await clickCommentDeleteButtonDialog(index);
                  }
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[200]!.withOpacity(1),
                  size: 20,
                ),
              ),
            ),
          )
        : const Visibility(
            visible: false,
            child: Text('계정이 일치하지 않으므로 휴지통 버튼이 보이지 않습니다.'),
          );
  }

  // 답변 정보 입력을 제공하는 Widget 입니다.
  Widget answerInformationInput() {
    return GetBuilder<PostListController>(
      id: 'answerInformationInput',
      builder: (controller) {
        print('answerInformationInput - 재랜더링 호출');

        return TapToExpand(
          color: Colors.grey[400],
          title: Text(
            '답변 정보 입력',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
            ),
          ),
          content: Column(
            children: [
              // 처리상태를 보여준다. -> 일반 사용자는 보여주지 않는다. IT 담당자만 보여줄 것...
              userType == UserClassification.GENERALUSER
                  ? const Visibility(
                      visible: false,
                      child: Text('일반 사용자의 경우 처리상태 칸을 보여주지 않습니다.'))
                  : commentProClassification(),

              // 장애원인, 처리일자, 처리시간을 보여준다.
              // 일반 사용자는 당연히 보여주지 않는다.
              // IT 담당자의 경우, 장애 처리현황 게시물이면 보여준다. 문의 처리현황 게시물은 보여주지 않는다.
              userType == UserClassification.GENERALUSER
                  ? const Visibility(
                      visible: false,
                      child:
                          Text('일반 사용자의 경우 장애원인, 실제 처리일자, 실제 처리시간을 보여주지 않습니다.'))
                  : postData!.obsOrInq ==
                          ObsOrInqClassification.obstacleHandlingStatus
                      ? obsCommentOption()
                      : const Visibility(
                          visible: false,
                          child: Text(
                              '문의 처리현황 게시물인 경우 장애 원인, 실제 처리일자, 실제 처리시간을 보여주지 않습니다.'),
                        ),

              // 높이 빈칸을 설정한다.
              userType == UserClassification.GENERALUSER
                  ? SizedBox(height: 20.h)
                  : postData!.obsOrInq ==
                          ObsOrInqClassification.obstacleHandlingStatus
                      ? SizedBox(height: 0.h)
                      : SizedBox(height: 20.h),

              // 내용
              // 일반 사용자와 IT 담당자 모두 보여진다.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 댓글을 입력한다.
                  writeComment(),

                  // 댓글 전송
                  sendComment(),
                ],
              )
            ],
          ),
          trailing: const Icon(
            Icons.ads_click_outlined,
            color: Colors.white,
          ),
          openedHeight:
              userType == UserClassification.GENERALUSER ? 150.h : 200.h,
          closedHeight: 70.h,
          onTapPadding: 20.w,
          scrollable: true,
          borderRadius: 10.r,
        );
      },
    );
  }

  // comment에 대한 처리상태를 setting 한다. (IT 담당자 - 장애 처리현황, 문의 처리현황 게시글에 모두 적용)
  Widget commentProClassification() {
    return Row(
      children: [
        // 처리상태 Text
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          child: Text('처리상태', style: TextStyle(fontSize: 13.sp)),
        ),

        SizedBox(width: 10.w),

        // comment에 대한 처리상태를 setting하는 Dropdown
        GetBuilder<PostListController>(
          id: 'commentProClassficationDropdown',
          builder: (controller) {
            return DropdownButton(
              value: PostListController.to.commentPSelectedValue.name,
              style: TextStyle(color: Colors.black, fontSize: 13.sp),
              items: ProClassification.values
                  .where((element) =>
                      element != ProClassification.ALL &&
                      element != ProClassification.NONE)
                  .map((element) {
                // enum의 값을 화면에 표시할 값으로 변환한다.
                String realText = element.asText;

                return DropdownMenuItem(
                  value: element.name,
                  child: Text(realText),
                );
              }).toList(),
              onChanged: (element) {
                // PostListController의 commentPSelectedValue 값을 바꾼다.
                PostListController.to.commentPSelectedValue = ProClassification
                    .values
                    .firstWhere((enumValue) => enumValue.name == element);

                // 해당 GetBuilder만 재랜더링 한다.
                PostListController.to
                    .update(['commentProClassficationDropdown']);
              },
            );
          },
        ),
      ],
    );
  }

  // 장애원인, 처리일자, 처리시간을 보여주는 Widget (IT 담당자 - 장애 처리현황 게시글에만 적용)
  Widget obsCommentOption() {
    return Column(
      children: [
        // 장애원인 (장애 처리현황에만 적용)
        causeOfDisability(),

        SizedBox(height: 10.h),

        // 처리일자(장애 처리현황에만 적용)
        actualProcessDate(),

        SizedBox(height: 10.h),

        // 처리시간(장애 처리현황에만 적용)
        actualProcessTime(),

        SizedBox(height: 10.h),
      ],
    );
  }

  // comment에 대한 장애원인을 setting 하는 Widget (IT 담당자 - 장애 처리현황 게시글에만 적용)
  Widget causeOfDisability() {
    return Row(
      children: [
        // 장애원인 Text
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          child: Text('장애원인', style: TextStyle(fontSize: 13.sp)),
        ),

        SizedBox(width: 10.w),

        // comment에 대한 장애원인을 setting하는 Dropdown
        GetBuilder<PostListController>(
          id: 'commentCauseObsClassificationDropdown',
          builder: (controller) {
            return DropdownButton(
              value: PostListController.to.commentCSelectedValue.name,
              style: TextStyle(color: Colors.black, fontSize: 13.sp),
              items: CauseObsClassification.values
                  .where((element) => element != CauseObsClassification.NONE)
                  .map((element) {
                // enum의 값을 화면에 표시할 값으로 변환한다.
                String realText = element.asText;

                return DropdownMenuItem(
                  value: element.name,
                  child: Text(realText),
                );
              }).toList(),
              onChanged: (element) {
                // PostListController의 commentCSelectedValue 값을 바꾼다.
                PostListController.to.commentCSelectedValue =
                    CauseObsClassification.values
                        .firstWhere((enumValue) => enumValue.name == element);

                // 해당 GetBuilder만 재랜더링 한다.
                PostListController.to
                    .update(['commentCauseObsClassificationDropdown']);
              },
            );
          },
        ),
      ],
    );
  }

  // comment에 대한 처리일자를 setting하는 Widget (IT 담당자 - 장애 처리현황 게시글에만 적용)
  Widget actualProcessDate() {
    return Row(
      children: [
        // 처리일자
        Text(
          '처리일자',
          style: TextStyle(fontSize: 13.sp),
        ),

        SizedBox(width: 10.w),

        // 처리일자를 현재 시간에 맞게 판단한 다음 text로 표현한다.
        Builder(builder: (context) {
          PostListController.to.commentActualProcessDate =
              DateFormat('yy/MM/dd').format(DateTime.now());
          return Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
            height: 25.h,
            child: Text(PostListController.to.commentActualProcessDate),
          );
        }),
      ],
    );
  }

  // comment에 대한 처리 시간을 setting 하는 Widget (IT 담당자 - 장애 처리현황 게시글에만 적용)
  Widget actualProcessTime() {
    return Row(
      children: [
        // 처리시간 Text
        Text(
          '처리시간',
          style: TextStyle(fontSize: 13.sp),
        ),

        SizedBox(width: 10.w),

        // 처리시간을 현재 시간에 맞게 판단한 다음 text로 표현한다.
        Builder(builder: (context) {
          PostListController.to.commentActualProcessTime =
              DateFormat('HH:mm').format(DateTime.now());
          return Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
            height: 25.h,
            child: Text(PostListController.to.commentActualProcessTime),
          );
        }),
      ],
    );
  }

  // comment 댓글 입력하기 창 입니다.
  Widget writeComment() {
    return SizedBox(
      width: 200.w,
      height: 40.h,
      child: TextField(
        controller: PostListController.to.commentController,
        onChanged: ((value) {
          print('comment 내용 : ${PostListController.to.commentController.text}');
        }),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '댓글을 입력하세요',
        ),
      ),
    );
  }

  // comment 보내기 아이콘 입니다.
  Widget sendComment() {
    return IconButton(
      onPressed: () async {
        // comment에 입력한 텍스트 확인하기
        String comment = PostListController.to.commentController.text;

        // 키보드 내리기
        FocusManager.instance.primaryFocus!.unfocus();

        // 게시글이 삭제됐는지 확인한다.
        bool isDeletePostResult = await isDeletePost(
          postData!.obsOrInq,
          postData!.postUid,
        );

        // 게시글이 삭제됐으면?
        if (isDeletePostResult == true) {
          // 게시글이 사라졌다는 AlertDailog를 표시한다.
          await deletePostDialog();

          // 이전 페이지로 돌아가기
          Get.back();
        }
        // 게시글이 삭제되지 않으면?
        else {
          // 댓글이 빈 값이면, 게시하지 않는다.
          if (comment.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text('내용을 입력하거나 실제 처리일자를 입력해야 합니다.'),
                backgroundColor: Colors.black87,
              ),
            );
            return;
          }

          // 일반 사용자, IT 담당자가 답변 정보 입력 할 수 있는 모든 조건을 충족한다. -> 검증 완료

          // Database에 comment(댓글)을 추가한다.
          await PostListController.to.addComment(comment, postData!);

          // Database에 게시물의 whoWriteCommentThePost 속성에 사용자 uid를 추가한다.
          await PostListController.to.addWhoWriteCommentThePost(
              postData!, SettingsController.to.settingUser!.userUid);

          // SpecificPostPage에 변경 사항이 존재하는 데이터를 업데이트 한다.
          await updateData();
        }
      },
      icon: const Icon(Icons.send),
    );
  }

  // Method
  // PostListPage에서 Routing 됐는지
  // KeyWordPostListPage에서 Routing 됐는지
  // WhatIWrotePage에서 Routing 됐는지
  // WhatICommentPage에서 Routing 됐는지 결정하는 method
  void whereRouting() {
    switch (Get.arguments[1]) {
      // PostListPage의 장애 처리현황 게시물을 Tab했다면?
      case RouteDistinction.postListPageObsPostToSpecificPostPage:
        whereRoute = RouteDistinction.postListPageObsPostToSpecificPostPage;
        break;
      // PostListPage의 문의 처리현황 게시물을 Tab했다면?
      case RouteDistinction.postListPageInqPostToSpecificPostPage:
        whereRoute = RouteDistinction.postListPageInqPostToSpecificPostPage;
        break;
      // KeywordPostListPage의 장애 처리현황 게시물을 Tab했다면?
      case RouteDistinction.keywordPostListPageObsPostToSpecificPostPage:
        whereRoute =
            RouteDistinction.keywordPostListPageObsPostToSpecificPostPage;
        break;
      // KeywordPostListPage의 문의 처리현황 게시물을 Tab했다면?
      case RouteDistinction.keywordPostListPageInqPostToSpecificPostPage:
        whereRoute =
            RouteDistinction.keywordPostListPageInqPostToSpecificPostPage;
        break;
      // WhatIWrotePostPage의 장애 처리현황 게시물을 Tab했다면?
      case RouteDistinction.whatIWrotePageObsPostToSpecificPostPage:
        whereRoute = RouteDistinction.whatIWrotePageObsPostToSpecificPostPage;
        break;
      // WhatIWrotePostPage의 문의 처리현황 게시물을 Tab했다면?
      case RouteDistinction.whatIWrotePageInqPostToSpecificPostPage:
        whereRoute = RouteDistinction.whatIWrotePageInqPostToSpecificPostPage;
        break;
      // WhatICommentPage의 장애 처리현황 게시물을 Tab했다면?
      case RouteDistinction.whatICommentPageObsPostToSpecificPostPage:
        whereRoute = RouteDistinction.whatICommentPageObsPostToSpecificPostPage;
        break;
      // WhatICommentPage의 문의 처리현황 게시물을 Tab했다면?
      case RouteDistinction.whatICommentPageInqPostToSpecificPostPage:
        whereRoute = RouteDistinction.whatICommentPageInqPostToSpecificPostPage;
        break;
      // NotificationPage에서 알림과 관련된 장애 처리현황 게시물을 Tab했다면?
      case RouteDistinction.notificationPageObsToSpecifcPostPage:
        whereRoute = RouteDistinction.notificationPageObsToSpecifcPostPage;
        break;
      // NotificationPage에서 알림과 관련된 문의 처리현황 게시물을 Tab했다면?
      default:
        whereRoute = RouteDistinction.notificationPageInqToSpecifcPostPage;
        break;
    }
  }

  // 이전 페이지에서 넘겨 받은 index를 통해
  // 게시물 데이터와 사용자 정보 데이터를 copy(clone)하는 method
  void copyPostAndUserData() {
    int index = Get.arguments[0];

    // PostListPage의 장애 처리현황 게시물을 Tab해서 Routing 되었을 경우
    if (whereRoute == RouteDistinction.postListPageObsPostToSpecificPostPage) {
      // Tab했던 장애 처리현황 게시물을 copy(clone)한다.
      postData = PostListController.to.obsPostData[index].copyWith();

      // Tab했던 장애 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = PostListController.to.obsUserData[index].copyWith();
    }
    // PostListPage의 문의 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.postListPageInqPostToSpecificPostPage) {
      // Tab했던 문의 처리현황 게시물을 copy(clone)한다.
      postData = PostListController.to.inqPostData[index].copyWith();

      // Tab했던 문의 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = PostListController.to.inqUserData[index].copyWith();
    }
    // KeywordPostListPage의 장애 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.keywordPostListPageObsPostToSpecificPostPage) {
      // Tab했던 장애 처리현황 게시물을 copy(clone)한다.
      postData = PostListController.to.conditionObsPostData[index].copyWith();

      // Tab했던 장애 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = PostListController.to.conditionObsUserData[index].copyWith();
    }
    // KeywordPostListPage의 문의 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.keywordPostListPageInqPostToSpecificPostPage) {
      // Tab했던 문의 처리현황 게시물을 copy(clone)한다.
      postData = PostListController.to.conditionInqPostData[index].copyWith();

      // Tab했던 문의 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = PostListController.to.conditionInqUserData[index].copyWith();
    }
    // WhatIWrotePostPage의 장애 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.whatIWrotePageObsPostToSpecificPostPage) {
      // Tab했던 장애 처리현황 게시물을 copy(clone)한다.
      postData = SettingsController.to.obsWhatIWrotePostDatas[index].copyWith();

      // Tab했던 장애 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = SettingsController.to.obsWhatIWroteUserDatas[index].copyWith();
    }
    // WhatIWrotePostPage의 문의 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.whatIWrotePageInqPostToSpecificPostPage) {
      // Tab했던 문의 처리현황 게시물을 copy(clone)한다.
      postData = SettingsController.to.inqWhatIWrotePostDatas[index].copyWith();

      // Tab했던 문의 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = SettingsController.to.inqWhatIWroteUserDatas[index].copyWith();
    }
    // WhatICommentPostPage의 장애 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.whatICommentPageObsPostToSpecificPostPage) {
      // Tab했던 장애 처리현황 게시물을 copy(clone)한다.
      postData =
          SettingsController.to.obsWhatICommentPostDatas[index].copyWith();

      // Tab했던 장애 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData =
          SettingsController.to.obsWhatICommentUserDatas[index].copyWith();
    }
    // WhatICommentPostPage의 문의 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.whatICommentPageInqPostToSpecificPostPage) {
      // Tab했던 문의 처리현황 게시물을 copy(clone)한다.
      postData =
          SettingsController.to.inqWhatICommentPostDatas[index].copyWith();

      // Tab했던 문의 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData =
          SettingsController.to.inqWhatICommentUserDatas[index].copyWith();
    }

    // NotificationPage의 알림과 관련된 장애 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else if (whereRoute ==
        RouteDistinction.notificationPageObsToSpecifcPostPage) {
      // Tab했던 장애 처리현황 게시물을 copy(clone)한다.
      postData = PostListController.to.obsPostData[index].copyWith();

      // Tab했던 장애 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = PostListController.to.obsUserData[index].copyWith();
    }

    // NotificationPage의 알림과 관련된 문의 처리현황 게시물을 Tab해서 Routing 되었을 경우
    else {
      // Tab했던 문의 처리현황 게시물을 copy(clone)한다.
      postData = PostListController.to.inqPostData[index].copyWith();

      // Tab했던 문의 처리현황 게시물에 대한 사용자 정보를 copy(clone)한다.
      userData = PostListController.to.inqUserData[index].copyWith();
    }
  }

  // 게시물이 삭제되었는지 확인하는 method
  Future<bool> isDeletePost(ObsOrInqClassification obsOrInq, String postUid) async {
    print('SpecificPostPage - isDeletePost() 호출');

    // 게시물이 삭제됐으면 isDeletePostResult는 true
    // 게시물이 삭제되지 않았으면 isDeletePostResult는 false를 반환한다.
    bool isDeletePostResult = await PostListController.to.isDeletePost(
      obsOrInq,
      postUid,
    );

    print('SpecificPostPage - isDeletePost() - ${isDeletePostResult}');

    return isDeletePostResult;
  }

  // 게시물이 삭제됐다는 것을 알리는 AlertDialog 입니다.
  Future<bool?> deletePostDialog() async {
    return showDialog<bool?>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierColor: Colors.black38,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                Text('해당 게시물은 삭제되었습니다 :)'),
              ],
            ),
            actions: [
              // 돌아가기 버튼
              TextButton(
                child: const Text(
                  '이전 페이지로 돌아가기',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 게시물에 대한 삭제를 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<bool?> clickDeletePostDialog(PostModel postData) async {
    return showDialog<bool?>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                Text('삭제하시겠습니까?'),
              ],
            ),
            actions: [
              // 취소 버튼
              TextButton(
                child: const Text(
                  '취소',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  // false를 가지고 이전 페이지로 돌아가기
                  Get.back<bool>(result: false);
                },
              ),
              // 확인 버튼
              TextButton(
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  // 로딩 바 시작
                  EasyLoading.show(
                    status: '게시물을\n삭제하는 중 입니다 :)',
                    maskType: EasyLoadingMaskType.black,
                  );

                  // DataBase에 게시물을 delete 한다.
                  await PostListController.to.deletePost(postData);

                  // 로딩 바 끝
                  EasyLoading.dismiss();

                  // true를 가지고 이전 페이지로 돌아가기
                  Get.back<bool>(result: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // comment에 대한 삭제 버튼을 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<bool?> clickCommentDeleteButtonDialog(int index) async {
    return showDialog<bool?>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                Text('이 comment를 삭제하시겠습니까?'),
              ],
            ),
            actions: [
              // 취소 버튼
              TextButton(
                child: const Text(
                  '취소',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  // 이전 페이지로 돌아가기
                  Get.back();
                },
              ),
              // 확인 버튼
              TextButton(
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  // 로딩바 시작(필요하면 추가하기로)
                  EasyLoading.show(
                    status: 'comment를\n삭제 합니다:)',
                    maskType: EasyLoadingMaskType.black,
                  );

                  // Database에 comment를 삭제한다.
                  await PostListController.to
                      .deleteComment(commentArray[index], postData!);

                  // SpecificPostPage에 변경 사항 가능성이 있는 데이터를 업데이트한다.
                  await updateData();

                  // 로딩바 끝(필요하면 추가하기로)
                  EasyLoading.dismiss();

                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // SpecificPostPage에서 변경 가능성이 존재하는 데이터를 업데이트하는 method
  Future<void> updateData() async {
    // DataBase에서
    // 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 
    // 위 필드인 userData에 업데이트 한다.
    await updateUserData();

    // DataBase에서
    // 게시물(obsPosts, inqPosts)에 대한 proStatus, phoneNumber, whoWriteCommentThePost에 대한 데이터를 받아와서
    // 위 필드인 postData에 업데이트한다.
    await updatePostData();

    // 답변 정보 입력에 대한 정보 초기화 작업 한다.
    resetAnswerInformationInput();

    // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
    // 필요한 부분만 재랜더링 한다.
    // 1. 게시물에 대한 처리상태가 업데이트 됐을 가능성을 대비하여 최신의 데이터를 보여줄 수 있도록 재랜더링 한다.
    // 2. 게시물을 작성한 사용자의 전화번호가 업데이트 됐을 가능성을 대비하여 최신의 데이터를 보여줄 수 있도록 재랜더링 한다.
    // 3. 사용자 Avatar와 이름이 업데이트 됐을 가능성을 대비하여 최신의 데이터를 보여줄 수 있도록 재랜더링 한다.
    // 4. 게시물에 대한 댓글 수가 업데이트 됐을 가능성을 대비하여 최신의 데이터를 보여줄 수 있도록 재랜더링 한다.
    // 5. 댓글 데이터가 업데이트 됐을 가능성을 대비하여 최신의 데이터를 보여줄 수 있도록 재랜더링 한다.
    // 6. 답변 정보 입력에 댓글 입력하는 부분을 빈칸으로 다시 만든다.
    //    IT 담당자가 장애 처리현황 게시물에 대한 답변 정보 입력을 하고, 바로 답변 정보 입력을 해야할 떄
    //    처리일자, 처리시간이 현재 일자, 시간으로 업데이트 되어야 한다. 그렇게 하기 위해서 재랜더링 하는 이유도 있다.
    PostListController.to.update([
      'showProclassification',
      'showTel',
      'showAvatar',
      'showUserName',
      'showCommentNum',
      'showCommentListView',
      'answerInformationInput',
    ]);
  }

  // DataBase에서
  // 게시글 작성한 사람(User)에 대한 image, userName 속성에 접근한다.
  // 접근한 다음 위 필드 userData에 업데이트 한다.
  Future<void> updateUserData() async {
    print('SpecificPostPage - updateUserData() 호출');

    // DataBase에 게시글 작성한 사람(User) 정보를 가져온다.
    UserModel user = await PostListController.to.getUserData(userData!.userUid);

    // UserData의 image, userName 속성에 값을 업데이트 한다.
    userData!.image = user.image;
    userData!.userName = user.userName;
  }

  // DataBase에서
  // 게시물(obsPosts, inqPosts)에 대해서 변경 가능성이 존재하는 속성에 접근한다.
  // 변경 가능성이 존재하는 속성 : proStatus, phoneNumber, whoWriteCommentThePost
  // 접근한 다음 위 필드 postData에 업데이트 한다.
  Future<void> updatePostData() async {
    print('SpecificPostPage - updatePostData() 호출');

    // DataBase에 게시글(obsPosts, inqPosts) 정보를 가져온다.
    PostModel post = await PostListController.to.getPostData(postData!);

    // postData의 proStatus, phoneNumber, whoWriteCommentThePost 속성에 값을 업데이트 한다.
    postData!.proStatus = post.proStatus;
    postData!.phoneNumber = post.phoneNumber;
    postData!.whoWriteCommentThePost = post.whoWriteCommentThePost;
  }

  // 답변 정보 입력에 대한 내용을 초기화 하는 method
  void resetAnswerInformationInput() {
    // 답변 정보 입력에서 IT 담당자에게만 보이는 처리상태, 장애원인을 초기화한다.
    // 즉, 처리상태는 대기(WAITING), 장애원인은 사용자(USER)로 초기화한다.
    PostListController.to.commentPSelectedValue = ProClassification.WAITING;
    PostListController.to.commentCSelectedValue = CauseObsClassification.USER;

    // 답변 정보 입력에서 IT 담당자에게만 보이는 처리일자, 처리시간을 초기화한다.
    // 즉 처리일자와 처리시간을 빈값으로 초기화한다.
    PostListController.to.commentActualProcessDate = '';
    PostListController.to.commentActualProcessTime = '';

    // comment Text를 관리하는 controller의 값을 빈값을 초기화한다.
    PostListController.to.commentController.text = '';
  }

  // SpecificPostPage에 사용했던 데이터를 초기화 하는 method
  void clearData() {
    // 배열, 변수 clear
    postData = null;
    userData = null;

    whereRoute = null;

    commentArray.clear();
    commentUserArray.clear();
  }

  // specificPostPage가 처음 불릴 떄 호출되는 method
  @override
  void initState() {
    super.initState();

    print('SpecificPostPage - initState() 호출');

    // PostListPage에서 Routing 됐는지
    // KeyWordPostListPage에서 Routing 됐는지
    // WhatIWrotePage에서 Routing 됐는지
    // WhatICommentPage에서 Routing 됐는지 결정하는 method
    whereRouting();

    // 이전 페이지에서 넘겨 받은 index를 통해 postData와 userData를 확인하고 copy(clone)하는 method
    copyPostAndUserData();

    // 게시글이 삭제됐는지 확인한다.
    isDeletePost(postData!.obsOrInq, postData!.postUid).then(
      (bool isDeletePostResult) async {
        print('SpecificPostPage - isDeletePost() 호출 후');

        // 게시글이 삭제됐으면?
        if (isDeletePostResult == true) {
          // 게시글이 삭제됐다는 AlertDailog를 표시한다.
          await deletePostDialog();

          // 이전 페이지로 돌아가기
          Get.back();
        }
        // 게시글이 삭제되지 않으면?
        else {
          // SpecificPostPage에서 변경 가능성이 존재하는 데이터를 업데이트하는 method
          await updateData();

          // Database에 Comment 데이터를 호출하는 것을 허락한다.
          isCallServerAboutCommentData = true;
        }
      },
    );
  }

  // SpecificPostPage가 사라질 떄 호출되는 method
  @override
  void dispose() {
    // 로그
    print('SpecificPostPage - dispose() 호출');

    // 답변 정보 입력을 초기화 한다.
    resetAnswerInformationInput();

    // SpecificPostPage에서 사용했던 데이터를 clear한다.
    clearData();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SpecificPostPage - build() 호출');

    return SafeArea(
      child: Scaffold(
        // 키보드를 위로 올리면 댓글 입력할 수 있도록 설정한다.
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이전 가기, 알림, 새로 고침, 삭제 버튼을 제공하는 Widget이다.
              topView(),

              SizedBox(height: 20.h),

              // 장애 처리현황 또는 문의 처리현황 분류 코드, 시스템 분류 코드를 제공하는 Widget 입니다.
              showObsOrInqAndSysClassification(),

              SizedBox(height: 10.h),

              // 처리상태 분류 코드와 전화번호를 제공하는 Widget 입니다.
              proClassficationAndTel(),

              SizedBox(height: 10.h),

              // Avatar와 UserName, PostTime을 표시하는 Widget이다.
              showAvatarAndUserNameAndPostTime(),

              // PostTitle, PostContent, PostPhoto(있으면 보여주고 없으면 보여주지 않기), PostCommentNum를 보여주는 Widget 입니다.
              showTitleAndContentAndPhotoAndCommentNum(),

              SizedBox(height: 20.h),

              // comment를 보여주는 ListView (단, comment가 없으면 invisible)
              showCommentListView(),

              SizedBox(height: 40.h),

              // 답변 정보 입력을 보여주는 Widget
              answerInformationInput(),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
