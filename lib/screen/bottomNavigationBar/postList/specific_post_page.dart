import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/distinguishRouting.dart';

// 게시한 글과 댓글을 보여주는 Page 입니다.
class SpecificPostPage extends StatelessWidget {
  SpecificPostPage({super.key});

  // PostListPage에서 라우팅 되었는지
  // 아니면 KeywordPostListPage에서 라우팅 되었는지 확인하는 변수
  DistinguishRouting? whereRoute;

  // PostListPage에서 Routing 됐는지
  // KeywordPostListPage에서 Routing 됐는지 여부를 결정하는 Widget 입니다.
  DistinguishRouting decideRouting() {
    return Get.arguments[2] ==
            DistinguishRouting.postListPage_to_specificPostPage
        ? whereRoute = DistinguishRouting.postListPage_to_specificPostPage
        : whereRoute =
            DistinguishRouting.keywordPostListPage_to_specificPostPage;
  }

  // 이전 가기, 알림 표시, 새로 고침을 표시하는 Widget 입니다.
  Widget topView() {
    return SizedBox(
      width: Get.width,
      height: 50,
      child: Row(
        children: [
          // 이전 가기 버튼 입니다.
          backIcon(),

          // 알림 버튼, 새로 고침 버튼 입니다.
          noticiationIcon_refreshIcon(),
        ],
      ),
    );
  }

  // 이전 가기 버튼 입니다.
  Widget backIcon() {
    return Container(
      margin: const EdgeInsets.only(left: 5, top: 20),
      child: IconButton(
        onPressed: () {
          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 알림 버튼과 새로 고침 버튼을 표시하는 Widget 입니다.
  Widget noticiationIcon_refreshIcon() {
    return Container(
      width: Get.width / 1.2,
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 알림 버튼 입니다.
          notificationIcon(),

          // 새로 고침 버튼 입니다.
          refreshIcon(),
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
      onPressed: () {
        // 게시물을 새로고침 하는 코드 작성
      },
      icon: const Icon(Icons.refresh_outlined),
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
        backgroundImage: whereRoute ==
                DistinguishRouting.postListPage_to_specificPostPage
            ? CachedNetworkImageProvider(Get.arguments[1]['image'].toString())
            : CachedNetworkImageProvider(
                PostListController
                    .to.conditionKeywordUserDatas[Get.arguments[0]]['image']
                    .toString(),
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
              Get.arguments[1]['userName'].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          : Text(
              PostListController
                  .to.conditionKeywordUserDatas[Get.arguments[0]]['userName']
                  .toString(),
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
            PostListController.to.postDatas[Get.arguments[0]].postTime
                .toString(),
            style: const TextStyle(fontSize: 13),
          )
        : Text(
            PostListController
                .to.conditionKeywordPostDatas[Get.arguments[0]].postTime
                .toString(),
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
          showLike_showComment(),
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
            PostListController.to.postDatas[Get.arguments[0]].postTitle
                .toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        : Text(
            PostListController
                .to.conditionKeywordPostDatas[Get.arguments[0]].postTitle
                .toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
  }

  // 글 내용 입니다.
  Widget showTextContent() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? Text(
            PostListController.to.postDatas[Get.arguments[0]].postContent
                .toString(),
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
          )
        : Text(
            PostListController
                .to.conditionKeywordPostDatas[Get.arguments[0]].postContent
                .toString(),
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
          );
  }

  // 게시물에 사진이 있는지 여부를 확인하는 Widget 입니다.
  Widget checkPhotos() {
    // PostListPage에서 Routing 되었는지
    // KeywordPostListPage에서 Routing 되었는지 여부에 따라 다른 로직 적용
    return whereRoute == DistinguishRouting.postListPage_to_specificPostPage
        ? PostListController
                .to.postDatas[Get.arguments[0]].imageList!.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: PostListController
                      .to.postDatas[Get.arguments[0]].imageList!.length,
                  itemBuilder: (context, index) {
                    return showPhotos(index);
                  },
                ))
            : const Visibility(
                child: Text('Visibility 테스트'),
                visible: false,
              )
        : PostListController.to.conditionKeywordPostDatas[Get.arguments[0]]
                .imageList!.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: PostListController
                      .to
                      .conditionKeywordPostDatas[Get.arguments[0]]
                      .imageList!
                      .length,
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
        child: CachedNetworkImage(
          imageUrl:
              whereRoute == DistinguishRouting.postListPage_to_specificPostPage
                  ? PostListController
                      .to.postDatas[Get.arguments[0]].imageList![imageIndex]
                      .toString()
                  : PostListController
                      .to
                      .conditionKeywordPostDatas[Get.arguments[0]]
                      .imageList![imageIndex]
                      .toString(),
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
    );
  }

  // 좋아요 수와 댓글 수를 보여주는 Widget 입니다.
  Widget showLike_showComment() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          // 좋아요 수를 보여준다.
          showLike(),

          const SizedBox(width: 10),

          // 댓글 수를 보여준다.
          showComment(),
        ],
      ),
    );
  }

  // 좋아요 수를 보여주는 Widget 입니다.
  Widget showLike() {
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
        Text('1', style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  // 댓글 수를 보여주는 Widget 입니다.
  Widget showComment() {
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
        Text('1', style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  // 글에 대한 공감을 누를 수 있는 Widget 입니다.
  Widget clickSympathy() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: ElevatedButton.icon(
          onPressed: () {
            // 게시물에 대한 공감을 1 올리는 코드를 작성한다.
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.grey),
          ),
          icon: const Icon(Icons.favorite),
          label: const Text('공감')),
    );
  }

  // 댓글 목록을 ListView로 나타내는 Widget 입니다.

  // 댓글, 대댓글을 입력할 수 있는 Widget 입니다.

  @override
  Widget build(BuildContext context) {
    // PostListPage에서 라우팅 되었다면...
    decideRouting();

    // 화면을 그린다.
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
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
              clickSympathy(),
            ],
          ),
        ),
      ),
    );
  }
}
