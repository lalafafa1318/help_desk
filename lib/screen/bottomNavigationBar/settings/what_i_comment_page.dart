import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';

class WhatICommentPage extends StatelessWidget {
  const WhatICommentPage({super.key});

  // 장애 처리현황인지 문의 처리현황인지 Text를 보여준다.
  Widget getObsOrInqText() {
    return GetBuilder<SettingsController>(
      id: 'getObsOrInqText',
      builder: (controller) {
        print('whatICommentPage - getObsOrInqText() 호출');
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
      },
    );
  }

  // 내가 댓글 단 게시물에 대한 목록을 가져오는 Widget
  Widget getObsOrInqWhatICommentThePost() {
    return GetBuilder<SettingsController>(
      id: 'getObsOrInqPost',
      builder: (controller) {
        // SettingsController의 selectObsOrInq 변수가 'obstacleHandlingStatus'인 경우
        // 즉 장애 처리현황 버튼을 클릭했으면...
        if (SettingsController.to.selectObsOrInq ==
            ObsOrInqClassification.obstacleHandlingStatus) {
          return FutureBuilder(
            future: SettingsController.to.getObsWhatICommentPostData(),
            builder: (context, snapshot) {
              // 데이터가 아직 도착하지 않았다면?
              if (snapshot.connectionState == ConnectionState.waiting) {
                return waitData();
              }

              // 데이터가 도착했다.
              // 하지만 장애 처리현황과 관련해 내가 댓글 작성한 게시물이 없다면??
              if (SettingsController.to.obsWhatICommentPostDatas.isEmpty) {
                return noWhatICommentThePostData();
              }

              // 데이터가 도착했다.
              // 장애 처리현황과 관련해 내가 쓴 게시물이 존재한다면?
              return prepareObsWhatICommentThePostData();
            },
          );
        }
        // SettingsController의 selectObsOrInq 변수가 'inqueryHandlingStatus'인 경우
        // 즉 문의 처리현황 버튼을 클릭했다면...
        else {
          return FutureBuilder(
            future: SettingsController.to.getInqWhatICommentPostData(),
            builder: (context, snapshot) {
              // 데이터가 아직 도착하지 않았다면?
              if (snapshot.connectionState == ConnectionState.waiting) {
                return waitData();
              }

              // 데이터가 도착했다.
              // 하지만 문의 처리현황과 관련해서 내가 쓴 글이 없다면?
              if (SettingsController.to.inqWhatICommentPostDatas.isEmpty) {
                return noWhatICommentThePostData();
              }

              // 데이터가 도착했다.
              // 문의 처리현황과 관련해서 내가 쓴 글이 있다면?
              return prepareInqWhatICommentThePostData();
            },
          );
        }
      },
    );
  }

  // 데이터가 아직 오지 않았을 떄 호출되는 Widget
  Widget waitData() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 장애 처리현황과 관련해서 내가 댓글 작성한 글이 없으면 호출되는 Widget
  Widget noWhatICommentThePostData() {
    return Expanded(
      flex: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        ),
      ),
    );
  }

  // 장애 처리현황과 관련해 내가 댓글 작성한 글을 ListView로 보여주기 위해 준비하는 Widget
  Widget prepareObsWhatICommentThePostData() {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: SettingsController.to.obsWhatICommentPostDatas.length,
        itemBuilder: (BuildContext context, int index) {
          return showObsWhatICommentPostData(index);
        },
      ),
    );
  }

  // 문의 처리현황과 관련해 내가 댓글 작성한 글을 ListView로 보여주기 위해 준비하는 Widget
  Widget prepareInqWhatICommentThePostData() {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: SettingsController.to.inqWhatICommentPostDatas.length,
        itemBuilder: (BuildContext context, int index) {
          return showInqWhatICommentPostData(index);
        },
      ),
    );
  }

  // 장애 처리현황과 관련해 내가 댓글 작성한 글을 각각 보여주는 Widget
  Widget showObsWhatICommentPostData(int index) {
    // SettingsController.to.obsWhatICommentPostDatas[index]
    // SettingsController.to.obWhatICommentUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 간단하게 명명한다.
    PostModel postData = SettingsController.to.obsWhatICommentPostDatas[index];
    UserModel userData = SettingsController.to.obsWhatICommentUserDatas[index];

    return GestureDetector(
      onTap: () {
        // SpecificPostPage로 Routing
        // argument 0번쨰 : obsWhatICommentPostDatas와 obsWhatICommentUserDatas를 담고 있는 배열의 index
        // argument 1번쨰 : whatICommentPage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.whatICommentPageObsPostToSpecificPostPage,
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

                        // 좋아요 수
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 15.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(postData.whoLikeThePost.length.toString()),
                          ],
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

  // 문의 처리현황과 관련해 내가 댓글 작성한 글을 각각 보여주는 Widget
  Widget showInqWhatICommentPostData(int index) {
    // SettingsController.to.inqWhatICommentPostDatas[index]
    // SettingsController.to.inqWhatICommentUserDatas[index]로 일일히 적기 어렵다.
    // 따라서 간단하게 명명한다.
    PostModel postData = SettingsController.to.inqWhatICommentPostDatas[index];
    UserModel userData = SettingsController.to.inqWhatICommentUserDatas[index];

    return GestureDetector(
      onTap: () {
        // SpecificPostPage로 Routing
        // argument 0번쨰 : inqWhatICommentPostDatas와 inqWhatICommentUserDatas를 담고 있는 배열의 index
        // argument 1번쨰 : whatICommentPage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.whatICommentPageInqPostToSpecificPostPage,
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

                        // 좋아요 수
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 15.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(postData.whoLikeThePost.length.toString()),
                          ],
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
              // 이전 가기 버튼을 누를 떄 다시 장애 처리현황으로 되돌린다.
              SettingsController.to.selectObsOrInq =
                  ObsOrInqClassification.obstacleHandlingStatus;

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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey,
          onPressed: () {
            // 장애 처리현황 또는 문의 처리현황 게시물을 선택해서 보여주는 method를 실행한다.
            SettingsController.to.changePost();
          },
          child: const Icon(Icons.change_circle_outlined, size: 40),
        ),
        body: Column(
          children: [
            SizedBox(height: 10.h),

            // 장애 처리현황인지 문의 처리현황인지 Text를 보여준다.
            getObsOrInqText(),

            SizedBox(height: 5.h),

            // 내가 쓴 게시물에 대한 목록을 가져온다.
            getObsOrInqWhatICommentThePost(),
          ],
        ),
      ),
    );
  }
}
