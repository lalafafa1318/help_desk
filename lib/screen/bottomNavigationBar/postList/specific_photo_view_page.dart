import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/distinguishRouting.dart';
import 'package:photo_view/photo_view.dart';

// PhotoView를 보여주는 Page 입니다 :)
class SpecificPhotoViewPage extends StatefulWidget {
  const SpecificPhotoViewPage({super.key});

  @override
  State<SpecificPhotoViewPage> createState() => _SpecificPhotoViewPageState();
}

class _SpecificPhotoViewPageState extends State<SpecificPhotoViewPage> {
  // 시작점이 PostListPage인지
  // KeywordPostListPage인지 확인하는 변수
  DistinguishRouting? whereRoute;

  // PostListController postDatas 또는 conditionKeywordPostDatas의 해당 index
  int? datasIndex;

  // 이미지 index
  int? imageIndex;

  // PhotoView pageScroller 입니다.
  PageController? pageController;

  // SpecificPhotoViewPage가 처음 불릴 떄 호출되는 method
  @override
  void initState() {
    super.initState();

    // 로그
    print('SpecificPhotoViewPage - initState() 호출');

    // 이전 페이지에서 전달한 arguments를 변수에 대입한다.
    whereRoute = Get.arguments[0];
    datasIndex = Get.arguments[1];
    imageIndex = Get.arguments[2];

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
  List<Widget> indicators(int imagesLength, int imageIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: imageIndex == index ? Colors.white : Colors.white24,
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
            // Post List Page에서 시작점이 출발됐는지
            // Keyword Post List Page에서 시작점이 출발됐는지 확인하여 PageView를 그린다.
            child: PageView.builder(
              itemCount: whereRoute ==
                      DistinguishRouting.postListPage_to_specificPostPage
                  ? PostListController
                      .to.postDatas[datasIndex!].imageList!.length
                  : PostListController.to.conditionKeywordPostDatas[datasIndex!]
                      .imageList!.length,
              pageSnapping: true,
              controller: pageController,
              onPageChanged: (page) {
                setState(() {
                  imageIndex = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.only(top: 30, left: 20, right: 20),

                  //확대, 축소가 가능하게 하기 위해 PhotoView를 적용했다.
                  child: PhotoView(
                    imageProvider: whereRoute ==
                            DistinguishRouting.postListPage_to_specificPostPage
                        ? CachedNetworkImageProvider(PostListController
                            .to.postDatas[datasIndex!].imageList![index]
                            .toString())
                        : CachedNetworkImageProvider(
                            PostListController
                                .to
                                .conditionKeywordPostDatas[datasIndex!]
                                .imageList![index]
                                .toString(),
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
            children: whereRoute ==
                    DistinguishRouting.postListPage_to_specificPostPage
                ? indicators(
                    PostListController
                        .to.postDatas[datasIndex!].imageList!.length,
                    imageIndex!,
                  )
                : indicators(
                    PostListController.to.conditionKeywordPostDatas[datasIndex!]
                        .imageList!.length,
                    imageIndex!),
          ),
        ],
      ),
    );
  }
}
