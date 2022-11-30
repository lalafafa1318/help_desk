import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:help_desk/utils/uuid_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// 글쓰기 화면의 상태 변수와 메서드를 관리하는 controller 입니다.
class PostingController extends GetxController {
  // Field

  // 장애 처리현황, 문의 처리현황 DropDown에서
  // 업로드 하려는 게시물이 장애 처리현황 쪽인지 문의 처리현황인지 판별하는 변수
  ObsOrInqClassification oSelectedValue =
      ObsOrInqClassification.obstacleHandlingStatus;

  // 시스템 분류 코드 DropDown에서 무엇을 Tab했는가 나타내는 변수
  SysClassification sSelectedValue = SysClassification.WICS;

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

  // 스마트폰 카메라 또는 갤러리를 선택하는 method
  Future<void> getImage(BuildContext context) async {
    // 카메라 또는 갤러리에서 이미지를 선택할 떄 대입하는 변수
    XFile? xFile;
    File? file;

    // 이미지를 가져올 떄
    // 스마트폰 카메라를 가져올지, 갤러리를 가져올지 선택하는 dialog를 띄운다.
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '이미지 가져오기',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('이미지를 가져오려면\n카메라 또는 갤러리를 선택하세요'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 카메라를 통해 이미지를 가져온다.
                TextButton(
                  child: const Text('카메라'),
                  onPressed: () async {
                    Get.back();

                    xFile = await imagePicker.pickImage(
                        source: ImageSource.camera, imageQuality: 100);

                    // 이미지를 정상적으로 가져올 떄 처리
                    if (xFile != null) {
                      file = File(xFile!.path);

                      // 상태 변수 변화
                      imageList.add(file!);
                    }
                    // 이미지를 가져오지 못했을 떄 처리
                    else {
                      ToastUtil.showToastMessage('이미지 가져오기에 실패하였습니다 :)');
                    }
                  },
                ),
                // 갤러리를 통해 이미지를 가져온다.
                TextButton(
                  child: const Text('갤러리'),
                  onPressed: () async {
                    Get.back();

                    xFile = await imagePicker.pickImage(
                        source: ImageSource.gallery, imageQuality: 100);

                    // 이미지를 정상적으로 가져올 떄 처리
                    if (xFile != null) {
                      file = File(xFile!.path);

                      // 상태 변수 변화
                      imageList.add(file!);
                    }
                    // 이미지를 가져오지 못했을 떄 처리
                    else {
                      ToastUtil.showToastMessage('이미지 가져오기에 실패하였습니다 :)');
                    }
                  },
                ),
              ],
            )
          ],
        );
      },
    );
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

    // 제목을 입력하지 않았거나
    // 내용을 입력하지 않았으면
    // 게시물에 대한 upload validation을 통과하지 못한다.
    if (titleString.isEmpty || contentString.isEmpty) {
      // 그냥 찍어놓은 로그
      print('게시물 업로드 Validation 미통과');

      // PostingController에 있는 상태 변수를 초기화 한다.
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
        // 게시물이 장애 처리현황인가 문의 처리현황인가를 구별해
        // Firebase Storage에 이미지를 저장하는 method
        postMap = CommunicateFirebase.postUploadImage(
          imageList: imageList,
          obsOrInq: oSelectedValue,
          userUid: AuthController.to.user.value.userUid,
        );

        // Firebase Storage에 저장된 image를 download하는 method
        // 동시에 image에 대한 url를 요청해서 시간 절약을 한다.
        for (UploadTask uploadTask
            in postMap['uploadTasks'] as List<UploadTask>) {
          imageUrlFuture.add(CommunicateFirebase.imageDownloadUrl(uploadTask));
        }

        // 동시에 image에 대한 url를 요청한 것을 순서대로 저장한다.
        final result = await Future.wait(imageUrlFuture);

        // 여러 개 imagesUrl을 저장하는 배열에 추가한다.
        for (int i = 0; i < result.length; i++) {
          imageUrlList.add(result[i].toString());
        }
      }

      // 업로드한 이미지가 0개이든, 1개 이상이든 이하 공통 작업
      print('게시물 업로드 Validation 통과');

      // 게시물 올린 시간을 측정한다.
      String formatDate =
          DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now());

      // PostModel을 생성한다.
      PostModel post = PostModel(
        obsOrInq: oSelectedValue,
        sysClassficationCode: sSelectedValue,
        imageList: imageUrlList,
        postTitle: titleString.toString(),
        postContent: contentString.toString(),
        phoneNumber: AuthController.to.user.value.phoneNumber,
        // 사용자가 게시물을 올릴 떄 처리상태는 WAITING(대기)이다.
        proStatus: ProClassification.WAITING,
        userUid: AuthController.to.user.value.userUid,
        postUid: postMap['postUUid'],
        postTime: formatDate,
        whoWriteCommentThePost: [],
      );

      // Firebase DataBase에 게시물 upload
      await CommunicateFirebase.setPostData(post, postMap['postUUid']);

      // upload method 내 변수 clear
      postMap.clear();
      imageUrlList.clear();

      // 게시물 업로드 완료 후 
      // PostingController에서 관리되고 있는 상태 변수를 초기화하거나 clear한다.
      initPostingElement();

      // 업로드 완료 의미인 true를 반환한다.
      return true;
    }
  }

  // PostingController에 관리되고 있는 상태 변수 초기화 하는 method
  void initPostingElement() {
    // PostingController에 관리되고 있는 상태 변수를 초기화 한다.
    oSelectedValue = ObsOrInqClassification.obstacleHandlingStatus;
    sSelectedValue = SysClassification.WICS;

    // PostingController에서 쓰이는 상태 변수를 clear한다.
    imageList.clear();
    titleString('');
    contentString('');
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
