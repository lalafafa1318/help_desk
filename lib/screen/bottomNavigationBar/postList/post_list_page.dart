import 'dart:io';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/routeDistinction/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
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
          searchTextWidget(),

          const SizedBox(width: 5),

          // 글쓰기 페이지로 이동하는 Widget 입니다.
          writeIconWidget(),
        ],
      ),
    );
  }

  // 검색창 입니다.
  Widget searchTextWidget() {
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
        controller: PostListController.to.searchTextController,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 5),
            child: IconButton(
              onPressed: () {
                // PostListPage에서 입력한 text를 검증한다.
                PostListController.to.validTextFromPostListPage();
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

  // StreamBuilder를 통해 전체 게시글 목록을 가져온다.
  Widget getAllPostDataLive() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: PostListController.to.getAllPostData(),
      builder: (context, snapshot) {
        // 데이터가 아직 오지 않았을 때
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('PostListPage - getAllPostDataLive() - 게시물 데이터를 기다리고 있습니다.');
          return waitAllPostData();
        }

        // 데이터가 왔는데 사이즈가 0이면..
        if (snapshot.data!.size == 0) {
          print('PostListPage - getAllPostDataLive() - 게시물 데이터가 없습니다.');
          return noPostData();
        }
        // 사이즈가 1 이상이면...
        else {
          print('PostListPage - getAllPostDataLive() - 게시물 데이터가 있습니다.');
          return prepareShowAllPostData(snapshot.data!.docs);
        }
      },
    );
  }

  // PostData들을 기다리는 Widget
  Widget waitAllPostData() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  // PostData들이 없을 떄 게시물 데이터가 없음을 보여주는 Widget
  Widget noPostData() {
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

  // 서버에서 받은 PostData들을 PostData를 담고 있는 배열에 추가하고
  // PostData에 따른 UserData도 UserData를 담고 있는 배열에 추가하는 역할을 하는 Widget
  Widget prepareShowAllPostData(List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) {
    return Expanded(
      child: FutureBuilder<List<PostModel>>(
        future: PostListController.to.allocatePostDatasInArray(allData),
        builder: (context, snapshot) {
          // 데이터를 기다리고 있으면 CircularProgressIndicator를 표시한다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            print(
                'PostListPage - prepareShowAllPostData() - 게시물 데이터를 기다리고 있습니다.');
            return const Center(child: CircularProgressIndicator());
          }

          // 데이터가 왔으면

          // 데이터가 왔으면 게시물이 업데이트 됐다는 것을 Toast Message로 알린다.
          ToastUtil.showToastMessage('게시물이 업데이트 되었습니다 :)');

          // 데이터가 왔으면 ListView.builder를 통해 게시물을 표시한다.
          return ListView.builder(
            itemCount: PostListController.to.postDatas.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // PostListPage 검색창에 써놓을 수 있는 text를 빈칸으로 설정한다.
                  PostListController.to.searchTextController!.text = '';

                  // SpecificPostPage로 Routing
                  // argument 0번쨰 : PostData와 UserData들을 담고 있는 배열의 index
                  // argument 1번쨰 : PostListPage에서 Routing 되었다는 것을 알려준다.
                  Get.to(
                    () => const SpecificPostPage(),
                    arguments: [
                      index,
                      RouteDistinction.postListPage_to_specificPostPage,
                    ],
                  );
                },
                child: showPostData(index),
              );
            },
          );
        },
      ),
    );
  }

  // PostData를 보여주는 Widget
  Widget showPostData(int index) {
    print('PostListPage - $index번쨰 showPostData()');

    // PostListController.to.postDatas[index]
    // PostListController.to.userDatas[index]로 일일히 적기 어렵다.
    // 따라서 이를 대응하는 변수를 설정한다.
    PostModel postData = PostListController.to.postDatas[index];
    UserModel userData = PostListController.to.userDatas[index];

    // 게시글을 표현하는 Card이다.
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
          backgroundImage: CachedNetworkImageProvider(userData.image),
        ),

        // User 이름
        titleText: userData.userName,

        // 게시물 제목
        subTitleText: postData.postTitle,

        // 게시물 올린 날짜
        description: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
            postData.postTime,
            style: const TextStyle(fontSize: 10),
          ),
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
              postData.postContent,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 10),

          // 게시물에 이미지가 있으면 이를 알려주고, 없으면 빈칸으로 보여준다.
          postData.imageList.isNotEmpty
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
                      postData.imageList.length.toString(),
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
              Text(postData.whoLikeThePost.length.toString()),
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
              const SizedBox(width: 5),
              Text(postData.whoWriteCommentThePost.length.toString()),
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

        // StreamBuilder를 통해 실시간으로 PostData들을  가져오는 Widget
        getAllPostDataLive(),
      ],
    );
  }
}
