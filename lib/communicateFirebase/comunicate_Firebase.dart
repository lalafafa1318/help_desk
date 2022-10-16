import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:help_desk/authentication/controller/auth_controller.dart';
import 'package:help_desk/model/comment_model.dart';
import 'package:help_desk/model/post_model.dart';
import 'package:help_desk/model/user_model.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/postList_controller.dart';
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
  static Future<void> setUserData(UserModel user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.userUid)
        .set(UserModel.toMap(user));
  }

  // Firebase DataBase에서 User 정보를 get하는 method
  static Future<Map<String, dynamic>> getUserData(String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> docRef =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    Map<String, dynamic> data = docRef.data()!;

    return data;
  }

  // Firebase DataBase에 User 정보를 update하는 method
  static Future<void> updateUserData(UserModel updateUser) async {
    await _firebaseFirestore
        .collection('users')
        .doc(updateUser.userUid)
        .update(UserModel.toMap(updateUser));
  }

  // 전체 게시물을 업로드 시간 내림차순 기준으로 가져오는 method
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPostData() async* {
    yield*  FirebaseFirestore.instance
        .collection('posts')
        .orderBy('postTime', descending: true)
        .snapshots();
  }

  // Firebase DataBase에 Post 정보를 set하는 method
  static Future<void> setPostData(PostModel post, String postUid) async {
    await _firebaseFirestore
        .collection('posts')
        .doc(postUid)
        .set(PostModel.toMap(post));
  }

  // Firebase DataBase에서 Post 정보를 get하는 method
  static Future<Map<String, dynamic>> getPostData(String postUid) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshotPostData =
        await _firebaseFirestore.collection('posts').doc(postUid).get();

    Map<String, dynamic> postData = documentSnapshotPostData.data()!;

    return postData;
  }

  // Firebase DataBase에서 Post 정보를 delete하는 method
  static Future<void> deletePostData(String postUid) async {
    // Firebase DataBase Post 정보 받아오기
    Map<String, dynamic> postData = await getPostData(postUid);

    List<String> imageList = List<String>.from(postData['imageList'] as List);

    if (imageList.isNotEmpty) {
      // Firebase DataBase에서 Post에 대한 image Stroage 삭제하기
      for (String image in imageList) {
        await _firebaseStorage.refFromURL(image).delete();
      }
    }

    // Firebase DataBase에서 Post 정보 삭제하기
    await _firebaseFirestore.collection('posts').doc(postUid).delete();

    // 변수 초기화
    postData.clear();
    imageList.clear();
  }

  // Firebase DataBase Post 정보의 whoLikeThePost 속성에 접근하여 좋아요를 누른 사용자를 확인하는 method
  static Future<bool> checkLikeUsersFromThePost(String postUid, String userUid) async {
    // Firebase DataBase에서 Post 정보를 get하는 method를 실행한다.
    Map<String, dynamic> postData = await getPostData(postUid);

    // whoLikeThePost에서 사용자 Uid가 있는지 확인한다.
    for (String uid in postData['whoLikeThePost']) {
      // uid 비교 작업
      if (userUid == uid) {
        return true;
      }
    }

    return false;
  }

  // Firebase DataBase Post 정보의 whoLikeThePost 속성에 사용자를 추가하는 method
  static Future<void> addUserWhoLikeThePost(String postUid, String userUid) async {
    // Firebase DataBase에서 Post 정보를 get하는 method를 실행한다.
    Map<String, dynamic> postData = await getPostData(postUid);

    // Firebase DataBase에서 Post 정보의 whoLikeThePost 속성의 배열 값을 가져온다.
    List<String> whoLikeThePostArray =
        List<String>.from(postData['whoLikeThePost'] as List);

    // 배열에 사용자 Uid를 추가한다.
    whoLikeThePostArray.add(userUid);

    // Firebase DataBase에서 Post 정보의 whoLikeThePost 속성의 배열 값을 업데이트 한다.
    await _firebaseFirestore
        .collection('posts')
        .doc(postUid)
        .update({'whoLikeThePost': whoLikeThePostArray});

    // 변수 초기화
    postData.clear();
    whoLikeThePostArray.clear();
  }

  // Firebase DataBase comment 정보를 set 하는 method
  static Future<void> setCommentData(CommentModel commentModel) async {
    // Firebase DataBase comment 정보를 set
    await _firebaseFirestore
        .collection('posts')
        .doc(commentModel.belongCommentPostUid)
        .collection('comments')
        .doc(commentModel.commentUid)
        .set(CommentModel.toMap(commentModel));

    // 서버에 Post 정보를 받아온다.
    Map<String, dynamic> postData =
        await getPostData(commentModel.belongCommentPostUid);

    // 임시적으로 whoWriteCommentThePost 배열을 생성한다.
    List<String> whoWriteCommentThePost =
        List<String>.from(postData['whoWriteCommentThePost'] as List);

    whoWriteCommentThePost.add(commentModel.whoWriteUserUid);

    // Firebase DataBase에서 Post 정보의 whoWriteCommentThePost 속성의 배열 값을 업데이트 한다.
    await _firebaseFirestore
        .collection('posts')
        .doc(commentModel.belongCommentPostUid)
        .update({'whoWriteCommentThePost': whoWriteCommentThePost});

    // 변수 초기화
    postData.clear();
    whoWriteCommentThePost.clear();
  }

  // Firebase DataBase 여러 개 comment을 get 하는 method
  static Future<void> getCommentData(String postUid) async {
    // 서버에서 게시물에 해당하는 댓글을 가져온다.
    QuerySnapshot<Map<String, dynamic>> comments = await _firebaseFirestore
        .collection('posts')
        .doc(postUid)
        .collection('comments')
        .orderBy('uploadTime', descending: false)
        .get();

    // 댓글을 관리하는 배열을 초기화 한다.
    PostListController.to.commentArray.clear();

    comments.docs.forEach(
      (element) {
        PostListController.to.commentArray
            .add(CommentModel.fromMap(element.data()));
      },
    );
  }
}
