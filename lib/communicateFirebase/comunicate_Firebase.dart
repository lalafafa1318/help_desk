import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/settings_controller.dart';
import 'package:help_desk/utils/uuid_util.dart';

// 실질적으로 Firebase와 통신하는 class 입니다.
class CommunicateFirebase {
  // Field
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Firebase Database에서 uid가 있는지 확인하는 method
  static Future<QuerySnapshot<Map<String, dynamic>>> getFireBaseUserUid(String userUid) async {
    QuerySnapshot<Map<String, dynamic>> userData = await _firebaseFirestore
        .collection('users')
        .where('userUid', isEqualTo: userUid)
        .get();

    return userData;
  }

  // Firebase Auth에서 로고인 하는 method
  static Future<UserCredential> login(OAuthCredential credential) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }

  // Firebase Auth에서 로그아웃 하는 method
  static Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // "회원가입" 페이지에 있는 Image를 Firebase Storage에 upload하는 method
  static UploadTask signInUploadImage({required File imageFile, required String userUid}) {
    // substring을 왜 써야 하는지 알 수 있는 코드 (jpg' or jpg 인가 차이)
    // print('imageFile : ${imageFile.toString()}');
    // print('substring을 사용하지 않는 예 : ${imageFile.toString().split('.').last}');
    // print(
    //     'substring을 사용하는 예 : ${imageFile.toString().split('.').last.substring(0, 3)}');

    // ImageFile의 확장자(png, jpg) 가져오기
    String imageFileExt = imageFile.toString().split('.').last.substring(0, 3);

    // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
    Reference storageReference = _firebaseStorage
        .ref()
        .child('users/$userUid/${UUidUtil.getUUid()}.$imageFileExt');

    // image를 해당 경로에 저장한다.
    UploadTask uploadFileEvent = storageReference.putFile(imageFile);

    return uploadFileEvent;
  }

  // "Posting" 페이지에 게시물을 업로드할 떄 Image를
  //  Firebase Stroage에 upload하는 method
  static Map<String, dynamic> postUploadImage({required RxList<File> imageList, required String userUid}) {
    // UploadTask을 관리하는 배열 입니다.
    List<UploadTask> uploadTasks = [];

    // posts -> 게시물 Uid -> User Uid -> 게시물 정보
    // 게시물 Uid를 정립한 것이다.
    String postUUid = UUidUtil.getUUid();

    for (File image in imageList) {
      // ImageFile의 확장자(png, jpg) 가져오기
      String imageFileExt = image.toString().split('.').last.substring(0, 3);

      // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
      Reference storageReference = _firebaseStorage
          .ref()
          .child('posts/$postUUid/${UUidUtil.getUUid()}.$imageFileExt');

      // image를 해당 경로에 저장한다.
      UploadTask uploadFileEvent = storageReference.putFile(image);

      // uploadTask을 배열에 추가한다.
      uploadTasks.add(uploadFileEvent);
    }

    // uploadTasks, postUUid 2가지가 다른 곳에서 필요하기 떄문에 map으로 설정했다.
    return {
      'uploadTasks': uploadTasks,
      'postUUid': postUUid,
    };
  }

  // "프로필 수정" 페이지에서 수정한 Image를 Firebase Storage에 update하는 method
  static Future<UploadTask> editUploadImage({required File imageFile, required String userUid}) async {
    // ImageFile의 확장자(png, jpg) 가져오기
    String imageFileExt = imageFile.toString().split('.').last.substring(0, 3);

    // Firebase Stroage에 존재하던 파일을 삭제한다.
    await _firebaseStorage
        .refFromURL(SettingsController.to.settingUser!.image.toString())
        .delete();

    // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
    Reference storageReference = _firebaseStorage
        .ref()
        .child('users/$userUid/${UUidUtil.getUUid()}.$imageFileExt');

    // image를 해당 경로에 저장한다.
    UploadTask uploadFileEvent = storageReference.putFile(imageFile);

    return uploadFileEvent;
  }

  // Firebase Storage에 upload, update된 image를 download 하는 method
  static Future<String> downloadUrl(UploadTask uploadFileEvent) async {
    String imageUrl = await (await uploadFileEvent.whenComplete(() => null))
        .ref
        .getDownloadURL();

    return imageUrl;
  }

  // Firebase DataBase에 User 정보를 set하는 method
  static Future<void> setUserInfo(UserModel user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.userUid)
        .set(UserModel.toMap(user));
  }

  // Firebase DataBase에서 User 정보를 get하는 method
  static Future<Map<String, dynamic>> getUserInfo(String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> docRef =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    Map<String, dynamic> data = docRef.data()!;

    return data;
  }

  // Firebase DataBase에 User 정보를 update하는 method
  static Future<void> updateUserInfo(UserModel updateUser) async {
    await _firebaseFirestore
        .collection('users')
        .doc(updateUser.userUid)
        .update(UserModel.toMap(updateUser));
  }

  // Firebase DataBase에 Post 정보를 set하는 method
  static Future<void> setPostInfo(PostModel post, String postUUid) async {
    await _firebaseFirestore
        .collection('posts')
        .doc(postUUid)
        .set(PostModel.toMap(post));
  }

  // Firebase DataBase Post 정보의 whoLikeThePost 속성에 접근하여 좋아요를 누른 사용자를 확인하는 method
  static void checkLikeUsersFromThePost(){
    


  }

}
