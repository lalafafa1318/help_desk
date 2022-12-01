import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/userClassification.dart';
import 'package:help_desk/model/comment_model.dart';
import 'package:help_desk/model/notification_model.dart';
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

  // Method

  // _firebaseFirestore를 얻기 위한 method
  // 여러 곳애서 다른 Instnace를 쓰지 말고 같은 Instance를 쓰게 하기 위함이다.
  static FirebaseFirestore getFirebaseFirestoreInstnace() {
    return _firebaseFirestore;
  }

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

  // 게시물이 장애 처리현황인가 문의 처리현황인가를 구별해
  // Firebase Storage에 이미지를 저장하는 method
  static Map<String, dynamic> postUploadImage({
    required RxList<File> imageList,
    required ObsOrInqClassification obsOrInq,
    required String userUid,
  }) {
    // UploadTask을 관리하는 배열 입니다.
    List<UploadTask> uploadTasks = [];

    // posts -> 게시물 Uid -> User Uid -> 게시물 정보
    // 게시물 Uid를 정립한 것이다.
    String postUUid = UUidUtil.getUUid();

    // 업로드한 게시물이 장애 처리현황인 경우
    if (obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      for (File image in imageList) {
        // ImageFile의 확장자(png, jpg) 가져오기
        String imageFileExt = image.toString().split('.').last.substring(0, 3);

        // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
        Reference storageReference = _firebaseStorage
            .ref()
            .child('obsPosts/$postUUid/${UUidUtil.getUUid()}.$imageFileExt');

        // image를 해당 경로에 저장한다.
        UploadTask uploadFileEvent = storageReference.putFile(image);

        // uploadTask을 배열에 추가한다.
        uploadTasks.add(uploadFileEvent);
      }
    }
    // 업로드한 게시물이 문의 처리현황인 경우
    else {
      for (File image in imageList) {
        // ImageFile의 확장자(png, jpg) 가져오기
        String imageFileExt = image.toString().split('.').last.substring(0, 3);

        // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
        Reference storageReference = _firebaseStorage
            .ref()
            .child('inqPosts/$postUUid/${UUidUtil.getUUid()}.$imageFileExt');

        // image를 해당 경로에 저장한다.
        UploadTask uploadFileEvent = storageReference.putFile(image);

        // uploadTask을 배열에 추가한다.
        uploadTasks.add(uploadFileEvent);
      }
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

    return docRef.data()!;
  }

  // Firebase DataBase에 User 정보를 update하는 method
  static Future<void> updateUser(UserModel updateUser) async {
    await _firebaseFirestore
        .collection('users')
        .doc(updateUser.userUid)
        .update(UserModel.toMap(updateUser));
  }

  // DataBase에 게시물(obsPosts, inqPosts)에 phoneNumber 속성을 최신 상태로 update 한다.
  static Future<void> updatePhoneNumberInPost(UserModel userModel) async {
    // 사용자가 장애 처리현황, 문의 처리현황 게시글을 작성했다면, DataBase에 존재하는 게시물의 phoneNumber 속성을 업데이트 한다.
    QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
        .collection('obsPosts')
        .where('userUid', isEqualTo: userModel.userUid)
        .get();

    data.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> element) {
      element.reference.update({'phoneNumber': userModel.phoneNumber});
    });

    data = await _firebaseFirestore
        .collection('inqPosts')
        .where('userUid', isEqualTo: userModel.userUid)
        .get();

    data.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> element) {
      element.reference.update({'phoneNumber': userModel.phoneNumber});
    });
  }

  // 장애 처리현황 게시물을 postTime 내림차순 기준으로 가져오는 method
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getObsPostData(UserClassification userType) async {
    // 사용자가 일반 사용자이면?
    // -> 사용자가 작성한 장애 처리현황 게시물만 가져온다.
    if (userType == UserClassification.GENERALUSER) {
      // postTime 속성을 내림차순으로 정렬한다.
      QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
          .collection('obsPosts')
          .orderBy('postTime', descending: true)
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> ultimateData =
          data.docs;

      // 자신이 쓴 게시물만 가져온다.
      ultimateData.removeWhere(
          (QueryDocumentSnapshot<Map<String, dynamic>> element) =>
              element.data()['userUid'].toString() !=
              SettingsController.to.settingUser!.userUid);

      return ultimateData;
    }
    // 사용자가 IT 담당자이면?
    // 모든 사용자가 작성한 장애 처리현황 게시물을 가져온다.
    else {
      QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
          .collection('obsPosts')
          .orderBy('postTime', descending: true)
          .get();

      return data.docs;
    }
  }

  // 문서 처리현황 게시물을 postTime 내림차순 기준으로 가져오는 method
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getInqPostData(UserClassification userType) async {
    // 사용자가 일반 사용자이면?
    //-> 사용자가 작성한 장애 처리현황 게시물만 가져온다.
    if (userType == UserClassification.GENERALUSER) {
      // postTime 속성을 내림차순으로 정렬한다.
      QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
          .collection('inqPosts')
          .orderBy('postTime', descending: true)
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> ultimateData =
          data.docs;

      // 자신이 쓴 게시물만 가져온다.
      ultimateData.removeWhere(
          (QueryDocumentSnapshot<Map<String, dynamic>> element) =>
              element.data()['userUid'].toString() !=
              SettingsController.to.settingUser!.userUid);

      return ultimateData;
    }
    // 사용자가 IT 담당자이면?
    // 모든 사용자가 작성한 장애 처리현황 게시물을 가져온다.
    else {
      QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
          .collection('inqPosts')
          .orderBy('postTime', descending: true)
          .get();

      return data.docs;
    }
  }

  // Firebase DataBase에 Post 정보를 set하는 method
  static Future<void> setPostData(PostModel post, String postUid) async {
    // 업로드 하려는 게시물이 장애 처리현황이다.
    if (post.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      await _firebaseFirestore
          .collection('obsPosts')
          .doc(postUid)
          .set(PostModel.toMap(post));
    }
    // 업로드 하려는 게시물이 문의 처리현황이다.
    else {
      await _firebaseFirestore
          .collection('inqPosts')
          .doc(postUid)
          .set(PostModel.toMap(post));
    }
  }

  // DataBase에 obsPosts 또는 inqPosts 정보를 get하는 method
  static Future<PostModel> getPostData(PostModel postData) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot;

    // 해당 게시물이 장애 처리현황 게시물인 경우..
    if (postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      documentSnapshot = await _firebaseFirestore
          .collection('obsPosts')
          .doc(postData.postUid)
          .get();
    }
    // 문의 처리현황 게시물인 경우...
    else {
      documentSnapshot = await _firebaseFirestore
          .collection('inqPosts')
          .doc(postData.postUid)
          .get();
    }
    // 1. Database에 게시물에 대한 whoWriteCommentThePost를 업데이트하고, 최신의 값을 가지는 작업
    postData.whoWriteCommentThePost = List<String>.from(
        documentSnapshot.data()!['whoWriteCommentThePost'] as List);

    // 2. DataBase 게시물에 대한 처리상태를 업데이트하고, 최신의 값을 가지는 작업
    
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await documentSnapshot
        .reference
        .collection('comments')
        .orderBy('uploadTime', descending: true)
        .get();

    // List로 변환한다.
    List<QueryDocumentSnapshot<Map<String, dynamic>>> comment =
        querySnapshot.docs;

    // 일반 사용자가 올린 댓글은 삭제한다.
    // IT 담당자가 올린 댓글만 저장한다.
    comment.removeWhere(
      (QueryDocumentSnapshot<Map<String, dynamic>> element) =>
          element.data()['proStatus'].toString() == 'ProClassification.NONE',
    );

    // IT 담당자가 올린 댓글이 있는지 없는지 판단한다.
    // -> IT 담당자가 올린 댓글이 없으면 게시물에 대한 처리상태를 WAITING(대기)로 결정한다.
    // -> IT 담당자가 올린 댓글이 있으면, 가장 최신 댓글에 대한 처리상태를 게시물에 대한 처리상태로 결정한다.
    comment.isEmpty
        ? await documentSnapshot.reference
            .update({'proStatus': 'ProClassification.WAITING'})
        : await documentSnapshot.reference.update(
            {'proStatus': comment.first.data()['proStatus'].toString()});

    // 화면에 보이는 게시물에 대한 처리상태를 업데이트 한다.
    // -> IT 담당자가 올린 댓글이 없었다면, 게시물에 대한 처리상태는 WAITING(대기)가 된다.
    // -> 만약 IT 담당자가 올린 댓글이 있었다면, 가장 최근에 올린 댓글에 대한 처리상태를 바탕으로 게시물에 대한 처리상태가 결정된다.
    comment.isEmpty
        ? postData.proStatus = ProClassification.WAITING
        : postData.proStatus = ProClassification.values.firstWhere(
            (element) =>
                element.toString() ==
                comment.first.data()['proStatus'].toString(),
          );

    return postData;
  }

  // DataBase에 게시물을 delete하는 method (postuid 필요)
  static Future<void> deletePostData(PostModel postData) async {
    // 게시물에 대한 imageList(이미지 url)를 가져온다.
    List<String> imageList = postData.imageList;

    // 게시물과 관련된 이미지를 FirebaseStorage에서 제거한다.
    if (imageList.isNotEmpty) {
      for (String image in imageList) {
        await _firebaseStorage.refFromURL(image).delete();
      }
    }

    // DataBase에서 게시물(obsPosts or inqPosts)을 삭제한다.
    // 헤당 게시물이 장애 처리현황인 경우...
    if (postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      await _firebaseFirestore
          .collection('obsPosts')
          .doc(postData.postUid)
          .delete();
    }
    // 해당 게시물이 문의 처리현황인 경우...
    else {
      await _firebaseFirestore
          .collection('inqPosts')
          .doc(postData.postUid)
          .delete();
    }
  }

  // 게시물이 삭제되었는지 확인하는 method
  static Future<bool> isDeletePost(ObsOrInqClassification obsOrInq, String postUid) async {
    DocumentSnapshot<Map<String, dynamic>> postData;

    // 확인하려는 게시물이 장애 처리현황인 경우...
    if (obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      postData =
          await _firebaseFirestore.collection('obsPosts').doc(postUid).get();
    }
    // 확인하려는 게시물이 문의 처리현황인 경우...
    else {
      postData =
          await _firebaseFirestore.collection('inqPosts').doc(postUid).get();
    }

    // 게시물 Uid에 대한 doc이 없으면 true를 반환한다.
    return !(postData.exists);
  }

  // transaction을 사용할 경우
  // DocumentReference 데이터 타입이여야 한다.
  // 따라서 getPostData method가 있어도, DocumentReference 데이터 타입을 가진 getPostData를 따로 만든 것이다.
  // DataBase에 게시물 데이터를에 접근하는 method
  static DocumentReference<Map<String, dynamic>> documentReferenceGetPostData(ObsOrInqClassification obsOrInq, String postUid) {
    DocumentReference<Map<String, dynamic>> documentRefrence;
    // 해당 게시물이 장애 처리현황 게시물인 경우..
    if (obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      documentRefrence = _firebaseFirestore.collection('obsPosts').doc(postUid);
    }
    // 문의 처리현황 게시물인 경우...
    else {
      documentRefrence = _firebaseFirestore.collection('inqPosts').doc(postUid);
    }

    return documentRefrence;
  }

  // Database에 게시물(post)의 whoWriteCommentThePost 속성에 사용자 uid를 추가하는 method
  static Future<void> addWhoWriteCommentThePost(PostModel postData, String userUid) async {
    // 반환 타입이 DocumentReference으로 DataBase에 게시물 데이터에 접근하는 method
    DocumentReference<Map<String, dynamic>> documentReference =
        documentReferenceGetPostData(postData.obsOrInq, postData.postUid);

    // 여러 사용자가 동시에 접근하여 대량의 트래픽이 발생할 경우를 대비해 transaction을 이용한다.
    await _firebaseFirestore.runTransaction(
      maxAttempts: 5,
      (transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get<Map<String, dynamic>>(documentReference);

        if (!snapshot.exists) {
          throw Exception('Does not exists');
        }

        List<String> whoWriteCommentThePost = List<String>.from(
            snapshot.data()!['whoWriteCommentThePost'] as List);

        whoWriteCommentThePost.add(userUid);

        transaction.update(
          documentReference,
          {'whoWriteCommentThePost': whoWriteCommentThePost},
        );
      },
    );
  }

  // DataBase에 comment(댓글)을 가져오는 method
  static DocumentReference<Map<String, dynamic>> getCommentData(
      CommentModel comment, PostModel postData) {
    DocumentReference<Map<String, dynamic>> documentRefrence;
    // 댓글과 관련된 게시물이 장애 처리현황 게시물인 경우..
    if (postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      documentRefrence = _firebaseFirestore
          .collection('obsPosts')
          .doc(postData.postUid)
          .collection('comments')
          .doc(comment.commentUid);
    }
    // 댓글과 관련된 게시물이 문의 처리현황 게시물인 경우...
    else {
      documentRefrence = _firebaseFirestore
          .collection('obsPosts')
          .doc(postData.postUid)
          .collection('comments')
          .doc(comment.commentUid);
    }

    return documentRefrence;
  }

  // DataBase에 comment(댓글)을 추가하는 method
  static Future<void> setCommentData(CommentModel commentModel, PostModel postData) async {
    // 댓글과 관련된 게시물이 장애 처리현황인 경우
    if (postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus) {
      // Database에 comment 정보를 set한다.
      await _firebaseFirestore
          .collection('obsPosts')
          .doc(commentModel.belongCommentPostUid)
          .collection('comments')
          .doc(commentModel.commentUid)
          .set(CommentModel.toMap(commentModel));
    }
    // 댓글과 관련된 게시물이 문의 처리현황인 경우
    else {
      // Database에 comment 정보를 set한다.
      await _firebaseFirestore
          .collection('inqPosts')
          .doc(commentModel.belongCommentPostUid)
          .collection('comments')
          .doc(commentModel.commentUid)
          .set(CommentModel.toMap(commentModel));
    }
  }

  // Database에서 게시물(post)에 대한 여러 comment를 가져오는 method
  static Future<Map<String, dynamic>> getCommentAndUser(PostModel postData) async {
    // Database에서 게시물(post)에 해당하는 여러 comment을 가져온다.
    QuerySnapshot<Map<String, dynamic>> comments =
        (postData.obsOrInq == ObsOrInqClassification.obstacleHandlingStatus
            ? await _firebaseFirestore
                .collection('obsPosts')
                .doc(postData.postUid)
                .collection('comments')
                .orderBy('uploadTime', descending: false)
                .get()
            : await _firebaseFirestore
                .collection('inqPosts')
                .doc(postData.postUid)
                .collection('comments')
                .orderBy('uploadTime', descending: false)
                .get());

    // 여러 Comment와 Comment에 대한 User를 담는 Map를 설정한다.
    Map<String, dynamic> commentAndUser = {};

    // 여러 comment를 관리하는 배열을 생성한다.
    List<CommentModel> commentArray = [];

    // 배열에 여러 개 comment를 추가한다.
    comments.docs.forEach(
      (comment) {
        commentArray.add(CommentModel.fromMap(comment.data()));
      },
    );

    // 여러 commen에 대한 User를 관리하는 배열을 생성한다.
    List<UserModel> commentUserArray = [];

    // comment의 whoWriteUserUid 속성을 참고하여
    // Database에서 User를 가져온다.
    for (CommentModel comment in commentArray) {
      DocumentSnapshot<Map<String, dynamic>> user = await _firebaseFirestore
          .collection('users')
          .doc(comment.whoWriteUserUid)
          .get();

      commentUserArray.add(UserModel.fromMap(user.data()!));
    }

    // Map에 commentArray와 comentUserArray을 삽입한다.
    commentAndUser['commentArray'] = commentArray;
    commentAndUser['commnetUserArray'] = commentUserArray;

    return commentAndUser;
  }

  // Database에 comment을 삭제한다.
  static Future<void> deleteComment(CommentModel comment, PostModel postData) async {
    // Database의 comemnt을 가져온다.
    DocumentReference<Map<String, dynamic>> commentReference =
        getCommentData(comment, postData);

    // Database의 comment을 삭제한다.
    await commentReference.delete();

    // 반환 타입이 DocumentReference으로 DataBase에 게시물 데이터에 접근하는 method
    DocumentReference<Map<String, dynamic>> postReference =
        documentReferenceGetPostData(postData.obsOrInq, postData.postUid);

    // Database의 post에 존재하는 whoWriteCommentThePost 속성에 comment를 쓴 사용자 uid를 삭제한다.
    // 대량의 트래픽이 발생할 경우를 대비해 transaction을 이용한다.
    await _firebaseFirestore.runTransaction(
      maxAttempts: 5,
      (transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get<Map<String, dynamic>>(postReference);

        if (!snapshot.exists) {
          throw Exception('Does not exists');
        }

        List<String> whoWriteCommentThePost = List<String>.from(
            snapshot.data()!['whoWriteCommentThePost'] as List);

        whoWriteCommentThePost
            .remove(SettingsController.to.settingUser!.userUid);

        transaction.update(
          postReference,
          {'whoWriteCommentThePost': whoWriteCommentThePost},
        );
      },
    );
  }

  // Database에 User의 notiPost 속성에 게시물 uid를 추가한다.
  static Future<void> addNotiPostFromUser(String postUid, String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    List<String> notiPost = List<String>.from(user.data()!['notiPost'] as List);

    notiPost.add(postUid);

    await _firebaseFirestore.collection('users').doc(userUid).update(
      {'notiPost': notiPost},
    );
  }

  // Database에 User의 notiPost 속성에 게시물 uid를 삭제한다.
  static Future<void> deleteNotiPostFromUser(String postUid, String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    List<String> notiPost = List<String>.from(user.data()!['notiPost'] as List);

    notiPost.remove(postUid);

    await _firebaseFirestore.collection('users').doc(userUid).update(
      {'notiPost': notiPost},
    );
  }

  // Database에 User의 notiPost 속성을 가져와 notiPost Array에 값을 대입한다.
  static Future<List<String>> getNotiPostFromUser(String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    return List<String>.from(user.data()!['notiPost'] as List);
  }

  // 알림 신청한 장애 처리현황 또는 문의 처리현황 게시글에 대한 댓글(comment)의 개수를 반환하는 method
  static Future<int> getCountFromComments(String postUid) async {
    QuerySnapshot<Map<String, dynamic>> comments;

    // 알림 신청한 게시물이 장애 처리현황인지 문의 처리현황인지 확인한다.
    DocumentSnapshot<Map<String, dynamic>> whichBelongPostUid =
        await _firebaseFirestore.collection('obsPosts').doc(postUid).get();

    // 알림 신청한 게시물이 장애 처리현황에 속한다면?
    if (whichBelongPostUid.data() != null) {
      comments = await _firebaseFirestore
          .collection('obsPosts')
          .doc(postUid)
          .collection('comments')
          .get();
    }
    // 알림 신청한 게시물이 장애 처리현황에 속하지 않는다면?
    else {
      comments = await _firebaseFirestore
          .collection('inqPosts')
          .doc(postUid)
          .collection('comments')
          .get();
    }

    // 해당 게시물에 대한 댓글 개수를 반환한다.
    return comments.size;
  }

  // Database에 Notificaion을 모두 가져오는 method
  static Future<List<NotificationModel>> getNotificationFromUser(
      String userUid) async {
    List<NotificationModel> notificationModelList = [];

    QuerySnapshot<Map<String, dynamic>> notifications = await _firebaseFirestore
        .collection('users')
        .doc(userUid)
        .collection('notifications')
        .orderBy('notiTime', descending: true)
        .get();

    notifications.docs.forEach(
      (notificationModel) {
        notificationModelList.add(
          NotificationModel.fromMap(notificationModel.data()),
        );
      },
    );

    return notificationModelList;
  }

  // Database에 Notification을 삭제하는 method
  static Future<void> deleteNotification(String notiUid, String userUid) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userUid)
        .collection('notifications')
        .doc(notiUid)
        .delete();
  }
}
