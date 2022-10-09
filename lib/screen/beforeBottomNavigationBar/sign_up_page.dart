import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:help_desk/authentication/auth.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/bindingController/binding_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/main_page.dart';
import 'package:help_desk/utils/toast_util.dart';

import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    required this.userUid,
    Key? key,
  }) : super(key: key);

  // FirebaseAuth User에 있는 Uid 입니다.
  final String userUid;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Image를 위한 Field
  final ImagePicker imagePicker = ImagePicker();
  File? imageFile;

  // TextFormField Validation을 위한 Field
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextFormField Text를 저장하는 Field
  TextEditingController? nameTextController;
  TextEditingController? descriptionTextController;

  @override
  void initState() {
    super.initState();

    nameTextController = TextEditingController();
    descriptionTextController = TextEditingController();

    print('sign_up_page initState() 호출');
  }

  @override
  void dispose() {
    // textController의 경우 addListener()를 사용하지 않았다면 굳이 dispose시킬 필요가 없다.
    // nameTextController!.dispose();
    // descriptionTextController!.dispose();

    print('sign_up_page dispose 호출');

    super.dispose();
  }

  // ImageBox 입니다.
  Widget imageBox() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          // 사진 입니다.
          SizedBox(
            width: 150,
            height: 150,
            child: DottedBorder(
              strokeWidth: 2,
              color: Colors.grey,
              dashPattern: const [5, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageFile == null
                        ? Image.asset(
                            'assets/images/default_image.png',
                          ).image
                        : Image.file(
                            imageFile!,
                          ).image,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 사진 변경하는 Button 입니다.
          ElevatedButton(
            onPressed: () async {
              XFile? xFile =
                  await imagePicker.pickImage(source: ImageSource.gallery);

              // 정상적으로 이미지를 받을 떄 처리
              if (xFile != null) {
                setState(() {
                  imageFile = File(xFile.path);
                  print('imageFile : ${imageFile}');
                });
              }
              // 갤러리에서 이미지를 받지 못할 떄에 대한 처리
              else {
                ToastUtil.showToastMessage('이미지를 받아오지 못했습니다 :)');
              }
            },
            child: const Text('활동사진 변경하기'),
          ),
        ],
      ),
    );
  }

  // name, description TextFormField 입니다.
  Widget twoTextFormField() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // name TextFormField
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
            child: TextFormField(
              controller: nameTextController,
              validator: (value) {
                if (!(value!.contains(RegExp(r'^[가-힣]{2,4}$')))) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이름',
                  hintText: 'Name 입니다.'),
            ),
          ),

          const SizedBox(height: 16),

          // description TextFormField
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
            child: TextFormField(
              maxLength: 50,
              maxLines: null,
              controller: descriptionTextController,
              validator: (value) {
                if (value!.isEmpty) {
                  return '설명을 입력해주세요.';
                }
                return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '설명',
                  hintText: 'Description 입니다.'),
            ),
          ),
        ],
      ),
    );
  }

  // 회원가입 하기 입니다.
  Widget signUpButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
      child:
          ElevatedButton(onPressed: signButton, child: const Text('회원가입 하기')),
    );
  }

  // "회원가입 하기" 내부 작동 코드 입니다.
  void signButton() {
    bool validResult = _formKey.currentState!.validate();

    // 이미지를 게시하고,  name, description validation이 통과할 경우
    if (imageFile != null && validResult) {
      // Firebase DataBase에 User 정보 올리기
      registerUser();

      EasyLoading.show(
          status: '회원 정보를\n 등록하고 있습니다.', maskType: EasyLoadingMaskType.black);
    } else {
      // Toast Message 띄우기
      ToastUtil.showToastMessage(
          '이미지, 이름 그리고 설명에 대한 validation을 통과하지 못했습니다.');
    }
  }

  // User 정보를 Firebase Storage와 Firebase Database에 저장하는 method
  Future<void> registerUser() async {
    // "회원가입" image를 Firebase Storage에 upload하는 method
    UploadTask uploadFileEvent = CommunicateFirebase.signInUploadImage(
      imageFile: imageFile!,
      userUid: widget.userUid,
    );

    // Firebase Storage에 저장된 image를 download하는 method
    String imageUrl = await CommunicateFirebase.downloadUrl(uploadFileEvent);

    // Firebase Database에 저장될 UserModel 객체
    UserModel user = UserModel(
      userName: nameTextController!.text,
      description: descriptionTextController!.text,
      image: imageUrl,
      userUid: widget.userUid,
    );

    // Firebase DataBase에 User 정보를 upload하는 method
    await CommunicateFirebase.setUserInfo(user);

    // AuthController에 있는 상태 변수에 User 정보를 대입한다.
    AuthController.to.user(user);

    // MainPage로 Routing 한다.
    // BottomNaviagtionBarController, PostListController, PostingController, SettingsController를 등록한다. (메모리에 올린다)
    Get.to(() => MainPage(), binding: BindingController.addServalController());

    // 로딩 없앤다.
    EasyLoading.dismiss();

    // 회원가입 했다는 표시로 true를 가지도록 한다.
    SettingsController.to.didSignUp = true;

    // 로그
    print('SettingsController- didSignUp : ${SettingsController.to.didSignUp}');
  }

  @override
  Widget build(BuildContext context) {
    // 뒤로 가기 거부
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          ToastUtil.showToastMessage('이전가기가 불가능합니다.');
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('회원가입', style: TextStyle(color: Colors.black)),
            elevation: 0.5,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                imageBox(),

                const SizedBox(height: 80),

                twoTextFormField(),

                const SizedBox(height: 80),

                signUpButton(),

                const SizedBox(height: 80),

                // temporyLogOut(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
