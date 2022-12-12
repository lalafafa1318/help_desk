import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:number_paginator/number_paginator.dart';

class WhatIWrotePage extends StatefulWidget {
  const WhatIWrotePage({super.key});

  @override
  State<WhatIWrotePage> createState() => _WhatIWrotePageState();
}

class _WhatIWrotePageState extends State<WhatIWrotePage> {
  // PostListPage의 Pager의 현재 번호
  int pagerCurrentPage = 0;

  // PostListPage의 Pager 끝 번호
  int pagerLastPage = 0;

  // Pager를 보여줄지 결정하는 변수
  bool isShowPager = false;

  // 내가 작성한 IT 요청건 게시물을 가져온다.
  Widget getWhatIWroteITRequestPosts() {
    print('whatIWrotePage - 내가 작성한 IT 요청건 게시물 가져오기');
    return FutureBuilder(
      future: SettingsController.to.getWhatIWroteITRequestPosts(),
      builder: (context, snapshot) {
        // 내가 작성한 IT 요청건 게시물을 기다리고 있다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitWhatIWroteITRequestPosts();
        }

        // 내가 작성한 IT 요청건 게시물이 1개도 없다.
        if (SettingsController.to.whatIWroteITRequestPosts.isEmpty) {
          return noWhatIWroteITRequestPosts();
        }

        // 내가 작성한 IT 요청건 게시물이 1개 이상 있다.
        return prepareShowWhatIWroteITRequestPosts();
      },
    );
  }

  // 내가 작성한 IT 요청건 게시물을 기다리고 있으면 Loading Bar를 띄운다.
  Widget waitWhatIWroteITRequestPosts() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 내가 작성한 IT 요청건 게시물이 1개도 없을 떄
  Widget noWhatIWroteITRequestPosts() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 250.h),
        // 금지 아이콘
        const Icon(
          Icons.info_outline,
          size: 60,
          color: Colors.grey,
        ),

        SizedBox(height: 10.h),

        // 검색 결과가 없다는 Text
        Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 20.sp),
        ),
      ],
    );
  }

  // 내가 작성한 IT 요청건 게시물을 화면에 표시하기 위해 준비한다.
  Widget prepareShowWhatIWroteITRequestPosts() {
    // 내가 작성한 IT 요청건 게시물이 5개 이상이면? -> Pager를 보여준다.
    if (SettingsController.to.whatIWroteITRequestPosts.length >= 5) {
      // Pager를 보여준다.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          isShowPager = true;
          SettingsController.to.update(['whatIWrotePageShowPager']);
        },
      );

      // 사용자가 Pager를 다르게 클릭할 떄마다 다른 IT 요청건 게시물을 보여줘야 한다. 따라서 위 GetBuilder가 호출된다.
      return GetBuilder<SettingsController>(
        id: 'movePagerAndShowDifferenWhatIWroteITRequestPosts',
        builder: (controller) {
          // 처음 페이지를 보여줄 떄
          if (pagerCurrentPage == 0) {
            return Column(
              children: SettingsController.to.whatIWroteITRequestPosts
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                  .map((index) => showWhatIWroteITRequestPost(index))
                  .toList(),
            );
          }

          // 중간 중간 페이지를 보여줄 떄
          else if (pagerCurrentPage + 1 != pagerLastPage) {
            return Column(
              children: SettingsController.to.whatIWroteITRequestPosts
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                  .map((index) => showWhatIWroteITRequestPost(index))
                  .toList(),
            );
          }

          // 마지막 페이지를 보여줄 떄
          else {
            return Column(
              children: SettingsController.to.whatIWroteITRequestPosts
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5,
                      SettingsController.to.whatIWroteITRequestPosts.length)
                  .map((index) => showWhatIWroteITRequestPost(index))
                  .toList(),
            );
          }
        },
      );
    }
    // 내가 작성한 IT 요청건 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
    else {
      return Column(
        children: SettingsController.to.whatIWroteITRequestPosts
            .asMap()
            .keys
            .toList()
            .map((index) => showWhatIWroteITRequestPost(index))
            .toList(),
      );
    }
  }

  // 하나 하나의 내가 작성한 IT 요청건 게시물을 보여준다.
  Widget showWhatIWroteITRequestPost(int index) {
    /* PostListController.to.whatIWroteITRequestPosts[index]
       PostListController.to.whatIWroteITRequestUsers[index]를 간단하게 명명한다. */
    PostModel postData = SettingsController.to.whatIWroteITRequestPosts[index];
    UserModel userData = SettingsController.to.whatIWroteITRequestUsers[index];

    return GestureDetector(
      onTap: () {
        /* SpecificPostPage로 Routing
           argument 0번쨰 : whatIWroteITRequestPosts와 whatIWroteITRequestUsers를 담고 있는 배열의 index
           argument 1번쨰 : whatIWrotePage에서 Routing 되었다는 것을 알려준다. */
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.WHATIWROTEPAGE_TO_SPECIFICPOSTPAGE,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시물의 index를 표시한다.
            Container(
              margin: EdgeInsets.only(top: 30.h),
              child: Text('${index + 1}'),
            ),

            // 내가 작성한 IT 요청건 게시물의 몸통 부분이다.
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // 시스템 처리 코드, 처리 단계를 나타내는 Container 입니다.
                  Container(
                    margin: EdgeInsets.only(top: 26.h),
                    width: ScreenUtil().screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 시스템 분류 코드
                        Container(
                          width: 100.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.r)),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '시스템 : ${postData.sysClassficationCode.asText}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // 처리 상태 분류 코드
                        Container(
                          width: 100.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.r)),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '처리상태 : ${postData.proStatus.asText}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // GFCard
                  GFCard(
                    elevation: 2.0,
                    boxFit: BoxFit.cover,
                    titlePosition: GFPosition.start,
                    showImage: false,
                    title: GFListTile(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.r),

                      // 사용자 이미지
                      avatar: GFAvatar(
                        radius: 30.r,
                        /* 사용자마다 회원가입할 떄 이미지를 넣었을 수 있고, 그렇게 하지 않을 수도 있다.
                           만약 사용자 이미지가 null 값일 떄에 대한 처리를 해야 한다. */
                        backgroundImage: userData.image == null
                            ? Image.asset('assets/images/default_image.png')
                                .image
                            : CachedNetworkImageProvider(userData.image!),
                      ),

                      // User 이름
                      titleText: userData.userName,

                      // 게시물 올린 날짜
                      description: Container(
                        margin: EdgeInsets.only(top: 5.h),
                        child: Text(
                          // postTime은 원래 초(Second)까지 존재하나
                          // 화면에서는 분(Minute)까지 표시한다.
                          postData.postTime.substring(0, 16),
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                    ),

                    // 글 내용과 사진, 좋아요, 댓글 수를 보여준다.
                    // +) 시스템, 처리상태를 나타낸다.
                    content: Column(
                      children: [
                        // 글 내용
                        Padding(
                          padding: EdgeInsets.all(16.0.r),
                          child: Text(
                            postData.postContent,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // 게시물 이미지 개수, 좋아요 수, 댓글 수를 보여준다.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // 게시물 이미지 개수
                            postData.imageList.isNotEmpty
                                ? Row(
                                    children: [
                                      SizedBox(width: 20.w),

                                      // 이미지 아이콘
                                      Icon(
                                        Icons.photo,
                                        color: Colors.black,
                                        size: 15.sp,
                                      ),

                                      // 간격
                                      SizedBox(width: 5.w),

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

                            SizedBox(width: 20.w),

                            // 댓글 수
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  color: Colors.blue[300],
                                  size: 15.sp,
                                ),
                                SizedBox(width: 5.w),
                                Text(postData.whoWriteCommentThePost.length
                                    .toString()),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pager
  Widget pager() {
    return GetBuilder<SettingsController>(
      id: 'whatIWrotePageShowPager',
      builder: (controller) {
        print('WhatIWrotePage - showPager 호출');

        return isShowPager == true
            // Pager를 보여준다.
            ? Container(
                padding: EdgeInsets.all(5.0.w),
                margin: EdgeInsets.only(bottom: 10.h),
                width: ScreenUtil().screenWidth,
                height: 50.h,
                child: NumberPaginator(
                  numberPages:
                      SettingsController.to.whatIWroteITRequestPosts.length %
                                  5 ==
                              0
                          ? pagerLastPage = (SettingsController
                                      .to.whatIWroteITRequestPosts.length /
                                  5)
                              .floor()
                          : pagerLastPage = (SettingsController
                                          .to.whatIWroteITRequestPosts.length /
                                      5)
                                  .floor() +
                              1,
                  initialPage: pagerCurrentPage,
                  onPageChange: (int pagerUpdatePage) async {
                    pagerCurrentPage = pagerUpdatePage;

                    // pager를 보여준다.
                    SettingsController.to.update(['whatIWrotePageShowPager']);

                    await Future.delayed(const Duration(milliseconds: 5));

                    /* 사용자가 Pager를 다르게 클릭할 떄마다 다른 IT 요청건 게시물을 보여줘야 한다. 
                       따라서 id가 movePagerAndShowDifferenWhatIWroteITRequestPosts 인 GetBuilder를 호출한다. */
                    SettingsController.to.update(
                        ['movePagerAndShowDifferenWhatIWroteITRequestPosts']);
                  },
                ),
              )
            // Pager를 보여주지 않는다.
            : const Visibility(
                visible: false,
                child: Text('Pager가 보이지 않습니다.'),
              );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    print('whatIWrotePage - initState() 호출');
  }

  @override
  void dispose() {
    super.dispose();

    print('whatIWrotePage - dispose() 호출');
  }

  @override
  Widget build(BuildContext context) {
    print('whatIWrotePage - build() 호출');

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
            icon: Padding(
              padding: EdgeInsets.all(8.5.r),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          // 제목
          title: Text(
            '내가 작성한 IT 요청건',
            style: TextStyle(color: Colors.black, fontSize: 18.sp),
          ),
          elevation: 0.5,
        ),
        floatingActionButton: Align(
          alignment:
              Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),

          // FloatingActionButton은 내가 쓴 IT 요청건 게시물을 새로고침 하는 역할을 한다.
          child: FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: () {
              setState(() {
                // PostListPage의 Pager의 현재 번호
                pagerCurrentPage = 0;

                // PostListPage의 Pager 끝 번호
                pagerLastPage = 0;

                // Pager를 보여줄지 결정하는 변수
                isShowPager = false;
              });
            },
            child: const Icon(Icons.change_circle_outlined, size: 40),
          ),
        ),
        body: SizedBox(
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5.h),

                // 내가 작성한 IT 요청건 게시물을 가져온다.
                getWhatIWroteITRequestPosts(),

                SizedBox(height: 5.h),

                // Pager
                pager(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
