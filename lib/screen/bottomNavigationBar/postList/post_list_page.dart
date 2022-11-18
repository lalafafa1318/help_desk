import 'dart:io';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/const/routeDistinction.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/keyword_post_list_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/specific_post_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:oktoast/oktoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 게시판 목록 class 입니다.
class PostListPage extends StatefulWidget {
  const PostListPage({Key? key}) : super(key: key);

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  // 장애/문의, 시스템별 분류코드와 처리상태 분류코드 Dropdown을 담는 Widget (차선책)
  Widget classfication() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 45.0.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        child: SizedBox(
          width: 700.w,
          height: 50.h,
          child: Row(
            children: [
              // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown을 담는 Widget
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: obsOrInqClassification(),
              ),

              SizedBox(width: 10.w),

              // 시스템별 분류 코드에 관한 Dropdown을 담는 Widget
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: sysClassification(),
              ),

              // 처리상태 분류 코드에 관한 Dropdown을 담는 Widget
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: proClassification(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown을 담는 Widget(차선책)
  Widget obsOrInqClassification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 장애 처리현황/문의 처리현황 Text 띄우기
        Text('장애/문의', style: TextStyle(color: Colors.black, fontSize: 12.sp)),

        SizedBox(width: 20.w),

        // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown
        GetBuilder<PostListController>(
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
                PostListController.to.oSelectedValue = ObsOrInqClassification
                    .values
                    .firstWhere((enumValue) => enumValue.name == element);

                // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown만 재랜더링 한다.
                PostListController.to.update(['obsOrInqDropdown']);
              },
            );
          },
        )
      ],
    );
  }

  // 시스템별 분류코드에 관한 Dropdown를 담는 Widget(차선책)
  Widget sysClassification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '시스템',
          style: TextStyle(color: Colors.black, fontSize: 12.sp),
        ),

        SizedBox(width: 20.w),

        // 시스템 분류 코드를 나타내는 DropDown
        GetBuilder<PostListController>(
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
        ),
      ],
    );
  }

  // 처리상태 분류코드에 관한 Dropdown을 담는 Widget(차선책)
  Widget proClassification() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 25.w),

        // 처리상태 text
        Text(
          '처리상태',
          style: TextStyle(color: Colors.black, fontSize: 12.sp),
        ),

        SizedBox(width: 20.w),

        // 처리상태 단계를 나타내는 Dropdown
        GetBuilder<PostListController>(
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
        ),
      ],
    );
  }

  // 장애/문의, 시스템 분류 코드 그리고 처리상태 분류 코드 Dropdown을 담는다. (제 1책)
  Widget newClassification() {
    return Row(
      children: [
        SizedBox(width: 20.w),
        obsOrInqDropdown(),
        SizedBox(width: 10.w),
        sysDropdown(),
        SizedBox(width: 10.w),
        proDropdown(),
      ],
    );
  }

  // 장애/문의를 나타내는 Dropdown 입니다. (제 1책)
  Widget obsOrInqDropdown() {
    // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown
    return GetBuilder<PostListController>(
      id: 'postListPageObsOrInqDropdown',
      builder: (controller) {
        print('PostListPage - 장애/문의 처리현황 DropDown 호출');
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
            PostListController.to.update(['postListPageObsOrInqDropdown']);
          },
        );
      },
    );
  }

  // 시스템 분류 코드를 나타내는 Dropdown 입니다. (제 1책)
  Widget sysDropdown() {
    // 시스템 분류 코드를 나타내는 DropDown
    return GetBuilder<PostListController>(
      id: 'postListPageSysClassificationDropdown',
      builder: (controller) {
        print('PostListPage 시스템 분류코드 DropDown 호출');
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
            PostListController.to
                .update(['postListPageSysClassificationDropdown']);
          },
        );
      },
    );
  }

  // 처리상태 분류 코드를 나타내는 Dropdown 입니다. (제 1책)
  Widget proDropdown() {
    // 처리상태 단계를 나타내는 Dropdown
    return GetBuilder<PostListController>(
      id: 'postListPageProClassficationDropdown',
      builder: (controller) {
        print('PostListPage 처리상태 단계 DropDown 호출');
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
            PostListController.to
                .update(['postListPageProClassficationDropdown']);
          },
        );
      },
    );
  }

  // 사용자가 검색, 정렬할 수 있도록 하는 Widget
  Widget topView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 검색창 입니다.
        searchText(),

        // 글쓰기 페이지로 이동하는 Widget 입니다.
        writeIcon(),
      ],
    );
  }

  // 검색창 입니다.
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

  // 글쓰기를 지원하는 listIcon 입니다.
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

  // 장애 처리현황 또는 문의 처리현황 게시글을 가져오는 Widget
  Widget getObsOrInqPostDataLive() {
    return GetBuilder<PostListController>(
      id: 'getObsOrInqPostDataLive',
      builder: (controller) {
        // PostListController의 selectObsOrInq 변수가 'obstacleHandlingStatus'인 경우
        // 즉 장애 처리현황 버튼을 클릭했으면...
        if (PostListController.to.selectObsOrInq ==
            ObsOrInqClassification.obstacleHandlingStatus) {
          print('장애 처리현황 게시물 가져오기');
          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: PostListController.to.getObsPostData(),
            builder: (context, snapshot) {
              // 데이터가 아직 오지 않았을 때
              if (snapshot.connectionState == ConnectionState.waiting) {
                return waitAllPostData();
              }

              // 데이터가 왔는데 사이즈가 0이면..
              if (snapshot.data!.size == 0) {
                return noPostData();
              }
              // 사이즈가 1 이상이면...
              else {
                return prepareShowObsPostData(snapshot.data!.docs);
              }
            },
          );
        }
        // PostListController의 selectObsOrInq 변수가 'inqueryHandlingStatus'인 경우
        // 즉 문의 처리현황 버튼을 클릭했다면...
        else {
          print('문의 처리현황 게시물 가져오기');
          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: PostListController.to.getInqPostData(),
            builder: (context, snapshot) {
              // 데이터가 아직 오지 않았을 때
              if (snapshot.connectionState == ConnectionState.waiting) {
                return waitAllPostData();
              }

              // 데이터가 왔는데 사이즈가 0이면..
              if (snapshot.data!.size == 0) {
                return noPostData();
              }
              // 사이즈가 1 이상이면...
              else {
                return prepareShowInqPostData(snapshot.data!.docs);
              }
            },
          );
        }
      },
    );
  }

  // 장애 처리현황 게시물 또는 문서 처리현황 게시물을 기다리고 있으면 Loading Bar를 띄우는 Widget
  Widget waitAllPostData() {
    return Container(
      margin: EdgeInsets.only(top: 200.h),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 장애 처리현황 게시물이 1개도 없을 떄
  Widget noPostData() {
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

  // Database에서 받은 장애 처리현황 게시물을 obsPostData에 추가하는 method
  Widget prepareShowObsPostData(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) {
    return FutureBuilder<List<PostModel>>(
      future: PostListController.to.allocObsPostDataInArray(allData),
      builder: (context, snapshot) {
        // 데이터를 기다리고 있으면 CircularProgressIndicator를 표시한다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitAllPostData();
        }

        // 데이터가 왔으면 Column으로 표현한다.
        // ListView 또는 ListView.builder()로 표현할 수 있으나
        // 이미 SliverList로 감쌌기 떄문에 의미가 없어진다.
        return Column(
          children: PostListController.to.obsPostData
              .asMap()
              .keys
              .toList()
              .map((index) => showObsPostData(index))
              .toList(),
        );
      },
    );
  }

  // Database에서 받은 문의 처리현황 게시물을 inqPostData에 추가하는 method
  Widget prepareShowInqPostData(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) {
    return FutureBuilder<List<PostModel>>(
      future: PostListController.to.allocInqPostDataInArray(allData),
      builder: (context, snapshot) {
        // 데이터를 기다리고 있으면 CircularProgressIndicator를 표시한다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          waitAllPostData();
        }

        return Column(
          children: PostListController.to.inqPostData
              .asMap()
              .keys
              .toList()
              .map((index) => showInqPostData(index))
              .toList(),
        );
      },
    );
  }

  // 장애 처리현황 게시물을 보여주는 Widget
  Widget showObsPostData(int index) {
    // PostListController.to.obsPostDatas[index]
    // PostListController.to.obsUserDatas[index]를 간단하게 명명한다.
    PostModel postData = PostListController.to.obsPostData[index];
    UserModel userData = PostListController.to.obsUserData[index];

    // 게시글을 표현하는 Card이다.
    return GestureDetector(
      onTap: () {
        // PostListPage 검색창에 써놓을 수 있는 text를 빈칸으로 설정한다.
        PostListController.to.searchTextController.text = '';

        //  SpecificPostPage로 Routing한다.
        // argument 0번쨰 : ObsPostData와 ObsUserData들을 담고 있는 배열의 index
        // argument 1번쨰 : PostListPage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.postListPageObsPostToSpecificPostPage,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(18.0.r),
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

                    // 시스템 분류 코드와 처리 상태 분류 코드 (차선책)
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     // 시스템 분류 코드
                    //     GFListTile(
                    //       color: Colors.black12,
                    //       title: const Text(
                    //         '시스템',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subTitle: Text(postData.sysClassficationCode.asText),
                    //     ),

                    //     SizedBox(height: 20.h),

                    //     // 처리 상태 분류 코드
                    //     GFListTile(
                    //       color: Colors.black12,
                    //       title: const Text(
                    //         '처리상태',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subTitle: Text(postData.proStatus.asText),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 문의 처리현황 게시물을 보여주는 Widget
  Widget showInqPostData(int index) {
    // PostListController.to.inqPostDatas[index]
    // PostListController.to.inqUserDatas[index]를 간단하게 명명한다.
    PostModel postData = PostListController.to.inqPostData[index];
    UserModel userData = PostListController.to.inqUserData[index];

    // 게시글을 표현하는 Card이다.
    return GestureDetector(
      onTap: () {
        // PostListPage 검색창에 써놓을 수 있는 text를 빈칸으로 설정한다.
        PostListController.to.searchTextController.text = '';

        //  SpecificPostPage로 Routing한다.
        // argument 0번쨰 : inqPostData와 inqUserData들을 담고 있는 배열의 index
        // argument 1번쨰 : PostListPage에서 Routing 되었다는 것을 알려준다.
        Get.to(
          () => const SpecificPostPage(),
          arguments: [
            index,
            RouteDistinction.postListPageInqPostToSpecificPostPage,
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

                    // 시스템 분류 코드와 처리 상태 분류 코드 (차선책)
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     // 시스템 분류 코드
                    //     GFListTile(
                    //       color: Colors.black12,
                    //       title: const Text(
                    //         '시스템',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subTitle: Text(postData.sysClassficationCode.asText),
                    //     ),

                    //     SizedBox(height: 20.h),

                    //     // 처리 상태 분류 코드
                    //     GFListTile(
                    //       color: Colors.black12,
                    //       title: const Text(
                    //         '처리상태',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subTitle: Text(postData.proStatus.asText),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 장애 처리현황 게시판 보기, 문의 처리현황 게시판 보기 Button을 제공하는 Widget
  // 지금은 쓰지 않지만 최악의 상황에 쓴다.
  Widget obsOrInqButtons() {
    return ExpansionTile(
      backgroundColor: Colors.white,
      title: const Text('장애/문의 게시물 선택'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 10.0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // PostListController의 selectObsOrInq 값을 업데이트 한다.
                  PostListController.to.selectObsOrInq =
                      ObsOrInqClassification.obstacleHandlingStatus;

                  // 장애 처리현황 또는 문의 처리현황 개시물을 가져오는 로직만 재랜더링 한다.
                  PostListController.to.update(['getObsOrInqPostDataLive']);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return Colors.blueAccent;
                      return Colors.white;
                    },
                  ),
                ),
                child: const Text(
                  '장애 처리현황',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: () {
                  // PostListController의 selectObsOrInq 값을 업데이트 한다.
                  PostListController.to.selectObsOrInq =
                      ObsOrInqClassification.inqueryHandlingStatus;

                  // 장애 처리현황 또는 문의 처리현황 개시물을 가져오는 로직만 재랜더링 한다.
                  PostListController.to.update(['getObsOrInqPostDataLive']);

                  // setState(() {});
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return Colors.blueAccent;
                      return Colors.white;
                    },
                  ),
                ),
                child: const Text(
                  '문의 처리현황',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // 전체적으로 화면을 build
  @override
  Widget build(BuildContext context) {
    print('PostListPage - build() 실행');
    // 장애/문의 : default는 '장애 처리현황'
    // 시스템 : deault는 'ALL'
    // 처리상태 : default는 'ALL'
    // 장애/문의 게시물 선택 : default는 '장애 처리현황 게시물'
    PostListController.to.oSelectedValue =
        ObsOrInqClassification.obstacleHandlingStatus;
    PostListController.to.sSelectedValue = SysClassification.ALL;
    PostListController.to.pSelectedValue = ProClassification.ALL;
    PostListController.to.selectObsOrInq =
        ObsOrInqClassification.obstacleHandlingStatus;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          // 장애 처리현황 또는 문의 처리현황 게시물을 선택해서 보여주는 method를 실행한다.
          PostListController.to.changePost();
        },
        child: const Icon(Icons.change_circle_outlined, size: 40),
      ),
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
            title: newClassification(),
            // 키워드를 검색하는 입력창을 보여준다.
            bottom: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: topView(),
            ),
          ),

          // 장애 처리현황인지 문의 처리현황인지 나타내는 Text
          SliverToBoxAdapter(
            child: GetBuilder<PostListController>(
              id: 'isObsOrInq',
              builder: (controller) {
                return Container(
                  margin: EdgeInsets.only(left: 10.w, top: 10.h),
                  width: ScreenUtil().screenWidth,
                  height: 50.h,
                  child: Text(
                    PostListController.to.selectObsOrInq ==
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
            ),
          ),

          // 장애 처리현황 또는 문의 처리현황을 선택하는 Widget
          // 지금은 쓰지 않지만 최악의 경우 쓴다.
          // SliverToBoxAdapter(
          //   child: obsOrInqButtons(),
          // ),

          // 장애 처리현황 또는 문의 처리현황 게시물을 가져오는 Widget
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // 장애 처리현황 또는 문의 처리현황 게시글을 가져오는 Widget
                getObsOrInqPostDataLive(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
