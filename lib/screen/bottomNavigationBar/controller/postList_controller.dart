import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/causeObsClassification.dart';
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
  /* PostListPage와 KeywordPostListPage에서 활용되는 Field */

  // 사용자가 PostListPage나 KeywordPostListPage의 검색창에 입력한 text를 control한다.
  TextEditingController searchTextController = TextEditingController();
  // PostListPage, KeywordPostListPage 시스템 분류 코드 DropDown에서 무엇을 Tab했는가 나타내는 변수
  SysClassification sSelectedValue = SysClassification.ALL;
  // PostListPage , KeywordPostListPage 처리상태 분류 코드 DropDown에서 무엇을 Tab했는가 나타내는 변수
  ProClassification pSelectedValue = ProClassification.ALL;
  // IT 요청건 게시물을 담는 배열
  List<PostModel> itRequestPosts = [];
  // IT 요청건 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> itRequestUsers = [];
  // 검색창에서 조건에 맞는 IT 요청건 게시물을 담는 배열
  List<PostModel> keywordITRequestPosts = [];
  // 검색창에서 조건에 맞는 IT 요청건 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> keywordITRequestUsers = [];

  /* SpecificPostPage에서 할용되는 Field 입니다. */

  // 사용자가 입력한 댓글과 대댓글을 control 하는 Field
  TextEditingController answerInformationInputTextController = TextEditingController();
  // SpecificPostPage의 답변 정보 입력의 처리상태를 관리하는 변수 (IT 담당자에 한해서 답변 정보를 입력할 떄 처리상태가 보여진다.)
  ProClassification answerInformationInputPSelectedValue = ProClassification.WAITING;
  // SpecificPostPage의 comment 장애원인을 관리하는 변수 (IT 담당자에 한해서 답변 정보를 입력할 떄 장애원인이 보여진다.)
  CauseObsClassification answerInformationInputCSelectedValue = CauseObsClassification.USER;
  // SpecificPostPage의 처리일자를 관리하는 변수 (IT 담당자에 한해서 답변 정보를 입력할 떄 처리일자가 보여진다.)
  String answerInformationInputActualProcessDate = '';
  // SpecificPostPage의 처리시간을 관리하는 변수 (IT 담당자에 한해서 답변 정보를 입력할 떄 처리시간이 보여진다.)
  String answerInformationInputActualProcessTime = '';

  // Method
  // PostListController를 쉽게 사용하도록 도와주는 method
  static PostListController get to => Get.find();

  // DataBase에 존재하는 IT 요청건 게시물의 postTime 속성을 내림차순 기준으로 비교하여 배열로 가져오는 method
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getITRequestPosts(UserClassification userType) async {
    return await CommunicateFirebase.getITRequestPosts(userType);
  }

  // snapshot.data!로 받은 IT 요청건 게시물을 PostListController의 itRequestPosts, itRequestUsers에 대입하는 method
  Future<List<PostModel>> allocITRequestPostsAndUsers(List<QueryDocumentSnapshot<Map<String, dynamic>>> ultimateData) async {
    // IT 요청건 게시물과 사용자 정보를 담는 배열을 clear한다.
    itRequestPosts.clear();
    itRequestUsers.clear();

    for (var doc in ultimateData) {
      // 하나 하나의 게시물을 일반 클래스 형식으로 전환한다.
      PostModel postModel = PostModel.fromMap(doc.data());

      // IT 요청건의 게시물을 담고 있는 itReqeustPosts에 일반 클래스 형식의 postModel를 추가한다.
      itRequestPosts.add(postModel);

      // postModel의 userUid 속성을 이용해 Database에서 IT 요청건 게시물에 대한 사용자 정보를 가져온다.
      Map<String, dynamic> userData =
          await CommunicateFirebase.getUser(postModel.userUid);

      // IT 요청건 게시물에 대한 사용자 정보를 담고 있는 itRequestUsers에 사용자 정보를 추가한다.
      itRequestUsers.add(UserModel.fromMap(userData));
    }
    return itRequestPosts;
  }

  // KeywordPostListPage에서 조건에 맞는 IT 요청건 게시물을 가져오는 method
  Future<List<PostModel>> getConditionITRequestPosts() async {
    // searchTextController.text로 길게 쓰기 싫어서 keyword로 간단히 명명한다.
    String keyword = searchTextController.text;

    // 1차 검증을 확인하는 변수
    bool isFirstVerified = false;

    // PostListController의 keywordITRequestPosts, keywordITRequestUsers를 clear한다.
    keywordITRequestPosts.clear();
    keywordITRequestUsers.clear();

    // for문을 통해 조건에 맞는 IT 요청건 게시물을 탐색한다.
    for (int i = 0; i < itRequestPosts.length; i++) {
      /* 1차 검증
         DropdownMenu에서 선택한 시스템 분류 코드가 ALL이고 처리상태 분류 코드도 ALL인 경우 */
      if (sSelectedValue == SysClassification.ALL &&
          pSelectedValue == ProClassification.ALL) {
        isFirstVerified = true;
      }

      /* 1차 검증
         DropdownMenu에서 선택한 시스템 분류 코드가 ALL이나 처리상태 분류 코드가 ALL이 아닌 경우 */
      else if (sSelectedValue == SysClassification.ALL &&
          pSelectedValue != ProClassification.ALL) {
        /*  DropDownMenu에서 선택한 처리상태 분류 코드와
            IT 요청건 게시물의 처리상태 분류 코드가 일치하는지 확인한다. */
        pSelectedValue == itRequestPosts[i].proStatus
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      /* 1차 검증
        DropdownMenu에서 선택한 시스템 분류 코드가 ALL이 아니나 처리상태 분류 코드가 ALL인 경우 */
      else if (sSelectedValue != SysClassification.ALL &&
          pSelectedValue == ProClassification.ALL) {
        sSelectedValue == itRequestPosts[i].sysClassficationCode
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      // 1차 검증
      // DropdownMenu에서 선택한 시스템 분류 코드와 처리상태 분류 코드가 모두 ALL이 아닌 경우
      else {
        (sSelectedValue == itRequestPosts[i].sysClassficationCode &&
                pSelectedValue == itRequestPosts[i].proStatus)
            ? isFirstVerified = true
            : isFirstVerified = false;
      }

      /* 2차 검증
         입력한 kewywordText가 글 제목, 설명 그리고 작성자 중에 포함되는 것이 있는지 확인한다. */
      if (isFirstVerified == true &&
          (itRequestPosts[i].postTitle.contains(keyword) ||
              itRequestPosts[i].postContent.contains(keyword) ||
              itRequestUsers[i].userName.contains(keyword))) {
        // 1차 검증과 2차 검증을 모두 통과한다면 비로소 kwywordITRequestPosts와 keywordITRequestUsers에 element를 추가한다.
        keywordITRequestPosts.add(itRequestPosts[i]);
        keywordITRequestUsers.add(itRequestUsers[i]);
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    return keywordITRequestPosts;
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
    // PostListPage 검색창에 입력한 text가 두 글자 이상인 경우 KeywordPostListPage로 Routing 한다.
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

  // DataBase에 IT 요청건 게시물을 delete하는 method
  Future<void> deletePost(PostModel postData) async {
    await CommunicateFirebase.deletePost(postData);
  }

  // Database에서 IT 요청건 게시물(itRequestPosts)에 대한 여러 comment를 가져오는 method
  Future<Map<String, dynamic>> getComments(PostModel postData) async {
    return await CommunicateFirebase.getComments(postData);
  }

  // DataBase에 사용자 정보(Users) 정보에 접근하는 method
  Future<UserModel> getUser(String userUid) async {
    Map<String, dynamic> userData =
        await CommunicateFirebase.getUser(userUid);

    // Map을 일반 클래스 형식으로 변환하여 반환한다.
    return UserModel.fromMap(userData);
  }

  // DataBase에 게시물 정보(itRequestPosts)에 접근하는 method
  Future<PostModel> getPost(PostModel postModel) async {
    PostModel postData = await CommunicateFirebase.getPost(postModel);

    // Map을 Model class로 변환하여 반환한다.
    return postData;
  }

  // Database에 IT 요청건 게시물(itRequestPosts)의 whoWriteCommentThePost 속성에 사용자 uid를 추가하는 method
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
          : answerInformationInputPSelectedValue,

      // 장애원인
      causeOfDisability: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? CauseObsClassification.NONE
          : answerInformationInputCSelectedValue,

      // 실제 처리일자
      actualProcessDate: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? null
          : PostListController.to.answerInformationInputActualProcessDate,

      // 실제 처리시간
      actualProcessTime: SettingsController.to.settingUser!.userType ==
              UserClassification.GENERALUSER
          ? null
          : PostListController.to.answerInformationInputActualProcessTime,
    );

    // Database에 comment(댓글)을 추가한다.
    await CommunicateFirebase.setComment(commentModel, postData);
  }

  // Database에 comment을 삭제한다.
  Future<void> deleteComment(CommentModel comment, PostModel postData) async {
    await CommunicateFirebase.deleteComment(comment, postData);
  }

  // 게시물이 삭제되었는지 확인하는 method
  Future<bool> isDeletePost(String postUid) async {
    // Database에서 게시물의 postUid가 있는지 없는지 확인한다.
    return await CommunicateFirebase.isDeletePost(postUid);
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
    itRequestPosts.clear();
    itRequestUsers.clear();

    keywordITRequestPosts.clear();
    keywordITRequestUsers.clear();

    super.onClose();
  }
}
