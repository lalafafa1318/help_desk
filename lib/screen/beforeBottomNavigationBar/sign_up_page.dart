import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/bindingController/binding_controller.dart';
import 'package:help_desk/communicateFirebase/comunicate_Firebase.dart';
import 'package:help_desk/const/departmentClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/beforeBottomNavigationBar/splash_page.dart';
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
  /* Image를 위한 Field 
    (37 ~ 38 줄) */
  final ImagePicker imagePicker = ImagePicker();
  File? imageFile;

  // 이름, 전화번호 관련된 TextFormField Validation을 위한 Field
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 이름과 관련된 TextFormField Text를 저장하는 Field
  TextEditingController? nameTextController;

  /* 부서명
     회원가입할 때 부서명은 ETHICALMANAGEMENT(윤리경영실)이 default로 보이게 된다. */
  DepartmentClassification departmentClassification =
      DepartmentClassification.ETHICALMANAGEMENT;

  // 전화번호와 관련된 TextFormField Text를 저장하는 Field
  TextEditingController? telTextController;

  @override
  void initState() {
    super.initState();

    nameTextController = TextEditingController();
    telTextController = TextEditingController();

    print('sign_up_page initState() 호출');
  }

  @override
  void dispose() {
    // textController의 경우 addListener()를 사용하지 않았다면 굳이 dispose시킬 필요가 없다.
    // nameTextController!.dispose();
    // telTextController!.dispose();

    print('sign_up_page dispose 호출');

    super.dispose();
  }

  // ImageBox 입니다.
  Widget imageBox() {
    return Container(
      margin: EdgeInsets.only(top: 30.h),
      child: Column(
        children: [
          // 이미지 입니다.
          SizedBox(
            width: 125.w,
            height: 125.h,
            child: DottedBorder(
              strokeWidth: 2,
              color: Colors.grey,
              dashPattern: const [5, 3],
              borderType: BorderType.RRect,
              radius: Radius.circular(10.r),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageFile == null
                        ? Image.asset(
                            'assets/images/default_image.png',
                          ).image
                        : Image.file(imageFile!).image,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // 프로필 수정 페이지에서 이미지는 선택 입력 값이다. 따라서 이를 사용자에게 알려주기 위해 Text로 표시한다.
          Text(
            '* 선택 입력값 입니다.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
          ),

          SizedBox(height: 10.h),

          // 이미지 변경하는 Button 입니다.
          ElevatedButton(
            onPressed: () async {
              // 스마트폰 갤러리를 연다.
              XFile? xFile =
                  await imagePicker.pickImage(source: ImageSource.gallery);

              // 정상적으로 이미지를 받을 떄 처리
              if (xFile != null) {
                setState(() {
                  imageFile = File(xFile.path);

                  print('imageFile : $imageFile');
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

  // 이름과 전화번호를 입력하고, 부서명을 Dropdown으로 보여준다.
  Widget threeRequiredInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 이름 TextFormField
          Container(
            padding: EdgeInsets.symmetric(horizontal: 48.0.w, vertical: 8.0.h),
            child: TextFormField(
              controller: nameTextController,
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
                helperText: '* 필수 입력값 입니다.',
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // 부서명 Dropdown
          SizedBox(
            width: 265.w,
            height: 50.h,
            child: DropdownButtonHideUnderline(
              child: GFDropdown(
                padding: const EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(5.r),
                border: const BorderSide(color: Colors.black26, width: 1),
                dropdownButtonColor: Colors.white,
                value: departmentClassification.name,
                items: DepartmentClassification.values
                    .map((DepartmentClassification element) {
                  // enum의 값을 화면에 표시할 값으로 변환한다.
                  String realText = element.asText;

                  return DropdownMenuItem(
                    value: element.name,
                    child: Text(realText),
                  );
                }).toList(),
                onChanged: (element) {
                  setState(() {
                    departmentClassification =
                        DepartmentClassification.values.firstWhere(
                      (DepartmentClassification enumValue) =>
                          enumValue.name == element,
                    );
                  });
                },
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Container(
            margin: EdgeInsets.only(right: 60.w),
            width: ScreenUtil().screenWidth / 2,
            child: Text(
              '* 필수 입력값 입니다.',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
            ),
          ),

          SizedBox(height: 20.h),

          // 전화번호 TextFormField
          Container(
            padding: EdgeInsets.symmetric(horizontal: 48.0.w, vertical: 8.0.h),
            child: TextFormField(
              maxLines: null,
              keyboardType: TextInputType.phone,
              controller: telTextController,
              validator: (value) {
                // 사용자가 입력한 text가 빈값인 경우...
                if (value!.isEmpty) {
                  return '전화번호가 빈값 입니다.';
                }
                /* 사용자가 입력한 text가 핸드폰 전화번호, 일반 전화번호 형식에 만족하지 않는 경우...
                   핸드폰 전화번호, 일반 전화번호 형식을 만족하지만 하이픈(-)이 있는 경우 ... */
                else if (!value.isPhoneNumber || value.contains('-')) {
                  return '전화번호 정규식에 적합하지 않습니다.';
                }
                // 사용자가 입력한 text가 문제 없는 경우..
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '하이픈(-)을 제외한 전화번호',
                helperText: '* 필수 입력값 입니다.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 회원가입 하기 입니다.
  Widget signUpButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48.0.w, vertical: 8.0.h),
      child: ElevatedButton(
        onPressed: () {
          // 키보드 내리기
          FocusManager.instance.primaryFocus?.unfocus();

          // 회원 가입 하는 method
          signButton();
        },
        child: const Text('회원가입 하기'),
      ),
    );
  }

  // signUpButton 내부 작동 코드 입니다.
  void signButton() {
    // 사용자가 입력한 이름과 전화번호를 검증한다.
    bool validResult = _formKey.currentState!.validate();

    // 회원 가입할 떄 이름, 전화번호가 필수 입력값이므로 검증에 통과했을 경우
    if (validResult) {
      // DataBase에 User 정보 올리기
      registerUser();
    }
    // 검증에 통과하지 못했을 경우
    else {
      // Toast Message 띄우기
      ToastUtil.showToastMessage('검증을 통과하지 못했습니다.\n다시 입력해주세요');
    }
  }

  // User 정보를 Firebase Storage와 Database에 저장하는 method
  Future<void> registerUser() async {
    /* 회원가입할 떄 이미지를 올렸을 떄 Firebase Storage와 관련된 변수들을 정의한다.    
         (230 ~ 231줄)  */
    UploadTask uploadFileEvent;
    String imageUrl = '';

    // 로딩 바를 띄운다.
    EasyLoading.show(
        status: '사용자 정보를\n등록하고 있습니다.', maskType: EasyLoadingMaskType.black);

    // 회원가입할 떄 이미지를 올렸을 떄 Firebase Stroage에 image를 upload 한다.
    if (imageFile != null) {
      // SignUpPage에 image를 Firebase Storage에 upload하는 method
      uploadFileEvent = CommunicateFirebase.signUpPageImageToStroage(
        imageFile: imageFile!,
        userUid: widget.userUid,
      );

      // Firebase Storage에 저장된 image를 download하는 method
      imageUrl = await CommunicateFirebase.imageDownloadUrl(uploadFileEvent);
    }

    // Firebase Database에 저장될 UserModel 객체
    UserModel user = UserModel(
      // 회원가입을 하면 userType을 GENERALUSER (일반 사용자)로 default한다.
      userType: UserClassification.GENERALUSER,
      department: departmentClassification,
      userName: nameTextController!.text,
      // 사용자가 회원가입할 떄 이미지를 게시하지 않았다면 null 값이 들어간다.
      image: imageFile == null ? null : imageUrl,
      userUid: widget.userUid,
      // 회원 가입할 떄 commentNotificationPostUid 속성은 무조건 []이다.
      commentNotificationPostUid: [],
      phoneNumber: telTextController!.text,
    );

    // Firebase DataBase에 User 정보를 upload하는 method
    await CommunicateFirebase.setUser(user);

    // AuthController에 있는 상태 변수에 User 정보를 대입한다.
    AuthController.to.user(user);

    /* MainPage로 Routing 한다.
      BottomNaviagtionBarController, PostListController, PostingController, SettingsController를 등록한다. */
    Get.to(() => MainPage(), binding: BindingController.addServalController());

    // 로딩 없앤다.
    EasyLoading.dismiss();

    // 회원가입 했다는 표시로 true를 가지도록 한다.
    SettingsController.to.didSignUp = true;
  }

  // 회원가입 페이지에서 이전 가기로 가는 method
  Future<void> onWillPop() async {
    await CommunicateFirebase.logout();

    // Splash를 다시 보여줘서 앱을 시작한다.
    await Get.offAll(() => const Splash());
  }

  @override
  Widget build(BuildContext context) {
    print('현재 페이지 : ${Get.currentRoute}');
    // 뒤로 가기 거부
    return SafeArea(
      // 사용자가 이전 가기를 눌렀을 떄
      child: WillPopScope(
        onWillPop: () async {
          // SignUpPage에서 이전으로 간다.
          await onWillPop();

          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            // 이전 가기 아이콘
            leading: IconButton(
              onPressed: () async {
                // SignUpPage에서 이전으로 간다.
                await onWillPop();
              },
              icon: const Padding(
                padding: EdgeInsets.all(7.5),
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            centerTitle: true,
            title: const Text('회원가입', style: TextStyle(color: Colors.black)),
            elevation: 0.5,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.h),

                // 활동사진을 입력하는 부분
                imageBox(),

                SizedBox(height: 40.h),

                // 이름과 전화번호를 입력하고, 부서명을 Dropdown으로 보여준다.
                threeRequiredInput(),

                SizedBox(height: 40.h),

                // 회원가입 하기 버튼을 입력하는 부분
                signUpButton(),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
