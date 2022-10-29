import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/comment_model.dart';
import 'package:help_desk/model/notification_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/routeDistinction/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/notification_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_photo_view_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

  // CommentData를 관리하는 배열
  List<CommentModel> commentArray = [];
  // CommentData의 whoWriteUserUid를 참고하여 UserData을 가져와 관리하는 배열
  List<UserModel> commentUserArray = [];

  // Server에 Comment 데이터를 호출하는 것을 허락할지, 불허할지 판별하는 변수
  bool isCallServerAboutCommentData = false;

  // 이전 가기, 알림, 새로 고침, 삭제 버튼을 제공하는 Widget이다.
  Widget topView() {
    return SizedBox(
      width: Get.width,
      height: 50,
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
      margin: const EdgeInsets.only(left: 5, top: 20),
      child: IconButton(
        onPressed: () async {
          // 키보드 내리기
          FocusManager.instance.primaryFocus!.unfocus();

          // 사용자가 하단 comment을 입력할 수 있는 창에 text를 입력했으면
          // PostListController.to.commentController!.text를 빈칸으로 설정한다.
          if (PostListController.to.commentController.text.isNotEmpty) {
            PostListController.to.commentController.text = '';
          }

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
      width: Get.width / 1.2,
      margin: const EdgeInsets.only(top: 20),
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
      builder: (controller) {
        // 사용자가 게시물(post)에 대해서 알림 신청을 했는지 하지 않았는지 여부를 판별한다.
        bool isResult =
            NotificationController.to.notiPost.contains(postData!.postUid);

        return IconButton(
          onPressed: () async {
            // 키보드 내리기
            FocusManager.instance.primaryFocus!.unfocus();

            // 게시글이 삭제됐는지 확인한다.
            bool isDeletePostResult = await isDeletePost();

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
              if (isResult == true) {
                // 해당 게시물 Uid가 notiPost Array의 몇번째 index에 있는지 확인한다.
                int index = NotificationController.to.notiPost
                    .indexOf(postData!.postUid);

                // 실시간으로 Listen 하는 것을 중지하는 것을 넘어서 삭제한다.
                NotificationController.to.listenList[index].cancel();

                // NotificationController의 notifPost Array에 게시물 uid를 삭제한다.
                NotificationController.to.notiPost.removeAt(index);

                // NotificationController의 commentCount Array에 element를 remove한다.
                NotificationController.to.commentCount.removeAt(index);

                // NotificationController의 listenList Array에 element을 remove한다.
                NotificationController.to.listenList.removeAt(index);

                // Server에 User의 notiPost 속성에 게시물 uid를 삭제한다.
                await NotificationController.to.deleteNotiPostFromUser(
                  postData!.postUid,
                  SettingsController.to.settingUser!.userUid,
                );

                // Notification.to.update()를 실행행 notifyButton Widget만 재랜더링 한다.
                NotificationController.to.update();

                // 하단 SnackBar 알림
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 500),
                    content: Text('댓글 알림 off)'),
                    backgroundColor: Colors.black87,
                  ),
                );
              }

              // 사용자가 게시물(post)에 대해서 알림 신청을 하지 않았다면?
              else {
                // NotificationControler의 notiPost Array에 게시물 uid를 추가한다.
                NotificationController.to.notiPost.add(postData!.postUid);

                // 해당 게시물 Uid가 notiPost Array의 몇번째 index에 있는지 확인한다.
                int index = NotificationController.to.notiPost
                    .indexOf(postData!.postUid);

                // 사용자가 알림 신청한 게시물(Post)에 대한 댓글 개수를 NotificationController의 commentCount Array에 추가한다.
                NotificationController.to.commentCount.add(
                  await CommunicateFirebase.getCountFromComments(
                    postData!.postUid,
                  ),
                );

                // Server에서 게시물(post)의 변동사항을 추가로 listen 한다.
                NotificationController.to.addListen(index);

                // Server에 User의 notiPost 속성에 게시물 uid를 추가한다.
                await NotificationController.to.addNotiPostFromUser(
                  postData!.postUid,
                  SettingsController.to.settingUser!.userUid,
                );

                // Notification.to.update()를 실행해 notifyButton Widget만 재랜더링 한다.
                NotificationController.to.update();

                // 하단 SnackBar 알림
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 500),
                    content: Text('댓글 알림을 on'),
                    backgroundColor: Colors.black87,
                  ),
                );
              }
            }
          },

          // 사용자가 게시물(post)에 대해서 알림 신청을 했는지 하지 않았는지 판별해 서로 다른 아이콘을 보여준다.
          icon: isResult
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
        bool isDeletePostResult = await isDeletePost();

        // 게시글이 삭제됐으면?
        if (isDeletePostResult == true) {
          // 게시글이 사라졌다는 AlertDailog를 표시한다.
          await deletePostDialog();

          // 이전 페이지로 돌아가기
          Get.back();
        }
        // 게시글이 삭제되지 않았으면?
        else {
          // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
          await updateImageAndUserNameToUserData();

          // Server에서 Post에 대한 whoLikeThePost(게시물 공감한 사람), whoWriteCommentThePost(게시물에 댓글 작성한 사람)
          // 에 대한 데이터를 받아와서 PostData에 업데이트 한다.
          await updateWhoLikeThePostAndWhoWriteCommentThePostToPostData();

          // Server에 Comment 데이터를 호출하는 것을 허락한다.
          // isCallServerAboutCommentData = true;

          // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
          // 부분적으로 재랜더링 한다.
          // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
          // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
          PostListController.to.update();

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
              bool? isDeletePostResult =
                  await clickDeletePostDialog(postData!.postUid);

              // 작성자가 게시물을 삭제한다면?
              if (isDeletePostResult == true) {
                // 이전 가기로 돌아가기
                Get.back();
              }
            },
            icon: const Icon(Icons.delete_outline_outlined),
          )
        : const Visibility(
            child: Text('Visibility 테스트'),
            visible: false,
          );
  }

  // Avatar와 UserName 그리고 PostTime을 제공하는 Widget 입니다.
  Widget showAvatarAndUserNameAndPostTime() {
    return SizedBox(
      width: Get.width,
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
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GFAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(userData!.image),
          ),
        );
      },
    );
  }

  // UserName과 PostTime을 제공하는 Widget 입니다.
  Widget showUserNameAndPostTime() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UserName을 제공하는 Widget 입니다.
          showUserName(),

          const SizedBox(height: 5),

          // PostTime을 제공하는 Widget 입니다.
          showPostTime(),
        ],
      ),
    );
  }

  // UserName을 제공하는 Widget 입니다.
  Widget showUserName() {
    return GetBuilder<PostListController>(
      builder: (controller) {
        return SizedBox(
          width: 300,
          child: Text(
            userData!.userName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      style: const TextStyle(fontSize: 13),
    );
  }

  // PostTitle, PostContent, PostPhoto(있으면 보여주고 없으면 보여주지 않기), PostLikeNum, PostCommentNum를 보여주는 Widget 입니다.
  Widget showTitleAndContnetAndPhotoAndLikeNumAndCommentNum() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PostTitle을 제공하는 Widget 입니다.
          showTextTitle(),

          const SizedBox(height: 10),

          // PostConent을 제공하는 Widget 입니다.
          showTextContent(),

          const SizedBox(height: 30),

          // PostPhoto을 보여주는 Widget 입니다.
          checkPhoto(),

          const SizedBox(height: 10),

          //PostLikeNum, PostCommentNum을 제공하는 Widget 입니다.
          showLikeNumAndCommentNum(),
        ],
      ),
    );
  }

  // PostTitle을 제공하는 Widget 입니다.
  Widget showTextTitle() {
    return Text(
      postData!.postTitle,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // PostConent을 제공하는 Widget 입니다.
  Widget showTextContent() {
    return Text(
      postData!.postContent,
      style: const TextStyle(
          color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  // PostPhoto을 보여주는 Widget 입니다.
  Widget checkPhoto() {
    return postData!.imageList.isNotEmpty
        ? SizedBox(
            width: double.infinity,
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: postData!.imageList.length,
              itemBuilder: (context, imageIndex) => showPhotos(imageIndex),
            ),
          )
        : const Visibility(
            child: Text('Visibility 테스트'),
            visible: false,
          );
  }

  // PostPhoto을 보여주는 Widget 입니다.
  Widget showPhotos(int imageIndex) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // Image border
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 5),
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

  //PostLikeNum, PostCommentNum을 제공하는 Widget 입니다.
  Widget showLikeNumAndCommentNum() {
    return GetBuilder<PostListController>(
      builder: (controller) {
        print('SpecificPostPage - showLikeNumAndCommentNum() 호출');

        return Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              // PostLikeNum을 제공하는 Widget 입니다.
              showLikeNum(),

              const SizedBox(width: 10),

              // PostCommentNum을 제공하는 Widget 입니다.
              showCommentNum(),
            ],
          ),
        );
      },
    );
  }

  // PostLikeNum을 제공하는 Widget 입니다.
  Widget showLikeNum() {
    return Row(
      children: [
        const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 20,
        ),
        const SizedBox(width: 3),
        Text(
          postData!.whoLikeThePost.length.toString(),
          style: const TextStyle(
              color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // PostCommentNum을 제공하는 Widget 입니다.
  Widget showCommentNum() {
    return Row(
      children: [
        Icon(
          Icons.comment_outlined,
          color: Colors.blue[300],
          size: 20,
        ),
        const SizedBox(width: 3),
        Text(
          postData!.whoWriteCommentThePost.length.toString(),
          style: const TextStyle(
              color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 게시물에 대한 공감을 누를 수 있는 Widget 입니다.
  Widget sympathy() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          // 키보드 내리기
          FocusManager.instance.primaryFocus!.unfocus();

          // 게시글이 삭제됐는지 확인한다.
          bool isDeletePostResult = await isDeletePost();

          // 게시글이 삭제됐으면?
          if (isDeletePostResult == true) {
            // 게시글이 사라졌다는 AlertDailog를 표시한다.
            await deletePostDialog();

            // 이전 페이지로 돌아가기
            Get.back();
          }
          // 게시글이 삭제되지 않으면?
          else {
            // 공감 관련 AlertDialog을 띠운다.
            await clickSympathyDialog();
          }
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.grey),
        ),
        icon: const Icon(Icons.favorite),
        label: const Text('공감'),
      ),
    );
  }

  // 여러 comment를 보여주기 위해 ListView로 나타내는 Widget 입니다.
  Widget showCommentListView() {
    return GetBuilder<PostListController>(
      builder: (controller) {
        // Server에서 여러 comment를 호출하기 위한 설정이 되었는지 확인한다.
        // 즉 true 상태이면 Server에서 여러 comment 를 받아서 commentArray 배열에 넣고, 화면에 뿌린다.
        // false 상태이면, 기존에 존재하는 commentArray를 가지고 화면에 뿌린다. 즉 Server 호출을 하지 않는다.
        return isCallServerAboutCommentData == true
            ? FutureBuilder<Map<String, dynamic>>(
                future:
                    PostListController.to.getCommentAndUser(postData!.postUid),
                builder: (context, snapshot) {
                  // 데이터를 기다리고 있다.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: Get.width,
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
                    return const Visibility(visible: false, child: Text('테스트'));
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
                    itemBuilder: (context, index) => showEachComment(index),
                  );
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const PageScrollPhysics(),
                itemCount: commentArray.length,
                itemBuilder: (context, index) => showEachComment(index),
              );
      },
    );
  }

  // comment을 보여주는 Widget 입니다.
  Widget showEachComment(int index) {
    // 로그
    print('SpecificPostPage - showEachComment() - 댓글 데이터를 가져옵니다.');

    return Container(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar와 UserName을 제공하는 Widget 입니다.
          commentAvatarAndName(index),

          // CommentContent을 제공하는 Widget 입니다.
          commentContent(index),

          const SizedBox(height: 5),

          // CommentPostTime과 좋아요 수를 제공하는 Widget 입니다.
          commentUploadTimeAndLikeNum(index),

          const SizedBox(height: 5),

          // Comment에 대한 좋아요 버튼, 삭제 버튼을 제공하는 Widget 입니다.
          commentLikeAndDeleteButton(index),

          const SizedBox(height: 10),

          // 구분선
          const Divider(height: 1, thickness: 2, color: Colors.grey),
        ],
      ),
    );
  }

  // Avatar와 UserName을 제공하는 Widget 입니다.
  Widget commentAvatarAndName(int index) {
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
        radius: 15,
        backgroundImage: CachedNetworkImageProvider(userImage),
      ),
    );
  }

// UserName을 제공하는 Widget 입니다.
  Widget commentName(String whoWriteUserUid, String userName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: whoWriteUserUid == postData!.userUid
          ? Text(
              '${userName}(글쓴이)',
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

// Comment에 대한 좋아요 버튼, Comment에 대한 삭제 버튼을 제공하는 Widget 입니다.
  Widget commentLikeAndDeleteButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Comment에 대한 좋아요 버튼을 제공하는 Widget 입니다.
        commentLikeButton(index),

        // Comment에 대한 삭제 버튼을 제공하는 Widget 입니다.
        commentDeleteButton(index),
      ],
    );
  }

// Comment에 대한 좋아요 버튼을 제공하는 Widget 입니다.
  Widget commentLikeButton(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 30,
      height: 25,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.grey,
      ),
      child: IconButton(
        padding: const EdgeInsets.only(top: 1),
        onPressed: () async {
          // 키보드 내리기
          FocusManager.instance.primaryFocus!.unfocus();

          // 게시글이 삭제됐는지 확인한다.
          bool isDeletePostResult = await isDeletePost();

          // 게시글이 삭제됐으면?
          if (isDeletePostResult == true) {
            // 게시글이 사라졌다는 AlertDailog를 표시한다.
            await deletePostDialog();

            // 이전 페이지로 돌아가기
            Get.back();
          }
          // 게시글이 삭제되지 않으면
          else {
            // 이 comment을 공감하겠습니까? AlertDialog 표시하기
            await clickCommentLikeButtonDialog(index);
          }
        },
        icon: Icon(
          Icons.thumb_up_sharp,
          color: Colors.grey[200]!.withOpacity(1),
          size: 15,
        ),
      ),
    );
  }

  // Comment에 대한 삭제 버튼을 제공하는 Widget 입니다.
  Widget commentDeleteButton(int index) {
    // comment를 쓴 사용자 uid와 계정 사용자 uid를 비교해서
    // 일치하면 삭제 버튼을 표시한다.
    return commentArray[index].whoWriteUserUid ==
            SettingsController.to.settingUser!.userUid
        ? Container(
            margin: const EdgeInsets.only(right: 10),
            width: 30,
            height: 25,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.grey,
            ),
            child: IconButton(
              padding: const EdgeInsets.only(top: 1),
              onPressed: () async {
                // 키보드 내리기
                FocusManager.instance.primaryFocus!.unfocus();

                // 게시글이 삭제됐는지 확인한다.
                bool isDeletePostResult = await isDeletePost();

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
                  await clickCommentDeleteButtonDialog(commentArray[index]);
                }
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[200]!.withOpacity(1),
                size: 20,
              ),
            ),
          )
        : const Visibility(
            visible: false,
            child: Text('테스트 입니다.'),
          );
  }

// CommentContent을 제공하는 Widget 입니다.
  Widget commentContent(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Text(commentArray[index].content),
    );
  }

  // CommentPostTime과 좋아요 수를 제공하는 Widget 입니다.
  Widget commentUploadTimeAndLikeNum(int index) {
    // commentArray[index].uploadTime, commentArray[index].whoCommnetLike.length를 간단하게 명명한다.
    String uploadTime = commentArray[index].uploadTime;
    int whoCommentLikeNum = commentArray[index].whoCommentLike.length;

    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          // CommentPostTime을 제공하는 Widget 입니다.
          commentUploadTime(uploadTime),

          const SizedBox(width: 15),

          // Comment에 대한 좋아요 수를 제공하는 Widget 입니다.
          commentLikeNum(whoCommentLikeNum),
        ],
      ),
    );
  }

  // CommentPostTime을 제공하는 Widget 입니다.
  Widget commentUploadTime(String uploadTime) {
    return Text(
      // uploadTime은 원래 초(Second)까지 존재하나
      // 화면에서는 분(Minute)까지 표시한다.
      uploadTime.substring(0, 16),
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }

// Comment에 대한 좋아요 수를 제공하는 Widget 입니다.
  Widget commentLikeNum(int whoCommentLikeNum) {
    return whoCommentLikeNum != 0
        ? Row(
            children: [
              // 좋아요 아이콘
              const Icon(Icons.thumb_up_sharp, size: 15, color: Colors.red),

              const SizedBox(width: 5),

              // 좋아요 수
              Text(
                whoCommentLikeNum.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          )
        : const Visibility(visible: false, child: Text('테스트'));
  }

// BottomNavigationBar - comment을 입력하는 Widget 입니다.
  Widget writeAndSendComment() {
    return Consumer<ScreenHeight>(builder: (context, res, child) {
      return Padding(
        padding: EdgeInsets.only(bottom: res.keyboardHeight),
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: Get.width,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // comment 입력하기 창
                  writeComment(),

                  // comment 보내기 아이콘
                  sendComment(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

// comment 입력하기 창 Widget 입니다
  Widget writeComment() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      width: 300,
      height: 50,
      child: TextField(
        controller: PostListController.to.commentController,
        onChanged: ((value) {
          print(
              'comment 내용 : ${PostListController.to.commentController!.text}');
        }),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'comment을 입력하세요',
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
        bool isDeletePostResult = await isDeletePost();

        // 게시글이 삭제됐으면?
        if (isDeletePostResult == true) {
          // 게시글이 사라졌다는 AlertDailog를 표시한다.
          await deletePostDialog();

          // 이전 페이지로 돌아가기
          Get.back();
        }
        // 게시글이 삭제되지 않으면?
        else {
          // comment에 입력한 text가 빈칸인지 아닌지에 따라 다른 로직 구현
          if (comment.isNotEmpty) {
            // Server에 comment(댓글)을 추가한다.
            await PostListController.to.addComment(comment, postData!.postUid);

            // Server에 게시물(post)의 whoWriteCommentThePost 속성에 사용자 uid를 추가한다.
            await PostListController.to
                .addWhoWriteCommentThePost(postData!.postUid);

            // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
            await updateImageAndUserNameToUserData();

            // Server에 저장된 게시물(Post)의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여
            // PostData에 업데이트 하는 method
            await updateWhoLikeThePostAndWhoWriteCommentThePostToPostData();

            // Server에 Comment 데이터를 호출하는 것을 허락한다.
            // isCallServerAboutCommentData = true;

            // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
            // 부분적으로 재랜더링 한다.
            // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
            // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
            PostListController.to.update();

            // comment Text를 관리하는 controller의 값을 빈 값으로 다시 만든다.
            PostListController.to.commentController.text = '';
          }
          //
          else {
            // 하단 SnackBar 알림
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 500),
                content: Text('내용을 입력하세요 :)'),
                backgroundColor: Colors.black87,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.send),
    );
  }

// PostListPage에서 Routing 됐는지
// KeyWordPostListPage에서 Routing 됐는지
// WhatIWrotePage에서 Routing 됐는지
// WhatICommentPage에서 Routing 됐는지 결정하는 method
  void whereRouting() {
    switch (Get.arguments[1]) {
      case RouteDistinction.postListPage_to_specificPostPage:
        whereRoute = RouteDistinction.postListPage_to_specificPostPage;
        break;
      case RouteDistinction.keywordPostListPage_to_specificPostPage:
        whereRoute = RouteDistinction.keywordPostListPage_to_specificPostPage;
        break;
      case RouteDistinction.whatIWrotePage_to_specificPostPage:
        whereRoute = RouteDistinction.whatIWrotePage_to_specificPostPage;
        break;
      case RouteDistinction.whatICommentPage_to_specificPostPage:
        whereRoute = RouteDistinction.whatICommentPage_to_specificPostPage;
        break;
      case RouteDistinction.notificationPage_to_specifcPostPage:
        whereRoute = RouteDistinction.notificationPage_to_specifcPostPage;
        break;
    }
  }

// 이전 페이지에서 넘겨 받은 index를 통해 postData와 userData를 확인하고 copy(clone)하는 method
  void copyPostAndUserData() {
    // NotificationPage를 제외한 나머지 Page에서 Routing 했다면 그에 관한 처리
    int index = Get.arguments[0];

    // PostListPage에서 Routing 했었다면?
    // NotificationPage에서 Routing 했었다면?
    if (whereRoute == RouteDistinction.postListPage_to_specificPostPage ||
        whereRoute == RouteDistinction.notificationPage_to_specifcPostPage) {
      // postData를 복제한다.
      postData = PostListController.to.postDatas[index].copyWith();

      // userData를 복제한다.
      userData = PostListController.to.userDatas[index].copyWith();
    }
    // KeywordPostListPage에서 Routing 했었다면?
    else if (whereRoute ==
        RouteDistinction.keywordPostListPage_to_specificPostPage) {
      // postData를 복제한다.
      postData = PostListController.to.conditionTextPostDatas[index].copyWith();

      // userData를 복제한다.
      userData = PostListController.to.conditionTextUserDatas[index].copyWith();
    }
    // whatIWrotePage에서 Routing 했었다면?
    else if (whereRoute ==
        RouteDistinction.whatIWrotePage_to_specificPostPage) {
      // postData를 복제한다.
      postData = SettingsController.to.whatIWrotePostDatas[index].copyWith();

      // userData를 복제한다.
      userData = SettingsController.to.whatIWroteUserDatas[index].copyWith();
    }
    // whatICommentPage에서 Routing 했었다면?
    else if (whereRoute ==
        RouteDistinction.whatICommentPage_to_specificPostPage) {
      // postData를 복제한다.
      postData = SettingsController.to.whatICommentPostDatas[index].copyWith();

      // userData를 복제한다.
      userData = SettingsController.to.whatICommentUserDatas[index].copyWith();
    }
  }

// 게시물이 삭제되었는지 확인하는 method
  Future<bool> isDeletePost() async {
    print('SpecificPostPage - isDeletePost() 호출');

    // 게시물이 삭제됐으면 isDeletePostResult는 true
    // 게시물이 삭제되지 않았으면 isDeletePostResult는 false
    bool isDeletePostResult =
        await PostListController.to.isDeletePost(postData!.postUid);

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
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
        );
      },
    );
  }

// 게시물에 대한 삭제를 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<bool?> clickDeletePostDialog(String postUid) async {
    return showDialog<bool?>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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

                // Server에 게시물을 delete 한다. (postuid 필요)
                await PostListController.to.deletePost(postUid);

                // 로딩 바 끝
                EasyLoading.dismiss();

                // true를 가지고 이전 페이지로 돌아가기
                Get.back<bool>(result: true);
              },
            ),
          ],
        );
      },
    );
  }

// 게시물에 대한 공감을 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<Widget?> clickSympathyDialog() async {
    return showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('이 글을 공감하시겠습니까?'),
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
                // PostData의 whoLikeThePost 속성에 사용자 uid가 있는지 확인한다.
                bool result = postData!.whoLikeThePost
                    .contains(SettingsController.to.settingUser!.userUid);

                // PostData의 whoLikeThePost에 사용자 Uid가 있는 경우, 없는 경우에 따라
                // 다른 로직을 구현하는 method
                await isUserUidInWhoLikeThePostFromPostData(result);
              },
            ),
          ],
        );
      },
    );
  }

// PostData의 whoLikeThePost에 사용자 Uid가 있는 경우, 없는 경우에 따라
// 다른 로직을 구현하는 method
  Future<void> isUserUidInWhoLikeThePostFromPostData(bool isResult) async {
    // PostData의 whoLikeThePost 속성에 사용자 Uid가 있다.
    if (isResult) {
      Get.back();

      // 하단 snackBar로 "이미 공감한 글 입니다 :)" 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미 공감했습니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }

    // PostData의 whoLikeThePost 속성에 사용자 Uid가 없다.
    else {
      Get.back();

      // Server에 저장된 게시물(Post)의 whoLikeThePost 속성에 사용자 uid을 추가한다.
      await PostListController.to.addWhoLikeThePost(
        postData!.postUid,
        SettingsController.to.settingUser!.userUid,
      );

      // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
      await updateImageAndUserNameToUserData();

      // Server에 저장된 게시물(Post)의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여
      // PostData에 업데이트 하는 method
      await updateWhoLikeThePostAndWhoWriteCommentThePostToPostData();

      // Server에 Comment 데이터를 호출하는 것을 허락한다.
      // isCallServerAboutCommentData = true;

      // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
      // 부분적으로 재랜더링 한다.
      // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
      // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
      PostListController.to.update();

      // 하단 snackBar로 "공감을 했습니다." 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이 글을 공감했습니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

// comment에 대한 좋아요 아이콘을 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<bool?> clickCommentLikeButtonDialog(int index) async {
    return showDialog<bool?>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('이 comment을 공감하시겠습니까?'),
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
                // 로딩바 시작
                EasyLoading.show(
                  status: 'comment 좋아요를\n 기록합니다 :)',
                  maskType: EasyLoadingMaskType.black,
                );

                // comment의 whoCommentLike 속성에 사용자 uid가 있는지 확인한다.
                bool isResult = commentArray[index]
                    .whoCommentLike
                    .contains(SettingsController.to.settingUser!.userUid);

                // comment의 whoCommentLike 속성에 사용자 Uid가 있는지 없는지에 따라 다른 로직을 구현한다.
                await isUserUidInWhoCommentLikeFromCommentData(
                  isResult,
                  commentArray[index],
                );

                // 로딩바 끝
                EasyLoading.dismiss();

                // 이전 페이지로 돌아가기
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  // comment의 whoCommentLike 속성에 사용자 Uid가 있는지 없는지에 따라 다른 로직을 구현하는 method
  Future<void> isUserUidInWhoCommentLikeFromCommentData(bool isResult, CommentModel comment) async {
    // comment의 whoCommentLike 속성에 사용자 Uid가 있었다.
    if (isResult) {
      // 하단 snackBar로 "이미 공감한 comment 입니다 :)" 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미 공감한 comment 입니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }

    // comment의 whoCommentLike 속성에 사용자 Uid가 없었다.
    else {
      // Server에 저장된 comment(댓글)의 whoCommentLike 속성에 사용자 uid를 추가한다.
      await PostListController.to.addWhoCommentLike(comment);

      // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
      await updateImageAndUserNameToUserData();

      // Server에 저장된 게시물(Post)의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여
      // PostData에 업데이트 하는 method
      await updateWhoLikeThePostAndWhoWriteCommentThePostToPostData();

      // Server에 Comment 데이터를 호출하는 것을 허락한다.
      // isCallServerAboutCommentData = true;

      // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
      // 부분적으로 재랜더링 한다.
      // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
      // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
      PostListController.to.update();

      // 하단 snackBar로 "공감을 했습니다." 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이 comment을 공감했습니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

// comment에 대한 삭제 버튼을 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<bool?> clickCommentDeleteButtonDialog(CommentModel comment) async {
    return showDialog<bool?>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                  status: 'comment를 삭제 합니다:)',
                  maskType: EasyLoadingMaskType.black,
                );

                // Server에 comment를 삭제한다.
                await PostListController.to.deleteComment(comment);

                // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
                await updateImageAndUserNameToUserData();

                // Server에 저장된 게시물(Post)의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여
                // PostData에 업데이트 하는 method
                await updateWhoLikeThePostAndWhoWriteCommentThePostToPostData();

                // Server에 Comment 데이터를 호출하는 것을 허락한다.
                // isCallServerAboutCommentData = true;

                // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
                // 부분적으로 재랜더링 한다.
                // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
                // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
                PostListController.to.update();

                // 로딩바 끝(필요하면 추가하기로)
                EasyLoading.dismiss();

                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
  Future<void> updateImageAndUserNameToUserData() async {
    // Server에 존재하는 User에 대한 image또는 UserName이 변동이 있는지 확인한다.
    // 이 작업을 왜 하는가?
    // 위 Field에 PostModel, UserModel은 copyWith 때문에 서로 다른 인스턴스를 만들기 떄문이다.
    // 즉 같은 인스턴스를 가리키지 않기 떄문이다.
    // 혹여나 image나 userName이 변동사항이 있을 수 있기 떄문에 일일히 확인하는 작업이 필요하다.
    print('SpecificPostPage - updateImageAndUserNameToUserData() 호출');

    // Server에 게시글 작성한 사람(User)의 image 속성과 userName 속성을 확인하여 가져온다.
    Map<String, String> imageAndUserName = await PostListController.to
        .checkImageAndUserNameToUser(userData!.userUid);

    // UserData의 image, userName 속성에 값을 업데이트 한다.
    userData!.image = imageAndUserName['image']!;
    userData!.userName = imageAndUserName['userName']!;
  }

  // Server에 저장된 게시물(Post)의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여
  // PostData에 업데이트 하는 method
  Future<void> updateWhoLikeThePostAndWhoWriteCommentThePostToPostData() async {
    // Server에 존재하는 Post에 대한 공감수 또는 댓글수가 변동이 있는지 확인한다.
    // 이 작업을 왜 하는가?
    // 위 Field에 PostModel, UserModel은 copyWith 때문에 서로 다른 인스턴스를 만들기 떄문이다.
    // 즉 같은 인스턴스를 가리키지 않기 떄문이다.
    // 혹여나 공감 수나 댓글 수가 변동사항이 있을 수 있기 떄문에 일일히 확인하는 작업이 필요하다.

    print('SpecificPostPage - updateSympathyNumAndCommnetNum() 호출');

    // Server에 저장된 게시물(Post)의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여 가져온다.
    Map<String, List<String>> sympathyNumOrCommentNum = await PostListController
        .to
        .checkWhoLikeThePostAndWhoWriteCommentThePost(postData!.postUid);

    // PostData의 whoLikeThePost, whoWriteCommentThePost 속성에 값을 업데이트 한다.
    postData!.whoLikeThePost.clear();
    postData!.whoLikeThePost.addAll(sympathyNumOrCommentNum['sympathyData']!);

    postData!.whoWriteCommentThePost.clear();
    postData!.whoWriteCommentThePost
        .addAll(sympathyNumOrCommentNum['commentData']!);
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
    isDeletePost().then(
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
          // Server에서 게시글 작성한 사람(User)에 대한 image, userName에 대한 데이터를 받아와서 userData에 업데이트 한다.
          await updateImageAndUserNameToUserData();

          // Server에서 Post에 대한 whoLikeThePost(게시물 공감한 사람), whoWriteCommentThePost(게시물에 댓글 작성한 사람)
          // 에 대한 데이터를 받아와서 PostData에 업데이트 한다.
          await updateWhoLikeThePostAndWhoWriteCommentThePostToPostData();

          // Server에 Comment 데이터를 호출하는 것을 허락한다.
          isCallServerAboutCommentData = true;

          // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
          // 부분적으로 재랜더링 한다.
          // 1. 업데이트 된 공감 수와 댓글 수를 화면에 보여주기 위해 재랜더링 한다.
          // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
          PostListController.to.update();
        }
      },
    );
  }

// specificPostPage가 사라질 떄 호출되는 method
  @override
  void dispose() {
    // 로그
    print('SpecificPostPage - dispose() 호출');

    // 배열, 변수 clear
    postData = null;
    userData = null;

    whereRoute = null;
    commentArray.clear();
    commentUserArray.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SpecificPostPage - build() 호출');

    return SafeArea(
      child: KeyboardSizeProvider(
        smallSize: 500.0,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // comment을 입력하고 전송할 수 있는 하단 BottomNavigationBar 이다.
          bottomNavigationBar: writeAndSendComment(),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이전 가기, 알림, 새로 고침, 삭제 버튼을 제공하는 Widget이다.
                topView(),

                const SizedBox(height: 20),

                // Avatar와 UserName, PostTime을 표시하는 Widget이다.
                showAvatarAndUserNameAndPostTime(),

                // PostTitle, PostContent, PostPhoto(있으면 보여주고 없으면 보여주지 않기), PostLikeNum, PostCommentNum를 보여주는 Widget 입니다.
                showTitleAndContnetAndPhotoAndLikeNumAndCommentNum(),

                const SizedBox(height: 5),

                // 공감을 클릭할 수 있는 버튼
                sympathy(),

                const SizedBox(height: 30),

                // comment를 보여주는 ListView (단, comment가 없으면 invisible)
                showCommentListView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
