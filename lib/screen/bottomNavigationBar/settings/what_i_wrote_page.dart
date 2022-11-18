import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
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

class WhatIWrotePage extends StatelessWidget {
  const WhatIWrotePage({super.key});

  // 내가 쓴 게시물에 대한 목록을 가져오는 Widget
  Widget getWhatIWroteThePost() {
    return FutureBuilder(
      // 사용자가 업로드한 게시물, 그에 대한 사용자 정보까지 가져오는 method
      future: SettingsController.to.getWhatIWrotePostData(),
      builder: (context, snapshot) {
        // 데이터가 아직 도착하지 않았다면?
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
              'WhatIWrotePage - getWhatIWroteThePost() - 게시물 데이터를 기다리고 있습니다.');
          return waitData();
        }

        // 데이터가 도착했다.
        // 하지만 사용자가 업로드한 게시물, 그에 대한 사용자 정보가 없을 떄
        if (SettingsController.to.whatIWrotePostDatas.isEmpty) {
          print('WhatIWrotePage - getWhatIWroteThePost() - 게시물 데이터가 없습니다.');
          return noWhatIWroteThePostData();
        }

        // 데이터가 도착했다.
        // 사용자가 업로드한 게시물, 그에 대한 사용자 정보가 있을 떄
        print('WhatIWrotePage - getWhatIWroteThePost() - 게시물 데이터가 있습니다.');
        return showWhatIWroteThePostData();
      },
    );
  }

  // 사용자가 업로드한 게시물, 그에 대한 사용자 정보가 아직 도착하지 않았을 떄 보여주는 Widget
  Widget waitData() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 사용자가 입력한 Keyword가 조건에 맞는 게시글이 없을 떄 보여주는 Widget
  Widget noWhatIWroteThePostData() {
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

  // 필터링된 사용자가 업로드한 게시물, 그에 대한 사용자 정보를 가지고 ListView로 보여주는 Widget
  Widget showWhatIWroteThePostData() {
    print('WhatIWrotePage - getWhatIWroteThePost() 호출');

    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: SettingsController.to.whatIWrotePostDatas.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // SpecificPostPage로 Routing
              // argument 0번쨰 : whoIWrotePostDatas와 whoIWroteUserDatas를 담고 있는 배열의 index
              // argument 1번쨰 : whatIWrotePage에서 Routing 되었다는 것을 알려준다.
              Get.to(
                () => const SpecificPostPage(),
                arguments: [
                  index,
                  RouteDistinction.whatIWrotePage_to_specificPostPage,
                ],
              );
            },
            child: showEachWhatIWrotePostData(index),
          );
        },
      ),
    );
  }

  // 각각의 게시물을 표현하는 widget
  Widget showEachWhatIWrotePostData(int index) {
    print('WhatIWrotePage - ${index} 번쨰 showEachWhatIWrotePostData() - 게시물 표현');

    // SettingsController.to.whatIWrotePostDatas[index]
    // SettingsController.to.whatIWroteUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 이를 대응하는 변수를 설정한다.
    PostModel whatIWrotePostData =
        SettingsController.to.whatIWrotePostDatas[index];
    UserModel whatIWroteUserData =
        SettingsController.to.whatIWroteUserDatas[index];

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
          backgroundImage: CachedNetworkImageProvider(whatIWroteUserData.image),
        ),

        // 사용자 이름
        titleText: whatIWroteUserData.userName,

        // 게시물 제목
        subTitleText: whatIWrotePostData.postTitle,

        // 게시물 올린 날짜
        description: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
            whatIWrotePostData.postTime.substring(0,16),
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
              whatIWrotePostData.postContent,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 10),

          // 게시물에 이미지가 있으면 이를 알려주고, 없으면 빈칸으로 보여준다.
          whatIWrotePostData.imageList.isNotEmpty
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
                      whatIWrotePostData.imageList.length.toString(),
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
                whatIWrotePostData.whoLikeThePost.length.toString(),
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
                whatIWrotePostData.whoWriteCommentThePost.length.toString(),
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
            '내가 쓴 글',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          elevation: 0.5,
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),

            // 내가 쓴 게시물에 대한 목록을 가져온다.
            getWhatIWroteThePost(),
          ],
        ),
      ),
    );
  }
}
