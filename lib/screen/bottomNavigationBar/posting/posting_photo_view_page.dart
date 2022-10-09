import 'package:flutter/material.dart';
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
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: currentPage == index ? Colors.white : Colors.white24,
          shape: BoxShape.circle,
        ),
      );
    });
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
            width: Get.width,
            height: 600,
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
                return Container(
                  margin: const EdgeInsets.only(top: 30, left: 20, right: 20),

                  // 확대, 축소가 가능하게 하기 위해 PhotoView를 적용했다.
                  child: PhotoView(
                    imageProvider:
                        Image.file(PostingController.to.imageList[index]).image,
                    enableRotation: false,
                  ),
                );
              },
            ),
          ),

          // SizedBox 입니다.
          const SizedBox(height: 30),

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
