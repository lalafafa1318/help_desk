import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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
  // Field
  // 사용자가 회원가입 절차를 거쳤는지 아닌지를 판별하는 상태 변수
  bool didSignUp = true;

  // 사용자 계정을 나타내는 인스턴스
  // AuthController의 사용자 정보를 복제했다.
  UserModel? settingUser;

  // 수정할 이미지에 대한 Field
  ImagePicker? imagePicker;
  File? editImage;

  // 수정할 이름, 설명에 대한 Field
  String editName = '';
  String editDescription = '';

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
    // 사용자가 image를 수정했을 떄
    if (editImage != null) {
      editImage = null;

      print('editImage : ${editImage}');
    }
    // 사용자가 name을 수정했을 떄
    if (editName != '') {
      editName = '';

      print('editName : ${editName}');
    }
    // 사용자가 description을 수정했을 떄
    if (editDescription != '') {
      editDescription = '';

      print('editDescription : ${editDescription}');
    }

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

    // 로딩 준비
    EasyLoading.show(
      status: '프로필 정보를\n 수정하고 있습니다.',
      maskType: EasyLoadingMaskType.black,
    );

    // 1. 검증 작업(validation)

    // 이름 정규표현식이 적합한 경우
    if (editName.contains(RegExp(r'^[가-힣]{2,4}$'))) {
      // 2.3.4 처리
      ToastUtil.showToastMessage('검증성공');
    }
    // 이름 정규표현식에 적합하지 않은 경우
    else {
      // 사용자가 이름 바꿀 의사가 있었으나 정규표현식에 맞지 않은 경우
      if (editName != '') {
        // 로딩 중지
        EasyLoading.dismiss();

        // 다시 프로필 수정 페이지로 유도
        ToastUtil.showToastMessage('검증 실패');
        return false;
      }

      // 사용자가 이름 바꿀 의사가 없고, 최소 이미지 또는 Description 중에서 수정했을 경우
      else if (editImage != null || editDescription != '') {
        // 2.3.4 처리
        ToastUtil.showToastMessage('검증 성공');
      }

      // 사용자가 3가지 모두 터치하지 않고 버튼을 누를 경우
      else {
        // 로딩 중지
        EasyLoading.dismiss();

        // 다시 프로필 수정 페이지로 유도
        ToastUtil.showToastMessage('검증 실패');
        return false;
      }
    }

    // 2. 테스트 용도 서버에 User 정보를 바꾼다.

    // 사용자가 이미지를 Update 친 경우
    // "프로필 수정 페이지" image를 Firebase Storage에 upload하는 method
    if (editImage != null) {
      updateFileEvent = await CommunicateFirebase.editUploadImage(
        imageFile: editImage!,
        userUid: settingUser!.userUid.toString(),
      );

      // Firebase Storage에 저장된 image를 download하는 method
      imageUrl = await CommunicateFirebase.imageDownloadUrl(updateFileEvent);
    }

    // Firebase Database에 업데이트 칠 UserModel 객체
    UserModel updateUser = UserModel(
      // 사용자가 일반 사용자인지 IT 담당자인지에 따라 userType을 다르게 설정한다.
      userType: settingUser!.userType == UserClassification.GENERALUSER
          ? UserClassification.GENERALUSER
          : UserClassification.ITUSER,
      userName: editName == '' ? settingUser!.userName : editName,
      image: imageUrl == null ? settingUser!.image : imageUrl.toString(),
      userUid: settingUser!.userUid,
      notiPost: settingUser!.notiPost,
      phoneNumber: settingUser!.phoneNumber,
    );

    // Firebase DataBase에 User 정보를 update하는 method
    await CommunicateFirebase.updateUserData(updateUser);

    // 3. AuthController user에 값을 바꾼다.
    AuthController.to.user(updateUser);

    // 4. SettingsController user에 값을 바꾼다.
    settingUser = updateUser;

    // 5. 후처리
    editImage = null;
    editName = '';
    editDescription = '';

    // 로딩 중지
    EasyLoading.dismiss();

    // settings_page로 돌아간다.
    Get.back();

    // settings_page를 재랜더링 한다.
    update(['showProfile']);

    return true;
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

    // AuthController - User를 복제한다.
    settingUser = AuthController.to.user.value.copyWith();

    // ImagePicker에 값을 대입한다.
    imagePicker = ImagePicker();
  }

  // SettingsController가 메모리에 제거되기 전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    print('settings_controller - onClose() 호출');

    // 변수 초기화
    settingUser = null;

    imagePicker = null;
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
