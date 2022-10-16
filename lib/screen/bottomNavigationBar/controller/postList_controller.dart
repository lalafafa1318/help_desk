import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/const.dart';
import 'package:help_desk/model/comment_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/keyword_post_list_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:help_desk/utils/uuid_util.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

// PostList에 관한 상태 변수, 메서드를 관리하는 Controller class 입니다.
class PostListController extends GetxController {
  // Field
  // 사용자가 PostListPage나 KeywordPostListPage의 검색창에 입력한 text를 control하는 Field
  TextEditingController? searchTextController;

  // 업로드된 Post 데이터를 담는 List
  List<PostModel> postDatas = [];
  // User 데이터를 담는 List
  List<UserModel> userDatas = [];

  // 사용자가 입력한 text을 포함하거나 일치하는 Post 데이터를 담는 List
  List<PostModel> conditionTextPostDatas = [];
  // 사용자가 입력한 text을 포함하거나 일치하는 User 데이터를 담는 map
  List<UserModel> conditionTextUserDatas = [];

  // 사용자가 입력한 댓글과 대댓글을 control 하는 Field
  TextEditingController? commentController;
  // 댓글, 대댓글 데이터
  List<CommentModel> commentArray = [];

  // Method
  // PostListController를 쉽게 사용하도록 도와주는 method
  static PostListController get to => Get.find();

  // 전체 게시물을 업로드 시간 내림차순 기준으로 가져오는 method
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPostData() async* {
    yield* CommunicateFirebase.getAllPostData();
  }

  // 서버에서 받은 PostData들을 PostData를 담고 있는 배열에 추가한다.
  // 추가로 PostData에 따른 UserData도 UserData를 담고 있는 배열에 추가하는 method
  Future<List<PostModel>> allocatePostDatasInArray(List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) async {
    // PostData와 userData를 담고 있는 배열을 clear한다.
    postDatas.clear();
    userDatas.clear();

    for (var doc in allData) {
      // QueryDocumentSnapshot -> Json -> Model class로 변환한다.
      PostModel postData = PostModel.fromQueryDocumentSnapshot(doc);
      // PostData들을 담고 있는 배열에 PostData를 추가한다.
      postDatas.add(postData);

      // userUid 속성을 이용해 서버에서 UserData를 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUserData(postData.userUid);
      // UserData들을 담고 있는 배열에 UserData를 추가한다.
      userDatas.add(UserModel.fromMap(userData));
    }

    return postDatas;
  }

  // 사용자가 입력한 keyword을 포함하거나 일치하는 게시판 데이터를 List에 넣어주는 method
  Future<List<PostModel>> getConditionTextPostData() async {
    // searchTextController.text로 길게 쓰기 싫어서 keyword로 대치한다.
    String keyword = searchTextController!.text;

    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    conditionTextPostDatas.clear();
    conditionTextUserDatas.clear();

    for (PostModel postData in postDatas) {
      // 검증하기 전 사용자 userName을 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUserData(postData.userUid.toString());

      // 사용자가 입력한 keyword가 글 제목, 내용 그리고 이름 어디에서 포함되고 일치하는 경우를 검증한다.
      if (userData['userName'].contains(keyword) ||
          postData.postTitle.toString().contains(keyword) ||
          postData.postContent.toString().contains(keyword)) {
        // PostData와 UserData들을 담당하는 배열에 PostData와 UserData를 추가한다.
        conditionTextPostDatas.add(postData);
        conditionTextUserDatas.add(UserModel.fromMap(userData));
      }
    }
    return conditionTextPostDatas;
  }

  // PostListPage 검색창에 입력한 text를 validation하는 method
  void validTextFromPostListPage() {
    // PostListPage 검색창에 입력한 text가 빈 값인 경우
    if (PostListController.to.searchTextController!.text.isEmpty) {
      // 키보드 내리기
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');
    }
    // PostListPage 검색창에 입력한 text가 한 글자인 경우
    else if (PostListController.to.searchTextController!.text.length == 1) {
      // 키보드 내리기
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');
    }
    // PostListPage 검색창에 입력한 text가 두 글자 이상인 경우
    // KeywordPostListPage로 Routing 한다.
    else {
      Get.to(() => const KeywordPostListPage());
    }
  }

  // KeywordPostListPage 검색창에 입력한 text를 validation하는 method
  void validTextFromKeywordPostListPage() {
    // PostListPage 검색창에 입력한 text가 빈 값인 경우
    if (PostListController.to.searchTextController!.text.isEmpty) {
      // 키보드 내리기
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');
    }
    // PostListPage 검색창에 입력한 text가 한 글자인 경우
    else if (PostListController.to.searchTextController!.text.length == 1) {
      // 키보드 내리기
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');
    }
    // PostListPage 검색창에 입력한 text가 두 글자인 경우
    // 업데이트된 text를 가지고 KeywordPostListPage를 재랜더링 합니다.
    else {
      update();
    }
  }

  // 게시물을 삭제하는 method
  Future<void> deletePostData(String postUid) async {
    await CommunicateFirebase.deletePostData(postUid);
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

  // 게시물에 대한 댓글 목록을 가져오는 method
  Future<List<CommentModel>> getCommentData(String postUid) async {
    // 서버에서 게시물에 대한 댓글 목록을 가져온다.
    await CommunicateFirebase.getCommentData(postUid);

    return PostListController.to.commentArray;
  }

  // comment에 있는 사용자 Uid를 가지고 user 정보에 접근하는 method
  Future<UserModel> getUserData(String commentUserUid) async {
    Map<String, dynamic> userData =
        await CommunicateFirebase.getUserData(commentUserUid);

    // Map을 Model class로 변환하여 반환한다.
    return UserModel.fromMap(userData);
  }

  // 사용자가 게시물 댓글을 추가할 떄 호출되는 method
  Future<void> addComment(String comment, String postUid) async {
    // 현재 시간을 바탕으로 원하는 형식으로 바꾼다.
    DateTime currentDateTime = DateTime.now();
    String formatDate =
        DateFormat('yy/MM/dd - HH:mm:ss').format(currentDateTime);

    // Comment 모델 만들기
    CommentModel commentModel = CommentModel(
        content: comment,
        uploadTime: formatDate,
        whoCommentLike: [],
        belongCommentPostUid: postUid,
        commentUid: UUidUtil.getUUid(),
        whoWriteUserUid: SettingsController.to.settingUser!.userUid);

    // 서버에 댓글을 추가하기
    await CommunicateFirebase.setCommentData(commentModel);

    // 댓글과 대댓글을 관리하는 textController 다시 빈칸으로 초기화
    PostListController.to.commentController!.text = '';

    // 키보드 내리기
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // PostListController가 메모리에 처음 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    searchTextController = TextEditingController();

    commentController = TextEditingController();

    print('PostListController onInit() 호출');
  }

  // PostListController가 메모리에서 내리기전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    // 로그
    print('PostListController onClose() 호출');

    // 변수 초기화
    postDatas.clear();

    conditionTextPostDatas.clear();

    conditionTextUserDatas.clear();

    super.onClose();
  }
}
