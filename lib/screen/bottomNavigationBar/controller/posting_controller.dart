import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/bottomNavigationBar_controller.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:help_desk/utils/uuid_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// 글쓰기 화면의 상태 변수와 메서드를 관리하는 controller 입니다.
class PostingController extends GetxController {
  // Field
  // 이미지를 담는 List
  RxList<File> imageList = <File>[].obs;

  // 제목 String
  RxString titleString = ''.obs;

  // 내용 String
  RxString contentString = ''.obs;

  // Gallery에서 image를 가져오기 위한 변수
  final ImagePicker imagePicker = ImagePicker();

  // Method
  // Controller를 더 쉽게 사용할 수 있도록 하는 get method
  static PostingController get to => Get.find();

  // Gallery에서 image를 가져와 추가하는 method
  Future<void> getImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);

    // 이미지를 정상적으로 가져올 떄 처리
    if (xFile != null) {
      File file = File(xFile.path);

      // 상태 변수 변화
      imageList.add(file);
    }
    // 이미지를 가져오지 못했을 떄 처리
    else {
      ToastUtil.showToastMessage('이미지 가져오기에 실패하였습니다 :)');
    }
  }

  // index번쨰 image를 삭제하는 method
  void deleteImage(int index) {
    // 상태 변수 변화
    imageList.removeAt(index);
  }

  // Posting 하는 method
  Future<bool> upload() async {
    // 여러 개 UploadTask와 게시물 Uuid가 저장된 map
    Map<String, dynamic> postMap = {};

    // 동시에 image에 대한 url를 요청해서, 순서대로 저장하는 List
    List<Future> imageUrlFuture = [];

    // 여러 개 imageUrl을 저장하는 List
    List<String> imageUrlList = [];

    // Validation 미통과
    if (titleString.isEmpty || contentString.isEmpty) {
      // 업로드후 상태 변수 초기화
      initPostingElement();

      // 업로드 실패 의미인 false를 반환한다.
      return false;
    }
    // Validation 통과
    else {
      // 업로드한 이미지가 0개인 경우
      if (imageList.isEmpty) {
        // 게시물 Uuid을 저장한다.
        postMap['postUUid'] = UUidUtil.getUUid();
      }

      // 업로드한 이미지가 최소 1개인 경우
      else {
        // upload한 이미지를 Firebase Storage에 저장한다.
        postMap = CommunicateFirebase.postUploadImage(
          imageList: imageList,
          userUid: AuthController.to.user.value.userUid,
        );

        // Firebase Storage에 저장된 image를 download하는 method
        // 동시에 image에 대한 url를 요청해서 시간 절약을 한다.
        for (UploadTask uploadTask
            in postMap['uploadTasks'] as List<UploadTask>) {
          imageUrlFuture.add(
            CommunicateFirebase.imageDownloadUrl(uploadTask),
          );
        }

        // 동시에 image에 대한 url를 요청한 것을 순서대로 저장한다.
        final result = await Future.wait(imageUrlFuture);

        // 여러 개 imagesUrl을 저장하는 배열에 추가한다.
        for (int i = 0; i < result.length; i++) {
          imageUrlList.add(result[i].toString());
        }
      }
      // 업로드한 이미지가 0개이든, 1개 이상이든 이하 공통 작업

      // 게시물 올린 현재 시간을 파악한다.
      DateTime currentDateTime = DateTime.now();
      // DateTime.now().add(const Duration(minutes: 4, seconds: 30));
      print('현재 시간 : $currentDateTime');

      String formatDate =
          DateFormat('yy/MM/dd - HH:mm:ss').format(currentDateTime);
      print('수정된 형식의 현재 시간 : $formatDate');

      // PostModel을 만듭니다.
      PostModel post = PostModel(
        imageList: imageUrlList,
        postTitle: titleString.toString(),
        postContent: contentString.toString(),
        userUid: AuthController.to.user.value.userUid,
        postUid: postMap['postUUid'],
        postTime: formatDate,
        whoLikeThePost: [],
        whoWriteCommentThePost: [],
      );

      // Firebase DataBase에 게시물 upload
      await CommunicateFirebase.setPostData(post, postMap['postUUid']);

      // upload method 내 변수 초기화
      postMap.clear();
      imageUrlList.clear();

      // 업로드후 상태 변수 초기화
      initPostingElement();

      // 업로드 완료 의미인 true를 반환한다.
      return true;
    }
  }

  // PostingController에서 관리하는 이미지, 글제목, 글내용을 초기화하는 method
  void initPostingElement() {
    // 업로드한 이미지 여부에 따라 로직 결정
    if (imageList.isEmpty) {
      titleString('');
      contentString('');
    } else {
      imageList.clear();
      titleString('');
      contentString('');
    }

    // 정말 상태 변수가 초기화 되었는지 확인한다.
    print('imageList : ${PostingController.to.imageList}');
    print('titleString : ${PostingController.to.titleString}');
    print('contentString : ${PostingController.to.contentString}');
  }

  // PostingController가 메모리에 처음 올라갈 떄 호출되는 method
  @override
  void onInit() {
    super.onInit();

    print('PostingController onInit() 호출되었습니다.');
  }

  // controller가 메모리에서 제거되기 전 일련의 과정을 수행하는 method
  @override
  void onClose() {
    // 로그
    print('PostingController onClose() 호출되었습니다.');

    super.onClose();
  }
}
