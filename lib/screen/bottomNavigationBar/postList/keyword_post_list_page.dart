import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
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

  // 시스템 분류 코드 그리고 처리상태 분류 코드를 담는 Dropdown
  Widget dropdownClassification() {
    return Container(
      margin: EdgeInsets.only(top: 5.h),
      width: ScreenUtil().screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 시스템 분류 코드를 나타내는 Dropdown
          sysDropdown(),

          // 처리상태 분류 코드를 나타내는 Dropdown
          proDropdown(),
        ],
      ),
    );
  }

  // 시스템 분류 코드를 나타내는 Dropdown 입니다.
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

  // 처리상태 분류 코드를 나타내는 Dropdown 입니다.
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

  // 사용자가 키워드를 입력할 수 있는 검색창을 제공하고 글쓰기 페이지로 이동할 수 있도록 아이콘을 마련한다.
  Widget topView() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 이전 페이지로 돌아가는 아이콘 입니다.
          backIcon(),

          // 검색창 입니다.
          searchText(),

          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // 이전 페이지로 돌아가는 아이콘 입니다.
  Widget backIcon() {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: IconButton(
        onPressed: () {
          // 사용자가 검색한 키워드를 빈칸으로 초기화 한다.
          PostListController.to.searchTextController.text = '';

          // 키보드 내리기
          FocusManager.instance.primaryFocus?.unfocus();

          // 이전 페이지로 돌아간다.
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
                // 전체 화면을 재랜더링 한다.
                setState(() {
                  // KeywordPPostListPage의 Pager의 현재 번호를 0으로 설정한다.
                  pagerCurrentPage = 0;

                  // KeywordPostListPage의 Pager 끝 번호를 0으로 설정한다.
                  pagerLastPage = 0;

                  // Pager를 일단 보여주지 않는 방향으로 선택한다.
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

  /* 시스템 분류코드에서 무엇을 선택했는가
     처리상태 분류코드에서 무엇을 선택했는가
     검색창에서 어떤 Text를 입력했는가
     총 3가지 조건을 분류하여 부합하는 게시글을 가져온다. */
  Widget getConditionITRequestPosts() {
    print('KeywordPostListPage - 조건에 맞는 IT 요청건 게시물 가져오기');

    return FutureBuilder<List<PostModel>>(
      future: PostListController.to.getConditionITRequestPosts(),
      builder: (context, snapshot) {
        // 조건에 맞는 IT 요청건 게시물을 기다리고 있다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitKeywordITRequestPosts();
        }

        // 조건에 맞는 IT 요청건 게시물이 1개도 없을 경우
        if (PostListController.to.keywordITRequestPosts.isEmpty) {
          return noKeywordITRequestPosts();
        }

        // 조건에 맞는 IT 요청건 게시물이 1개라도 있는 경우
        return prepareShowKeywordITRequestPosts();
      },
    );
  }

  // 조건에 맞는 IT 요청건 게시물을 기다리고 있으면 Loading Bar를 띄운다.
  Widget waitKeywordITRequestPosts() {
    return Container(
      margin: EdgeInsets.only(top: 250.h),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 조건에 맞는 게시물이 1개도 없는 경우 화면에 표시하는 Widget
  Widget noKeywordITRequestPosts() {
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

  // 조건에 맞는 IT 요청건 게시물을 가지고 화면에 표시하기 위해 준비한다.
  Widget prepareShowKeywordITRequestPosts() {
    // 조건에 맞는 IT 요청건 게시물이 5개 이상이면? -> Pager를 보여준다.
    if (PostListController.to.keywordITRequestPosts.length >= 5) {
      // Pager를 보여준다.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          isShowPager = true;
          PostListController.to.update(['keywordPostListPageShowPager']);
        },
      );

      // 사용자가 Pager를 다르게 클릭할 떄마다 다른 IT 요청건 게시물을 보여줘야 한다. 따라서 위 GetBuilder가 호출된다.
      return GetBuilder<PostListController>(
        id: 'movePagerAndShowDifferentKeywordITRequestPosts',
        builder: (controller) {
          // 처음 페이지를 보여줄 떄
          if (pagerCurrentPage == 0) {
            return Column(
              children: PostListController.to.keywordITRequestPosts
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                  .map((index) => showConditionITRequestPosts(index))
                  .toList(),
            );
          }

          // 중간 중간 페이지를 보여줄 떄
          else if (pagerCurrentPage + 1 != pagerLastPage) {
            return Column(
              children: PostListController.to.keywordITRequestPosts
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                  .map((index) => showConditionITRequestPosts(index))
                  .toList(),
            );
          }

          // 마지막 페이지를 보여줄 떄
          else {
            return Column(
              children: PostListController.to.keywordITRequestPosts
                  .asMap()
                  .keys
                  .toList()
                  .getRange(pagerCurrentPage * 5,
                      PostListController.to.keywordITRequestPosts.length)
                  .map((index) => showConditionITRequestPosts(index))
                  .toList(),
            );
          }
        },
      );
    }
    // 조건에 맞는 IT 요청건 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
    else {
      return Column(
        children: PostListController.to.keywordITRequestPosts
            .asMap()
            .keys
            .toList()
            .map((index) => showConditionITRequestPosts(index))
            .toList(),
      );
    }
  }

  // 하나 하나의 조건에 맞는 IT 요청건 게시물을 보여준다.
  Widget showConditionITRequestPosts(int index) {
    /* PostListController.to.keywordITRequestPosts[index]
       PostListController.to.keywordITRequestUsers[index]를 간단하게 명명한다. */
    PostModel postModel = PostListController.to.keywordITRequestPosts[index];
    UserModel userModel = PostListController.to.keywordITRequestUsers[index];

    // 하나 하나의 조건에 맞는 IT 요청건 게시물을 보여주는 Card
    return GestureDetector(
      onTap: () {
        /* SpecificPostPage로 Routing
            argument 0번쨰 : keywordITRequestPosts와 keywordITRequestUsers를 담고 있는 배열의 index
            argument 1번쨰 : KeywordPostListPage에서 Routing 되었다는 것을 증명하는 enum 값을 함꼐 보낸다. */
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.KEYWORDPOSTLISTPAGE_TO_SPECIFICPOSTPAGE,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시물의 index를 표시한다.
            Container(
              margin: EdgeInsets.only(top: 30.h),
              child: Text('${index + 1}'),
            ),

            // 조건에 맞느 IT 요청건 게시물의 몸통 부분이다.
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
                              '시스템 : ${postModel.sysClassficationCode.asText}',
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
                              '처리상태 : ${postModel.proStatus.asText}',
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
                        backgroundImage: userModel.image == null
                            ? Image.asset('assets/images/default_image.png')
                                .image
                            : CachedNetworkImageProvider(userModel.image!),
                      ),

                      // 사용자 이름
                      titleText: userModel.userName,

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

  // Pager를 보여준다.
  Widget pager() {
    return Container(
      padding: EdgeInsets.all(5.0.w),
      margin: EdgeInsets.only(bottom: 10.h),
      width: ScreenUtil().screenWidth,
      height: 50.h,
      child: NumberPaginator(
        numberPages: PostListController.to.keywordITRequestPosts.length % 5 == 0
            ? pagerLastPage =
                (PostListController.to.keywordITRequestPosts.length / 5).floor()
            : pagerLastPage =
                (PostListController.to.keywordITRequestPosts.length / 5)
                        .floor() +
                    1,
        initialPage: pagerCurrentPage,
        onPageChange: (int pagerUpdatePage) async {
          pagerCurrentPage = pagerUpdatePage;

          // Pager를 보여준다.
          PostListController.to.update(['keywordPostListPageShowPager']);

          await Future.delayed(const Duration(milliseconds: 5));

          /* 사용자가 Pager를 다르게 클릭할 떄마다 다른 IT 요청건 게시물을 보여줘야 한다. 
             따라서 id가 movePagerAndShowDifferentKeywordITRequestPosts인 GetBuilder를 호출한다. */
          PostListController.to
              .update(['movePagerAndShowDifferentKeywordITRequestPosts']);
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
            // 시스템 Dropdown, 처리상태 Dropdown를 바탕으로 키워드를 검색하는 입력창을 보여준다.
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              floating: true,
              snap: false,
              pinned: false,
              expandedHeight: 100.h,
              // 시스템 Dropdown, 처리상태 Dropdown를 보여준다.
              actions: [dropdownClassification()],

              // 키워드를 검색하는 입력창을 보여준다.
              bottom: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.0,
                actions: [topView()],
              ),
            ),

            /* 시스템 분류코드에서 무엇을 선택했는가
               처리상태 분류코드에서 무엇을 선택했는가
               검색창에서 어떤 Text를 입력했는가
               총 3가지 조건을 분류하여 부합하는 게시글을 가져온다. */
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // 3가지 조건에 맞는 IT 요청건 게시물을 가져온다.
                  getConditionITRequestPosts(),
                ],
              ),
            ),

            // Pager 입니다. 조건에 맞는 IT 요청건 게시물이 5개 미만이면 Pager를 보여주지 않습니다.
            SliverToBoxAdapter(
              child: GetBuilder<PostListController>(
                id: 'keywordPostListPageShowPager',
                builder: (controller) {
                  print('KeywordPostListPage - showPager 호출');

                  return isShowPager == true
                      // Pager를 보여준다.
                      ? pager()
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
