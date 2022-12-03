import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:image_picker/image_picker.dart';

class SettingsController extends GetxController {
  // **** 기타 설정 **** //
  // 사용자가 회원가입 절차를 거쳤는지 아닌지를 판별하는 상태 변수
  bool didSignUp = true;
  // 사용자 계정을 나타내는 인스턴스
  // AuthController의 사용자 정보를 복제했다.
  UserModel? settingUser;

  // **** 프로필 수정 페이지에서 관리하는 데이터 **** //
  // 수정한 이미지에 대한 Field
  ImagePicker imagePicker = ImagePicker();
  File? editImage;
  // 이름, 전화번호 관련된 TextFormField Validation을 위한 Field
  final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
  // 이름과 관련된 TextFormField Text를 저장하는 Field
  TextEditingController? nameTextController;
  // 전화번호와 관련된 TextFormField Text를 저장하는 Field
  TextEditingController? telTextController;

  // **** 내가 쓴 글 페이지, 내가 댓글 단 글 페이지에서 관리하는 데이터 **** //
  // whatIWrotePage, whatICommentPage 장애/게시물 선택에서
  // 장애 처리현황을 선택했는가? 문의 처리현황을 선택했는가?
  ObsOrInqClassification selectObsOrInq =
      ObsOrInqClassification.obstacleHandlingStatus;
  // 장애 처리현황과 관련해서 사용자가 쓴 게시물을 담는 배열
  List<PostModel> obsWhatIWrotePostDatas = [];
  // 장애 처리현황과 관련해서 사용자가 쓴 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> obsWhatIWroteUserDatas = [];
  // 문의 처리현황과 관련해서 사용자가 쓴 게시물을 담는 배열
  List<PostModel> inqWhatIWrotePostDatas = [];
  // 문의  처리현황과 관련해서 사용자가 쓴 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> inqWhatIWroteUserDatas = [];
  // 장애 처리현황과 관련해서 사용자가 댓글 작성한 게시물을 담는 배열
  List<PostModel> obsWhatICommentPostDatas = [];
  // 장애 처리현황과 관련해서 사용자가 댓글 작성한 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> obsWhatICommentUserDatas = [];
  // 문의 처리현황과 관련해서 사용자가 댓글 작성한 게시물을 담는 배열
  List<PostModel> inqWhatICommentPostDatas = [];
  // 문의 처리현황과 관련해서 사용자가 댓글 작성한 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> inqWhatICommentUserDatas = [];

  // Method
  // Settings를 쉽게 사용할 수 있도록 하는 method
  static SettingsController get to => Get.find();

  // 프로필 수정 페이지에서 이전 가기를 눌렀을 떄 호출되는 method
  void getBackEditProfilePage() {
    // 프로필 수정할 페이지에서 사용했던 데이터를 초기화한다.
    clearEditProfileData();

    // 이전 가기
    Get.back();
  }

  // Gallery에서 가져온 image를 File 타입 editImage에 대입하는 method
  void allocateEditImage(XFile file) {
    editImage = File(file.path);

    print('SettingsController - allocateEditImage() : 프로필 사진이 수정되었습니다.');

    // 반응형 변수를 쓰고 있지 않아서 별도로 update() 불러야 한다.
    update(['editImage']);
  }

  // 프로필이 수정되면 호출되는 method
  Future<bool> changeUserInfo() async {
    // 필요한 변수 준비
    UploadTask? updateFileEvent;
    String? imageUrl;

    // 1. 검증 작업(validation)

    // 사용자가 입력한 이름과 전화번호를 검증한다.
    bool validResult = editFormKey.currentState!.validate();

    // 이미지를 게시하지 않거나, 이름과 전화번호에 대해서 검증 실패한 경우...
    if (!(editImage != null && validResult)) {
      // Toast Message 띄우기
      ToastUtil.showToastMessage('검증을 통과하지 못했습니다.\n다시 입력해주세요');
      return false;
    }

    // 2. 테스트 용도 서버에 User 정보를 바꾼다.
    // 로딩 준비
    EasyLoading.show(
      status: '프로필 정보를\n수정하고 있습니다.',
      maskType: EasyLoadingMaskType.black,
    );

    // "프로필 수정 페이지" image를 Firebase Storage에 upload하는 method
    updateFileEvent = await CommunicateFirebase.editUploadImage(
      imageFile: editImage!,
      userUid: settingUser!.userUid.toString(),
    );

    // Firebase Storage에 저장된 image를 download하는 method
    imageUrl = await CommunicateFirebase.imageDownloadUrl(updateFileEvent);

    // Firebase Database에 업데이트 칠 UserModel 객체
    UserModel updateUser = UserModel(
      // 사용자가 일반 사용자인지 IT 담당자인지에 따라 userType을 다르게 설정한다.
      userType: settingUser!.userType == UserClassification.GENERALUSER
          ? UserClassification.GENERALUSER
          : settingUser!.userType == UserClassification.IT1USER
              ? UserClassification.IT1USER
              : UserClassification.IT2USER,
      userName: nameTextController!.text,
      image: imageUrl.toString(),
      userUid: settingUser!.userUid,
      commentNotificationPostUid: settingUser!.commentNotificationPostUid,
      phoneNumber: telTextController!.text,
    );

    // Firebase DataBase에 User 정보를 update하는 method
    await CommunicateFirebase.updateUser(updateUser);

    // 3. AuthController user에 값을 바꾼다.
    AuthController.to.user(updateUser);

    // 4. SettingsController user에 값을 바꾼다.
    settingUser = updateUser;

    // 5. 사용자가 프로필을 수정하기 전, 업로드한 게시물이 있을 경우...
    // DataBase에 게시물(obsPosts, inqPosts)에 phoneNumber 속성을 최신 상태로 update 한다.
    await CommunicateFirebase.updatePhoneNumberInPost(settingUser!);

    // 6. 초기화 작업
    clearEditProfileData();

    // 로딩 중지
    EasyLoading.dismiss();

    // settings_page로 돌아간다.
    Get.back();

    // settings_page를 재랜더링 한다.
    update(['showProfile']);

    return true;
  }

  // 프로필 수정할 페이지에서 사용했던 데이터를 초기화하는 method
  void clearEditProfileData() {
    // 이미지와 이름, 전화번호를 초기화 한다.
    editImage = null;
    nameTextController!.text = '';
    telTextController!.text = '';
  }

  // 장애 처리현황 또는 문의 처리현황 게시물을 가져오는 method
  void changePost() {
    // SettingsController의 selectObsOrInq 변수를 업데이트한다.
    if (selectObsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      selectObsOrInq = ObsOrInqClassification.inqueryHandlingStatus;
    }
    //
    else {
      selectObsOrInq = ObsOrInqClassification.obstacleHandlingStatus;
    }

    // GetBuilder를 통해 장애 처리현황 게시물 또는 문의 처리현황 게시물을 보여준다.
    SettingsController.to.update(['getObsOrInqPost']);

    // 보여주는 게시물이 장애 처리현황인지 문의 처리현황인지 보여준다.
    SettingsController.to.update(['getObsOrInqText']);
  }

  // 장애 처리현황 게시물과 관련해서 내가 작성한 글을 가져오는 method
  Future<List<PostModel>> getObsWhatIWrotePostData() async {
    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    obsWhatIWrotePostDatas.clear();
    obsWhatIWroteUserDatas.clear();

    // PostListController.to.obsPostData,
    // PostListController.to.obsUserData를
    // 짧게 명명하고자 참조변수를 설정한다.
    List<PostModel> obsPostDatas = PostListController.to.obsPostData;
    List<UserModel> obsUserDatas = PostListController.to.obsUserData;

    // 장애 처리현황 게시물과 관련해서 내가 작성한 글을 찾는다.
    for (int i = 0; i < obsPostDatas.length; i++) {
      if (obsPostDatas[i].userUid == settingUser!.userUid) {
        obsWhatIWrotePostDatas.add(obsPostDatas[i]);
        obsWhatIWroteUserDatas.add(obsUserDatas[i]);
      }
    }

    return obsWhatIWrotePostDatas;
  }

  // 문의 처리현황 게시물과 관련해서 내가 작성한 글을 가져오는 method
  Future<List<PostModel>> getInqWhatIWrotePostData() async {
    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    inqWhatIWrotePostDatas.clear();
    inqWhatIWroteUserDatas.clear();

    // PostListController.to.inqPostData,
    // PostListController.to.inqUserData를
    // 짧게 명명하고자 참조변수를 설정한다.
    List<PostModel> inqPostDatas = PostListController.to.inqPostData;
    List<UserModel> inqUserDatas = PostListController.to.inqUserData;

    // 문의 처리현황 게시물과 관련해서 내가 작성한 글을 찾는다.
    for (int i = 0; i < inqPostDatas.length; i++) {
      if (inqPostDatas[i].userUid == settingUser!.userUid) {
        inqWhatIWrotePostDatas.add(inqPostDatas[i]);
        inqWhatIWroteUserDatas.add(inqUserDatas[i]);
      }
    }

    return inqWhatIWrotePostDatas;
  }

  // 장애 처리현황 게시물과 관련해서 내가 댓글 작성한 글을 가져오는 method
  Future<List<PostModel>> getObsWhatICommentPostData() async {
    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    obsWhatICommentPostDatas.clear();
    obsWhatICommentUserDatas.clear();

    // PostListController.to.obsPostData,
    // PostListController.to.obsUserData를
    // 짧게 명명하고자 참조변수를 설정한다.
    List<PostModel> obsPostDatas = PostListController.to.obsPostData;
    List<UserModel> obsUserDatas = PostListController.to.obsUserData;

    // 장애 처리현황 게시물과 관련해서 내가 댓글 작성한 글을 찾는다.
    for (int i = 0; i < obsPostDatas.length; i++) {
      if (obsPostDatas[i]
          .whoWriteCommentThePost
          .contains(settingUser!.userUid)) {
        obsWhatICommentPostDatas.add(obsPostDatas[i]);
        obsWhatICommentUserDatas.add(obsUserDatas[i]);
      }
    }

    return obsWhatICommentPostDatas;
  }

  // 문의 처리현황 게시물과 관련해서 내가 댓글 작성한 글을 가져오는 method
  Future<List<PostModel>> getInqWhatICommentPostData() async {
    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    inqWhatICommentPostDatas.clear();
    inqWhatICommentUserDatas.clear();

    // PostListController.to.inqPostData,
    // PostListController.to.inqUserData를
    // 짧게 명명하고자 참조변수를 설정한다.
    List<PostModel> inqPostDatas = PostListController.to.inqPostData;
    List<UserModel> inqUserDatas = PostListController.to.inqUserData;

    // 장애 처리현황 게시물과 관련해서 내가 작성한 글을 찾는다.
    for (int i = 0; i < inqPostDatas.length; i++) {
      if (inqPostDatas[i]
          .whoWriteCommentThePost
          .contains(settingUser!.userUid)) {
        inqWhatICommentPostDatas.add(inqPostDatas[i]);
        inqWhatICommentUserDatas.add(inqUserDatas[i]);
      }
    }

    return inqWhatICommentPostDatas;
  }

  // SettingsController가 메모리에 처음 올라갔을 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    print('SettingsController - onInit() 호출');

    // AuthController의 사용자 정보를 복제한다.
    settingUser = AuthController.to.user.value.copyWith();

    nameTextController = TextEditingController();
    telTextController = TextEditingController();
  }

  // SettingsController가 메모리에 제거되기 전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    print('settings_controller - onClose() 호출');

    // 변수 초기화 및 clear
    settingUser = null;
    editImage = null;

    obsWhatIWrotePostDatas.clear();
    obsWhatIWroteUserDatas.clear();

    inqWhatICommentPostDatas.clear();
    inqWhatICommentUserDatas.clear();

    obsWhatICommentPostDatas.clear();
    obsWhatICommentUserDatas.clear();

    inqWhatICommentPostDatas.clear();
    inqWhatICommentUserDatas.clear();

    super.onClose();
  }
}
