import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/departmentClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:image_picker/image_picker.dart';

class SettingsController extends GetxController {
  /* 사용자가 회원가입 절차를 거쳤는지 아닌지 판단, 사용자 계정 정보를 담는 데이터  
     (21 ~ 23줄) */

  // 사용자가 회원가입 절차를 거쳤는지 아닌지를 판별하는 상태 변수
  bool didSignUp = true;
  // 사용자 계정을 나타내는 인스턴스  AuthController의 사용자 정보를 복제했다.
  UserModel? settingUser;

  /* EditProfilePage에서 활용되는 데이터
     (28 ~ 40줄) */

  // 수정한 이미지와 관련된 변수 
  final ImagePicker imagePicker = ImagePicker();
  File? editImage;
  // 이름, 전화번호 관련된 TextFormField Validation을 위한 Field
  final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
  // 이름과 관련된 TextFormField Text를 저장하는 Field
  TextEditingController? nameTextController;
  /* 부서명
     프로필 수정할 때 부서명은 ETHICALMANAGEMENT(윤리경영실)이 default로 보이게 된다. */
  DepartmentClassification departmentClassification =
      DepartmentClassification.ETHICALMANAGEMENT;
  // 전화번호와 관련된 TextFormField Text를 저장하는 Field
  TextEditingController? telTextController;

  /* whatIWrotePage, whatICommentPage에서 관리하는 데이터 
     (45 ~ 52줄) */

  // 사용자가 작성한 IT 요청건 게시물을 담는 배열
  List<PostModel> whatIWroteITRequestPosts = [];
  // 사용자가 작성한 IT 요청건 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> whatIWroteITRequestUsers = [];
  // 사용자가 댓글 작성한 IT 요청건 게시물을 담는 배열
  List<PostModel> whatICommentITRequestPosts = [];
  // 사용자가 댓글 작성한 IT 요청건 게시물에 대한 사용자 정보를 담는 배열
  List<UserModel> whatICommentITRequestUsers = [];

  // SettingsController를 쉽게 사용할 수 있도록 하는 method
  static SettingsController get to => Get.find();

  // EditProfilePage 에서 이전 가기를 눌렀을 떄 호출되는 method
  Future<void> getBackEditProfilePage() async {
    // 키보드 내리기
    FocusManager.instance.primaryFocus?.unfocus();

    // 프로필 수정할 페이지에서 사용했던 데이터를 초기화한다.
    clearEditProfileData();

    await Future.delayed(const Duration(milliseconds: 30));

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
    /* 프로필 수정 페이지에서 이미지와 관련된 변수 
       (76 ~ 77줄) */
    UploadTask? updateFileEvent;
    String? imageUrl;

    /* 프로필을 수정할 수 있는지 없는지에 따른 검증 작업(validation)  
       (82번쨰 줄 ~ 90번쨰 줄) */

    // 사용자가 입력한 이름과 전화번호를 검증한다.
    bool validResult = editFormKey.currentState!.validate();

    // 프로필 수정 페이지에서 필수 입력값인 이름과 전화번호에 대해서 검증 실패한 경우...
    if (validResult == false) {
      // Toast Message 띄우기
      ToastUtil.showToastMessage('검증을 통과하지 못했습니다.\n다시 입력해주세요');
      return false;
    }

    /* DataBase에 사용자 정보(Users) 정보를 바꾸고 로컬에도 사용자 정보를 변경한다. 
          (92번째 줄 ~ 128번쨰 줄) */

    // 로딩 준비
    EasyLoading.show(
      status: '프로필 정보를\n수정하고 있습니다.',
      maskType: EasyLoadingMaskType.black,
    );

    // 프로필 수정 페이지에서 이미지를 수정했을 떄 관한 이하 if문
    if (editImage != null) {
      // EditProfilePage에 있는 image를 Firebase Storage에 upload하는 method
      updateFileEvent = await CommunicateFirebase.editProfilePageImageToStorage(
        imageFile: editImage!,
        image: settingUser!.image,
        userUid: settingUser!.userUid.toString(),
      );

      // Firebase Storage에 저장된 image를 download하는 method
      imageUrl = await CommunicateFirebase.imageDownloadUrl(updateFileEvent);
    }

    // Database에 업데이트 칠 UserModel 객체
    UserModel updateUser = UserModel(
      // 사용자가 일반 사용자인지 IT 담당자인지에 따라 userType을 다르게 설정한다.
      userType: settingUser!.userType == UserClassification.GENERALUSER
          ? UserClassification.GENERALUSER
          : settingUser!.userType == UserClassification.IT1USER
              ? UserClassification.IT1USER
              : UserClassification.IT2USER,
      department: departmentClassification,
      userName: nameTextController!.text,
      /* 프로필 수정 페이지에서 사용자가 이미지를 변경했다면 변경한 이미지로 들어간다.
         만약 변경하지 않았다면 원래대로 들어간다. */
      image: editImage == null ? settingUser!.image : imageUrl.toString(),
      userUid: settingUser!.userUid,
      commentNotificationPostUid: settingUser!.commentNotificationPostUid,
      phoneNumber: telTextController!.text,
    );

    // Firebase DataBase에 User 정보를 update하는 method
    await CommunicateFirebase.updateUser(updateUser);

    /*  AuthController user에 값을 바꾼다.
        SettingsController user에 값을 바꾼다. */
    AuthController.to.user(updateUser);
    settingUser = updateUser;

    /* 3. 프로필 수정 페이지에서 사용자가 전화번호를 변경했다면
          DataBase에 IT 요청건 게시물(itRequestPosts)에 phoneNumber 속성을 최신 상태로 update 한다. */
    await CommunicateFirebase.updatePhoneNumberInPost(settingUser!);

    // EditProfilePage에서 사용했던 데이터를 초기화한다.
    clearEditProfileData();

    // 로딩 중지
    EasyLoading.dismiss();

    // settings_page로 돌아간다.
    Get.back();

    // settings_page를 재랜더링 한다.
    update(['showProfile']);

    return true;
  }

  // EditProfilePage에서 사용했던 데이터를 초기화하는 method
  void clearEditProfileData() {
    // 이미지와 이름, 전화번호를 초기화 한다.
    editImage = null;
    nameTextController!.text = '';
    telTextController!.text = '';

    // 프로필 수정할 떄 부서명을 다시 ETHICALMANAGEMENT (윤리경영실)로 설정한다.
    departmentClassification = DepartmentClassification.ETHICALMANAGEMENT;
  }

  // 내가 작성한 IT 요청건 게시물을 가져오는 method
  Future<List<PostModel>> getWhatIWroteITRequestPosts() async {
    // SettingsController의 whatIWroteITRequestPosts와 whatIWrotetITRequestUsers를 clear한다.
    whatIWroteITRequestPosts.clear();
    whatIWroteITRequestUsers.clear();

    /* PostListController.to.itRequestPosts
       PostListController.to.itRequestUser를 간단히 명명하고자 참조변수를 설정한다. */
    List<PostModel> itRequestPosts = PostListController.to.itRequestPosts;
    List<UserModel> itRequestUsers = PostListController.to.itRequestUsers;

    // for문을 통해 내가 작성한 IT 요청건 게시물을 찾는다.
    for (int i = 0; i < itRequestPosts.length; i++) {
      if (itRequestPosts[i].userUid == settingUser!.userUid) {
        whatIWroteITRequestPosts.add(itRequestPosts[i]);
        whatIWroteITRequestUsers.add(itRequestUsers[i]);
      }
    }

    return whatIWroteITRequestPosts;
  }

  // 장애 처리현황 게시물과 관련해서 내가 댓글 작성한 글을 가져오는 method
  Future<List<PostModel>> getWhatICommentITRequestPosts() async {
    // SettingsController의 whatICommentITRequestPosts와 whatICommentITRequestUsers를 clear한다.
    whatICommentITRequestPosts.clear();
    whatICommentITRequestUsers.clear();

    /* PostListController.to.itRequestPosts
       PostListController.to.itRequestUser를 간단히 명명하고자 참조변수를 설정한다. */
    List<PostModel> itRequestPosts = PostListController.to.itRequestPosts;
    List<UserModel> itRequestUsers = PostListController.to.itRequestUsers;

    // for문을 통해 내가 댓글 작성한 IT 요청건 게시물을 찾는다.
    for (int i = 0; i < itRequestPosts.length; i++) {
      if (itRequestPosts[i]
          .whoWriteCommentThePost
          .contains(settingUser!.userUid)) {
        whatICommentITRequestPosts.add(itRequestPosts[i]);
        whatICommentITRequestUsers.add(itRequestUsers[i]);
      }
    }

    return whatICommentITRequestPosts;
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

    whatIWroteITRequestPosts.clear();
    whatIWroteITRequestUsers.clear();
    whatICommentITRequestPosts.clear();
    whatICommentITRequestUsers.clear();

    super.onClose();
  }
}
