import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/routeDistinction/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';

// 검색창에서 키워드를 입력해 게시판 목록을 보여주는 Page 입니다
class KeywordPostListPage extends StatefulWidget {
  const KeywordPostListPage({super.key});

  @override
  State<KeywordPostListPage> createState() => _KeywordPostListPageState();
}

class _KeywordPostListPageState extends State<KeywordPostListPage> {
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
          searchTextWidget(),
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
          PostListController.to.searchTextController!.text = '';

          // 키보드 내리기
          FocusManager.instance.primaryFocus?.unfocus();

          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  // 검색창 입니다.
  Widget searchTextWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      width: 250.w,
      height: 50.h,
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
                  // KeywordPostListPage에서 입력한 text를 검증한다.
                  bool isResult =
                      PostListController.to.validTextFromKeywordPostListPage();

                  // 검증에 성공한 경우에 화면을 재랜더링 한다.
                  if (isResult) {
                    setState(() {});
                  }
                },
                icon: Icon(Icons.search, color: Colors.grey[800])),
          ),
          hintText: '글 제목, 내용 그리고 작성자',
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // KeywordPostListPaged에서 검색창에 입력한 text를 가지고, 그것에 맞는 PostData와 UserData를 배열에 추가하는 Widget
  Widget checkConditionTextPostData() {
    return FutureBuilder<List<PostModel>>(
      future: PostListController.to.getConditionTextPostData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
              'KeywordPostListPage - checkConditionKeywordPostData() - 게시물 데이터를 기다리고 있습니다.');
          return waitData();
        }

        // keyword에 맞는 게시글이 없었다면?
        if (PostListController.to.conditionTextPostDatas.isEmpty) {
          print(
              'KeywordPostListPage - checkConditionKeywordPostData() - 게시물 데이터가 없습니다.');
          return noConditionKeywordPostData();
        }

        // keyword에 맞는 게시글이 있었다면?
        print(
            'KeywordPostListPage - checkConditionKeywordPostData() - 게시물 데이터가 있습니다.');
        return showConditionPostData();
      },
    );
  }

  // 사용자가 입력한 Keyword가 조건에 맞는 게시글이 있는지 없는지 기다리는 Widget
  Widget waitData() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 사용자가 입력한 Keyword가 조건에 맞는 게시글이 없을 떄 보여주는 Widget
  Widget noConditionKeywordPostData() {
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

  // 필러링된 PostData와 UserData를 담은 배열을 가지고 ListView로 표현하는 Widget
  Widget showConditionPostData() {
    print('KeywordPostListPage - showConditionPostData() 호출');

    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: PostListController.to.conditionTextPostDatas.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // SpecificPostPage로 Routing
              // argument 0번쨰 : condtionKeywordPostData와 conditionKeywordUserData들을 담고 있는 배열의 index
              // argument 1번쨰 : KeywordPostListPage에서 Routing 되었다는 것을 알려준다.
              Get.to(
                () => const SpecificPostPage(),
                arguments: [
                  index,
                  RouteDistinction.keywordPostListPage_to_specificPostPage,
                ],
              );
            },
            child: showEachConditionPostData(index),
          );
        },
      ),
    );
  }

  // 각각의 게시물을 표현하는 widget
  Widget showEachConditionPostData(int index) {
    print(
        'KeywordPostListPage - ${index} 번쨰 showEachConditionPostData() - 게시물 표현');

    // PostListController.to.conditonKeywordPostDatas[index]
    // PostListController.to.conditionTextUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 이를 대응하는 변수를 설정한다.
    PostModel conditionKeywordPostData =
        PostListController.to.conditionTextPostDatas[index];
    UserModel conditionKeywordUserData =
        PostListController.to.conditionTextUserDatas[index];

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
          backgroundImage:
              CachedNetworkImageProvider(conditionKeywordUserData.image),
        ),

        // 사용자 이름
        titleText: conditionKeywordUserData.userName,

        // 게시물 제목
        subTitleText: conditionKeywordPostData.postTitle,

        // 게시물 올린 날짜
        description: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
            conditionKeywordPostData.postTime,
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
              conditionKeywordPostData.postContent,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 10),

          // 게시물에 이미지가 있으면 이를 알려주고, 없으면 빈칸으로 보여준다.
          conditionKeywordPostData.imageList.isNotEmpty
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
                      conditionKeywordPostData.imageList.length.toString(),
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
              Text(
                conditionKeywordPostData.whoLikeThePost.length.toString(),
              ),
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
              Text(
                conditionKeywordPostData.whoWriteCommentThePost.length
                    .toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('KeywordPostListPage - build() 호출');

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // 검색창, 글쓰기를 지원하는 View
            topView(),

            // 사용자가 입력한 text를 가지고 서버에 Keyword를 포함하거나 일치하는 게시글이 있는지 확인한다.
            // 이 부분을 StreamBuilder로 받아올 수 있으나,
            // 실시간으로 업데이트할 필요성이 적다고 생각해 FutureBuilder를 활용한다.
            checkConditionTextPostData(),
          ],
        ),
      ),
    );
  }
}
