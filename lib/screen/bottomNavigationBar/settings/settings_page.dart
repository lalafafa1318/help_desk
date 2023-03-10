import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/const/departmentClassification.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/settings/edit_profile_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/settings/what_i_comment_page.dart';
import 'package:help_desk/screen/bottomNavigationBar/settings/what_i_wrote_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  // 이미지 + Edit Outlined Button view
  Widget topView(SettingsController controller) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: 270.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 아바타 view
          showAvatarView(controller),

          // Edit Outlined Button
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(top: 15.h, right: 10.w),
              child: editOutlinedButtonView(),
            ),
          ),
        ],
      ),
    );
  }

  // 이미지를 보여준다.
  Widget showAvatarView(SettingsController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image 입니다.
        SizedBox(
          width: 100.w,
          height: 100.h,
          child: DottedBorder(
            strokeWidth: 2,
            color: Colors.grey,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            /* 사용자마다 회원가입할 떄 이미지를 넣었을 수 있고, 그렇게 하지 않을 수도 있다.
               만약 사용자 이미지가 null 값일 떄에 대한 처리를 해야 한다. */
            child: SettingsController.to.settingUser!.image == null
                ? Image.asset(
                    'assets/images/default_image.png',
                    height: 100.h,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: controller.settingUser!.image.toString(),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
          ),
        ),

        SizedBox(height: 20.h),

        // 이름
        Text(
          controller.settingUser!.userName,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
        ),

        SizedBox(height: 10.h),

        // 부서명
        Text(
          controller.settingUser!.department.asText,
          style: const TextStyle(color: Colors.grey),
        ),

        SizedBox(height: 10.h),

        // 전화번호
        Text(
          controller.settingUser!.phoneNumber,
          style: const TextStyle(color: Colors.grey),
        ),

        SizedBox(height: 10.h),
      ],
    );
  }

  // Edit Outlined Button View 입니다.
  Widget editOutlinedButtonView() {
    return GFButton(
      onPressed: () {
        // 프로필 수정 코드
        Get.to(() => const EditProfilePage());
      },
      text: "Edit",
      type: GFButtonType.transparent,
    );
  }

  // 기능 View 입니다.
  Widget functionView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0.w),
      child: Container(
        width: ScreenUtil().screenWidth,
        height: 210.h,
        color: Colors.white70,
        child: ListView(
          children: [
            // 프로필 변경 이동 페이지 칸
            changeProfileView(),

            Divider(height: 3.h, thickness: 1.w),

            // 내가 업로드한 IT 요청건 게시물 이동 페이지 칸
            writeView(),

            Divider(height: 3.h, thickness: 1.w),

            // 내가 댓글 작성한 IT 요청건 게시물 이동 페이지 칸
            commentView(),

            const Divider(height: 3, thickness: 1),

            // 로그아웃 설정 이동 페이지 칸
            logoutView(),
          ],
        ),
      ),
    );
  }

  //  프로필 변경 이동 페이지 칸
  Widget changeProfileView() {
    return SizedBox(
      height: 50.h,
      child: InkWell(
        onTap: () {
          Get.to(() => const EditProfilePage());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            const Icon(Icons.change_circle_outlined, size: 20),

            // 아이콘과 제목 간격을 10만큼 넓힌다.
            SizedBox(width: 10.w),

            // 제목
            Text(
              '프로필 수정',
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

  //  내가 업로드한 IT 요청건 게시물 칸
  Widget writeView() {
    return GestureDetector(
      onTap: () {
        // 내가 업로드한 IT 요청건 게시물칸을 클릭하면 Routing
        Get.to(() => const WhatIWrotePage());
      },
      child: SizedBox(
        height: 50.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            const Icon(Icons.list, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 10.w),

            // 제목
            Text(
              '내가 작성한 IT 요청건',
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

  //  내가 댓글 작성한 IT 요청건 게시물 칸
  Widget commentView() {
    return GestureDetector(
      onTap: () {
        // 내가 댓글 작성한 IT 요청건 게시물칸을 클릭하면 Routing
        Get.to(() => const WhatICommentPage());
      },
      child: SizedBox(
        height: 50.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            const Icon(Icons.comment_bank_outlined, size: 20),

            // 아이콘과 제목 간격을 10만큼 넓힌다.
            SizedBox(width: 10.w),

            // 제목
            Text(
              '내가 댓글 작성한 IT 요청건',
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

  //  로그아웃 칸
  Widget logoutView() {
    return SizedBox(
      height: 50.h,
      child: InkWell(
        onTap: () async {
          await AuthController.to.logout();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            const Icon(Icons.logout_outlined, size: 20),

            // 아이콘과 제목 간격을 10만큼 넓힌다.
            SizedBox(width: 10.w),

            // 제목
            Text(
              '로그아웃',
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      id: 'showProfile',
      builder: (SettingsController controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFf2eeed),
          body: Column(
            children: [
              SizedBox(height: 40.h),

              // 아바타 View + Edit outline Button
              topView(controller),

              SizedBox(height: 10.h),

              // 기능 view
              functionView(),
            ],
          ),
        );
      },
    );
  }
}
