// 프로필 수정하는 class
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/border/gf_border.dart';
import 'package:getwidget/types/gf_border_type.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/utils/toast_util.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  // Image + 프로필 사진 변경하는 Button을 관리하는 Widget
  Widget imageBox() {
    return Container(
      margin: EdgeInsets.only(top: 40.h),
      child: Column(
        children: [
          // Image를 보여준다.
          GetBuilder<SettingsController>(
            id: 'editImage',
            builder: (controller) {
              return SizedBox(
                width: 125.w,
                height: 125.h,
                child: DottedBorder(
                  strokeWidth: 2,
                  color: Colors.grey,
                  dashPattern: const [5, 3],
                  borderType: BorderType.RRect,
                  radius: Radius.circular(10.r),

                  // 첫번쨰는 Network를 통해 이미지를 보여주고
                  // 다음부터는 스마트폰 갤러리를 통해 이미지를 보여준다.
                  child: controller.editImage == null
                      ? getNetworkImage()
                      : getGalleryImage(150.w, 150.h),
                ),
              );
            },
          ),

          SizedBox(height: 20.h),

          // 프로필 사진 변경하는 Button 입니다.
          ElevatedButton(
            onPressed: () async {
              XFile? xFile = await SettingsController.to.imagePicker!
                  .pickImage(source: ImageSource.gallery);

              // 이미지를 올바르게 가져온 경우 처리
              if (xFile != null) {
                SettingsController.to.allocateEditImage(xFile);
              }
              // 이미지를 받아오는데 실패한 경우 처리
              else {
                ToastUtil.showToastMessage(
                  '이미지를 받아오는데 실패하였습니다 :)',
                );
              }
            },
            child: const Text('대표사진 변경하기'),
          ),
        ],
      ),
    );
  }

  // Network를 통해 Image를 가져오는 Widget
  Widget getNetworkImage() {
    return CachedNetworkImage(
      imageUrl: SettingsController.to.settingUser!.image.toString(),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  // SmartPhone Gallery를 통해 Image를 가져오는 Widget
  Widget getGalleryImage(double width, double height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.file(
            SettingsController.to.editImage!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ).image,
        ),
      ),
    );
  }

  // name, description TextFormField 입니다.
  Widget editTwoTextField() {
    return Column(
      children: [
        // Edit Name TextField
        Container(
          width: ScreenUtil().screenWidth,
          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: GFBorder(
            color: Colors.black12,
            dashedLine: const [2, 0],
            type: GFBorderType.rect,

            // 단순형 상태 관리 GetBuilder
            child: GetBuilder<SettingsController>(
              id: 'editName',
              builder: (controller) {
                return SizedBox(
                  height: 60.h,
                  child: TextField(
                    onChanged: (value) {
                      SettingsController.to.editName = value;

                      // update를 쳐서 GetBuilder를 부른다.
                      SettingsController.to.update(['editName']);
                    },
                    maxLength: 30,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: '수정할 이름을 입력해주세요',
                      errorText:
                          controller.editName.contains(RegExp(r'^[가-힣]{2,4}$'))
                              ? null
                              : '이름 정규표현식에 맞지 않습니다',
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Edit Description TextField
        Container(
          width: ScreenUtil().screenWidth,
          height: 100.h,
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          child: GFBorder(
            color: Colors.black12,
            dashedLine: const [2, 0],
            type: GFBorderType.rect,

            // 단순형 상태관리 GetBuilder
            child: GetBuilder<SettingsController>(
              id: 'editDescription',
              builder: (controller) {
                return TextField(
                  onChanged: (value) {
                    SettingsController.to.editDescription = value;

                    // update를 쳐서 GetBuilder를 실행한다.
                    SettingsController.to.update(['editDescription']);
                  },
                  maxLines: 3,
                  maxLength: 50,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '수정할 Description을 입력해주세요',
                    errorText:
                        controller.editDescription == '' ? '빈 내용 입니다' : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // 프로필을 수정하는 버튼
  Widget editProfileButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 8.h),
      child: ElevatedButton(
        onPressed: () {
          // 프로필을 수정하는 코드를 진행한다.
          print('프로필 수정하기 버튼 누르기');

          // 키보드 내리기
          FocusManager.instance.primaryFocus?.unfocus();

          // 프로필 수정하는 method를 호출한다.
          SettingsController.to.changeUserInfo();
        },
        child: const Text('프로필 수정하기'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              // 이전 페이지로 가는 메소드
              // 이미지, 이름 또는 설명 중에 바뀐 부분이 있으면 값을 초기화 한다.
              SettingsController.to.getBackEditProfilePage();
            },
            icon: const Padding(
              padding: EdgeInsets.all(7.5),
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          elevation: 0.5,
          centerTitle: true,
          title:
              const Text('프로필 수정 페이지', style: TextStyle(color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image와 프로필 사진을 변경하는 Button이 있는 Widget
              imageBox(),

              SizedBox(height: 40.h),

              // name, description이 있는 Widget
              editTwoTextField(),

              SizedBox(height: 40.h),

              editProfileButton(),
            ],
          ),
        ),
      ),
    );
  }
}
