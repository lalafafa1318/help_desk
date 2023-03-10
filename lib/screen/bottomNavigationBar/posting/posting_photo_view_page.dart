import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:photo_view/photo_view.dart';

// 저장된 여러 PhotoView를 보여주는 class 입니다.
class PostingPhotoViewPage extends StatefulWidget {
  const PostingPhotoViewPage({Key? key}) : super(key: key);

  @override
  State<PostingPhotoViewPage> createState() => _PostingPhotoViewPageState();
}

class _PostingPhotoViewPageState extends State<PostingPhotoViewPage> {
  // PhotoView 현재 페이지
  int? currentPage;

  // PhotoView pageScroller 입니다.
  PageController? pageController;

  // PostingPhotoViewPage가 생길 떄 호출되는 method
  @override
  void initState() {
    super.initState();

    // 로그
    print('PostingPhotoViewPage - initState() 호출');

    // 변수 대입
    currentPage = Get.arguments;

    pageController = PageController(initialPage: currentPage!);
  }

  // PostingPhotoViewPage가 사라질 떄 호출되는 method
  @override
  void dispose() {
    // 로그
    print('PostingPhotoViewPage - dispose() 호출');

    // 메모리 회수 -> 메모리 누수 방지
    pageController!.dispose();

    super.dispose();
  }

  // Indicator 입니다.
  List<Widget> indicators(int imagesLength, int currentPage) {
    return List<Widget>.generate(
      imagesLength,
      (index) {
        return Container(
          margin: EdgeInsets.all(3.w),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: currentPage == index ? Colors.white : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 이전 페이지로 돌아가게 하는 AppBar 역할
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25.0),
        ),
      ),

      // PageView와 Indicator 구현
      body: Column(
        children: [
          // PhotoView
          SizedBox(
            width: ScreenUtil().screenWidth,
            height: 450.h,
            child: PageView.builder(
              itemCount: PostingController.to.imageList.length,
              pageSnapping: true,
              controller: pageController,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRect(
                    child: Container(
                      margin:
                          EdgeInsets.only(top: 50.h, left: 20.w, right: 20.w),
                      child: PhotoView(
                        imageProvider:
                            Image.file(PostingController.to.imageList[index])
                                .image,
                        // 이미지가 축소되지 않도록 한다.
                        minScale: PhotoViewComputedScale.contained * 1,
                        // 이미지를 확대하면 2배 확대까지만 가능하도록 한다.
                        maxScale: PhotoViewComputedScale.covered * 2,
                        enableRotation: false,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // SizedBox 입니다.
          SizedBox(height: 75.h),

          // Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                indicators(PostingController.to.imageList.length, currentPage!),
          ),
        ],
      ),
    );
  }
}
