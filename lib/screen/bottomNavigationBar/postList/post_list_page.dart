import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 게시판 목록 class 입니다.
class PostListPage extends StatefulWidget {
  const PostListPage({Key? key}) : super(key: key);

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  // Pager에 대한 setting
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

  // 시스템 분류 코드를 나타내는 Dropdown
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

  // 처리상태 분류 코드를 나타내는 Dropdown
  Widget proDropdown() {
    // 처리상태 단계를 나타내는 Dropdown
    return GetBuilder<PostListController>(
      id: 'proClassficationDropdown',
      builder: (controller) {
        print('처리상태 단계 DropDown 호출');
        return DropdownButton(
          value: PostListController.to.pSelectedValue.name,
          style: TextStyle(color: Colors.black, fontSize: 13.sp),
          items: ProClassification.values
              .where((element) => element != ProClassification.NONE)
              .map((element) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 키워드를 입력할 수 있는 검색창
          searchText(),

          // 글쓰기 페이지로 이동한다.
          writeIcon(),
        ],
      ),
    );
  }

  // 키워드를 입력할 수 있는 검색창
  Widget searchText() {
    return Container(
      margin: EdgeInsets.only(left: 20.r),
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

              // PostListPage에서 입력한 text를 검증한다.
              PostListController.to.validTextFromPostListPage();
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

  // 글쓰기 페이지로 이동한다.
  Widget writeIcon() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.r),
      child: IconButton(
        onPressed: () {
          // 글쓰기 페이지로 이동한다.
          BottomNavigationBarController.to.checkBottomNaviState(1);
        },
        icon: const Icon(PhosphorIcons.pencil, color: Colors.black),
      ),
    );
  }

  // IT 요청건 게시물을 가져온다.
  Widget getITRequestPosts() {
    print('PostListPage - IT 요청건 게시물 가져오기');

    return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      future: PostListController.to
          .getITRequestPosts(SettingsController.to.settingUser!.userType),
      builder: (context, snapshot) {
        // IT 요청건 게시물을 기다리고 있다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitITRequestPosts();
        }

        // IT 요청건 게시물이 1개도 없다.
        if (snapshot.data!.isEmpty) {
          return noITRequestPosts();
        }
        // IT 요청건 게시물이 1개 이상 있다.
        else {
          return prepareShowITRequestPosts(snapshot.data!);
        }
      },
    );
  }

  // IT 요청건 게시물을 기다리고 있으면 Loading Bar를 띄운다.
  Widget waitITRequestPosts() {
    return Container(
      margin: EdgeInsets.only(top: 150.h),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // IT 요청건 게시물이 1개도 없을 떄
  Widget noITRequestPosts() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 150.h),

        // 금지 아이콘
        const Icon(
          Icons.info_outline,
          size: 60,
          color: Colors.grey,
        ),

        SizedBox(height: 10.h),

        // 검색 결과가 없다는 Text
        Text(
          '게시물 데이터가 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 20.sp),
        ),
      ],
    );
  }

  // snapshot.data!로 받은 IT 요청건 게시물을 PostListController의 itRequestPosts, itRequestUsers에 대입한다.
  Widget prepareShowITRequestPosts(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> ultimateData) {
    return FutureBuilder<List<PostModel>>(
      future: PostListController.to.allocITRequestPostsAndUsers(ultimateData),
      builder: (context, snapshot) {
        // 데이터를 기다리고 있으면 CircularProgressIndicator를 표시한다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitITRequestPosts();
        }

        // IT 요청건 게시물이 5개 이상이면? -> Pager를 보여준다.
        if (PostListController.to.itRequestPosts.length >= 5) {
          // Pager를 보여준다.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              isShowPager = true;
              PostListController.to.update(['showPager']);
            },
          );

          // 사용자가 Pager를 다르게 클릭할 떄마다 다른 IT 요청건 게시물을 보여줘야 한다. 따라서 위 GetBuilder가 호출된다.
          return GetBuilder<PostListController>(
            id: 'movePagerAndShowDifferentITRequestPosts',
            builder: (controller) {
              // 첫 페이지를 보여줄 떄
              if (pagerCurrentPage == 0) {
                return Column(
                  children: PostListController.to.itRequestPosts
                      .asMap()
                      .keys
                      .toList()
                      .getRange(pagerCurrentPage, pagerCurrentPage + 5)
                      .map((index) => showITRequestPost(index))
                      .toList(),
                );
              }

              // 중간 중간 페이지를 보여줄 떄
              else if (pagerCurrentPage + 1 != pagerLastPage) {
                return Column(
                  children: PostListController.to.itRequestPosts
                      .asMap()
                      .keys
                      .toList()
                      .getRange(pagerCurrentPage * 5, pagerCurrentPage * 5 + 5)
                      .map((index) => showITRequestPost(index))
                      .toList(),
                );
              }

              // 마지막 페이지를 보여줄 떄
              else {
                return Column(
                  children: PostListController.to.itRequestPosts
                      .asMap()
                      .keys
                      .toList()
                      .getRange(pagerCurrentPage * 5,
                          PostListController.to.itRequestPosts.length)
                      .map((index) => showITRequestPost(index))
                      .toList(),
                );
              }
            },
          );
        }
        // IT 요청건 게시물이 5개 미만이면? -> Pager를 보여주지 않는다.
        else {
          return Column(
            children: PostListController.to.itRequestPosts
                .asMap()
                .keys
                .toList()
                .map((index) => showITRequestPost(index))
                .toList(),
          );
        }
      },
    );
  }

  // 하나 하나의 IT 요청건 게시물을 보여준다.
  Widget showITRequestPost(int index) {
    /* PostListController.to.itRequestPosts[index]
       PostListController.to.itRequestUsers[index]를 간단하게 명명한다. */
    PostModel postData = PostListController.to.itRequestPosts[index];
    UserModel userData = PostListController.to.itRequestUsers[index];

    // 하나 하나의 IT 요청건 게시물을 보여주는 Card
    return GestureDetector(
      onTap: () {
        // PostListPage 검색창에 써놓을 수 있는 text를 빈칸으로 설정한다.
        PostListController.to.searchTextController.text = '';

        /* SpecificPostPage로 Routing한다.
            argument 0번쨰 : itRequestPosts와 itRequestUsers들을 담고 있는 배열의 index
            argument 1번쨰 : PostListPage에서 Routing 되었다는 것을 증명하는 enum 값을 함꼐 보낸다. */
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.POSTLISTPAGE_TO_SPECIFICPOSTPAGE,
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

            // IT 요청건 게시물의 몸통 부분이다.
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // 시스템 처리 코드, 처리 단계를 나타내는 Container
                  Container(
                    margin: EdgeInsets.only(top: 26.h),
                    width: ScreenUtil().screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 시스템 분류 코드
                        Container(
                          width: 160.w,
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
                          /* postTime은 원래 초(Second)까지 존재하나
                             화면에서는 분(Minute)까지 표시한다. */
                          postData.postTime.substring(0, 16),
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                    ),

                    // 글 내용과 사진, 댓글 수를 보여준다.
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

                        // 게시물 이미지 개수, 댓글 수를 보여준다.
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
                                    visible: false,
                                    child: Text('이미지가 없으면 표시하지 않습니다.'),
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

  // Pager를 표시한다.
  Widget pager() {
    return Container(
      padding: EdgeInsets.all(5.0.w),
      margin: EdgeInsets.only(bottom: 10.h),
      width: ScreenUtil().screenWidth,
      height: 50.h,
      child: NumberPaginator(
        numberPages: PostListController.to.itRequestPosts.length % 5 == 0
            ? pagerLastPage =
                (PostListController.to.itRequestPosts.length / 5).floor()
            : pagerLastPage =
                (PostListController.to.itRequestPosts.length / 5).floor() + 1,
        initialPage: pagerCurrentPage,
        onPageChange: (int pagerUpdatePage) async {
          pagerCurrentPage = pagerUpdatePage;

          // Pager를 보여준다.
          PostListController.to.update(['showPager']);

          await Future.delayed(const Duration(milliseconds: 5));

          /* 사용자가 Pager를 다르게 클릭할 떄마다 다른 IT 요청건 게시물을 보여줘야 한다. 
             따라서 id가 movePagerAndShowDifferentITRequestPosts인 GetBuilder를 호출한다. */
          PostListController.to
              .update(['movePagerAndShowDifferentITRequestPosts']);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    print('PostListPage - initState() 호출');

    /* PostListPage 상단에 시스템 분류 코드는 "시스템 전체"가 default로 보이게끔 한다.
                         처리상태 분류 코드는 "처리상태 전체가" default로 보이게끔 한다. */
    PostListController.to.sSelectedValue = SysClassification.ALL;
    PostListController.to.pSelectedValue = ProClassification.ALL;

    // 키워드 입력창에 있는 text를 빈 값으로 설정한다.
    PostListController.to.searchTextController.text = '';
  }

  @override
  void dispose() {
    print('PostListPage - dispose() 호출');

    super.dispose();
  }

  // 전체적으로 화면을 build
  @override
  Widget build(BuildContext context) {
    print('dd : ${Get.currentRoute}');
    print('PostListPage - build() 실행');
    print('PostListPage userType : ${AuthController.to.user.value.userType}');

    return Scaffold(
      floatingActionButton: Align(
        alignment:
            Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),
        // FloatingActionButton은 IT 요청건 게시물을 새로고침 하는 역할을 한다.
        child: FloatingActionButton(
          backgroundColor: Colors.grey,
          onPressed: () {
            // 전체 화면을 재랜더링 한다.
            setState(() {
              // PostListPage의 Pager의 현재 번호를 0으로 설정한다.
              pagerCurrentPage = 0;

              // PostListPage의 Pager 끝 번호를 0으로 설정한다.
              pagerLastPage = 0;

              // Pager를 보여줄지 결정하는 변수를 false로 설정한다.
              isShowPager = false;
            });
          },
          child: const Icon(Icons.change_circle_outlined, size: 40),
        ),
      ),
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

          // IT 요청건이라는 Text를 표시한다.
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 10.w, top: 10.h),
              width: ScreenUtil().screenWidth,
              height: 50.h,
              child: Text(
                'IT 요청건',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // IT 요청건 게시물을 가져온다.
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // IT 요청건 게시물을 가져온다.
                getITRequestPosts(),
              ],
            ),
          ),

          // Pager 입니다. IT 요청건 게시물이 5개 미만이면 Pager를 보여주지 않습니다.
          SliverToBoxAdapter(
            child: GetBuilder<PostListController>(
              id: 'showPager',
              builder: (controller) {
                print('PostListPage - showPager 호출');

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
    );
  }
}
