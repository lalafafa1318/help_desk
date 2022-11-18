import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/causeObsClassification.dart';
import 'package:help_desk/const/hourClassification.dart';
import 'package:help_desk/const/minuteClassification.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
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
  TextEditingController searchTextController = TextEditingController();

  // PostListPage, KeywordPostListPage 장애/문의 DropDown에서
  // 장애 처리현황을 Tab했는가, 문의 처리현황을 Tab했는가 나타내는 변수
  ObsOrInqClassification oSelectedValue =
      ObsOrInqClassification.obstacleHandlingStatus;

  // PostListPage, KeywordPostListPage 시스템 분류 코드 DropDown에서 무엇을 Tab했는가 나타내는 변수
  SysClassification sSelectedValue = SysClassification.ALL;

  // PostListPage , KeywordPostListPage 처리상태 분류 코드 DropDown에서 무엇을 Tab했는가 나타내는 변수
  ProClassification pSelectedValue = ProClassification.ALL;

  // 장애 처리현황 게시물을 담는 배열
  List<PostModel> obsPostData = [];
  // 장애 처리현황 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> obsUserData = [];

  // 문의 처리현황 게시물을 담는 배열
  List<PostModel> inqPostData = [];
  // 문의 처리현황 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> inqUserData = [];

  // 검색창에서 조건에 맞는 장애 처리현황 게시물을 담는 배열
  List<PostModel> conditionObsPostData = [];
  // 검색창에서 조건에 맞는 장애 처리현황 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> conditionObsUserData = [];

  // 검색창에서 조건에 맞는 문의 처리현황 게시물을 담는 배열
  List<PostModel> conditionInqPostData = [];
  // 검색창에서 조건에 맞는 문의 처리현황 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> conditionInqUserData = [];

  // 사용자가 입력한 댓글과 대댓글을 control 하는 Field
  TextEditingController commentController = TextEditingController();

  // PostListPage 장애/게시물 선택에서
  // 장애 처리현황을 선택했는가? 문의 처리현황을 선택했는가?
  ObsOrInqClassification selectObsOrInq =
      ObsOrInqClassification.obstacleHandlingStatus;

  // SpecificPostPage의 comment 처리상태를 관리하는 변수
  ProClassification commentPSelectedValue = ProClassification.INPROGRESS;

  // SpecificPostPage의 comment 장애원인을 관리하는 변수 (장애 처리현황 게시물에 한함)
  CauseObsClassification commentCSelectedValue = CauseObsClassification.USER;

  // SpecificPostPage의 comment 실제 처리시간(시, Hour)을 관리하는 변수 (장애 처리현황 게시물에 한함)
  HourClassification commentHSelectedValue = HourClassification.ZERO_ZERO_HOUR;

  // SpecificPostPage의 comment 실제 처리시간(분, Minute)을 관리하는 변수 (장애 처리현황 게시물에 한함)
  MinuteClassification commentMSelectedValue =
      MinuteClassification.ZERO_ZERO_MINUTE;

  // Method
  // PostListController를 쉽게 사용하도록 도와주는 method
  static PostListController get to => Get.find();

  // 장애 처리현황 게시물을 postTime 내림차순 기준으로 가져오는 method
  Future<QuerySnapshot<Map<String, dynamic>>> getObsPostData() async {
    return await CommunicateFirebase.getObsPostData();
  }

  // 문의 처리현황 게시물을 postTime 내림차순 기준으로 가져오는 method
  Future<QuerySnapshot<Map<String, dynamic>>> getInqPostData() async {
    return await CommunicateFirebase.getInqPostData();
  }

  // Database에서 받은 장애 처리현황 게시물을 obsPostData에 추가하는 method
  // 그리고 게시물에 대한 사용자 정보를 파악하여 obsUserData에 추가하는 method
  Future<List<PostModel>> allocObsPostDataInArray(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) async {
    // 장애 처리현황 게시물을 담고 있는 obsPostData
    // 게시물에 대한 사용자 정보를 담고 있는 obsUserData를 clear 한다.
    obsPostData.clear();
    obsUserData.clear();

    for (var doc in allData) {
      // QueryDocumentSnapshot -> Json -> Model class로 변환한다.
      PostModel postModel = PostModel.fromQueryDocumentSnapshot(doc);
      // 장애 처리현황에 관한 게시물을 담고 있는 obsPostData에 Model class를 추가한다.
      obsPostData.add(postModel);

      // modelData의 userUid 속성을 이용해
      // Server에서 게시물에 대한 사용자 정보를 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUserData(postModel.userUid);

      // 장애 처리현황 게시물에 대한 사용자 정보를 담고 있는 obsUserData에 element를 추가한다.
      obsUserData.add(UserModel.fromMap(userData));
    }

    return obsPostData;
  }

  // Database에서 받은 문의 처리현황 게시물을 inqPostData에 추가하는 method
  // 그리고 게시물에 대한 사용자 정보를 파악하여 inqUserData에 추가하는 method
  Future<List<PostModel>> allocInqPostDataInArray(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) async {
    // 문의 처리현황 게시물을 담고 있는 inqPostData
    // 게시물에 대한 사용자 정보를 담고 있는 inqUserData를 clear 한다.

    inqPostData.clear();
    inqUserData.clear();

    await Future.delayed(const Duration(milliseconds: 5));

    for (var doc in allData) {
      // QueryDocumentSnapshot -> Json -> Model class로 변환한다.
      PostModel postModel = PostModel.fromQueryDocumentSnapshot(doc);
      // 문의 처리현황에 관한 게시물을 담고 있는 inqPostData에 Model class를 추가한다.
      inqPostData.add(postModel);

      // modelData의 userUid 속성을 이용해
      // Server에서 게시물에 대한 사용자 정보를 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUserData(postModel.userUid);

      // 문의 처리현황 게시물에 대한 사용자 정보를 담고 있는 inqUserData에 element를 추가한다.
      inqUserData.add(UserModel.fromMap(userData));
    }

    return inqPostData;
  }

  // 장애 처리현황 또는 문의 처리현황 게시물을 선택해서 보여주는 method
  void changePost() {
    // PostListController의 selectObsOrInq 변수를 업데이트한다.
    if (selectObsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      selectObsOrInq = ObsOrInqClassification.inqueryHandlingStatus;
    }
    //
    else {
      selectObsOrInq = ObsOrInqClassification.obstacleHandlingStatus;
    }

    // GetBuilder를 통해 장애 처리현황 게시물 또는 문의 처리현황 게시물을 보여준다.
    PostListController.to.update(['getObsOrInqPostDataLive']);

    // 보여주는 게시물이 장애 처리현황인지 문의 처리현황인지 보여준다.
    PostListController.to.update(['isObsOrInq']);
  }

  // 장애 처리현황 게시물에서 필터링하는 method
  Future<List<PostModel>> getConditionObsPostData() async {
    // searchTextController.text로 길게 쓰기 싫어서 keyword로 대치한다.
    String keyword = searchTextController.text;

    // 1차 검증을 확인하는 변수
    bool isFirstVerified = false;

    // 기존에 존재했던 conditionObsPostData, conditionObsUserData를 clear한다.
    conditionObsPostData.clear();
    conditionObsUserData.clear();

    // 조건에 맞는 게시물을 찾는다.
    for (int i = 0; i < obsPostData.length; i++) {
      // 1차 검증
      // DropdownMenu에서 선택한 시스템 분류 코드가 ALL이고 처리상태 분류 코드도 ALL인 경우
      if (sSelectedValue == SysClassification.ALL &&
          pSelectedValue == ProClassification.ALL) {
        isFirstVerified = true;
      }

      // 1차 검증
      // DropdownMenu에서 선택한 시스템 분류 코드가 ALL이나 처리상태 분류 코드가 ALL이 아닌 경우
      else if (sSelectedValue == SysClassification.ALL &&
          pSelectedValue != ProClassification.ALL) {
        // DropDownMenu에서 선택한 처리상태 분류 코드와
        // 게시물의 처리상태 분류 코드가 일치하는지 확인한다.
        pSelectedValue == obsPostData[i].proStatus
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      // 1차 검증
      // DropdownMenu에서 선택한 시스템 분류 코드가 ALL이 아니나 처리상태 분류 코드가 ALL인 경우
      else if (sSelectedValue != SysClassification.ALL &&
          pSelectedValue == ProClassification.ALL) {
        sSelectedValue == obsPostData[i].sysClassficationCode
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      // 1차 검증
      // DropdownMenu에서 선택한 시스템 분류 코드와 처리상태 분류 코드가 모두 ALL이 아닌 경우
      else {
        (sSelectedValue == obsPostData[i].sysClassficationCode &&
                pSelectedValue == obsPostData[i].proStatus)
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      // 2차 검증
      // 입력한 text가 글 제목, 설명 그리고 작성자 중에 포함되는 것이 있는지 확인한다.
      if (isFirstVerified == true &&
          (obsPostData[i].postTitle.contains(keyword) ||
              obsPostData[i].postContent.contains(keyword) ||
              obsUserData[i].userName.contains(keyword))) {
        // 1차 검증과 2차 검증을 모두 만족한다면 비로소 conditionObsPostData와 conditionObsUserData에 element를 추가한다.
        conditionObsPostData.add(obsPostData[i]);
        conditionObsUserData.add(obsUserData[i]);
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    return conditionObsPostData;
  }

  // 문의 처리현황 게시물에서 필터링하는 method
  Future<List<PostModel>> getConditionInqPostData() async {
    // searchTextController.text로 길게 쓰기 싫어서 keyword로 대치한다.
    String keyword = searchTextController.text;

    // 1차 검증을 확인하는 변수
    bool isFirstVerified = false;

    // 기존에 존재했던 conditionInqPostData, conditionInqUserData를 clear한다.
    conditionInqPostData.clear();
    conditionInqUserData.clear();

    // 조건에 맞는 게시물을 찾는다.
    for (int i = 0; i < inqPostData.length; i++) {
      // 1차 검증

      // DropdownMenu에서 선택한 시스템 분류 코드가 ALL이고 처리상태 분류 코드도 ALL인 경우
      if (sSelectedValue == SysClassification.ALL &&
          pSelectedValue == ProClassification.ALL) {
        isFirstVerified = true;
      }
      // DropdownMenu에서 선택한 시스템 분류 코드가 ALL이나 처리상태 분류 코드가 ALL이 아닌 경우
      else if (sSelectedValue == SysClassification.ALL &&
          pSelectedValue != ProClassification.ALL) {
        // DropDownMenu에서 선택한 처리상태 분류 코드와
        // 게시물의 처리상태 분류 코드가 일치하는지 확인한다.
        pSelectedValue == inqPostData[i].proStatus
            ? isFirstVerified = true
            : isFirstVerified = false;
      }
      // DropdownMenu에서 선택한 시스템 분류 코드가 ALL이 아니나 처리상태 분류 코드가 ALL인 경우
      else if (sSelectedValue != SysClassification.ALL &&
          pSelectedValue == ProClassification.ALL) {
        sSelectedValue == inqPostData[i].sysClassficationCode
            ? isFirstVerified = true
            : isFirstVerified = false;
      }
      // DropdownMenu에서 선택한 시스템 분류 코드와 처리상태 분류 코드가 모두 ALL이 아닌 경우
      else {
        (sSelectedValue == inqPostData[i].sysClassficationCode &&
                pSelectedValue == inqPostData[i].proStatus)
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      // 2차 검증
      // 입력한 text가 글 제목, 설명 그리고 작성자 중에 포함되는 것이 있는지 확인한다.
      if (isFirstVerified == true &&
          (inqPostData[i].postTitle.contains(keyword) ||
              inqPostData[i].postContent.contains(keyword) ||
              inqUserData[i].userName.contains(keyword))) {
        // 1차 검증과 2차 검증을 모두 만족한다면 비로소 conditionInqPostData와 conditionInqUserData에 element를 추가한다.
        conditionInqPostData.add(inqPostData[i]);
        conditionInqUserData.add(inqUserData[i]);
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    return conditionInqPostData;
  }

  // PostListPage 검색창에 입력한 text를 validation하는 method
  void validTextFromPostListPage() {
    // PostListPage 검색창에 입력한 text가 빈 값인 경우
    if (PostListController.to.searchTextController.text.isEmpty) {
      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');
    }
    // PostListPage 검색창에 입력한 text가 한 글자인 경우
    else if (PostListController.to.searchTextController.text.length == 1) {
      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');
    }
    // PostListPage 검색창에 입력한 text가 두 글자 이상인 경우
    // KeywordPostListPage로 Routing 한다.
    else {
      Get.to(() => const KeywordPostListPage());
    }
  }

  // KeywordPostListPage 검색창에 입력한 text를 validation하는 method
  bool validTextFromKeywordPostListPage() {
    // PostListPage 검색창에 입력한 text가 빈 값인 경우
    if (PostListController.to.searchTextController.text.isEmpty) {
      // 키보드 내리기
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');

      return false;
    }
    // PostListPage 검색창에 입력한 text가 한 글자인 경우
    else if (PostListController.to.searchTextController.text.length == 1) {
      // 키보드 내리기
      FocusManager.instance.primaryFocus?.unfocus();

      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');

      return false;
    }
    // PostListPage 검색창에 입력한 text가 두 글자인 경우
    // 업데이트된 text를 가지고 KeywordPostListPage를 재랜더링 합니다.
    else {
      return true;
    }
  }

  // Database에 게시글 작성한 사람(User)의 image 속성과 userName 속성을 확인하여 가져온s는 method
  Future<Map<String, String>> checkImageAndUserNameToUser(
      String userUid) async {
    return await CommunicateFirebase.checkImageAndUserNameToUser(userUid);
  }

  // DataBase에 저장된 obsPosts 또는 inqPosts의 whoLikeThePost 속성과 whoWriteTheCommentThePost 속성을 확인하여 가져오는 method
  Future<Map<String, List<String>>>
      checkWhoLikeThePostAndWhoWriteCommentThePost(
    ObsOrInqClassification obsOrInq,
    String postUid,
  ) async {
    return await CommunicateFirebase
        .checkWhoLikeThePostAndWhoWriteCommentThePost(obsOrInq, postUid);
  }

  // DataBase에 게시물을 delete하는 method
  Future<void> deletePost(PostModel postData) async {
    await CommunicateFirebase.deletePostData(postData);
  }

  // DataBase에 저장된 게시물(Post)의 whoLikeThePost 속성에 사용자 uid을 추가하는 method
  Future<void> addWhoLikeThePost(PostModel postData, String userUid) async {
    await CommunicateFirebase.addWhoLikeThePost(postData, userUid);
  }

  // Database에서 게시물(post)에 대한 여러 comment를 가져오는 method
  Future<Map<String, dynamic>> getCommentAndUser(PostModel postData) async {
    return await CommunicateFirebase.getCommentAndUser(postData);
  }

  // comment에 있는 사용자 Uid를 가지고 user 정보에 접근하는 method
  Future<UserModel> getUserData(String commentUserUid) async {
    Map<String, dynamic> userData =
        await CommunicateFirebase.getUserData(commentUserUid);

    // Map을 Model class로 변환하여 반환한다.
    return UserModel.fromMap(userData);
  }

  // Database에 게시물(post)의 whoWriteCommentThePost 속성에 사용자 uid를 추가하는 method
  Future<void> addWhoWriteCommentThePost(
      PostModel postData, String userUid) async {
    await CommunicateFirebase.addWhoWriteCommentThePost(postData, userUid);
  }

  // DataBase에 comment(댓글)을 추가하는 method
  Future<void> addComment(String comment, String processDate, PostModel postData) async {
    // Comment 모델 만들기
    CommentModel commentModel = CommentModel(
      content: comment,
      uploadTime: DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now()),
      whoCommentLike: [],
      belongCommentPostUid: postData.postUid,
      commentUid: UUidUtil.getUUid(),
      whoWriteUserUid: SettingsController.to.settingUser!.userUid,
      // 처리상태
      proStatus: commentPSelectedValue,
      // 장애원인 (장애 처리현황 게시물에 한함)
      causeOfDisability:
          postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
              ? commentCSelectedValue
              : CauseObsClassification.NONE,
      // 실제 처리일자 (장애 처리현황 게시물에 한함)
      actualProcessDate:
          postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
              ? processDate
              : null,
      // 실제 처리시간 (장애 처리현황 게시물에 한함)
      actualProcessTime:
          postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
              ? '${commentHSelectedValue.asText.substring(0,2)}:${commentMSelectedValue.asText.substring(0,2)}'
              : null,
    );

    // Database에 comment(댓글)을 추가한다.
    await CommunicateFirebase.setCommentData(commentModel, postData);
  }

  // // 사용자가 해당 commen에 대해서 좋아요 버튼을 클릭할 떄
  // // 서버에 존재하는 comment의 whoCommentLike 속성에 사용자 uid가 있는지 판별하는 method
  // Future<bool> checkLikeUsersFromTheComment(
  //     CommentModel comment, String userUid) async {
  //   bool isResult = await CommunicateFirebase.checkLikeUsersFromTheComment(
  //       comment, userUid);

  //   return isResult;
  // }

  // Database에 저장된 comment(댓글)의 whoCommentLike 속성에 사용자 uid를 추가한다.
  Future<void> addWhoCommentLike(
      CommentModel comment, PostModel postData) async {
    await CommunicateFirebase.addWhoCommentLike(comment, postData);
  }

  // Database에 comment을 삭제한다.
  Future<void> deleteComment(CommentModel comment, PostModel postData) async {
    await CommunicateFirebase.deleteComment(comment, postData);
  }

  // 게시물이 삭제되었는지 확인하는 method
  Future<bool> isDeletePost(
      ObsOrInqClassification obsOrInq, String postUid) async {
    // Database에서 게시물의 postUid가 있는지 없는지 확인한다.
    return await CommunicateFirebase.isDeletePost(obsOrInq, postUid);
  }

  // PostListController가 메모리에 처음 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    print('PostListController onInit() 호출');
  }

  // PostListController가 메모리에서 내리기전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    // 로그
    print('PostListController onClose() 호출');

    // 배열 clear
    obsPostData.clear();
    obsUserData.clear();

    inqPostData.clear();
    inqUserData.clear();

    // conditionTextPostDatas.clear();
    // conditionTextUserDatas.clear();

    super.onClose();
  }
}
