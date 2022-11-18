import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';

class WhatICommentPage extends StatelessWidget {
  const WhatICommentPage({super.key});

  // 내가 댓글 단 게시물에 대한 목록을 가져오는 Widget
  Widget getWhatICommentThePost() {
    return FutureBuilder(
      // 사용자가 댓글 단 게시물, 그에 대한 사용자 정보까지 가져오는 method
      future: SettingsController.to.getWhatICommentPostData(),
      builder: (context, snapshot) {
        // 데이터가 아직 도착하지 않았다면?
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
              'WhatICommentPage - getWhatICommentThePost() - 게시물 데이터를 기다리고 있습니다.');
          return waitData();
        }

        // 데이터가 도착했다.
        // 하지만 사용자가 댓글 단 게시물, 그에 대한 사용자 정보가 없을 떄
        if (SettingsController.to.whatICommentPostDatas.isEmpty) {
          print('WhatICommentPage - getWhatICommentThePost() - 게시물 데이터가 없습니다.');
          return noWhatICommentThePostData();
        }

        // 데이터가 도착했다.
        // 사용자가 댓글 단 게시물, 그에 대한 사용자 정보가 있을 떄
        print('WhatICommentPage - getWhatICommentThePost() - 게시물 데이터가 있습니다.');
        return showWhatICommentThePostData();
      },
    );
  }

  // 사용자가 댓글 단 게시물, 그에 대한 사용자 정보가 아직 도착하지 않았을 떄 보여주는 Widget
  Widget waitData() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 사용자가 댓글 단 게시물, 그에 대한 사용자 정보가 없을떄 보여주는 Widget
  Widget noWhatICommentThePostData() {
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

  // 필터링된 사용자가 댓글 단 게시물, 그에 대한 사용자 정보를 가지고 ListView로 보여주는 Widget
  Widget showWhatICommentThePostData() {
    print('WhatICommentPage - getWhatICommentThePost() 호출');

    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: SettingsController.to.whatICommentPostDatas.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // SpecificPostPage로 Routing
              // argument 0번쨰 : whoICommentPostDatas와 whoICommentUserDatas를 담고 있는 배열의 index
              // argument 1번쨰 : whatICommentPage에서 Routing 되었다는 것을 알려준다.
              Get.to(
                () => const SpecificPostPage(),
                arguments: [
                  index,
                  RouteDistinction.whatICommentPage_to_specificPostPage,
                ],
              );
            },
            child: showEachWhatICommentPostData(index),
          );
        },
      ),
    );
  }

  // 각각의 게시물을 표현하는 widget
  Widget showEachWhatICommentPostData(int index) {
    print(
        'WhatICommentPage - ${index} 번쨰 showEachWhatICommentPostData() - 게시물 표현');

    // SettingsController.to.whatICommentPostDatas[index]
    // SettingsController.to.whatICommentUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 이를 대응하는 변수를 설정한다.
    PostModel whatICommentPostData =
        SettingsController.to.whatICommentPostDatas[index];
    UserModel whatICommentUserData =
        SettingsController.to.whatICommentUserDatas[index];

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
              CachedNetworkImageProvider(whatICommentUserData.image),
        ),

        // 사용자 이름
        titleText: whatICommentUserData.userName,

        // 게시물 제목
        subTitleText: whatICommentPostData.postTitle,

        // 게시물 올린 날짜
        description: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
            whatICommentPostData.postTime.substring(0, 16),
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
              whatICommentPostData.postContent,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 10),

          // 게시물에 이미지가 있으면 이를 알려주고, 없으면 빈칸으로 보여준다.
          whatICommentPostData.imageList.isNotEmpty
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
                      whatICommentPostData.imageList.length.toString(),
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
                whatICommentPostData.whoLikeThePost.length.toString(),
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
                whatICommentPostData.whoWriteCommentThePost.length.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          // 이전 가기 버튼
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Padding(
              padding: EdgeInsets.all(8.5),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),

          // 제목
          title: const Text(
            '내가 댓글 단 글',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          elevation: 0.5,
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),

            // 내가 댓글 단 게시물에 대한 목록을 가져온다.
            getWhatICommentThePost(),
          ],
        ),
      ),
    );
  }
}
