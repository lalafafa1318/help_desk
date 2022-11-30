import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:number_paginator/number_paginator.dart';

// 검색창에서 키워드를 입력해 게시판 목록을 보여주는 Page 입니다
class KeywordPostListPage extends StatefulWidget {
  const KeywordPostListPage({super.key});

  @override
  State<KeywordPostListPage> createState() => _KeywordPostListPageState();
}

class _KeywordPostListPageState extends State<KeywordPostListPage> {
  // Pager에 대한 Field Setting
  // PostListPage의 Pager의 현재 번호
  int pagerCurrentPage = 0;

  // PostListPage의 Pager 끝 번호
  int pagerLastPage = 0;

  // Pager를 보여줄지 결정하는 변수
  bool isShowPager = false;

  // 장애/문의, 시스템 분류 코드 그리고 처리상태 분류 코드 Dropdown을 담는다. (제 1책)
  Widget dropdownClassification() {
    return Container(
      margin: EdgeInsets.only(top: 5.h),
      width: ScreenUtil().screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10.w),
          obsOrInqDropdown(),
          SizedBox(width: 10.w),
          sysDropdown(),
          SizedBox(width: 10.w),
          proDropdown(),
        ],
      ),
    );
  }

  // 장애/문의를 나타내는 Dropdown 입니다. (제 1책)
  Widget obsOrInqDropdown() {
    // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown
    return GetBuilder<PostListController>(
      id: 'obsOrInqDropdown',
      builder: (controller) {
        print('장애/문의 처리현황 DropDown 호출');
        return DropdownButton(
          value: PostListController.to.oSelectedValue.name,
          style: TextStyle(color: Colors.black, fontSize: 13.sp),
          items: ObsOrInqClassification.values.map((element) {
            // enum의 값을 화면에 표시할 값으로 변환한다.
            String realText = element.asText;

            return DropdownMenuItem(
              value: element.name,
              child: Text(realText),
            );
          }).toList(),
          onChanged: (element) {
            // PostListController의 oSelectedValue의 값을 바꾼다.
            PostListController.to.oSelectedValue = ObsOrInqClassification.values
                .firstWhere((enumValue) => enumValue.name == element);

            // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown만 재랜더링 한다.
            PostListController.to.update(['obsOrInqDropdown']);
          },
        );
      },
    );
  }

  // 시스템 분류 코드를 나타내는 Dropdown 입니다. (제 1책)
  Widget sysDropdown() {
    // 시스템 분류 코드를 나타내는 DropDown
    return GetBuilder<PostListController>(
      id: 'sysClassificationDropdown',
      builder: (controller) {
        print('시스템 분류코드 DropDown 호출');
        return DropdownButton(
          value: PostListController.to.sSelectedValue.name,
          style: TextStyle(color: Colors.black, fontSize: 13.sp),
          items: SysClassification.values.map((element) {
            // enum의 값을 화면에 표시할 값으로 변환한다.
            String realText = element.asText;

            return DropdownMenuItem(
              value: element.name,
              child: Text(realText),
            );
          }).toList(),
          onChanged: (element) {
            // PostListController의 sSelectedValue의 값을 바꾼다.
            PostListController.to.sSelectedValue = SysClassification.values
                .firstWhere((enumValue) => enumValue.name == element);

            // 시스템 분류 코드를 결정하는 Dropdown만 재랜더링 한다.
            PostListController.to.update(['sysClassificationDropdown']);
          },
        );
      },
    );
  }

  // 처리상태 분류 코드를 나타내는 Dropdown 입니다. (제 1책)
  Widget proDropdown() {
    // 처리상태 단계를 나타내는 Dropdown
    return GetBuilder<PostListController>(
      id: 'proClassficationDropdown',
      builder: (controller) {
        print('처리상태 단계 DropDown 호출');
        return DropdownButton(
          value: PostListController.to.pSelectedValue.name,
          style: TextStyle(color: Colors.black, fontSize: 13.sp),
          items: ProClassification.values.map((element) {
            // enum의 값을 화면에 표시될 값으로 변환한다.
            String realText = element.asText;
            return DropdownMenuItem(
              value: element.name,
              child: Text(realText),
            );
          }).toList(),
          onChanged: (element) {
            // PostListController의 pSelectedValue의 값을 바꾼다.
            PostListController.to.pSelectedValue = ProClassification.values
                .firstWhere((enumValue) => enumValue.name == element);

            // 처리 상태 분류 코드를 결정하는 Dropdown만 재랜더링 한다.
            PostListController.to.update(['proClassficationDropdown']);
          },
        );
      },
    );
  }

  // 이전 페이지 아이콘과 검색창를 나타내는 Widget 입니다.
  Widget topView() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이전 페이지 아이콘 입니다.
          backIcon(),

          SizedBox(width: 5.w),

          // 검색창 입니다.
          searchText(),
        ],
      ),
    );
  }

  // 이전 페이지 아이콘 Widget 입니다.
  Widget backIcon() {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: IconButton(
        onPressed: () {
          // 사용자가 검색한 키워드를 빈칸으로 원상복구 한다.
          PostListController.to.searchTextController.text = '';

          // 키보드 내리기
          FocusManager.instance.primaryFocus?.unfocus();

          // 이전 페이지로 가기
          Get.back();
        },
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  // 검색창 입니다.
  Widget searchText() {
    return SizedBox(
      width: 250.w,
      height: 40.h,
      child: TextField(
        controller: PostListController.to.searchTextController,
        style: TextStyle(
          fontSize: 15.0.sp,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0).r,
          prefixIcon: IconButton(
            onPressed: () {
              //  키보드 내리기
              FocusManager.instance.primaryFocus?.unfocus();

              // KeywordPostListPage에서 입력한 text를 검증한다.
              bool isResult =
                  PostListController.to.validTextFromKeywordPostListPage();

              // KeywordPostListPage에서 입력한 text가 검증에 성공한다면??
              if (isResult) {
                setState(() {
                  // PostListPage의 Pager의 현재 번호
                  pagerCurrentPage = 0;

                  // PostListPage의 Pager 끝 번호
                  pagerLastPage = 0;

                  // Pager를 보여줄지 결정하는 변수
                  isShowPager = false;
                });
              }
            },
            icon: Icon(Icons.search, size: 20.sp),
          ),
          hintText: "키워드 입력",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 32.0.w),
            borderRadius: BorderRadius.circular(20.0.r),
          ),
        ),
      ),
    );
  }

  // 장애/문의에서 무엇을 선택했는가
  // 시스템 분류코드에서 무엇을 선택했는가
  // 처리상태 분류코드에서 무엇을 선택했는가
  // 검색창에서 어떤 Text를 입력했는가
  // 총 4가지 조건을 분류하여 부합하는 게시글을 가져오는 method
  Widget getConditionPostData() {
    // PostListController의 oSelectedValue 값이 '장애 처리현황'인 경우...
    if (PostListController.to.oSelectedValue ==
        ObsOrInqClassification.obstacleHandlingStatus) {
      print('장애 처리현황 가져오기');

      return FutureBuilder<List<PostModel>>(
        future: PostListController.to.getConditionObsPostData(),
        builder: (context, snapshot) {
          // 데이터를 기다리고 있다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return waitAllPostData();
          }

          // 조건에 맞는 게시물이 1개도 없을 경우
          if (PostListController.to.conditionObsPostData.isEmpty) {
            return noConditionPostData();
          }

          // 조건에 맞는 게시물이 있는 경우
          return prepareShowConditionObsPostData();
        },
      );
    }
    // PostListController의 oSelectedValue 값이 '문의 처리현황'인 경우...
    else {
      print('문의 처리현황 가져오기');

      return FutureBuilder<List<PostModel>>(
        future: PostListController.to.getConditionInqPostData(),
        builder: (context, snapshot) {
          // 데이터를 기다리고 있다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return waitAllPostData();
          }

          // 조건에 맞는 게시물이 1개도 없을 경우
          if (PostListController.to.conditionInqPostData.isEmpty) {
            return noConditionPostData();
          }

          // 조건에 맞는 게시물이 있는 경우
          return prepareShowConditionInqPostData();
        },
      );
    }
  }

  // 데이터를 기다리고 있다.
  Widget waitAllPostData() {
    return Container(
      margin: EdgeInsets.only(top: 250.h),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 조건에 맞는 게시물이 1개도 없는 경우 화면에 표시하는 Widget
  Widget noConditionPostData() {
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

  // 조건에 맞는 장애 처리현황 게시물을 가지고 ListView로 화면에 표시하기 위해 준비하는 Widget
  Widget prepareShowConditionObsPostData() {
    // 장애 처리현황 게시물이 5개 이상이면? -> Pager를 보여준다.
    if (PostListController.to.conditionObsPostData.length >= 5) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          isShowPager = true;
          PostListController.to.update(['keywordPostListPageShowPager']);
        },
      );
      // 한 페이지당 5개 게시물을 가져온다.
      return GetBuilder<PostListController>(
        id: 'updateConditionObsPostData',
        builder: (controller) {
          print('KeywordPostListPage - updateConditionObsPostData 호출');

          // 처음 페이지를 보여줄 떄
          if (pagerCurrentPage == 0) {
            return Column(
              children: PostListController.to.conditionObsPostData
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                  .map((index) => showConditionObsPostData(index))
                  .toList(),
            );
          }

          // 중간 중간 페이지를 보여줄 떄
          else if (pagerCurrentPage + 1 != pagerLastPage) {
            return Column(
              children: PostListController.to.conditionObsPostData
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                  .map((index) => showConditionObsPostData(index))
                  .toList(),
            );
          }

          // 마지막 페이지를 보여줄 떄
          else {
            return Column(
              children: PostListController.to.conditionObsPostData
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5,
                      PostListController.to.conditionObsPostData.length)
                  .map((index) => showConditionObsPostData(index))
                  .toList(),
            );
          }
        },
      );
    }
    // 장애 처리현황 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
    else {
      return Column(
        children: PostListController.to.conditionObsPostData
            .asMap()
            .keys
            .toList()
            .map((index) => showConditionObsPostData(index))
            .toList(),
      );
    }
  }

  // 조건에 맞는 문의 처리현황 게시물을 가지고 ListView로 화면에 표시하기 위해 준비하는 Widget
  Widget prepareShowConditionInqPostData() {
    // 문의 처리현황 게시물이 5개 이상이면? -> Pager를 보여준다.
    if (PostListController.to.conditionInqPostData.length >= 5) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          isShowPager = true;
          PostListController.to.update(['keywordPostListPageShowPager']);
        },
      );
      // 한 페이지당 5개 게시물을 가져온다.
      return GetBuilder<PostListController>(
        id: 'updateConditionInqPostData',
        builder: (controller) {
          print('KeywordPostListPage - updateConditionInqPostData 호출');

          // 처음 페이지를 보여줄 떄
          if (pagerCurrentPage == 0) {
            return Column(
              children: PostListController.to.conditionInqPostData
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                  .map((index) => showConditionInqPostData(index))
                  .toList(),
            );
          }

          // 중간 중간 페이지를 보여줄 떄
          else if (pagerCurrentPage + 1 != pagerLastPage) {
            return Column(
              children: PostListController.to.conditionInqPostData
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                  .map((index) => showConditionInqPostData(index))
                  .toList(),
            );
          }

          // 마지막 페이지를 보여줄 떄
          else {
            return Column(
              children: PostListController.to.conditionInqPostData
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5,
                      PostListController.to.conditionInqPostData.length)
                  .map((index) => showConditionInqPostData(index))
                  .toList(),
            );
          }
        },
      );
    }
    // 장애 처리현황 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
    else {
      return Column(
        children: PostListController.to.conditionInqPostData
            .asMap()
            .keys
            .toList()
            .map((index) => showConditionInqPostData(index))
            .toList(),
      );
    }
  }

  // 각각의 장애 처리현황 게시물을 표현하는 Widget
  Widget showConditionObsPostData(int index) {
    // PostListController.to.conditonObsPostData[index]
    // PostListController.to.conditionObsUserData[index]로 일일히 적기 어렵다.
    // 따라서 이를 간단하게 명명하는 변수를 설정한다.
    PostModel postModel = PostListController.to.conditionObsPostData[index];
    UserModel userModel = PostListController.to.conditionObsUserData[index];

    return GestureDetector(
      onTap: () {
        // SpecificPostPage로 Routing
        // argument 0번쨰 : condtionObsPostData와 conditionObsUserData들을 담고 있는 배열의 index
        // argument 1번쨰 : KeywordPostListPage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.keywordPostListPageObsPostToSpecificPostPage,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30.h),
              child: Text('${index + 1}'),
            ),
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
                    backgroundImage:
                        CachedNetworkImageProvider(userModel.image),
                  ),

                  // 사용자 이름
                  titleText: userModel.userName,

                  // 게시물 제목
                  subTitleText: postModel.postTitle,

                  // 게시물 올린 날짜
                  description: Container(
                    margin: EdgeInsets.only(top: 5.h),
                    child: Text(
                      postModel.postTime.substring(0, 16),
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                ),
                content: Column(
                  children: [
                    // 글 내용
                    Padding(
                      padding: EdgeInsets.all(16.0.r),
                      child: Text(
                        postModel.postContent,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // 게시물 이미지 개수, 좋아요 수, 댓글 수를 보여준다.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 게시물 이미지 개수
                        postModel.imageList.isNotEmpty
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
                                    postModel.imageList.length.toString(),
                                  ),
                                ],
                              )
                            : const Visibility(
                                visible: false,
                                child: Text('이미지가 없어서 표시하지 않습니다.'),
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
                            Text(postModel.whoWriteCommentThePost.length
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
                              postModel.sysClassficationCode.asText,
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
                              postModel.proStatus.asText,
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

  // 각각의 문의 처리현황 게시물을 표현하는 Widget
  Widget showConditionInqPostData(int index) {
    // PostListController.to.conditonInqPostData[index]
    // PostListController.to.conditionInqUserData[index]로 일일히 적기 어렵다.
    // 따라서 이를 간단하게 명명하는 변수를 설정한다.
    PostModel postModel = PostListController.to.conditionInqPostData[index];
    UserModel userModel = PostListController.to.conditionInqUserData[index];

    return GestureDetector(
      onTap: () {
        // SpecificPostPage로 Routing
        // argument 0번쨰 : condtionInqPostData와 conditionInqUserData들을 담고 있는 배열의 index
        // argument 1번쨰 : KeywordPostListPage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.keywordPostListPageInqPostToSpecificPostPage,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30.h),
              child: Text('${index + 1}'),
            ),
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
                    backgroundImage:
                        CachedNetworkImageProvider(userModel.image),
                  ),

                  // 사용자 이름
                  titleText: userModel.userName,

                  // 게시물 제목
                  subTitleText: postModel.postTitle,

                  // 게시물 올린 날짜
                  description: Container(
                    margin: EdgeInsets.only(top: 5.h),
                    child: Text(
                      postModel.postTime.substring(0, 16),
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                ),
                content: Column(
                  children: [
                    // 글 내용
                    Padding(
                      padding: EdgeInsets.all(16.0.r),
                      child: Text(
                        postModel.postContent,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // 게시물 이미지 개수, 좋아요 수, 댓글 수를 보여준다.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 게시물 이미지 개수
                        postModel.imageList.isNotEmpty
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
                                    postModel.imageList.length.toString(),
                                  ),
                                ],
                              )
                            : const Visibility(
                                visible: false,
                                child: Text('이미지 개수가 없어서 표시하지 않습니다.'),
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
                            Text(postModel.whoWriteCommentThePost.length
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
                              postModel.sysClassficationCode.asText,
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
                              postModel.proStatus.asText,
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

  // Pager를 보여준다.
  Widget pager(int postDataLength) {
    return Container(
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

          PostListController.to.update(['keywordPostListPageShowPager']);

          await Future.delayed(const Duration(milliseconds: 5));

          PostListController.to.oSelectedValue ==
                  ObsOrInqClassification.obstacleHandlingStatus
              ? PostListController.to.update(['updateConditionObsPostData'])
              : PostListController.to.update(['updateConditionInqPostData']);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    print('KeywordPostListPage - initState() 호출');
  }

  @override
  void dispose() {
    print('KeywordPostListPage - dispose() 호출');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          physics: const PageScrollPhysics(),
          slivers: [
            // 장애/문의 Dropdown, 시스템 Dropdown, 처리상태 Dropdown
            // 키워드를 검색하는 입력창을 보여주는 SliverAppBar
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              floating: true,
              snap: false,
              pinned: false,
              expandedHeight: 100.h,
              // 장애/문의 Dropdown, 시스템 Dropdown, 처리상태 Dropdown를 보여준다.
              // flexibleSpace: dropdownClassification(),
              actions: [dropdownClassification()],

              // 키워드를 검색하는 입력창을 보여준다.
              bottom: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.0,
                actions: [topView()],
              ),
            ),

            // 장애/문의에서 무엇을 선택했는가
            // 시스템 분류코드에서 무엇을 선택했는가
            // 처리상태 분류코드에서 무엇을 선택했는가
            // 검색창에서 어떤 Text를 입력했는가
            // 총 4가지 조건을 분류하여 부합하는 게시글을 가져오는 Widget
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  getConditionPostData(),
                ],
              ),
            ),

            // Pager 입니다.
            // 장애 처리현황, 문의 처리현황과 같은 종류별 게시물이 5개 미만이면 Pager를 보여주지 않습니다.
            SliverToBoxAdapter(
              child: GetBuilder<PostListController>(
                id: 'keywordPostListPageShowPager',
                builder: (controller) {
                  print('KeywordPostListPage - showPager 호출');

                  int postDataLength = 0;

                  // 장애 처리현황, 문의 처리현황 마다 다르게 Pager의 numberPages를 결정한다.
                  PostListController.to.oSelectedValue ==
                          ObsOrInqClassification.obstacleHandlingStatus
                      ? postDataLength =
                          PostListController.to.conditionObsPostData.length
                      : postDataLength =
                          PostListController.to.conditionInqPostData.length;

                  return isShowPager == true
                      // Pager를 보여준다.
                      ? pager(postDataLength)
                      // Pager를 보여주지 않는다.
                      : const Visibility(
                          visible: false,
                          child: Text('Pager가 보이지 않습니다.'),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
