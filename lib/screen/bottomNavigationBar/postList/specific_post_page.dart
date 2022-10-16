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
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/distinguishRouting.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_photo_view_page.dart';
import 'package:help_desk/utils/toast_util.dart';

// 게시한 글과 댓글을 보여주는 Page 입니다.
class SpecificPostPage extends StatefulWidget {
  const SpecificPostPage({super.key});

  @override
  State<SpecificPostPage> createState() => _SpecificPostPageState();
}

class _SpecificPostPageState extends State<SpecificPostPage> {
  // PostListPage에서 라우팅 되었는지
  // KeywordPostListPage에서 라우팅 되었는지 여부를 확인하는 변수
  DistinguishRouting? whereRoute;

  // PostListPage에서 Routing 되었다고 가정하고, PostData에 접근할 수 있도록 하는 변수
  PostModel? routeFromPostListPage_accessPostData;
  // PostListPage에서 Routing되었을 떄 UserData에 접근할 수 있도록 하는 변수
  UserModel? routeFromPostListPage_accessUserData;

  // KeywordPostListPage에서 Routing 되었다고 가정하고, PostData에 접근할 수 있도록 하는 변수
  PostModel? routeFromKeywordPostListPage_accessPostData;
  // keywordPostListPage에서 Routing 되었다고 가정하고, UserData에 접근할 수 있도록 하는 변수
  UserModel? routeFromKeywordPostListPage_accessUserData;

  // 댓글 데이터
  List<CommentModel>? commentArray;

  // PostListPage에서 Routing 됐는지
  // KeyWordPostListPage에서 Routing 됐는지 결정한다.
  DistinguishRouting decideRouting() {
    return Get.arguments[1] ==
            DistinguishRouting.postListPage_to_specificPostPage
        ? whereRoute = DistinguishRouting.postListPage_to_specificPostPage
        : whereRoute =
            DistinguishRouting.keywordPostListPage_to_specificPostPage;
  }

  // 화면을 재랜더링할 떄 변수를 다시 할당한다.
  void allocateVariable() {
    // PostListPage에서 Routing 됐을 떄
    if (whereRoute == DistinguishRouting.postListPage_to_specificPostPage) {
      int index = Get.arguments[0];

      // PostData를 복제한다.
      routeFromPostListPage_accessPostData =
          PostListController.to.postDatas[index].copyWith();
      // UserData를 복제한다.
      routeFromPostListPage_accessUserData =
          PostListController.to.userDatas[index].copyWith();
    }
    // KeywordPostListPage에서 Routing 됐을 떄
    else {
      int index = Get.arguments[0];

      // conditionKeywordPostData를 복제한다.
      routeFromKeywordPostListPage_accessPostData =
          PostListController.to.conditionTextPostDatas[index].copyWith();
      // conditionKeywordUserData를 복제한다.
      routeFromKeywordPostListPage_accessUserData =
          PostListController.to.conditionTextUserDatas[index].copyWith();
    }

    commentArray = PostListController.to.commentArray;
  }

  // 이전 가기, 알림 표시, 새로 고침 아이콘을 표시하는 Widget 입니다.
  // if 사용자가 업로드한 게시물의 경우 삭제 아이콘도 추가한다 :)
  Widget topView() {
    return SizedBox(
      width: Get.width,
      height: 50,
      child: Row(
        children: [
          // 이전 가기 버튼 입니다.
          backIcon(),

          // 북마크 버튼, 알림 버튼, 새로 고침 버튼 입니다.
          bookMarkIcon_noticiationIcon_refreshIcon_optionalDeleteIcon(),
        ],
      ),
    );
  }

  // 이전 가기 버튼 입니다.
  Widget backIcon() {
    return Container(
      margin: const EdgeInsets.only(left: 5, top: 20),
      child: IconButton(
        onPressed: () async {
          // 사용자가 댓글에 text를 입력했으면, commentController를 빈칸으로 만든다.
          if (PostListController.to.commentController!.text.isNotEmpty) {
            PostListController.to.commentController!.text = '';
          }

          // 키보드 내리기 (설사 키보드가 안나왔다 해도 내린다.)
          FocusManager.instance.primaryFocus?.unfocus();

          // 키보드를 내리고 이전 페이지로 가는 과정에서 여유를 주고자 작성했다. -> 그러면 내부 에러 코드가 나오지 않게 된다.
          await Future.delayed(const Duration(microseconds: 450000));

          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 북마크 버튼과 알림 버튼과 새로 고침 버튼을 표시하는 Widget 입니다.
  // if 사용자가 업로드한 게시물의 경우 삭제 아이콘도 추가한다 :)
  Widget bookMarkIcon_noticiationIcon_refreshIcon_optionalDeleteIcon() {
    return Container(
      width: Get.width / 1.2,
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 북마크 버튼 입니다.
          bookMarkIcon(),

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

  // 북마크 버튼 입니다.
  Widget bookMarkIcon() {
    return IconButton(
      onPressed: () {
        // 알림 여부를 변경하는 코드를 작성한다.

        // 토스트로 알림 표시를 제공한다.
      },

      // 알림 신청을 했으면 알림 아이콘을 표시하고, 그렇지 않으면 알림 거부 아이콘을 표시한다.
      icon: const Icon(Icons.bookmark_border_outlined, color: Colors.grey),
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
      onPressed: () {
        // 게시물을 새로고침 하는 코드 작성
        setState(() {
          ToastUtil.showToastMessage('게시물이 새로고침 되었습니다 :)');
        });
      },
      icon: const Icon(Icons.refresh_outlined),
    );
  }

  // 삭제 버튼 입니다. (자신이 업로드한 게시물이 아니면 삭제 버튼이 보이지 않습니다.)
  Widget deleteIcon() {
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? SettingsController.to.settingUser!.userUid ==
                routeFromPostListPage_accessPostData!.userUid
            ? IconButton(
                onPressed: () async {
                  // AlertDialog를 통해 삭제할 것인지 묻는다.
                  bool? isDelete = await clickDeleteIconDialog(
                    routeFromPostListPage_accessPostData!.postUid,
                  );

                  if (isDelete == true) {
                    // PostListPage로 돌아가기
                    Get.back();
                  }
                },
                icon: const Icon(Icons.delete_outline_outlined),
              )
            : const Visibility(
                child: Text('Visibility 테스트'),
                visible: false,
              )
        : SettingsController.to.settingUser!.userUid ==
                routeFromKeywordPostListPage_accessPostData!.userUid
            ? IconButton(
                onPressed: () async {
                  // AlertDialog를 통해 삭제할 것인지 묻는다.
                  bool? isDelete = await clickDeleteIconDialog(
                    routeFromKeywordPostListPage_accessPostData!.postUid,
                  );

                  if (isDelete == true) {
                    // KeywordPostPage로 돌아가기
                    Get.back();

                    // KeywordPostListPage를 재랜더링 한다.
                    PostListController.to.update();
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
  Widget showAvatar_showUserName_showPostTime() {
    return SizedBox(
      width: Get.width,
      child: Row(
        children: [
          // 아바타를 보여준다.
          showAvatar(),

          // User 이름과 게시물 올린 시간을 표시한다.
          showUserName_showPostTime(),
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
        // PostListPage에서 Routing 되었는지
        // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
        backgroundImage:
            whereRoute == DistinguishRouting.postListPage_to_specificPostPage
                ? CachedNetworkImageProvider(
                    routeFromPostListPage_accessUserData!.image,
                  )
                : CachedNetworkImageProvider(
                    routeFromKeywordPostListPage_accessUserData!.image,
                  ),
      ),
    );
  }

  // User 이름과 게시물 올린 시간을 표시한다.
  Widget showUserName_showPostTime() {
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
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return SizedBox(
      width: 300,
      child: whereRoute == DistinguishRouting.postListPage_to_specificPostPage
          ? Text(
              routeFromPostListPage_accessUserData!.userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          : Text(
              routeFromKeywordPostListPage_accessUserData!.userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
    );
  }

  // 게시물 올린 시간을 보여주는 Widget 입니다.
  Widget showPostTime() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? Text(
            routeFromPostListPage_accessPostData!.postTime,
            style: const TextStyle(fontSize: 13),
          )
        : Text(
            routeFromKeywordPostListPage_accessPostData!.postTime,
            style: const TextStyle(fontSize: 13),
          );
  }

  // 글 제목과 내용, 사진(있으면 보여주고 없으면 보여주지 않기), 좋아요, 댓글 수를 보여주는 Widget 입니다.
  Widget
      showTextTitle_showTextContent_showPhotos_showTextLike_showTextComment() {
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
          checkPhotos(),

          const SizedBox(height: 10),

          // 좋아요와 댓글 수 입니다.
          showLikeNumber_showCommentNumber(),
        ],
      ),
    );
  }

  // 글 제목 입니다.
  Widget showTextTitle() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? Text(
            routeFromPostListPage_accessPostData!.postTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        : Text(
            routeFromKeywordPostListPage_accessPostData!.postTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
  }

  // 글 내용 입니다.
  Widget showTextContent() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? Text(
            routeFromPostListPage_accessPostData!.postContent,
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
          )
        : Text(
            routeFromKeywordPostListPage_accessPostData!.postContent,
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
          );
  }

  // 게시물에 사진이 있는지 여부를 확인하는 Widget 입니다.
  Widget checkPhotos() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? routeFromPostListPage_accessPostData!.imageList.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      routeFromPostListPage_accessPostData!.imageList.length,
                  itemBuilder: (context, imageIndex) {
                    return showPhotos(imageIndex);
                  },
                ))
            : const Visibility(
                child: Text('Visibility 테스트'),
                visible: false,
              )
        : routeFromKeywordPostListPage_accessPostData!.imageList.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: routeFromKeywordPostListPage_accessPostData!
                      .imageList.length,
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
        child:
            // 사진을 Tap하면?
            GestureDetector(
          onTap: () {
            int index = Get.arguments[0];

            // PhotoView 페이지로 Routing한다.
            // argument 0번쨰 : PostListPage 또는 KeywordPostListPage에서 Routing 되었는지 알려준다.
            // argument 1번째 : PostData, UserData 혹은  condtionKeywordPostData, conditionKeywordUserData들을 담고 있는 배열의 index
            // argument 2번쨰 : image의 index
            Get.to(
              () => const SpecificPhotoViewPage(),
              arguments: [whereRoute, index, imageIndex],
            );
          },
          // 사진을 그린다.
          child: CachedNetworkImage(
            imageUrl: whereRoute ==
                    DistinguishRouting.postListPage_to_specificPostPage
                ? routeFromPostListPage_accessPostData!.imageList[imageIndex]
                : routeFromKeywordPostListPage_accessPostData!
                    .imageList[imageIndex],
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

  // 좋아요 수와 댓글 수를 보여주는 Widget 입니다.
  Widget showLikeNumber_showCommentNumber() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          // 좋아요 수를 보여준다.
          showLikeNumber(),

          const SizedBox(width: 10),

          // 댓글 수를 보여준다.
          showCommentNumber(),
        ],
      ),
    );
  }

  // 좋아요 수를 보여주는 Widget 입니다.
  Widget showLikeNumber() {
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
            whereRoute == DistinguishRouting.postListPage_to_specificPostPage
                ? routeFromPostListPage_accessPostData!.whoLikeThePost.length
                    .toString()
                : routeFromKeywordPostListPage_accessPostData!
                    .whoLikeThePost.length
                    .toString(),
            style: const TextStyle(
                color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 댓글 수를 보여주는 Widget 입니다.
  Widget showCommentNumber() {
    return Row(
      children: [
        // 댓글 아이콘 입니다.
        Icon(
          Icons.comment_outlined,
          color: Colors.blue[300],
          size: 20,
        ),

        const SizedBox(width: 3),

        // 댓글 수 입니다.
        Text(
          whereRoute == DistinguishRouting.postListPage_to_specificPostPage
              ? routeFromPostListPage_accessPostData!
                  .whoWriteCommentThePost.length
                  .toString()
              : routeFromKeywordPostListPage_accessPostData!
                  .whoWriteCommentThePost.length
                  .toString(),
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
          FocusManager.instance.primaryFocus?.unfocus();

          // 키보드를 내리고 AlertDialog가 보여지기까지 과정에서 여유를 주고자 작성했다. -> 그러면 내부 에러 코드가 나오지 않게 된다.
          await Future.delayed(const Duration(microseconds: 300000));

          // AlertDialog를 통해 공감할 것인지 묻는다.
          await clickSympathyDialog();
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.grey),
        ),
        icon: const Icon(Icons.favorite),
        label: const Text('공감'),
      ),
    );
  }

  // 댓글과 대댓글을 보여주기 위해 ListView로 나타내는 Widget 입니다.
  Widget showCommentListView() {
    return FutureBuilder<List<CommentModel>>(
      future: PostListController.to.getCommentData(
        whereRoute == DistinguishRouting.postListPage_to_specificPostPage
            ? routeFromPostListPage_accessPostData!.postUid
            : routeFromKeywordPostListPage_accessPostData!.postUid,
      ),
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
                children:
                    snapshot.data!.map((e) => showCommentElement(e)).toList(),
              )
            : const Visibility(visible: false, child: Text('테스트'));
      },
    );
  }

  // 댓글과 대댓글을 보여주는 Widget 입니다.
  Widget showCommentElement(CommentModel comment) {
    return Container(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타와 사용자 이름 보여주기  좋아요 클릭 아이콘 보여주기, 대댓글 보내기, 삭제하기
          commentTopView(comment),

          // 글 내용
          commentContent(comment),

          const SizedBox(height: 5),

          // 시간대와 좋아요 수
          commentUploadTime_likeCommentNum(comment),

          const SizedBox(height: 10),

          // 구분선
          const Divider(height: 1, thickness: 2, color: Colors.grey),
        ],
      ),
    );
  }

  // 아바타와 사용자 이름 보여주기  좋아요 아이콘 보여주기, 대댓글 보내기, 삭제하기
  Widget commentTopView(CommentModel comment) {
    return Row(
      children: [
        // 댓글 창에 있는 아바타와 사용자 이름 보여주기
        showCommentAvatar_showCommentName(comment),

        // 댓글 창에 있는 좋아요 아이콘 보여주기, 대댓글 보내기, 삭제하기
        showSettingBox(),
      ],
    );
  }

  // 댓글 창에 있는 아바타와 사용자 이름 보여주기
  Widget showCommentAvatar_showCommentName(CommentModel comment) {
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
            // 댓글 창에 있는 아바타
            showCommentAvatar(snapshot.data!),

            // 댓글 창에 있는 사용자 이름
            showCommentName(snapshot.data!),
          ],
        );
      },
    );
  }

  // 댓글 창에 있는 아바타
  Widget showCommentAvatar(UserModel commentUser) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GFAvatar(
        radius: 15,
        backgroundImage: CachedNetworkImageProvider(commentUser.image),
      ),
    );
  }

  // 댓글 창에 있는 사용자 이름
  Widget showCommentName(UserModel commentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Text(
        commentUser.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // 댓글 창에 있는 좋아요 아이콘 보여주기, 대댓글 보내기, 삭제하기
  Widget showSettingBox() {
    return SizedBox(
      width: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 댓글 창에 있는 대댓글 보내기 아이콘
          sendCommentReply(),

          const SizedBox(width: 5),

          // 댓글 창에 있는 좋아요 아이콘
          likeComment(),

          const SizedBox(width: 5),

          // 댓글 창에 있는 삭제하기 아이콘
          deleteComment(),
        ],
      ),
    );
  }

  // 댓글 창에 있는 대댓글 보내기 아이콘
  Widget sendCommentReply() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 30,
        height: 25,
        color: Colors.grey,
        child: IconButton(
          padding: const EdgeInsets.only(top: 1),
          onPressed: () {},
          icon: Icon(
            Icons.message_outlined,
            color: Colors.grey[200]!.withOpacity(1),
            size: 15,
          ),
        ),
      ),
    );
  }

  // 댓글 창에 있는 좋아요 아이콘
  Widget likeComment() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 30,
        height: 25,
        color: Colors.grey,
        child: IconButton(
          padding: const EdgeInsets.only(top: 1),
          onPressed: () {},
          icon: Icon(
            Icons.thumb_up_sharp,
            color: Colors.grey[200]!.withOpacity(1),
            size: 15,
          ),
        ),
      ),
    );
  }

  // 댓글 창에 있는 삭제하기 아이콘
  Widget deleteComment() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 30,
        height: 25,
        color: Colors.grey,
        child: IconButton(
          padding: const EdgeInsets.only(top: 1),
          onPressed: () {},
          icon: Icon(
            Icons.delete_outline,
            color: Colors.grey[200]!.withOpacity(1),
            size: 20,
          ),
        ),
      ),
    );
  }

  // 댓글 내용
  Widget commentContent(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Text(comment.content),
    );
  }

  // 댓글 업로드 시간과 댓글에 대한 좋아요 수를 나타낸다.
  Widget commentUploadTime_likeCommentNum(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          // 댓글 업로드 시간
          commentUploadTime(comment),

          const SizedBox(width: 15),

          // 댓글에 대한 좋아요 수
          likeCommentNum(comment),
        ],
      ),
    );
  }

  // 댓글 업로드 시간
  Widget commentUploadTime(CommentModel comment) {
    return Text(
      comment.uploadTime,
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }

  // 댓글에 대한 좋아요 수
  Widget likeCommentNum(CommentModel comment) {
    int commentLikeNum = comment.whoCommentLike.length;

    return commentLikeNum != 0
        ? Row(
            children: [
              // 좋아요 아이콘
              const Icon(Icons.thumb_up_sharp, size: 15, color: Colors.red),

              // 좋아요 수
              Text(commentLikeNum.toString(),
                  style: const TextStyle(color: Colors.red)),
            ],
          )
        : const Visibility(visible: false, child: Text('테스트'));
  }

  // BottomNavigationBar - 댓글을 입력하는 Widget 입니다.
  Widget writeComment_sendComment() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // padding: EdgeInsets.only(bottom: ScreenUtil().statusBarHeight),
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
                // 댓글 입력하기 창
                writeComment(),

                // 댓글 보내기 아이콘
                sendComment(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 댓글 입력하기 창 Widget 입니다
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
          hintText: '댓글을 입력하세요',
        ),
      ),
    );
  }

  // 댓글 보내기 아이콘 입니다.
  Widget sendComment() {
    return IconButton(
      onPressed: () async {
        // 댓글에 입력한 텍스트 확인하기
        String comment = PostListController.to.commentController!.text;

        // 댓글에 입력한 텍스트가 빈칸이 아니면 서버에 저장하기
        if (comment.isNotEmpty) {
          String postUid =
              (whereRoute == DistinguishRouting.postListPage_to_specificPostPage
                  ? routeFromPostListPage_accessPostData!.postUid
                  : routeFromKeywordPostListPage_accessPostData!.postUid);

          // 복제된 PostModel에 whoWriteCommentThePost에 댓글 쓴 사람 uid 추가하기
          whereRoute == DistinguishRouting.postListPage_to_specificPostPage
              ? routeFromPostListPage_accessPostData!.whoWriteCommentThePost
                  .add(SettingsController.to.settingUser!.userUid)
              : routeFromKeywordPostListPage_accessPostData!
                  .whoWriteCommentThePost
                  .add(SettingsController.to.settingUser!.userUid);

          // 서버에 Comment 추가하기
          await PostListController.to.addComment(comment, postUid);

          // Specific Post Page 화면 재랜더링
          setState(() {});
        }
        // 댓글에 입력한 텍스트가 빈칸이면 하단 SnackBar로 알림
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
      },
      icon: const Icon(Icons.send),
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
                // 서버를 통해 게시물에 대해서 사용자가 좋아요를 누른 적이 있는지 확인한다.
                bool isResult = await checkLikeUsersFromThePost();

                // 좋아요 리스트에 사용자 Uid가 있는 경우, 없는 경우에 따라 다른 로직을 구현하는 method
                await isUserUidInWhoLikeThePost(isResult);
              },
            ),
          ],
        );
      },
    );
  }

  // 서버를 통해 게시물에 대해서 사용자가 좋아요를 누른 적이 있는지 확인하는 method
  Future<bool> checkLikeUsersFromThePost() async {
    if (whereRoute == DistinguishRouting.postListPage_to_specificPostPage) {
      return await PostListController.to.checkLikeUsersFromThePost(
        routeFromPostListPage_accessPostData!.postUid,
        SettingsController.to.settingUser!.userUid,
      );
    }
    //
    else {
      return await PostListController.to.checkLikeUsersFromThePost(
        routeFromKeywordPostListPage_accessPostData!.postUid,
        SettingsController.to.settingUser!.userUid,
      );
    }
  }

  // 좋아요 리스트에 사용자 Uid가 있는 경우, 없는 경우에 따라 다른 로직을 구현하는 method
  Future<void> isUserUidInWhoLikeThePost(bool isResult) async {
    // 좋아요 리스트에 사용자 Uid가 있는 경우
    if (isResult) {
      // 이전 페이지 돌아가기
      Get.back();

      // 리스트에 있으면 하단 snackBar로 "이미 공감한 글 입니다 :)" 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미 공감했습니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }

    // 좋아요 리스트에 사용자 Uid가 없는 경우
    else {
      // 이전 페이지 돌아가기
      Get.back();

      // 복제된 PostData에 whoLikeThePost에 사용자를 추가한다.
      whereRoute == DistinguishRouting.postListPage_to_specificPostPage
          ? routeFromPostListPage_accessPostData!.whoLikeThePost
              .add(SettingsController.to.settingUser!.userUid)
          : routeFromKeywordPostListPage_accessPostData!.whoLikeThePost
              .add(SettingsController.to.settingUser!.userUid);

      // 리스트에 없으면, 서버 Post 속성 whoLikeThePost에 사용자를 추가한다. (이전과는 다른 방식을 요구할 것이다)
      if (whereRoute == DistinguishRouting.postListPage_to_specificPostPage) {
        await PostListController.to.addUserWhoLikeThePost(
          routeFromPostListPage_accessPostData!.postUid,
          SettingsController.to.settingUser!.userUid,
        );
      }
      //
      else {
        await PostListController.to.addUserWhoLikeThePost(
          routeFromKeywordPostListPage_accessPostData!.postUid,
          SettingsController.to.settingUser!.userUid,
        );
      }

      // 화면을 재랜더링 한다.
      setState(() {});

      // 하단 snackBar로 "공감을 했습니다." 표시한다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이 글을 공감했습니다 :)'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  // specific Post Pager가 처음 불릴 떄 호출되는 method
  @override
  void initState() {
    super.initState();

    print('SpecificPostPage - initState() 호출');

    // PostListPage에서 Routing 됐는지
    // KeywordPostListPage에서 Routing 됐는지 결정한다.
    decideRouting();

    // PostListPage에서 Routing 됐는가, KeywordPostListPage에서 Routing 됐는가에 따라
    // 변수를 달리 대입한다.
    allocateVariable();
  }

  // specific Post Page가 사라질 떄 호출되는 method
  @override
  void dispose() {
    // 변수 초기화
    print('SpecificPostPage - dispose() 호출');

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('SpecificPostPage - didChangeDependencies() 호출');
  }

  // 댓글 목록을 ListView로 나타내는 Widget 입니다.
  @override
  Widget build(BuildContext context) {
    print('SpecificPostPage - build() 호출');

    // 화면을 그린다.
    return SafeArea(
        child: Scaffold(
      // 댓글을 입력하고 전송할 수 있는 하단 BottomNavigationBar 이다.
      bottomNavigationBar: writeComment_sendComment(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이전 가기, 알림 표시, 새로 고침을 표시하는 Widget 입니다.
            topView(),

            const SizedBox(height: 20),

            // 아바타와 User 이름, 게시물 올린 시간을 표시하는 Widget 입니다.
            showAvatar_showUserName_showPostTime(),

            // 글 제목과 내용, 사진(있으면 보여주고 없으면 보여주지 않기), 좋아요, 댓글 수를 보여주는 Widget 입니다.
            showTextTitle_showTextContent_showPhotos_showTextLike_showTextComment(),

            const SizedBox(height: 5),

            // 공감을 클릭할 수 있는 버튼
            sympathy(),

            const SizedBox(height: 30),

            // 댓글과 대댓글 (댓글이 없으면 invisible)
            showCommentListView(),
          ],
        ),
      ),
    ));
  }
}
