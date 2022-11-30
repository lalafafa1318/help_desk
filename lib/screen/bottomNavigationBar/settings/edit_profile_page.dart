// 프로필 수정하는 class
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
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

  // 이름과 전화번호 관련된 TextFormField를 보여준다.
  Widget editTwoTextField() {
    return Form(
      key: SettingsController.to.editFormKey,
      child: Column(
        children: [
          // 이름 TextFormField
          Container(
            padding: EdgeInsets.symmetric(horizontal: 48.0.w, vertical: 8.0.h),
            child: TextFormField(
              controller: SettingsController.to.nameTextController,
              validator: (value) {
                // 사용자가 입력한 text가 정규 표현식을 만족하지 못하는 경우...
                if (!(value!.contains(RegExp(r'^[가-힣]{2,4}$')))) {
                  return '이름을 입력해주세요';
                }
                // 사용자가 입력한 text가 문제 없는 경우...
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '이름',
                hintText: 'Name 입니다.',
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 전화번호 TextFormField
          Container(
            padding: EdgeInsets.symmetric(horizontal: 48.0.w, vertical: 8.0.h),
            child: TextFormField(
              maxLines: null,
              keyboardType: TextInputType.phone,
              controller: SettingsController.to.telTextController,
              validator: (value) {
                // 사용자가 입력한 text가 빈값인 경우...
                if (value!.isEmpty) {
                  return '전화번호가 빈값 입니다.';
                }
                // 사용자가 입력한 text가 핸드폰 전화번호, 일반 전화번호 형식에 만족하지 않는 경우...
                // 또는 핸드폰 전화번호, 일반 전화번호 형식을 만족하지만 하이픈(-)이 있는 경우 ...
                else if (!value.isPhoneNumber || value.contains('-')) {
                  return '전화번호 정규식에 적합하지 않습니다.';
                }
                // 사용자가 입력한 text가 문제 없는 경우..
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '하이픈(-)을 제외한 전화번호',
                hintText: '전화번호 입니다.',
              ),
            ),
          ),
        ],
      ),
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
              SizedBox(height: 30.h),

              // Image와 프로필 사진을 변경하는 Button이 있는 Widget
              imageBox(),

              SizedBox(height: 30.h),

              // 이름과 전화번호를 수정하는 부분
              editTwoTextField(),

              SizedBox(height: 40.h),

              // 프로필 수정하기 버튼을 입력하는 부분
              editProfileButton(),
            ],
          ),
        ),
      ),
    );
  }
}
