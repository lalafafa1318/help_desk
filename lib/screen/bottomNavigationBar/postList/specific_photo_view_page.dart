import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:photo_view/photo_view.dart';

// PhotoView를 보여주는 Page 입니다 :)
class SpecificPhotoViewPage extends StatefulWidget {
  const SpecificPhotoViewPage({super.key});

  @override
  State<SpecificPhotoViewPage> createState() => _SpecificPhotoViewPageState();
}

class _SpecificPhotoViewPageState extends State<SpecificPhotoViewPage> {
  // PostData에 참조하는 변수
  PostModel? postData;

  //PostData의 imageList Property가 있다. 몇번째 사진인지 알려주는 imageIndex이다.
  int? imageIndex;

  // PhotoView pageScroller 입니다.
  PageController? pageController;

  // SpecificPhotoViewPage가 처음 불릴 떄 호출되는 method
  @override
  void initState() {
    super.initState();

    // 로그
    print('SpecificPhotoViewPage - initState() 호출');

    // SpecificPostPage에서 전달한 arguments를 변수에 대입한다.
    postData = Get.arguments[0];
    imageIndex = Get.arguments[1];

    pageController = PageController(initialPage: imageIndex!);
  }

  // SpecificPhotoViewPage가 사라질 떄 호출되는 method
  @override
  void dispose() {
    // 로그
    print('SpecificPhotoViewPage - dispose() 호출');

    // 메모리 회수 -> 메모리 누수 방지
    pageController!.dispose();

    super.dispose();
  }

  // Indicator 입니다.
  List<Widget> indicators(int imagesLength, int image) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: image == index ? Colors.white : Colors.white24,
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
            // 이전 페이지로 돌아가기
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
              itemCount: postData!.imageList.length,
              pageSnapping: true,
              controller: pageController,
              onPageChanged: (page) {
                setState(() {
                  imageIndex = page;
                });
              },
              itemBuilder: (BuildContext context, int imageIndex) {
                return Container(
                  margin: const EdgeInsets.only(top: 30, left: 20, right: 20),

                  //확대, 축소가 가능하게 하기 위해 PhotoView를 적용했다.
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(
                      postData!.imageList[imageIndex],
                    ),
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
            children: indicators(
              postData!.imageList.length,
              imageIndex!,
            ),
          ),
        ],
      ),
    );
  }
}
