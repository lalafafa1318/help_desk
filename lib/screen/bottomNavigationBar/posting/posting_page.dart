import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/border/gf_border.dart';
import 'package:getwidget/types/gf_border_type.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/main_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_photo_view_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_upload_page.dart';

import 'package:help_desk/utils/toast_util.dart';

class PostingPage extends StatelessWidget {
  const PostingPage({Key? key}) : super(key: key);

  // ImageContainer 입니다.
  Widget imageContainer() {
    return Container(
      width: Get.width,
      height: 100,
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          // 사진 올리기
          Container(
            margin: const EdgeInsets.only(left: 20),
            width: Get.width * 0.2,
            height: Get.width * 0.25,
            child: DottedBorder(
              strokeWidth: 2,
              child: GestureDetector(
                onTap: () async {
                  if (PostingController.to.imageList.length == 10) {
                    // 이미지를 띄울 수 없다는 경고문 띄우기
                    ToastUtil.showToastMessage(
                        '업로드할 수 있는 이미지 개수가 초과되었습니다.');
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
                    const SizedBox(height: 20),

                    const Icon(Icons.camera_alt_outlined),

                    const SizedBox(height: 5),

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
              radius: const Radius.circular(10),
            ),
          ),

          // 업로드한 사진들 보여주기(외부 코드)
          Obx(
            () => Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                padding: const EdgeInsets.only(right: 20),
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
      width: Get.width * 0.2,
      height: Get.width * 0.2,
      margin: const EdgeInsets.only(left: 20),
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
              radius: const Radius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
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
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.grey,
                child: Icon(Icons.close, size: 15, color: Colors.black),
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
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: GFBorder(
        color: Colors.black12,
        dashedLine: const [2, 0],
        type: GFBorderType.rect,
        child: SizedBox(
          height: 40,
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
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: GFBorder(
        color: Colors.black12,
        dashedLine: const [2, 0],
        type: GFBorderType.rect,
        child: SizedBox(
          height: 250,
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
          icon: const Padding(
            padding: EdgeInsets.all(8.5),
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),

        // 타이틀
        title: const Text(
          '글쓰기',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),

        // 완료 버튼
        actions: [
          Container(
            margin: const EdgeInsets.all(17.0),
            child: GestureDetector(
              onTap: () {
                // 다른 페이지로 Routing해서 Loading을 띄운다.
                Get.to(() => const PostingUploadPage());
              },
              child: const Text(
                '완료',
                style: TextStyle(color: Color(0xFFf08c0a), fontSize: 18),
              ),
            ),
          )
        ],

        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: Get.width,
          child: Column(
            children: [
              const SizedBox(height: 50),

              // 사진 추가하는 곳
              imageContainer(),

              const SizedBox(height: 50),

              // 글 제목(Text Title)
              textTitleContainer(),

              const SizedBox(height: 10),

              // 글 내용(Text Content)
              textContentContainer(),
            ],
          ),
        ),
      ),
    );
  }
}
