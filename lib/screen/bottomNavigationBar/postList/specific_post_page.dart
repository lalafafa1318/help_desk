import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/routeDistinction/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_photo_view_page.dart';
import 'package:help_desk/utils/toast_util.dart';

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

  // PostData와 UserData를 참조하는 변수
  PostModel? postData;
  UserModel? userData;

  // CommentData에 접근할 수 있도록 하는 변수
  List<CommentModel>? commentArray;

  // 처음 SpecificPostPage로 들어올 떄
  // 서버로부터 댓글 데이터를 얻기 위해 2번 호출되는 것을 방지하고자 설정한 변수
  bool isCallServerAboutCommentData = false;

  // 이전 가기, 알림, 새로 고침, 삭제 버튼을 표시하는 Widget 입니다.
  Widget topView() {
    return SizedBox(
      width: Get.width,
      height: 50,
      child: Row(
        children: [
          // 이전 가기 버튼 입니다.
          backButton(),

          // 알림, 새로 고침, 삭제 버튼을 표현합니다.
          notifyAndRefreshAndDeleteIcon(),
        ],
      ),
    );
  }

  // 이전 가기 버튼 입니다.
  Widget backButton() {
    return Container(
      margin: const EdgeInsets.only(left: 5, top: 20),
      child: IconButton(
        onPressed: () async {
          // 사용자가 comment에 text를 입력했으면, commentController를 빈칸으로 만든다.
          if (PostListController.to.commentController!.text.isNotEmpty) {
            PostListController.to.commentController!.text = '';
          }

          // // 키보드 내리기 (설사 키보드가 안나왔다 해도 내린다.)
          // FocusManager.instance.primaryFocus?.unfocus();

          // // 키보드를 내리고 이전 페이지로 가는 과정에서 여유를 주고자 작성했다. -> 그러면 내부 에러 코드가 나오지 않게 된다.
          // await Future.delayed(const Duration(microseconds: 450000));

          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 알림, 새로 고침, 삭제 버튼 입니다.
  Widget notifyAndRefreshAndDeleteIcon() {
    return Container(
      width: Get.width / 1.2,
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 북마크 버튼 입니다.
          // bookMarkIcon(),

          // 알림 버튼 입니다.
          notificationIcon(),

          // 새로 고침 버튼 입니다.
          refreshIcon(),

          // 삭제 버튼 입니다.
          deleteIcon(),
        ],
      ),
    );
  }

  // 알림 버튼 입니다.
  Widget notificationIcon() {
    return IconButton(
      onPressed: () {
        // 알림 여부를 변경하는 코드를 작성한다.

        // 토스트로 알림 표시를 제공한다.
      },

      // 알림 신청을 했으면 알림 아이콘을 표시하고, 그렇지 않으면 알림 거부 아이콘을 표시한다.
      icon: const Icon(Icons.notifications_off_outlined, color: Colors.grey),
    );
  }

  // 새로 고침 버튼 입니다.
  Widget refreshIcon() {
    return IconButton(
      onPressed: () async {
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
          // 서버에서 공감 데이터와 댓글 데이터를 받아서 PostData에 업데이트 한다.
          await updateSympathyNumAndCommentNum();

          // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
          // 부분적으로 재랜더링 한다.
          // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
          // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
          PostListController.to.update();

          // Toast Message로 알린다.
          ToastUtil.showToastMessage('게시물이 새로고침 되었습니다 :)');
        }
      },
      icon: const Icon(Icons.refresh_outlined),
    );
  }

  // 삭제 버튼 입니다. (자신이 업로드한 게시물이 아니면 삭제 버튼이 보이지 않습니다.)
  Widget deleteIcon() {
    return postData!.userUid == SettingsController.to.settingUser!.userUid
        ? IconButton(
            onPressed: () async {
              // AlertDialog를 통해 삭제할 것인지 묻는다.
              bool? isDeletePostResult =
                  await clickDeleteIconDialog(postData!.postUid);

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

  // 아바타와 User 이름, 게시물 올린 시간을 표시하는 Widget 입니다.
  Widget showAvatarAndUserNameAndPostTime() {
    return SizedBox(
      width: Get.width,
      child: Row(
        children: [
          // 아바타를 보여준다.
          showAvatar(),

          // User 이름과 게시물 올린 시간을 표시한다.
          showUserNameAndPostTime(),
        ],
      ),
    );
  }

  // 아바타를 보여주는 Widget 입니다.
  Widget showAvatar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GFAvatar(
        radius: 30,
        backgroundImage: CachedNetworkImageProvider(userData!.image),
      ),
    );
  }

  // User 이름과 게시물 올린 시간을 표시한다.
  Widget showUserNameAndPostTime() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User 이름을 보여준다.
          showUserName(),

          const SizedBox(height: 5),

          // 게시물 올린 시간을 표시한다.
          showPostTime(),
        ],
      ),
    );
  }

  // User 이름을 보여주는 Widget 입니다.
  Widget showUserName() {
    return SizedBox(
      width: 300,
      child: Text(
        userData!.userName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 게시물 올린 시간을 보여주는 Widget 입니다.
  Widget showPostTime() {
    return Text(
      postData!.postTime,
      style: const TextStyle(fontSize: 13),
    );
  }

  // 글 제목과 내용, 사진(있으면 보여주고 없으면 보여주지 않기), 좋아요 수, comment 수를 보여주는 Widget 입니다.
  Widget showTitleAndContnetAndPhotoAndLikeNumAndCommentNum() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 글 제목 입니다.
          showTextTitle(),

          const SizedBox(height: 10),

          // 글 내용 입니다.
          showTextContent(),

          const SizedBox(height: 30),

          // 사진이 있는지 확인하는 Widget
          checkPhoto(),

          const SizedBox(height: 10),

          // 좋아요와 comment 수 입니다.
          showLikeNumAndCommentNum(),
        ],
      ),
    );
  }

  // 글 제목 입니다.
  Widget showTextTitle() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return Text(
      postData!.postTitle,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // 글 내용 입니다.
  Widget showTextContent() {
    return Text(
      postData!.postContent,
      style: const TextStyle(
          color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  // 게시물에 사진이 있는지 여부를 확인하는 Widget 입니다.
  Widget checkPhoto() {
    return postData!.imageList.isNotEmpty
        ? SizedBox(
            width: double.infinity,
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: postData!.imageList.length,
              itemBuilder: (context, imageIndex) {
                return showPhotos(imageIndex);
              },
            ))
        : const Visibility(
            child: Text('Visibility 테스트'),
            visible: false,
          );
  }

  // 사진을 보여주는 Widget 입니다. (optional)
  Widget showPhotos(int imageIndex) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // Image border
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        // 사진을 Tap하면?
        child: GestureDetector(
          onTap: () {
            // PhotoView 페이지로 Routing한다.

            // argument 0번쨰 : PostData이다.
            // argument 1번쨰 : PostData의 imageList Property가 있다. 몇번째 사진인지 알려주는 imageIndex이다.
            Get.to(
              () => const SpecificPhotoViewPage(),
              arguments: [postData, imageIndex],
            );
          },
          // 사진을 그린다.
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

  // 좋아요 수와 comment 수를 보여주는 Widget 입니다.
  Widget showLikeNumAndCommentNum() {
    return GetBuilder<PostListController>(
      builder: (controller) {
        print('SpecificPostPage - showLikeNumAndCommentNum() 호출');

        return Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              // 좋아요 수를 보여준다.
              showLikeNum(),

              const SizedBox(width: 10),

              // comment 수를 보여준다.
              showCommentNum(),
            ],
          ),
        );
      },
    );
  }

  // 좋아요 수를 보여주는 Widget 입니다.
  Widget showLikeNum() {
    return Row(
      children: [
        // 좋아요 아이콘 입니다.
        const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 20,
        ),

        const SizedBox(width: 3),

        // 좋아요 수 입니다.
        Text(
          postData!.whoLikeThePost.length.toString(),
          style: const TextStyle(
              color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // comment 수를 보여주는 Widget 입니다.
  Widget showCommentNum() {
    return Row(
      children: [
        // comment 아이콘 입니다.
        Icon(
          Icons.comment_outlined,
          color: Colors.blue[300],
          size: 20,
        ),

        const SizedBox(width: 3),

        // comment 수 입니다.
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
          // // 키보드 내리기 (설사 키보드가 안나왔다 해도 내린다.)
          // FocusManager.instance.primaryFocus?.unfocus();

          // // 키보드를 내리고 AlertDialog가 보여지기까지 과정에서 여유를 주고자 작성했다. -> 그러면 내부 에러 코드가 나오지 않게 된다.
          // await Future.delayed(const Duration(microseconds: 300000));

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

  // comment를 보여주기 위해 ListView로 나타내는 Widget 입니다.
  Widget showCommentListView() {
    return GetBuilder<PostListController>(
      builder: (controller) {
        // 서버로부터 commentData를 호출하기 위한 설정이 되었으면
        // 즉 true 상태이면 서버로부터 commentData를 받는다.
        return isCallServerAboutCommentData == true
            ? FutureBuilder<List<CommentModel>>(
                future: PostListController.to.getCommentData(postData!.postUid),
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
                  return snapshot.data!.isNotEmpty
                      ? Column(
                          children: snapshot.data!
                              .map((comment) => showEachComment(comment))
                              .toList(),
                        )
                      : const Visibility(visible: false, child: Text('테스트'));
                },
              )
            : const Visibility(visible: false, child: Text('테스트'));
      },
    );
  }

  // comment을 보여주는 Widget 입니다.
  Widget showEachComment(CommentModel comment) {
    // 로그
    print('SpecificPostPage - showEachComment() - 댓글 데이터를 가져옵니다.');

    return Container(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 아바타와 사용자 이름 보여주기  좋아요, 삭제 아이콘 표시하기
          commentTopView(comment),

          // 글 내용
          commentContent(comment),

          const SizedBox(height: 5),

          // 시간대와 좋아요 수
          commentUploadTimeAndLikeNum(comment),

          const SizedBox(height: 10),

          // 구분선
          const Divider(height: 1, thickness: 2, color: Colors.grey),
        ],
      ),
    );
  }

  // 아바타와 사용자 이름 보여주기  좋아요, 삭제 아이콘 표시하기
  Widget commentTopView(CommentModel comment) {
    return Row(
      children: [
        // comment 창에 있는 아바타와 사용자 이름 보여주기
        commentAvatarAndName(comment),

        // comment 창에 있는 좋아요 아이콘 보여주기, 삭제하기
        commentLikeAndDeleteIcon(comment),
      ],
    );
  }

  // comment  창에 있는 아바타와 사용자 이름 보여주기
  Widget commentAvatarAndName(CommentModel comment) {
    String commentUserUid = comment.whoWriteUserUid;

    // comment에 있는 사용자 Uid를 가지고 user 정보에 접근해야 한다.
    return FutureBuilder<UserModel>(
      future: PostListController.to.getUserData(commentUserUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return Row(
          children: [
            // comment 창에 있는 아바타
            commentAvatar(snapshot.data!),

            // comment 창에 있는 사용자 이름
            commentName(snapshot.data!),
          ],
        );
      },
    );
  }

  // comment  창에 있는 아바타
  Widget commentAvatar(UserModel commentUser) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GFAvatar(
        radius: 15,
        backgroundImage: CachedNetworkImageProvider(commentUser.image),
      ),
    );
  }

  // comment 창에 있는 사용자 이름
  Widget commentName(UserModel commentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Text(
        commentUser.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // comment 창에 있는 좋아요 아이콘 보여주기, 삭제하기
  Widget commentLikeAndDeleteIcon(CommentModel comment) {
    return SizedBox(
      width: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // comment 창에 있는 대comment 보내기 아이콘
          // sendCommentReply(comment),

          const SizedBox(width: 5),

          // comment 창에 있는 좋아요 아이콘
          commentLikeIcon(comment),

          const SizedBox(width: 5),

          // comment 창에 있는 삭제하기 아이콘
          commentDeleteIcon(comment),
        ],
      ),
    );
  }

  // comment 창에 있는 좋아요 아이콘
  Widget commentLikeIcon(CommentModel comment) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 30,
        height: 25,
        color: Colors.grey,
        child: IconButton(
          padding: const EdgeInsets.only(top: 1),
          onPressed: () async {
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
              await clickCommentLikeIconDialog(comment);
            }
          },
          icon: Icon(
            Icons.thumb_up_sharp,
            color: Colors.grey[200]!.withOpacity(1),
            size: 15,
          ),
        ),
      ),
    );
  }

  // comment 창에 있는 삭제하기 아이콘
  Widget commentDeleteIcon(CommentModel comment) {
    // comment를 쓴 사용자 uid와 계정 사용자 uid를 비교해서, 맞으면 삭제하기 아이콘을 표시한다.
    return comment.whoWriteUserUid == SettingsController.to.settingUser!.userUid
        ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: 30,
              height: 25,
              color: Colors.grey,
              child: IconButton(
                padding: const EdgeInsets.only(top: 1),
                onPressed: () async {
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
                    await clickCommentDeleteIconDialog(comment);
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
            child: Text('테스트 입니다.'),
          );
  }

  // comment 내용
  Widget commentContent(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Text(comment.content),
    );
  }

  // comment 업로드 시간과 좋아요 수를 나타낸다.
  Widget commentUploadTimeAndLikeNum(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          // comment 업로드 시간
          commentUploadTime(comment),

          const SizedBox(width: 15),

          // comment에 대한 좋아요 수
          commentLikeNum(comment),
        ],
      ),
    );
  }

  // comment 업로드 시간
  Widget commentUploadTime(CommentModel comment) {
    return Text(
      comment.uploadTime,
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }

  // comment에 대한 좋아요 수
  Widget commentLikeNum(CommentModel comment) {
    int commentLikeNum = comment.whoCommentLike.length;

    return commentLikeNum != 0
        ? Row(
            children: [
              // 좋아요 아이콘
              const Icon(Icons.thumb_up_sharp, size: 15, color: Colors.red),

              const SizedBox(width: 5),

              // 좋아요 수
              Text(
                commentLikeNum.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          )
        : const Visibility(visible: false, child: Text('테스트'));
  }

  // BottomNavigationBar - comment을 입력하는 Widget 입니다.
  Widget writeAndSendComment() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
  }

  // comment 입력하기 창 Widget 입니다
  Widget writeComment() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
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
        String comment = PostListController.to.commentController!.text;

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
            // 서버에 존재하는 게시물에 댓글을 추가한다.
            await PostListController.to.addComment(comment, postData!.postUid);

            // 서버에 존재하는 게시물의 whoWriteCommentThePost 속성에 사용자 uid를 추가한다.
            await PostListController.to
                .addWhoWriteCommentThePost(postData!.postUid);

            // 서버에서 공감 데이터와 댓글 데이터를 받아서 PostData에 업데이트 한다.
            await updateSympathyNumAndCommentNum();

            // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
            // 부분적으로 재랜더링 한다.
            // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
            // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
            PostListController.to.update();

            // 키보드 내리기
            FocusManager.instance.primaryFocus?.unfocus();

            // comment Text를 관리하는 controller의 값을 빈 값으로 다시 만든다.
            PostListController.to.commentController!.text = '';
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
  void decideRouting() {
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
    }
  }

  // PostData와 UserData에 접근할 수 있도록 변수를 할당한다.
  void allocateVariable() {
    int index = Get.arguments[0];

    if (whereRoute == RouteDistinction.postListPage_to_specificPostPage) {
      // postData를 복제한다.
      postData = PostListController.to.postDatas[index].copyWith();

      // userData를 복제한다.
      userData = PostListController.to.userDatas[index].copyWith();
    }
    //
    else if (whereRoute ==
        RouteDistinction.keywordPostListPage_to_specificPostPage) {
      // postData를 복제한다.
      postData = PostListController.to.conditionTextPostDatas[index].copyWith();

      // userData를 복제한다.
      userData = PostListController.to.conditionTextUserDatas[index].copyWith();
    }
    //
    else if (whereRoute ==
        RouteDistinction.whatIWrotePage_to_specificPostPage) {
      // postData를 복제한다.
      postData = SettingsController.to.whatIWrotePostDatas[index].copyWith();

      // userData를 복제한다.
      userData = SettingsController.to.whatIWroteUserDatas[index].copyWith();
    }
    //
    else {
      // postData를 복제한다.
      postData = SettingsController.to.whatICommentPostDatas[index].copyWith();

      // userData를 복제한다.
      userData = SettingsController.to.whatICommentUserDatas[index].copyWith();
    }

    commentArray = PostListController.to.commentArray;
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

  // 게시물이 삭제되었다는 것을 알리는 AlertDialog 입니다.
  Future<bool?> deletePostDialog() async {
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
  Future<bool?> clickDeleteIconDialog(String postUid) async {
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

                // 게시물을 서버에 삭제하는 코드 (게시물 uid 필요)
                await PostListController.to.deletePostData(postUid);

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
                // PostData의 whoLikeThePost에 사용자 uid가 있는지 확인한다.
                bool isUserUidWhoLikeThePostResult = checkLikeUsersFromThePost(
                  SettingsController.to.settingUser!.userUid,
                );

                // PostData의 whoLikeThePost에 사용자 Uid가 있는 경우, 없는 경우에 따라
                // 다른 로직을 구현하는 method
                await isUserUidInWhoLikeThePost(isUserUidWhoLikeThePostResult);
              },
            ),
          ],
        );
      },
    );
  }

  // PostData의 whoLikeThePost에 사용자 uid가 있는지 확인한다.
  bool checkLikeUsersFromThePost(String userUid) {
    return postData!.whoLikeThePost.contains(userUid);
  }

  // PostData의 whoLikeThePost에 사용자 Uid가 있는 경우, 없는 경우에 따라
  // 다른 로직을 구현하는 method
  Future<void> isUserUidInWhoLikeThePost(bool isUserUidWhoLikeThePostResult) async {
    // PostData의 whoLikeThePost에 사용자 Uid가 있다.
    if (isUserUidWhoLikeThePostResult) {
      Get.back();

      // 하단 snackBar로 "이미 공감한 글 입니다 :)" 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미 공감했습니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }

    // PostData의 whoLikeThePost에 사용자 Uid가 없다.
    else {
      Get.back();

      // 서버에 저장된 게시물(Post)의 whoLikeThePost Property 에 UserUid를 추가한다.
      await PostListController.to.addUserWhoLikeThePost(
        postData!.postUid,
        SettingsController.to.settingUser!.userUid,
      );

      // 서버의 공감 데이터와 댓글 데이터를 받아와서 PostData에 업데이트 하는 method
      await updateSympathyNumAndCommentNum();

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
  Future<bool?> clickCommentLikeIconDialog(CommentModel comment) async {
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

                // 서버에 저장된 댓글(comment)에 대해서 사용자가 좋아요를 누른 적이 있는지 확인한다.
                bool isWhoCommentLikeResult =
                    await checkLikeUsersFromTheComment(comment);

                // comment - whoCommentLike property에 사용자 Uid가 있는 경우,
                // 없는 경우에 따라 다른 로직을 구현하는 method
                await isUserUidInWhoCommentLike(
                    comment, isWhoCommentLikeResult);

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

  // 서버에 저장된 댓글(comment)에 대해서 사용자가 좋아요를 누른 적이 있는지 확인하는 method
  Future<bool> checkLikeUsersFromTheComment(CommentModel comment) async {
    return await PostListController.to.checkLikeUsersFromTheComment(
      comment,
      SettingsController.to.settingUser!.userUid,
    );
  }

  // 서버에 저장된 댓글(comment)에 대한 whoCommentLike 속성에 사용자가 있는지 없는지에 따라 다른 로직을 구현하는 method
  Future<void> isUserUidInWhoCommentLike(CommentModel comment, bool isWhoCommentLikeResult) async {
    // 서버에 저장된 댓글(comment)에 대한 whoCommentLike 속성에 사용자 uid가 있다.
    if (isWhoCommentLikeResult) {
      // 하단 snackBar로 "이미 공감한 comment 입니다 :)" 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미 공감한 comment 입니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }

    // 서버에 저장된 댓글(comment)에 대한 whoCommentLike 속성에 사용자가 없었다.
    else {
      // 서버에 저장된 댓글(comment)의 whoCommentLike Property 에 UserUid를 추가한다.
      await PostListController.to.addUserWhoCommentLike(comment);

      // 서버의 공감 데이터와 댓글 데이터를 받아와서 PostData에 업데이트 하는 method
      await updateSympathyNumAndCommentNum();

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

  // comment에 대한 휴지통 아이콘을 클릭했을 떄 나타나는 AlertDialog 입니다.
  Future<bool?> clickCommentDeleteIconDialog(CommentModel comment) async {
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

                // 서버에 comment를 삭제한다.
                await PostListController.to.deleteComment(comment);

                // 서버의 공감 데이터와 댓글 데이터를 받아와서 PostData에 업데이트 하는 method
                await updateSympathyNumAndCommentNum();

                // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
                // 부분적으로 재랜더링 한다.
                // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
                // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
                PostListController.to.update();

                // 로딩바 끝(필요하면 추가하기로)
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

  // 서버에서 공감 데이터와 댓글 데이터를 받아와서 PostData에 업데이트 하는 method
  Future<void> updateSympathyNumAndCommentNum() async {
    // 서버에 존재하는 Post에 대한 공감수 또는 댓글수가 변동이 있는지 확인한다.
    // 이 작업을 왜 하는가?
    // 위 Field에 PostModel, UserModel은 copyWith 때문에 서로 다른 인스턴스를 만들기 떄문이다.
    // 즉 같은 인스턴스를 가리키지 않기 떄문이다.
    // 혹여나 공감 수나 댓글 수가 변동사항이 있을 수 있기 떄문에 일일히 확인하는 작업이 필요하다.

    print('SpecificPostPage - updateSympathyNumAndCommnetNum() 호출');

    // 서버에 저장된 공감 데이터와 댓글 데이터를 가져온다.
    Map<String, List<String>> sympathyNumOrCommentNum = await PostListController
        .to
        .checkSympathyNumOrCommentNum(postData!.postUid);

    // 위 Field PostModel에 변동될 수 있는 공감 수와 댓글 수를 업데이트 한다.
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
    decideRouting();

    // PostData와 UserData에 대한 복제 객체를 만든다.
    allocateVariable();
  }

  // initState()가 호출되고 다음에 호출되는 method
  // 키보드를 위로 올리고, 아래로 내릴 떄 먼저 호출되는 method
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('SpecificPostPage - didChangeDependencies() 호출');

    // 게시글이 삭제됐는지 확인한다.
    isDeletePost().then((bool isDeletePostResult) async {
      print('SpecificPostPage - isDeletePost() 호출 후');

      // 게시글이 사라졌으면?
      if (isDeletePostResult == true) {
        // 게시글이 사라졌다는 AlertDailog를 표시한다.
        await deletePostDialog();

        // 이전 페이지로 돌아가기
        Get.back();
      }
      // 게시글이 사라지지 않으면?
      else {
        // 서버에서 공감 데이터와 댓글 데이터를 받아서 PostData에 업데이트 한다.
        await updateSympathyNumAndCommentNum();

        // 서버로부터 댓글 데이터를 호출하는 것을 허락한다.
        isCallServerAboutCommentData = true;

        // 전체 화면을 재랜더링 하지 않는다. 비효율적이다.
        // 부분적으로 재랜더링 한다.
        // 1. 업데이트 된 댓글 수와 공감 수를 화면에 보여주기 위해 재랜더링 한다.
        // 2. 댓글 데이터를 화면에 보여주기 위해 재랜더링 한다.
        PostListController.to.update();
      }
    });
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
    commentArray!.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SpecificPostPage - build() 호출');

    // 화면을 그린다.
    return SafeArea(
      child: Scaffold(
        // comment을 입력하고 전송할 수 있는 하단 BottomNavigationBar 이다.
        bottomNavigationBar: writeAndSendComment(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이전 가기, 알림, 새로 고침 삭제 버튼을 표시하는 Widget 입니다.
              topView(),

              const SizedBox(height: 20),

              // 아바타와 User 이름, 게시물 올린 시간을 표시하는 Widget 입니다.
              showAvatarAndUserNameAndPostTime(),

              // 글 제목과 내용, 사진(있으면 보여주고 없으면 보여주지 않기), 좋아요, comment 수를 보여주는 Widget 입니다.
              showTitleAndContnetAndPhotoAndLikeNumAndCommentNum(),

              const SizedBox(height: 5),

              // 공감을 클릭할 수 있는 버튼
              sympathy(),

              const SizedBox(height: 30),

              // comment과 대comment (comment이 없으면 invisible)
              showCommentListView(),
            ],
          ),
        ),
      ),
    );
  }
}
