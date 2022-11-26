import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/border/gf_border.dart';
import 'package:getwidget/types/gf_border_type.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_photo_view_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_upload_page.dart';

import 'package:help_desk/utils/toast_util.dart';

class PostingPage extends StatelessWidget {
  const PostingPage({Key? key}) : super(key: key);

  // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown을 담는 Widget
  Widget obsOrInqClassification() {
    return Container(
      margin: EdgeInsets.only(left: 20.w),
      child: Row(
        children: [
          // 장애 처리현황/문의 처리현황 Text 띄우기
          Text('장애/문의', style: TextStyle(fontSize: 13.sp)),

          SizedBox(width: 90.w),

          // 장애처리 현황인지 문의처리 현황인지 결정하는 Dropdown
          GetBuilder<PostingController>(
            id: 'postingPageObsOrInqDropdown',
            builder: (controller) {
              print('PostingPage 장애/문의 처리현황 Dropdown 호출');
              return DropdownButton(
                value: PostingController.to.oSelectedValue.name,
                style: TextStyle(color: Colors.black, fontSize: 13.sp),
                items: ObsOrInqClassification.values.map((element) {
                  // enum 값을 화면에 표시할 값으로 변환한다.
                  String realText = element.asText;

                  return DropdownMenuItem(
                    value: element.name,
                    child: Text(realText),
                  );
                }).toList(),
                onChanged: (element) {
                  // PostingController의 oSelectedValue 값을 바꾼다.
                  PostingController.to.oSelectedValue = ObsOrInqClassification
                      .values
                      .firstWhere((enumValue) => enumValue.name == element);

                  // GetBuilder를 호출하기 위해 update를 친다.
                  PostingController.to.update(['postingPageObsOrInqDropdown']);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // 시스템 분류 코드를 결정하는 Dropdown을 담는 Widget
  Widget sysClassification() {
    return Container(
      margin: EdgeInsets.only(left: 20.w),
      child: Row(
        children: [
          // 장애 처리현황/문의 처리현황 Text 띄우기
          Text('시스템', style: TextStyle(fontSize: 13.sp)),

          SizedBox(width: 105.w),

          // 시스템 분류 코드를 결정하는 Dropdown
          GetBuilder<PostingController>(
            id: 'postingPagesysClassificationDropdown',
            builder: (controller) {
              print('PostingPage 시스템 분류코드 Dropdown 호출');

              return DropdownButton(
                value: PostingController.to.sSelectedValue.name,
                style: TextStyle(color: Colors.black, fontSize: 13.sp),
                // Dropdown에 "시스템 전체"는 보여주지 않는다.
                // "시스템 전체"는 검색 용도에만 쓰인다.
                items: SysClassification.values
                    .where((element) => element != SysClassification.ALL)
                    .map((element) {
                  // enum 값을 화면에 표시할 값으로 변환한다.
                  String realText = element.asText;

                  return DropdownMenuItem(
                    value: element.name,
                    child: Text(realText),
                  );
                }).toList(),
                onChanged: (element) {
                  // controller에 있는 값을 바꾼다.
                  PostingController.to.sSelectedValue = SysClassification.values
                      .firstWhere((enumValue) => enumValue.name == element);

                  // GetBuilder를 호출하기 위해 update를 친다.
                  PostingController.to
                      .update(['postingPagesysClassificationDropdown']);
                },
              );
            },
          )
        ],
      ),
    );
  }

  // ImageContainer 입니다.
  Widget imageContainer() {
    return Container(
      width: ScreenUtil().screenWidth,
      height: 100.h,
      margin: EdgeInsets.only(left: 2.5.w),
      child: Row(
        children: [
          // 사진 올리기
          Container(
            margin: EdgeInsets.only(left: 15.w),
            width: 100.w,
            child: DottedBorder(
              strokeWidth: 2,
              child: GestureDetector(
                onTap: () async {
                  if (PostingController.to.imageList.length == 10) {
                    // 이미지를 띄울 수 없다는 경고문 띄우기
                    ToastUtil.showToastMessage('업로드할 수 있는 이미지 개수가 초과되었습니다.');
                  }
                  //
                  else {
                    // 이미지 불러오기
                    await PostingController.to.getImage();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 25.h),

                    const Icon(Icons.camera_alt_outlined),

                    SizedBox(height: 5.h),

                    // 상태 변화 감지
                    Obx(
                      () => Text(
                        '${PostingController.to.imageList.value.length}/10',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              color: Colors.grey,
              dashPattern: const [5, 3],
              borderType: BorderType.RRect,
              radius: Radius.circular(10.r),
            ),
          ),

          // 업로드한 사진들 보여주기(외부 코드)
          Obx(
            () => Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                padding: EdgeInsets.only(right: 20.w),
                itemCount: PostingController.to.imageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return showImage(
                    PostingController.to.imageList[index],
                    index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 업로드한 사진들 보여주기 (내부 코드)
  Widget showImage(File file, int index) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(left: 20.w),
      child: GestureDetector(
        onTap: () {
          // Routing을 이용해서 PhotoViewPage를 보여준다.
          Get.to(() => const PostingPhotoViewPage(), arguments: index);
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // 사진 보여주기
            DottedBorder(
              strokeWidth: 2,
              color: Colors.grey,
              dashPattern: const [5, 3],
              borderType: BorderType.RRect,
              radius: Radius.circular(10.r),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0.r),
                  image: DecorationImage(
                    image: Image.file(file).image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 사진 삭제
            GestureDetector(
              onTap: () {
                // 사진 삭제
                PostingController.to.deleteImage(index);
              },
              child: CircleAvatar(
                radius: 10.r,
                backgroundColor: Colors.grey,
                child: const Icon(Icons.close, size: 15, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 글 제목 입니다.
  Widget textTitleContainer() {
    return Container(
      width: ScreenUtil().screenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: GFBorder(
        color: Colors.black12,
        dashedLine: const [2, 0],
        type: GFBorderType.rect,
        child: SizedBox(
          height: 40.h,
          child: TextField(
            onChanged: (value) {
              PostingController.to.titleString(value);
              print('title : ${PostingController.to.titleString}');
            },
            maxLength: 30,
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              hintText: '제목을 입력해주세요',
            ),
          ),
        ),
      ),
    );
  }

  // 글 내용 입니다.
  Widget textContentContainer() {
    return Container(
      width: ScreenUtil().screenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: GFBorder(
        color: Colors.black12,
        dashedLine: const [2, 0],
        type: GFBorderType.rect,
        child: SizedBox(
          height: 200.h,
          child: TextField(
            onChanged: (value) {
              PostingController.to.contentString(value);
              print('content : ${PostingController.to.contentString}');
            },
            maxLength: 300,
            maxLines: 10,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '내용을 입력해주세요',
            ),
          ),
        ),
      ),
    );
  }

  // 전화번호를 입력하는 Widget
  Widget enterYourPhoneNumber() {
    return Container(
      width: ScreenUtil().screenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: GFBorder(
        color: Colors.black12,
        dashedLine: const [2, 0],
        type: GFBorderType.rect,
        child: SizedBox(
          height: 40.h,
          child: TextField(
            onChanged: (value) {
              PostingController.to.phoneNumber = value;
              print('phoneNumber : ${PostingController.to.phoneNumber}');
            },
            maxLength: 30,
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              hintText: '010XXXXXXXX 형식의 전화번호',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,

        // 취소 버튼
        leading: IconButton(
          onPressed: () {
            // PostingController에 관리되고 있는 상태 변수 초기화 한다.
            PostingController.to.initPostingElement();

            BottomNavigationBarController.to.deleteBottomNaviBarHistory();
          },
          icon: Container(
            margin: EdgeInsets.only(top: 1.h),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),

        // 타이틀
        title: Text(
          '글쓰기',
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),

        // 완료 버튼
        actions: [
          Container(
            width: 40.w,
            margin: EdgeInsets.only(right: 10.w),
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                // 다른 페이지로 Routing해서 Loading을 띄운다.
                Get.to(() => const PostingUploadPage());
              },
              child: Text(
                '완료',
                style:
                    TextStyle(color: const Color(0xFFf08c0a), fontSize: 18.sp),
              ),
            ),
          ),
        ],

        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: ScreenUtil().screenWidth,
          child: Column(
            children: [
              SizedBox(height: 10.h),

              // 장애 처리현황인지 문의 처리현황인지 결정하는 Dropdown을 담는 Widget
              obsOrInqClassification(),

              SizedBox(height: 10.h),

              // 시스템 분류 코드를 결정하는 Dropdown을 담는 Widget
              sysClassification(),

              SizedBox(height: 50.h),

              // 사진 추가하는 곳
              imageContainer(),

              SizedBox(height: 50.h),

              // 글 제목(Text Title)
              textTitleContainer(),

              SizedBox(height: 10.h),

              // 글 내용(Text Content)
              textContentContainer(),

              SizedBox(height: 10.h),

              // 전화번호를 입력하는 Widget
              enterYourPhoneNumber(),
            ],
          ),
        ),
      ),
    );
  }
}
