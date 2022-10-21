import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/settings/what_i_wrote_page.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:image_picker/image_picker.dart';

class SettingsController extends GetxController with WidgetsBindingObserver {
  // Field
  // 사용자가 회원가입 절차를 거쳤는지 아닌지를 판별하는 상태 변수
  bool didSignUp = true;

  // 사용자 계정을 나타내는 인스턴스
  // AuthController - User의 image, description, userName, userUid를 복제했다.
  UserModel? settingUser;

  // 수정할 이미지에 대한 Field
  ImagePicker? imagePicker;
  File? editImage;

  // 수정할 이름, 설명에 대한 Field
  String editName = '';
  String editDescription = '';

  // 사용자가 작성한 게시글을 담는 배열
  List<PostModel> whatIWrotePostDatas = [];
  // 사용자가 작성한 게시글에 관한 사용자 정보를 담는 배열
  List<UserModel> whatIWroteUserDatas = [];

  // 사용자가 댓글 작성한 게시글을 담는 배열
  List<PostModel> whatICommentPostDatas = [];
  // 사용자가 댓글 작성한 게시글에 관한 사용자 정보를 담는 배열
  List<UserModel> whatICommentUserDatas = [];

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
    update();
  }

  // 프로필이 수정되면 호출되는 method
  Future<bool> changeUserInfo() async {
    // 필요한 변수 준비
    UploadTask? updateFileEvent;
    String? imageUrl;

    // 로딩 준비
    EasyLoading.show(
        status: '프로필 정보를\n 수정하고 있습니다.', maskType: EasyLoadingMaskType.black);

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
      userName: editName == '' ? settingUser!.userName : editName,
      description:
          editDescription == '' ? settingUser!.description : editDescription,
      image: imageUrl == null ? settingUser!.image : imageUrl.toString(),
      userUid: settingUser!.userUid,
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

    // 이전 가기로 가기
    Get.back();

    // Settings Page - GetBuilder을 호출하기 위해 update()를 부른다.
    update();

    return true;
  }

  // 사용자가 업로드한 게시글을 가져오는 method
  Future<List<PostModel>> getWhatIWrotePostData() async {
    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    whatIWrotePostDatas.clear();
    whatIWroteUserDatas.clear();

    // PostListController.to.postDatas를 짧게 명명하고자 참조변수를 설정한다.
    List<PostModel> postDatas = PostListController.to.postDatas;
    List<UserModel> userDatas = PostListController.to.userDatas;

    // 사용자가 업로드한 게시물을 가져온다.
    for (int i = 0; i < postDatas.length; i++) {
      // 게시물의 userUid가 현 계정의 userUid와 같은지 확인한다.
      if (postDatas[i].userUid == settingUser!.userUid) {
        // whatIWrotePostDatas와 whatIWroteUserDatas 배열에 PostData와 UserData를 추가한다.
        whatIWrotePostDatas.add(postDatas[i]);
        whatIWroteUserDatas.add(userDatas[i]);
      }
    }

    return whatIWrotePostDatas;
  }

  // 사용자가 댓글 작성한 게시물을 가져오는 method
  Future<List<PostModel>> getWhatICommentPostData() async {
    // PostData들과 UserData들을 담고 있는 배열을 clear한다.
    whatICommentPostDatas.clear();
    whatICommentUserDatas.clear();

    // PostListController.to.postDatas를 짧게 명명하고자 참조변수를 설정한다.
    List<PostModel> postDatas = PostListController.to.postDatas;
    List<UserModel> userDatas = PostListController.to.userDatas;

    // 사용자가 댓글 작성한 게시물을 가져온다.
    for (int i = 0; i < postDatas.length; i++) {
      // 해당 게시물의 whoWriteCommentThePost Property에 userUid가 있는지 확인한다.
      if (postDatas[i].whoWriteCommentThePost.contains(settingUser!.userUid)) {
        // whatICommentPostDatas와 whatICommentUserDatas 배열에 PostData와 UserData를 추가한다.
        whatICommentPostDatas.add(postDatas[i]);
        whatICommentUserDatas.add(userDatas[i]);
      }
    }

    return whatICommentPostDatas;
  }

  // SettingsController가 메모리에 처음 올라갔을 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    print('settings_controller - onInit() 호출');

    // AuthController - User를 복제한다.
    settingUser = AuthController.to.user.value.copyWith();

    // ImagePicker에 값을 대입한다.
    imagePicker = ImagePicker();
  }

  // SettingsController가 메모리에 제거되기 전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    print('settings_controller - onClose() 호출');

    settingUser = null;

    imagePicker = null;

    super.onClose();
  }
}
