import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_failure_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/posting/posting_success_page.dart';
import 'package:help_desk/utils/toast_util.dart';

// Posting할 떄 loading하여 결과에 따라 다른 로직을 보여주는 class 입니다.
class PostingUploadPage extends StatelessWidget {
  const PostingUploadPage({Key? key}) : super(key: key);

  // Loading을 띄우는 widget
  Widget postLoading() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SpinKitCircle(
            color: Colors.red,
          ),
          SizedBox(height: 15),
          Text('업로드 중입니다.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ToastUtil.showToastMessage('이전 가기가 불가능합니다 :)');

        return false;
      },
      child: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: PostingController.to.upload(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              // 비동기 함수 return 값을 아직 받지 못했을 떄
              if (snapshot.connectionState == ConnectionState.waiting) {
                return postLoading();
              }

              // 비동기 함수 return 값을 받았을 떄
              else {
                // validation을 통과하여 서버에 데이터를 성공적으로 넣었을 떄 처리
                if (snapshot.data == true) {
                  return const PostingSuccessPage();
                }
                // validation을 통과하지 못했을 떄 처리
                else {
                  return const PostingFailurePage();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
