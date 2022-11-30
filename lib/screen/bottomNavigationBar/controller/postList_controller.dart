import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/causeObsClassification.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/comment_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/postList/keyword_post_list_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:help_desk/utils/uuid_util.dart';
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

  // PostListPage 장애/게시물 선택에서
  // 장애 처리현황을 선택했는가? 문의 처리현황을 선택했는가?
  ObsOrInqClassification selectObsOrInq =
      ObsOrInqClassification.obstacleHandlingStatus;

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

  // SpecificPostPage의 comment 처리상태를 관리하는 변수 (IT 담당자에 한해서 처리상태가 보여진다.)
  // default는 대기(WAITING) 상태이다.
  ProClassification commentPSelectedValue = ProClassification.WAITING;

  // SpecificPostPage의 comment 장애원인을 관리하는 변수 (IT 담당자 - 장애 처리현황 게시물에 한해서 장애원인이 보여진다.)
  // default는 사용자(USER)이다.
  CauseObsClassification commentCSelectedValue = CauseObsClassification.USER;

  // SpecificPostPage의 처리일자를 관리하는 변수 (IT 담당자 - 장애 처리현황 게시물에 한해서 처리일자가 보여진다.)
  String commentActualProcessDate = '';

  // SpecificPostPage의 처리시간을 관리하는 변수 (IT 담당자 - 장애 처리현황 게시물에 한해서 처리시간이 보여진다.)
  String commentActualProcessTime = '';

  // Method
  // PostListController를 쉽게 사용하도록 도와주는 method
  static PostListController get to => Get.find();

  // 장애 처리현황 게시물을 postTime 내림차순 기준으로 가져오는 method
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getObsPostData(
      UserClassification userType) async {
    return await CommunicateFirebase.getObsPostData(userType);
  }

  // 문의 처리현황 게시물을 postTime 내림차순 기준으로 가져오는 method
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getInqPostData(
      UserClassification userType) async {
    return await CommunicateFirebase.getInqPostData(userType);
  }

  // Database에서 받은 장애 처리현황 게시물을 obsPostData에 추가하는 method
  // 그리고 게시물에 대한 사용자 정보를 파악하여 obsUserData에 추가하는 method
  Future<List<PostModel>> allocObsPostDataInArray(List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) async {
    // 장애 처리현황 게시물을 담고 있는 obsPostData
    // 게시물에 대한 사용자 정보를 담고 있는 obsUserData를 clear 한다.
    obsPostData.clear();
    obsUserData.clear();

    for (var doc in allData) {
      PostModel postModel = PostModel.fromMap(doc.data());
      // 장애 처리현황에 관한 게시물을 담고 있는 obsPostData에 Model class를 추가한다.
      obsPostData.add(postModel);

      // modelData의 userUid 속성을 이용해
      // Database에서 게시물에 대한 사용자 정보를 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUserData(postModel.userUid);

      // 장애 처리현황 게시물에 대한 사용자 정보를 담고 있는 obsUserData에 element를 추가한다.
      obsUserData.add(UserModel.fromMap(userData));
    }
    return obsPostData;
  }

  // Database에서 받은 문의 처리현황 게시물을 inqPostData에 추가하는 method
  // 그리고 게시물에 대한 사용자 정보를 파악하여 inqUserData에 추가하는 method
  Future<List<PostModel>> allocInqPostDataInArray(List<QueryDocumentSnapshot<Map<String, dynamic>>> allData) async {
    // 문의 처리현황 게시물을 담고 있는 inqPostData
    // 게시물에 대한 사용자 정보를 담고 있는 inqUserData를 clear 한다.
    inqPostData.clear();
    inqUserData.clear();

    await Future.delayed(const Duration(milliseconds: 5));

    for (var doc in allData) {
      PostModel postModel = PostModel.fromMap(doc.data());
      // 문의 처리현황에 관한 게시물을 담고 있는 inqPostData에 Model class를 추가한다.
      inqPostData.add(postModel);

      // modelData의 userUid 속성을 이용해
      // Database에서 게시물에 대한 사용자 정보를 가져온다.
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
      ToastUtil.showToastMessage('키워드가 빈칸 입니다 :)');

      return false;
    }
    // PostListPage 검색창에 입력한 text가 한 글자인 경우
    else if (PostListController.to.searchTextController.text.length == 1) {
      ToastUtil.showToastMessage('두 글자 이상 입력해주세요 :)');

      return false;
    }
    // PostListPage 검색창에 입력한 text가 두 글자인 경우
    // 업데이트된 text를 가지고 KeywordPostListPage를 재랜더링 합니다.
    else {
      return true;
    }
  }

  // DataBase에 게시글 작성한 사람(User)의 image,userName,phoneNumber 속성을 확인하여 가져오는 method
  // Future<Map<String, String>> getImageAndUserNameAndPhoneNumber(
  //     String userUid) async {
  //   return await CommunicateFirebase.getImageAndUserNameAndPhoneNumber(userUid);
  // }

  // IT 담당자가 가장 최근 올린 댓글을 가져오는 method
  // Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getITUserLastComment(
  //     PostModel postData) async {
  //   return await CommunicateFirebase.getITUserLastComment(postData);
  // }

  // DataBase에 저장된 obsPosts 또는 inqPosts의 whoWriteTheCommentThePost 속성을 확인하여 가져오는 method
  // Future<List<String>> updateWhoWriteCommentThePost(
  //   ObsOrInqClassification obsOrInq,
  //   String postUid,
  // ) async {
  //   return await CommunicateFirebase.updateWhoWriteCommentThePost(
  //       obsOrInq, postUid);
  // }

  // DataBase에 게시물을 delete하는 method
  Future<void> deletePost(PostModel postData) async {
    await CommunicateFirebase.deletePostData(postData);
  }

  // Database에서 게시물(post)에 대한 여러 comment를 가져오는 method
  Future<Map<String, dynamic>> getCommentAndUser(PostModel postData) async {
    return await CommunicateFirebase.getCommentAndUser(postData);
  }

  // DataBase에 user 정보에 접근하는 method
  Future<UserModel> getUserData(String userUid) async {
    Map<String, dynamic> userData =
        await CommunicateFirebase.getUserData(userUid);

    // Map을 Model class로 변환하여 반환한다.
    return UserModel.fromMap(userData);
  }

  // DataBase에 post 정보에 접근하는 method
  Future<PostModel> getPostData(PostModel postModel) async {
    PostModel postData = await CommunicateFirebase.getPostData(postModel);

    // Map을 Model class로 변환하여 반환한다.
    return postData;
  }

  // Database에 게시물(post)의 whoWriteCommentThePost 속성에 사용자 uid를 추가하는 method
  Future<void> addWhoWriteCommentThePost(
      PostModel postData, String userUid) async {
    await CommunicateFirebase.addWhoWriteCommentThePost(postData, userUid);
  }

  // DataBase에 comment(댓글)을 추가하는 method
  Future<void> addComment(String comment, PostModel postData) async {
    // Comment 모델 만들기
    CommentModel commentModel = CommentModel(
      content: comment,
      uploadTime: DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now()),
      belongCommentPostUid: postData.postUid,
      commentUid: UUidUtil.getUUid(),
      whoWriteUserUid: SettingsController.to.settingUser!.userUid,
      // 처리상태
      proStatus: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? ProClassification.NONE
          : commentPSelectedValue,
      // 장애원인
      causeOfDisability: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? CauseObsClassification.NONE
          : postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
              ? commentCSelectedValue
              : CauseObsClassification.NONE,
      // 실제 처리일자
      actualProcessDate: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? null
          : postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
              ? PostListController.to.commentActualProcessDate
              : null,
      // 실제 처리시간
      actualProcessTime: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? null
          : postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
              ? PostListController.to.commentActualProcessTime
              : null,
    );

    // Database에 comment(댓글)을 추가한다.
    await CommunicateFirebase.setCommentData(commentModel, postData);
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

    conditionObsPostData.clear();
    conditionObsUserData.clear();

    conditionInqPostData.clear();
    conditionInqUserData.clear();

    super.onClose();
  }
}
