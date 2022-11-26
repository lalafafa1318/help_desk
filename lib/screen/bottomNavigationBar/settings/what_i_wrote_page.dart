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

import '../../../const/obsOrInqClassification.dart';

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

  // 장애 처리현황인지 문의 처리현황인지 Text를 보여준다.
  Widget getObsOrInqText() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 20.w),
      width: ScreenUtil().screenWidth,
      height: 50.h,
      child: Text(
        SettingsController.to.selectObsOrInq ==
                ObsOrInqClassification.obstacleHandlingStatus
            ? '장애 처리현황'
            : '문의 처리현황',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 내가 쓴 게시물에 대한 목록을 가져오는 Widget
  Widget getObsOrInqWhatIWroteThePost() {
    // SettingsController의 selectObsOrInq 변수가 'obstacleHandlingStatus'인 경우
    // 즉 장애 처리현황 버튼을 클릭했으면...
    if (SettingsController.to.selectObsOrInq ==
        ObsOrInqClassification.obstacleHandlingStatus) {
      print('장애 처리현황 가져오기');

      return FutureBuilder(
        future: SettingsController.to.getObsWhatIWrotePostData(),
        builder: (context, snapshot) {
          // 데이터가 아직 도착하지 않았다면?
          if (snapshot.connectionState == ConnectionState.waiting) {
            return waitData();
          }

          // 데이터가 도착했다.
          // 하지만 장애 처리현황과 관련해 내가 쓴 게시물이 없다면??
          if (SettingsController.to.obsWhatIWrotePostDatas.isEmpty) {
            return noWhatIWroteThePostData();
          }

          // 데이터가 도착했다.
          // 장애 처리현황과 관련해 내가 쓴 게시물이 존재한다면?
          return prepareObsWhatIWroteThePostData();
        },
      );
    }
    // SettingsController의 selectObsOrInq 변수가 'inqueryHandlingStatus'인 경우
    // 즉 문의 처리현황 버튼을 클릭했다면...
    else {
      print('문의 처리현황 가져오기');

      return FutureBuilder(
        future: SettingsController.to.getInqWhatIWrotePostData(),
        builder: (context, snapshot) {
          // 데이터가 아직 도착하지 않았다면?
          if (snapshot.connectionState == ConnectionState.waiting) {
            return waitData();
          }

          // 데이터가 도착했다.
          // 하지만 문의 처리현황과 관련해서 내가 쓴 글이 없다면?
          if (SettingsController.to.inqWhatIWrotePostDatas.isEmpty) {
            return noWhatIWroteThePostData();
          }

          // 데이터가 도착했다.
          // 문의 처리현황과 관련해서 내가 쓴 글이 있다면?
          return prepareInqWhatIWroteThePostData();
        },
      );
    }
  }

  // 데이터가 아직 오지 않았을 떄 호출되는 Widget
  Widget waitData() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 내가 쓴 게시물이 없으면 호출되는 Widget
  Widget noWhatIWroteThePostData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 200.h),
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

  // 장애 처리현황과 관련해 내가 쓴 글을 ListView로 보여주기 위해 준비하는 Widget
  Widget prepareObsWhatIWroteThePostData() {
    // 장애 처리현황과 관련해 내가 작성한 게시물이 5개 이상이면? -> Pager를 보여준다.
    if (SettingsController.to.obsWhatIWrotePostDatas.length >= 5) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          isShowPager = true;
          SettingsController.to.update(['whatIWrotePageShowPager']);
        },
      );
      // 한 페이지당 5개 게시물을 가져온다.
      return GetBuilder<SettingsController>(
        id: 'updateWhatIWroteObsPostData',
        builder: (controller) {
          print('whatIWrotePage - updateWhatIWroteObsPostData 호출');

          // 처음 페이지를 보여줄 떄
          if (pagerCurrentPage == 0) {
            return Column(
              children: SettingsController.to.obsWhatIWrotePostDatas
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                  .map((index) => showObsWhatIWrotePostData(index))
                  .toList(),
            );
          }

          // 중간 중간 페이지를 보여줄 떄
          else if (pagerCurrentPage + 1 != pagerLastPage) {
            return Column(
              children: SettingsController.to.obsWhatIWrotePostDatas
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                  .map((index) => showObsWhatIWrotePostData(index))
                  .toList(),
            );
          }

          // 마지막 페이지를 보여줄 떄
          else {
            return Column(
              children: SettingsController.to.obsWhatIWrotePostDatas
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5,
                      SettingsController.to.obsWhatIWrotePostDatas.length)
                  .map((index) => showObsWhatIWrotePostData(index))
                  .toList(),
            );
          }
        },
      );
    }
    // 장애 처리현황 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
    else {
      return Column(
        children: SettingsController.to.obsWhatIWrotePostDatas
            .asMap()
            .keys
            .toList()
            .map((index) => showObsWhatIWrotePostData(index))
            .toList(),
      );
    }
  }

  // 문의 처리현황과 관련해 내가 쓴 글을 ListView로 보여주기 위해 준비하는 Widget
  Widget prepareInqWhatIWroteThePostData() {
    // 문의 처리현황과 관련해 내가 작성한 게시물이 5개 이상이면? -> Pager를 보여준다.
    if (SettingsController.to.inqWhatIWrotePostDatas.length >= 5) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          isShowPager = true;
          SettingsController.to.update(['whatIWrotePageShowPager']);
        },
      );
      // 한 페이지당 5개 게시물을 가져온다.
      return GetBuilder<SettingsController>(
        id: 'updateWhatIWroteInqPostData',
        builder: (controller) {
          print('whatIWrotePage - updateWhatIWroteInqPostData 호출');

          // 처음 페이지를 보여줄 떄
          if (pagerCurrentPage == 0) {
            return Column(
              children: SettingsController.to.inqWhatIWrotePostDatas
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                  .map((index) => showInqWhatIWrotePostData(index))
                  .toList(),
            );
          }

          // 중간 중간 페이지를 보여줄 떄
          else if (pagerCurrentPage + 1 != pagerLastPage) {
            return Column(
              children: SettingsController.to.inqWhatIWrotePostDatas
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                  .map((index) => showInqWhatIWrotePostData(index))
                  .toList(),
            );
          }

          // 마지막 페이지를 보여줄 떄
          else {
            return Column(
              children: SettingsController.to.inqWhatIWrotePostDatas
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5,
                      SettingsController.to.inqWhatIWrotePostDatas.length)
                  .map((index) => showInqWhatIWrotePostData(index))
                  .toList(),
            );
          }
        },
      );
    }
    // 장애 처리현황 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
    else {
      return Column(
        children: SettingsController.to.inqWhatIWrotePostDatas
            .asMap()
            .keys
            .toList()
            .map((index) => showInqWhatIWrotePostData(index))
            .toList(),
      );
    }
  }

  // 장애 처리현황과 관련해 내가 쓴 글을 각각 보여주는 Widget
  Widget showObsWhatIWrotePostData(int index) {
    // SettingsController.to.obsWhatIWrotePostDatas[index]
    // SettingsController.to.obsWroteUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 간단하게 명명한다.
    PostModel postData = SettingsController.to.obsWhatIWrotePostDatas[index];
    UserModel userData = SettingsController.to.obsWhatIWroteUserDatas[index];

    return GestureDetector(
      onTap: () {
        // SpecificPostPage로 Routing
        // argument 0번쨰 : obsWhatIWrotePostDatas와 obsWhatIWroteUserDatas를 담고 있는 배열의 index
        // argument 1번쨰 : whatIWrotePage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.whatIWrotePageObsPostToSpecificPostPage,
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
            // 게시물
            Expanded(
              child: GFCard(
                elevation: 2.0,
                boxFit: BoxFit.cover,
                titlePosition: GFPosition.start,
                showImage: false,
                title: GFListTile(
                  color: Colors.black12,
                  padding: EdgeInsets.all(16.r),

                  // User 이미지
                  avatar: GFAvatar(
                    radius: 30.r,
                    backgroundImage: CachedNetworkImageProvider(userData.image),
                  ),

                  // User 이름
                  titleText: userData.userName,

                  // 게시물 제목
                  subTitleText: postData.postTitle,

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

                    // 시스템 분류 코드와 처리 상태 분류 코드 (제 1책)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              postData.sysClassficationCode.asText,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

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
                              postData.proStatus.asText,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 문의 처리현황과 관련해 내가 쓴 글을 각각 보여주는 Widget
  Widget showInqWhatIWrotePostData(int index) {
    // SettingsController.to.whatIWrotePostDatas[index]
    // SettingsController.to.whatIWroteUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 이를 대응하는 변수를 설정한다.
    PostModel postData = SettingsController.to.inqWhatIWrotePostDatas[index];
    UserModel userData = SettingsController.to.inqWhatIWroteUserDatas[index];

    return GestureDetector(
      onTap: () {
        // SpecificPostPage로 Routing
        // argument 0번쨰 : whoIWrotePostDatas와 whoIWroteUserDatas를 담고 있는 배열의 index
        // argument 1번쨰 : whatIWrotePage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.whatIWrotePageInqPostToSpecificPostPage,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(18.0.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시물의 index를 표시한다.
            Container(
              margin: EdgeInsets.only(top: 30.h),
              child: Text('${index + 1}'),
            ),

            // 게시물
            Expanded(
              child: GFCard(
                elevation: 2.0,
                boxFit: BoxFit.cover,
                titlePosition: GFPosition.start,
                showImage: false,
                title: GFListTile(
                  color: Colors.black12,
                  padding: EdgeInsets.all(16.r),

                  // User 이미지
                  avatar: GFAvatar(
                    radius: 30.r,
                    backgroundImage: CachedNetworkImageProvider(userData.image),
                  ),

                  // User 이름
                  titleText: userData.userName,

                  // 게시물 제목
                  subTitleText: postData.postTitle,

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

                    // 시스템 분류 코드와 처리 상태 분류 코드 (제 1책)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              postData.sysClassficationCode.asText,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

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
                              postData.proStatus.asText,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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

        int postDataLength = 0;

        // 장애 처리현황, 문의 처리현황 마다 다르게 Pager의 numberPages를 결정한다.
        if (SettingsController.to.selectObsOrInq ==
            ObsOrInqClassification.obstacleHandlingStatus) {
          postDataLength = SettingsController.to.obsWhatIWrotePostDatas.length;
        }
        //
        else {
          postDataLength = SettingsController.to.inqWhatIWrotePostDatas.length;
        }
        return isShowPager == true
            // Pager를 보여준다.
            ? Container(
                padding: EdgeInsets.all(5.0.w),
                margin: EdgeInsets.only(bottom: 10.h),
                width: ScreenUtil().screenWidth,
                height: 50.h,
                child: NumberPaginator(
                  numberPages: postDataLength % 5 == 0
                      ? pagerLastPage = (postDataLength / 5).floor()
                      : pagerLastPage = (postDataLength / 5).floor() + 1,
                  initialPage: pagerCurrentPage,
                  onPageChange: (int pagerUpdatePage) async {
                    pagerCurrentPage = pagerUpdatePage;

                    SettingsController.to.update(['whatIWrotePageShowPager']);

                    await Future.delayed(const Duration(milliseconds: 5));

                    SettingsController.to.selectObsOrInq ==
                            ObsOrInqClassification.obstacleHandlingStatus
                        ? SettingsController.to
                            .update(['updateWhatIWroteObsPostData'])
                        : SettingsController.to
                            .update(['updateWhatIWroteInqPostData']);
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
              // 이전 가기 버튼을 누를 떄 다시 장애 처리현황으로 되돌린다.
              SettingsController.to.selectObsOrInq =
                  ObsOrInqClassification.obstacleHandlingStatus;

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
            '내가 쓴 글',
            style: TextStyle(color: Colors.black, fontSize: 18.sp),
          ),
          elevation: 0.5,
        ),
        floatingActionButton: Align(
          alignment:
              Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),
          child: FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: () {
              // 장애 처리현황 또는 문의 처리현황 게시물을 선택해서 보여주는 method를 실행한다.
              SettingsController.to.changePost();

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h),

              // 장애 처리현황인지 문의 처리현황인지 Text를 보여준다.
              getObsOrInqText(),

              SizedBox(height: 5.h),

              // 내가 쓴 게시물에 대한 목록을 가져온다.
              getObsOrInqWhatIWroteThePost(),

              SizedBox(height: 5.h),

              // Pager
              pager(),
            ],
          ),
        ),
      ),
    );
  }
}
