import 'dart:io';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/const.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/distinguishRouting.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/keyword_post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:oktoast/oktoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 게시판 목록 class 입니다.
class PostListPage extends StatelessWidget {
  const PostListPage({Key? key}) : super(key: key);

  // 사용자가 검색, 정렬할 수 있도록 하는 Widget
  Widget topView() {
    return Container(
      color: Colors.white10,
      width: Get.width,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 검색창 입니다.
          searchKeywordWidget(),

          const SizedBox(width: 5),

          // 글쓰기 페이지로 이동하는 Widget 입니다.
          writeIconWidget(),
        ],
      ),
    );
  }

  // 검색창 입니다.
  Widget searchKeywordWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: PostListController.to.keywordController,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 5),
            child: IconButton(
              onPressed: () {
                // 사용자가 입력한 Keyword를 검증합니다.
                PostListController.to.validKeywordFromPostListPage();
              },
              icon: Icon(Icons.search, color: Colors.grey[800]),
            ),
          ),
          hintText: '글 제목, 설명 그리고 작성자',
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // 글쓰기를 지원하는 listIcon 입니다.
  Widget writeIconWidget() {
    return IconButton(
      onPressed: () {
        // 글쓰기 페이지로 이동한다.
        BottomNavigationBarController.to.checkBottomNaviState(1);
      },
      icon: const Icon(PhosphorIcons.pencil),
    );
  }

  // StreamBuilder을 통해 실시간으로 Post Data들을 확인하는 Widget
  Widget getPostDatasLive() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('postTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // 데이터가 아직 오지 않았을 때
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('게시물 데이터를 기다리고 있습니다.');
          return waitPostDatas();
        }

        // 데이터가 왔는데 사이즈가 0이면..
        if (snapshot.data!.size == 0) {
          print('게시물 데이터가 없습니다.');
          return noPostDatas();
        }
        // 사이즈가 1 이상이면...
        else {
          print('게시물 데이터가 있습니다.');

          // 변경사항을 Post Data에 넣어주는 작업
          PostListController.to.getPostData(snapshot.data!.docs);

          // 토스트 메시지로 데이터가 업데이트 됐다는 것을 알린다. 
          ToastUtil.showToastMessage('게시물 데이터가\n 업데이트 되었습니다 :)');

          // ListView를 보여준다.
          return preparePostDatas();
        }
      },
    );
  }

  // Post Datas를 기다리는 Widget
  Widget waitPostDatas() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  // Post Datas가 없을 떄 게시물 데이터가 없음을 보여주는 Widget
  Widget noPostDatas() {
    return Expanded(
      flex: 1,
      child: Center(
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
              '게시물 데이터가 없습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  // Post Datas를 ListView로 나타내기 위한 Widget
  Widget preparePostDatas() {
    return Expanded(
      child: ListView.builder(
        reverse: false,
        itemCount: PostListController.to.postDatas.length,
        itemBuilder: (BuildContext context, int postDatasIndex) {
          return getUserData(postDatasIndex);
        },
      ),
    );
  }

  // 게시물 정보에 있는 사용자 Uid를 바탕으로 사용자 정보를 가져오는 Widget
  Widget getUserData(int postDatasIndex) {
    // 사용자 Uid를 뽑는다.
    String userUid = PostListController.to.postDatas[postDatasIndex].userUid.toString();

    // 사용자 Uid를 이용하여 User 정보를 가져오고 활용한다. + Post 정보도 활용한다.
    return FutureBuilder(
      future: CommunicateFirebase.getUserInfo(userUid),
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<String, dynamic>> snapshot,
      ) {
        // User 정보가 도착하지 않았다면?
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitPostDatas();
        }
        // User 정보가 도착했다면?
        return GestureDetector(
          onTap: () {
            // 업로드된 게시물에 대한 PostDatas에 대한 index와  PostDatas에 대한 User Data가 필요하다.
            // 따라서 index와 User Data를 argument로 전달한다.
            // 마지막으로 PostListPage에서 Routing 됐다는 것을 증명하기 위해서 enum를 argument로 전달한다.
            Get.to(
              () => SpecificPostPage(),
              arguments: [
                postDatasIndex,
                snapshot.data!,
                DistinguishRouting.postListPage_to_specificPostPage,
              ],
            );
          },
          child: showPostDataElement(postDatasIndex, snapshot.data!),
        );
      },
    );
  }

  // 각각의 게시물을 표현하는 widget
  Widget showPostDataElement(int postDatasIndex, Map<String, dynamic> userInfo) {
    return GFCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      elevation: 2.0,
      boxFit: BoxFit.cover,
      titlePosition: GFPosition.start,
      showImage: false,
      title: GFListTile(
        color: Colors.black12,
        padding: const EdgeInsets.all(16),

        // User 이미지
        avatar: GFAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider(userInfo['image'].toString()),
        ),

        // User 이름
        titleText: userInfo['userName'].toString(),

        // 게시물 제목
        subTitleText:
            PostListController.to.postDatas[postDatasIndex].postTitle.toString(),

        // 게시물 올린 날짜
        description: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
              PostListController.to.postDatas[postDatasIndex].postTime.toString(),
              style: const TextStyle(fontSize: 10)),
        ),
      ),

      // 글 내용과 사진, 좋아요, 댓글 수를 보여준다.
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 글 내용
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              PostListController.to.postDatas[postDatasIndex].postContent.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 10),

          // 게시물에 이미지가 있으면 이를 알려주고, 없으면 빈칸으로 보여준다.
          PostListController.to.postDatas[postDatasIndex].imageList!.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 이미지 아이콘
                    const Icon(
                      Icons.photo,
                      color: Colors.black,
                      size: 15,
                    ),

                    // 간격
                    const SizedBox(width: 5),

                    // 이미지 아이콘 개수
                    Text(
                      PostListController.to.postDatas[postDatasIndex].imageList!.length
                          .toString(),
                    ),
                  ],
                )
              : const Visibility(
                  child: Text('Visibility 테스트'),
                  visible: false,
                ),

          const SizedBox(height: 10),

          // 좋아요 아이콘과 수
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text('10'),
            ],
          ),

          const SizedBox(height: 10),

          // 댓글 아이콘과 수
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.comment_outlined,
                color: Colors.blue[300],
                size: 15,
              ),
              SizedBox(width: 5),
              Text('123'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색창, 글쓰기를 지원하는 View
        topView(),

        // StreamBuilder를 통해 실시간으로 Post Datas을 가져오는 Widget
        getPostDatasLive(),
      ],
    );
  }
}
