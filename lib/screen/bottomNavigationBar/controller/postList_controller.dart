import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/const.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/keyword_post_list_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:http/http.dart';

// PostList에 관한 상태 변수, 메서드를 관리하는 Controller class 입니다.
class PostListController extends GetxController {
  // Field
  // 사용자가 검색창에 입력한 Keyword를 controll하는 Field
  TextEditingController? keywordController;

  // 업로드된 게시판 데이터를 담는 List
  List<PostModel> postDatas = [];

  // 사용자가 입력한 keyword을 포함하거나 일치하는 게시판 데이터를 담는 List
  List<PostModel> conditionKeywordPostDatas = [];

  // 사용자가 입력한 keyword을 포함하거나 일치하는 사용자 데이터를 담는 map
  List<Map<String, dynamic>> conditionKeywordUserDatas = [];

  // Method
  // PostListController를 쉽게 사용하도록 도와주는 method
  static PostListController get to => Get.find();

  // 변경된 게시판 업로드 데이터를 List에 넣어주는 method
  void getPostData(List<QueryDocumentSnapshot<Map<String, dynamic>>> datas) {
    postDatas.clear();

    for (var data in datas) {
      // QueryDocumentSnapshot -> Json -> Model class로 변환한다.
      PostModel postElement = PostModel.fromQueryDocumentSnapshot(data);

      postDatas.add(postElement);
    }

    print('postDatas 개수 : ${postDatas.length}');
  }

  // 사용자가 입력한 keyword을 포함하거나 일치하는 게시판 데이터를 List에 넣어주는 method
  Future<List<PostModel>> getConditionKeywordPostData() async {
    // keywordController.text로 길게 쓰기 싫어서 keyword로 대치한다.
    String keyword = keywordController!.text;

    // 기존 데이터를 삭제한다.
    conditionKeywordPostDatas.clear();
    conditionKeywordUserDatas.clear();

    for (PostModel postData in postDatas) {
      // 검증하기 전 사용자 userName을 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUserInfo(postData.userUid.toString());

      // 사용자가 입력한 keyword가 글 제목, 내용 그리고 이름 어디에서 포함되고 일치하는 경우를 검증한다.
      if (userData['userName'].contains(keyword) ||
          postData.postTitle.toString().contains(keyword) ||
          postData.postContent.toString().contains(keyword)) {
        conditionKeywordPostDatas.add(postData);
        conditionKeywordUserDatas.add(userData);
      }
    }

    return conditionKeywordPostDatas;
  }

  // PostListPage 검색창에 입력한 Keyword를 validation하는 method
  void validKeywordFromPostListPage() {
    // 키워드가 빈칸 인 경우
    if (PostListController.to.keywordController!.text.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');
    }
    // 키워드가 한 글자 인 경우
    else if (PostListController.to.keywordController!.text.length == 1) {
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');
    }
    // 키워드가 두 글자 이상인 경우
    // KeywordPostListPage로 Routing 한다.
    else {
      Get.to(() => KeywordPostListPage());
    }
  }

  // KeywordPostListPage 검색창에 입력한 Keyword를 validation하는 method
  void validKeywordFromKeywordPostListPage() {
    // 키워드가 빈칸 인 경우
    if (PostListController.to.keywordController!.text.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');
    }
    // 키워드가 한 글자 인 경우
    else if (PostListController.to.keywordController!.text.length == 1) {
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');
    }
    // 키워드가 두 글자 이상인 경우
    // 업데이트된 Keyword를 가지고 KeywordPostListPage를 재랜더링 합니다.
    else {
      update();
    }
  }

  // 사용자가 게시물에 대해서 좋아요 버튼을 클릭할 떄
  // 게시물의 좋아요 속성에 사용자가 있는지 판별하는 method
  Future<bool> checkLikeUsersFromThePost(String postUid, String userUid) async {
    bool isResult =
        await CommunicateFirebase.checkLikeUsersFromThePost(postUid, userUid);

    return isResult;
  }

  // 사용자가 게시물에 대해서 공감을 누른 경우 호출되는 method (단, 공감을 하지 않았을 때에만 적용)
  Future<void> addUserWhoLikeThePost(String postUid, String userUid) async {
     await CommunicateFirebase.addUserWhoLikeThePost(postUid, userUid);
  }

  // PostListController가 메모리에 처음 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    keywordController = TextEditingController();

    print('PostListController onInit() 호출');
  }

  // PostListController가 메모리에서 내리기전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    // 로그
    print('PostListController onClose() 호출');

    // 변수 초기화
    postDatas.clear();

    conditionKeywordPostDatas.clear();

    conditionKeywordUserDatas.clear();

    super.onClose();
  }
}
