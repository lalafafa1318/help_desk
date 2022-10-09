import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/const/const.dart';
import 'package:help_desk/main.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/screen/bottomNavigationBar/settings/edit_profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  // 아바타 view(name, description 포함)  + Edit Outlined Button view
  Widget topView(SettingsController controller) {
    return SizedBox(
      width: Get.width,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 아바타 view
          showAvatarView(controller),

          // Edit Outlined Button
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 15, right: 10),
              child: editOutlinedButtonView(),
            ),
          ),
        ],
      ),
    );
  }

  // 아바타 view 입니다.(name, description 포함)
  Widget showAvatarView(SettingsController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image 입니다.
        SizedBox(
          width: 100,
          height: 100,
          child: DottedBorder(
            strokeWidth: 2,
            color: Colors.grey,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            // 이미지 입니다.
            child: CachedNetworkImage(
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
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 이름
        Text(
          // '${SettingsController.to.settingUser!.userName}',
          '${controller.settingUser!.userName}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),

        const SizedBox(height: 10),

        // 설명 - Expandable Text
        SizedBox(
          width: 150,
          height: 100,
          child: ExpandableText(
            '${controller.settingUser!.description}',
            expandText: 'show more',
            collapseText: 'show less',
            textAlign: TextAlign.center,
            maxLines: 2,
            linkColor: Colors.blue,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Edit Outlined Button View 입니다.
  Widget editOutlinedButtonView() {
    return GFButton(
      onPressed: () {
        // 프로필 수정 코드
        Get.to(() => EditProfilePage());
      },
      text: "Edit",
      type: GFButtonType.transparent,
    );
  }

  // 기능 View 입니다.
  Widget functionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: Get.width,
        height: 320,
        color: Colors.white70,
        child: ListView(
          children: [
            // 프로필 변경 이동 페이지 칸
            changeProfileView(),

            const Divider(height: 3, thickness: 1),

            // 북마크 이동 페이지 칸
            bookMarkView(),

            const Divider(height: 3, thickness: 1),

            // 내가 쓴 글 이동 페이지 칸
            writeView(),

            const Divider(height: 3, thickness: 1),

            // 내가 댓글 단 글 이동 페이지 칸
            commentView(),

            const Divider(height: 3, thickness: 1),

            // 최근 본 글 이동 페이지 칸
            recentView(),

            const Divider(height: 3, thickness: 1),

            // 회원 탈퇴 설정 이동 페이지 칸
            // memberWithdrawView(),

            // const Divider(height: 3, thickness: 1),

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
      height: 50,
      child: InkWell(
        onTap: () {
          Get.to(() => EditProfilePage());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.change_circle_outlined, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '프로필 수정',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  //  북마크 칸
  Widget bookMarkView() {
    return GestureDetector(
      onTap: () {
        // 북마크 이동 페이지 칸을 클릭하면 로직 적용
        Get.to(() => EditProfilePage());
      },
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.bookmark, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '북마크',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  //  내가 쓴 글 칸
  Widget writeView() {
    return GestureDetector(
      onTap: () {
        // 북마크 이동 페이지 칸을 클릭하면 로직 적용
      },
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.list, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '내가 쓴 글',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  //  내가 댓글 단 글 칸
  Widget commentView() {
    return GestureDetector(
      onTap: () {
        // 내가 댓글 단 글 칸을 클릭하면 로직 적용
      },
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.comment_bank_outlined, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '내가 댓글 단 글',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  //  최근 본 글 칸
  Widget recentView() {
    return GestureDetector(
      onTap: () {
        // 내가 댓글 단 글 칸을 클릭하면 로직 적용
      },
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.recent_actors_outlined, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '최근 본 글',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  //  회원 탈퇴 설정 칸 (구현할 수도 안할 수도...)
  Widget memberWithdrawView() {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.transfer_within_a_station_rounded, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '회원 탈퇴하기',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  //  로그아웃 칸
  Widget logoutView() {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: () {
          AuthController.to.notKakaoLogout();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 아이콘
            Icon(Icons.logout_outlined, size: 20),

            // 아이콘과 제목 간격을 5만큼 넓힌다.
            SizedBox(width: 5),

            // 제목
            Text(
              '로그아웃',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFf2eeed),
          // backgroundColor: Colors.white,
          body: Column(
            children: [
              const SizedBox(height: 30),

              // 아바타 View + Edit outline Button
              topView(controller),

              // 기능 view
              functionView(),
            ],
          ),
        );
      },
    );
  }
}
