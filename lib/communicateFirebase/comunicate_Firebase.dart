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
  static Future<QuerySnapshot<Map<String, dynamic>>> getFireBaseUserUid(
      String userUid) async {
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
  static UploadTask signInUploadImage(
      {required File imageFile, required String userUid}) {
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
  static Map<String, dynamic> postUploadImage(
      {required RxList<File> imageList, required String userUid}) {
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
  static Future<UploadTask> editUploadImage(
      {required File imageFile, required String userUid}) async {
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
  static Future<String> imageDownloadUrl(UploadTask uploadFileEvent) async {
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

  // 서버의 Post 정보에 대한 공감 수와 댓글 수에 대한 최신 상태를 가져오는 method
  static Future<Map<String, List<String>>> checkSympathyNumOrCommentNum(
      String postUid) async {
    DocumentSnapshot<Map<String, dynamic>> postData =
        await _firebaseFirestore.collection('posts').doc(postUid).get();

    return {
      // 공감 데이터
      'sympathyData':
          List<String>.from(postData.data()!['whoLikeThePost'] as List),
      // 댓글 데이터
      'commentData':
          List<String>.from(postData['whoWriteCommentThePost'] as List),
    };
  }

  // 전체 게시물을 업로드 시간 내림차순 기준으로 가져오는 method
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPostData() async* {
    yield* FirebaseFirestore.instance
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

  // Firebase DataBase Post 정보의 whoLikeThePost 속성에 사용자를 추가하는 method
  static Future<void> addUserWhoLikeThePost(
      String postUid, String userUid) async {
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

  // Firebase Database Post의 postUid를 찾는 method
  static Future<bool> checkPostUid(String postUid) async {
    final postData = await _firebaseFirestore
        .collection('posts')
        .where('postUid', isEqualTo: postUid)
        .get();

    // isEmpty면 게시물은 삭제가 되었다는 뜻이다. -> true를 반환한다.
    // isNotEmpty면 게시물은 존재한다는 뜻이다. -> false를 반환한다.
    return postData.docs.isEmpty;
  }

  // 서버에 존재하는 게시물의 whoWriteCommentThePost 속성에 사용자 uid를 추가하는 method
  static Future<void> addWhoWriteCommentThePost(String postUid) async {
    // 서버에 존재하는 게시물 정보를 받아온다.
    DocumentSnapshot<Map<String, dynamic>> postData =
        await _firebaseFirestore.collection('posts').doc(postUid).get();

    // 게시물 정보의 whoWriteCommentThePost 속성의 배열 값을 가져온다.
    List<String> whoWriteCommentThePost =
        List<String>.from(postData.data()!['whoWriteCommentThePost'] as List);

    // 배열에 사용자 Uid를 추가한다.
    whoWriteCommentThePost.add(SettingsController.to.settingUser!.userUid);

    // 서버에 존재하는 Post 정보의 whoWriteCommentThePost 속성의 배열 값을 업데이트 한다.
    await _firebaseFirestore
        .collection('posts')
        .doc(postUid)
        .update({'whoWriteCommentThePost': whoWriteCommentThePost});

    // 변수 초기화
    whoWriteCommentThePost.clear();
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
  }

  // Firebase DataBase 여러 개 comment을 get 하는 method
  static Future<List<CommentModel>> getCommentData(String postUid) async {
    // 서버에서 게시물에 해당하는 댓글을 가져온다.
    QuerySnapshot<Map<String, dynamic>> comments = await _firebaseFirestore
        .collection('posts')
        .doc(postUid)
        .collection('comments')
        .orderBy('uploadTime', descending: false)
        .get();

    // comment를 관리하는 배열을 생성한다.
    List<CommentModel> commentArray = [];

    // comment 관리하는 배열에 여러 개 comment를 추가한다.
    comments.docs.forEach(
      (comment) {
        commentArray.add(CommentModel.fromMap(comment.data()));
      },
    );

    return commentArray;
  }

  // Firebase DataBase comment 정보의 whoLikeThePost 속성에 접근하여
  // 사용자가 comment에 대해서 클릭한 적이 있는지 판별하는 method
  static Future<bool> checkLikeUsersFromTheComment(CommentModel comment, String userUid) async {
    // post - postUid - comments - commentUid에 접근하여 해당 comment에 접근한다.
    DocumentSnapshot<Map<String, dynamic>> commentData =
        await _firebaseFirestore
            .collection('posts')
            .doc(comment.belongCommentPostUid)
            .collection('comments')
            .doc(comment.commentUid)
            .get();

    // comment - whoCommentLike Property에 userUid가 있는지 확인한다.
    for (String uid in commentData.data()!['whoCommentLike']) {
      if (uid == userUid) {
        // 해당 comment에 대해서 좋아요를 이미 눌렀다는 뜻이다. 따라서 true를 반환한다.
        return true;
      }
    }

    // 해당 comment에 대해서 좋아요를 누르지 않았다는 뜻이다. 따라서 false를 반환한다.
    return false;
  }

  // Firebase DataBase comment 정보의 whoCommentLike 속성에 사용자를 추가하는 method
  static Future<void> addUserWhoCommentLike(CommentModel comment) async {
    // post - postUid - comments - commentUid에 접근하여 해당 comment에 접근한다.
    DocumentSnapshot<Map<String, dynamic>> commentData =
        await _firebaseFirestore
            .collection('posts')
            .doc(comment.belongCommentPostUid)
            .collection('comments')
            .doc(comment.commentUid)
            .get();

    // Firebase DataBase에서 comment 정보의 whoCommentLike 속성의 배열 값을 가져온다.
    List<String> whoCommentLike =
        List<String>.from(commentData['whoCommentLike'] as List);

    // 배열에 사용자 Uid를 추가한다.
    whoCommentLike.add(SettingsController.to.settingUser!.userUid);

    // Firebase DataBase에서 comment 정보의 whoCommentLike 속성의 배열 값을 업데이트 한다.
    await _firebaseFirestore
        .collection('posts')
        .doc(comment.belongCommentPostUid)
        .collection('comments')
        .doc(comment.commentUid)
        .update({'whoCommentLike': whoCommentLike});

    // 변수 초기화
    whoCommentLike.clear();
  }

  // Firebase DataBase에서 comment 정보를 삭제한다.
  static Future<void> deleteComment(CommentModel comment) async {
    // comment 정보를 삭제한다.
    await _firebaseFirestore
        .collection('posts')
        .doc(comment.belongCommentPostUid)
        .collection('comments')
        .doc(comment.commentUid)
        .delete();

    // comment가 속해 있는 post에 대한 whoWriteCommentThePost Property에 comment를 쓴 사용자 uid를 삭제한다.
    DocumentSnapshot<Map<String, dynamic>> postData = await _firebaseFirestore
        .collection('posts')
        .doc(comment.belongCommentPostUid)
        .get();

    // Firebase DataBase에서 Post 정보의 whoWriteCommentThePost 속성의 배열 값을 가져온다.
    List<String> whoWriteCommentThePost =
        List<String>.from(postData['whoWriteCommentThePost'] as List);

    // 배열에 comment를 쓴 userUid를 삭제한다.
    whoWriteCommentThePost.remove(SettingsController.to.settingUser!.userUid);

    // Firebase DataBase에서 Post 정보의 whoWriteCommentThePost 속성의 배열 값을 업데이트 한다.
    await _firebaseFirestore
        .collection('posts')
        .doc(comment.belongCommentPostUid)
        .update({'whoWriteCommentThePost': whoWriteCommentThePost});

    // 변수 clear
    whoWriteCommentThePost.clear();
  }
}
