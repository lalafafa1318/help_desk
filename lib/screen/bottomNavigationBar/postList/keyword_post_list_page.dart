import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/distinguishRouting.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';

// 검색창에서 키워드를 입력해 게시판 목록을 보여주는 Page 입니다
class KeywordPostListPage extends StatelessWidget {
  const KeywordPostListPage({super.key});

  // 사용자가 검색, 정렬할 수 있도록 하는 Widget
  Widget topView() {
    return Container(
      color: Colors.white10,
      width: Get.width,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 이전 페이지 아이콘 Widget 입니다.
          backIcon(),

          // 검색창 입니다.
          searchKeywordWidget(),
        ],
      ),
    );
  }

  // 이전 페이지 아이콘 Widget 입니다.
  Widget backIcon() {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      child: IconButton(
        onPressed: () {
          // 사용자가 검색한 키워드를 빈칸으로 원상복구 한다.
          PostListController.to.keywordController!.text = '';

          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 검색창 입니다.
  Widget searchKeywordWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 5),
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
                  PostListController.to.validKeywordFromKeywordPostListPage();
                },
                icon: Icon(Icons.search, color: Colors.grey[800])),
          ),
          hintText: '글 제목, 내용 그리고 작성자',
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // 사용자가 입력한 Keyword을 포함하거나 일치하는 게시물을 보여주기 위한 선행 작업을 수행하는 Widget
  Widget checkConditionKeywordPostDatas() {
    return FutureBuilder<List<PostModel>>(
      future: PostListController.to.getConditionKeywordPostData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitDatas();
        }

        // keyword에 맞는 게시글이 없었다면?
        if (snapshot.data!.isEmpty) {
          return noConditionKeywordPostDatas();
        }

        // keyword에 맞는 게시글이 있었다면?
        return showConditionPostDatas();
      },
    );
  }

  // 사용자가 입력한 Keyword가 조건에 맞는 게시글이 있는지 없는지 기다리는 Widget
  Widget waitDatas() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  // 사용자가 입력한 Keyword가 조건에 맞는 게시글이 없을 떄 보여주는 Widget
  Widget noConditionKeywordPostDatas() {
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
              '검색 결과가 없습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ListView를 나타내는 Widget
  Widget showConditionPostDatas() {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: PostListController.to.conditionKeywordPostDatas.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // PostListController의 conditionKeyWordPostDatas와 conditionKeywordUserDatas에 대한 index만 필요하다.
              // 따라서 index를 argument로 전달한다.
              // 마지막으로 KeywordPostListPage에서 Routing 됐다는 것을 증명하기 위해서 enum를 argument로 전달한다.
              Get.to(
                () => SpecificPostPage(),
                arguments: [
                  index,
                  '',
                  DistinguishRouting.keywordPostListPage_to_specificPostPage,
                ],
              );
            },
            child: showConditionKeywordPostDataElement(index),
          );
        },
      ),
    );
  }

  // 각각의 게시물을 표현하는 widget
  Widget showConditionKeywordPostDataElement(int index) {
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
          backgroundImage: CachedNetworkImageProvider(
            PostListController.to.conditionKeywordUserDatas[index]['image']
                .toString(),
          ),
        ),

        // 사용자 이름
        titleText: PostListController
            .to.conditionKeywordUserDatas[index]['userName']
            .toString(),

        // 게시물 제목
        subTitleText: PostListController
            .to.conditionKeywordPostDatas[index].postTitle
            .toString(),

        // 게시물 올린 날짜
        description: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
              PostListController.to.conditionKeywordPostDatas[index].postTime
                  .toString(),
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
              PostListController.to.conditionKeywordPostDatas[index].postContent
                  .toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 10),

          // 게시물에 이미지가 있으면 이를 알려주고, 없으면 빈칸으로 보여준다.
          PostListController
                  .to.conditionKeywordPostDatas[index].imageList!.isNotEmpty
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
                      PostListController
                          .to.conditionKeywordPostDatas[index].imageList!.length
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
    print('argument : ${PostListController.to.keywordController!.text}');

    return GetBuilder<PostListController>(
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // 검색창, 글쓰기를 지원하는 View
                topView(),

                // 사용자가 입력한 Keyword를 가지고 서버에 Keyword를 포함하거나 일치하는 게시글이 있는지 확인한다.
                // 이 부분을 StreamBuilder로 받아올 수 있으나,
                // 실시간으로 업데이트할 필요성이 적다고 생각해 FutureBuilder를 활용한다.
                checkConditionKeywordPostDatas(),
              ],
            ),
          ),
        );
      },
    );
  }
}
