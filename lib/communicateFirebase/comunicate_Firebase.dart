import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
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
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /* _firebaseFirestore를 얻기 위한 method
     여러 곳애서 다른 Instnace를 쓰지 말고 같은 Instance를 쓰게 하기 위함이다. */
  static FirebaseFirestore getFirebaseFirestoreInstnace() {
    return _firebaseFirestore;
  }

  // Database에서 uid가 있는지 확인하는 method
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

  // SignUpPage에 있는 Image를 Firebase Storage에 upload하는 method
  static UploadTask signUpPageImageToStroage({required File imageFile, required String userUid}) {
    // ImageFile의 확장자(png, jpg) 가져오기
    String imageFileExt = imageFile.toString().split('.').last.substring(0, 3);

    // image를 Firebase Storage 어떤 경로에 배치할 지 정한다.
    Reference storageReference = _firebaseStorage
        .ref()
        .child('users/$userUid/${UUidUtil.getUUid()}.$imageFileExt');

    // image를 해당 경로에 저장한다.
    UploadTask uploadFileEvent = storageReference.putFile(imageFile);

    return uploadFileEvent;
  }

  // EditProfilePage에서 수정한 Image를 Firebase Storage에 update하는 method
  static Future<UploadTask> editProfilePageImageToStorage({
    required File imageFile,
    required String? image,
    required String userUid,
  }) async {
    // ImageFile의 확장자(png, jpg) 가져오기
    String imageFileExt = imageFile.toString().split('.').last.substring(0, 3);

    /* 사용자에 대한 이미지가 null 값이 아닐 떄    
       즉, 사용자가 회원 가입 했을 떄 이미지를 등록했었을 떄 
       Firebase Storage에 이미지에 대한 파일이 존재하므로 이를 삭제하는 if문 */
    if (image != null) {
      // Firebase Stroage에 존재하던 파일을 삭제한다.
      await _firebaseStorage
          .refFromURL(SettingsController.to.settingUser!.image.toString())
          .delete();
    }

    // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
    Reference storageReference = _firebaseStorage
        .ref()
        .child('users/$userUid/${UUidUtil.getUUid()}.$imageFileExt');

    // image를 해당 경로에 저장한다.
    UploadTask uploadFileEvent = storageReference.putFile(imageFile);

    return uploadFileEvent;
  }

  // PostingPage에서 image를 게시했으면 Firebase Storage에 upload하는 method
  static Map<String, dynamic> postingPageImageToStorage({required RxList<File> imageList, required String userUid}) {
    // UploadTask을 관리하는 배열 입니다.
    List<UploadTask> uploadTasks = [];

    // 게시물 Uid를 정립한 것이다.
    String postUUid = UUidUtil.getUUid();

    // 사용자가 PostingPage에서 게시한 image 개수만큼 for문을 돈다.
    for (File image in imageList) {
      // ImageFile의 확장자(png, jpg) 가져오기
      String imageFileExt = image.toString().split('.').last.substring(0, 3);

      // image를 FirebaseStorage 어떤 경로에 배치할 지 정한다.
      Reference storageReference = _firebaseStorage.ref().child(
          'itRequestPosts/$postUUid/${UUidUtil.getUUid()}.$imageFileExt');

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

  // Firebase Storage에 upload, update된 image를 download 하는 method
  static Future<String> imageDownloadUrl(UploadTask uploadFileEvent) async {
    String imageUrl = await (await uploadFileEvent.whenComplete(() => null))
        .ref
        .getDownloadURL();

    return imageUrl;
  }

  // DataBase에 사용자 정보(Users)를 set하는 method
  static Future<void> setUser(UserModel user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.userUid)
        .set(UserModel.toMap(user));
  }

  // DataBase에서 사용자 정보(Users)를 get하는 method
  static Future<Map<String, dynamic>> getUser(String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> userData =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    return userData.data()!;
  }

  // DataBase에 User 정보를 update하는 method
  static Future<void> updateUser(UserModel updateUser) async {
    await _firebaseFirestore
        .collection('users')
        .doc(updateUser.userUid)
        .update(UserModel.toMap(updateUser));
  }

  // DataBase에 IT 요청건 게시물(itRequestPosts)에 phoneNumber 속성을 최신 상태로 update 한다.
  static Future<void> updatePhoneNumberInPost(UserModel userModel) async {
    QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
        .collection('itRequestPosts')
        .where('userUid', isEqualTo: userModel.userUid)
        .get();

    data.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> element) {
      element.reference.update({'phoneNumber': userModel.phoneNumber});
    });
  }

  // DataBase에 존재하는 IT 요청건 게시물의 postTime 속성을 내림차순 기준으로 비교하여 배열로 가져오는 method
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getITRequestPosts(UserClassification userType) async {
    // DataBase에 존재하는 IT 요청건 게시물의 postTime 속성을 내림차순으로 정렬해서 가져온다.
    QuerySnapshot<Map<String, dynamic>> data = await _firebaseFirestore
        .collection('itRequestPosts')
        .orderBy('postTime', descending: true)
        .get();

    // 사용자 자격이 IT 담당자이면? -> 모든 IT 요청건 게시물을 가져온다.
    if (userType == UserClassification.IT1USER ||
        userType == UserClassification.IT2USER) return data.docs;

    /* 사용자가 일반 요청자라면? -> 사용자가 작성한 IT 요청건 게시물만 가져온다. 
       (182번 ~ 193번 줄) */

    // removeWhere()를 쓰기 위해서 데이터 타입을 List<QueryDocumentSnapshot<Map<String, dynamic>>>으로 변환한다.
    List<QueryDocumentSnapshot<Map<String, dynamic>>> ultimateData = data.docs;

    // 일반 요청자가 작성한 게시물만 놔둔다.
    ultimateData.removeWhere(
      (QueryDocumentSnapshot<Map<String, dynamic>> element) =>
          element.data()['userUid'].toString() !=
          SettingsController.to.settingUser!.userUid,
    );

    // 일반 요청자가 작성한 IT 요청건 게시물만 반환한다.
    return ultimateData;
  }

  // Firebase DataBase에 IT 요청건 게시물을 set하는 method
  static Future<void> setPost(PostModel post, String postUid) async {
    await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(postUid)
        .set(PostModel.toMap(post));
  }

  // DataBase에 게시물 정보(itRequestPosts)를 get하는 method
  static Future<PostModel> getPost(PostModel postData) async {
    // DataBase에 게시물 정보(itRequestPosts)를 얻는다.
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firebaseFirestore
            .collection('itRequestPosts')
            .doc(postData.postUid)
            .get();

    // Database에 게시물에 대한 whoWriteCommentThePost를 업데이트하고, 최신의 값을 가진다.
    postData.whoWriteCommentThePost = List<String>.from(
        documentSnapshot.data()!['whoWriteCommentThePost'] as List);

    // Database에서 게시물에 대한 댓글 데이터를 얻는다.
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await documentSnapshot
        .reference
        .collection('comments')
        .orderBy('uploadTime', descending: true)
        .get();

    // removeWhere()을 쓰기 위해서 데이터 타입을 List<QueryDocumentSnapshot<Map<String, dynamic>>>으로 변환한다.
    List<QueryDocumentSnapshot<Map<String, dynamic>>> comments =
        querySnapshot.docs;

    /* 일반 사용자가 올린 댓글은 삭제한다.
       IT 담당자가 올린 댓글만 저장한다. */
    comments.removeWhere(
      (QueryDocumentSnapshot<Map<String, dynamic>> element) =>
          element.data()['proStatus'].toString() == 'ProClassification.NONE',
    );

    /* IT 담당자가 올린 댓글이 있는지 없는지 판단한다.
       -> IT 담당자가 올린 댓글이 없으면  DataBase에 존재하는 게시물(itRequestPosts)에 대한 proStatus 속성을 WAITING(대기)로 결정한다.
       -> IT 담당자가 올린 댓글이 있으면, DataBase에 존재하는 게시물(itRequestPosts)에 대한 proStatus 속성을 
          IT 담당자가 가장 최근 댓글을 작성했을 떄 처리 상태를 무엇으로 설정했는지에 따라 이를 결정한다. */
    comments.isEmpty
        ? await documentSnapshot.reference
            .update({'proStatus': 'ProClassification.WAITING'})
        : await documentSnapshot.reference.update(
            {'proStatus': comments.first.data()['proStatus'].toString()},
          );

    /* 화면에 보이는 게시물에 대한 처리상태를 업데이트 한다.
       -> IT 담당자가 올린 댓글이 없었다면, 게시물에 대한 처리상태는 WAITING(대기)가 된다.
       -> 만약 IT 담당자가 올린 댓글이 있었다면, IT 담당자가 가장 최근 댓글을 작성했을 떄 처리 상태를 무엇으로 설정했는지에 따라 이를 결정한다. */
    comments.isEmpty
        ? postData.proStatus = ProClassification.WAITING
        : postData.proStatus = ProClassification.values.firstWhere(
            (element) =>
                element.toString() ==
                comments.first.data()['proStatus'].toString(),
          );

    return postData;
  }

  // DataBase에 IT 요청건 게시물을 delete하는 method
  static Future<void> deletePost(PostModel postData) async {
    // 게시물에 대한 imageList(이미지 url)를 가져온다.
    List<String> imageList = postData.imageList;

    // 게시물과 관련된 이미지를 Firebase Storage에서 제거한다.
    if (imageList.isNotEmpty) {
      for (String image in imageList) {
        await _firebaseStorage.refFromURL(image).delete();
      }
    }

    /* IT 요청건 게시물에 대한 댓글이 있으면 댓글을 삭제한다. 
       (274줄 ~ 286줄) */
    QuerySnapshot<Map<String, dynamic>> comments = await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(postData.postUid)
        .collection('comments')
        .get();
    for (int i = 0; i < comments.size; i++) {
      await _firebaseFirestore
          .collection('itRequestPosts')
          .doc(postData.postUid)
          .collection('comments')
          .doc(comments.docs[i].data()['commentUid'])
          .delete();
    }

    // IT 요청건 게시물을 삭제한다.
    await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(postData.postUid)
        .delete();
  }

  // Database에서 IT 요청건 게시물의 postUid가 있는지 없는지 확인하는 method
  static Future<bool> isDeletePost(String postUid) async {
    DocumentSnapshot<Map<String, dynamic>> postData = await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(postUid)
        .get();

    // IT 요청건 게시물에 대한 postUid가 없으면 true, 있으면 false를 반환한다.
    return !(postData.exists);
  }

  /* transaction을 사용할 경우 DocumentReference<Map<String, dynamic>>> 데이터 타입이여야 한다.
     DataBase에 게시물 데이터를에 접근하는 method */
  static DocumentReference<Map<String, dynamic>> documentReferenceGetPost(
      String postUid) {
    DocumentReference<Map<String, dynamic>> documentRefrence =
        _firebaseFirestore.collection('itRequestPosts').doc(postUid);

    return documentRefrence;
  }

  // Database에 IT 요청건 게시물(itRequestPosts)의 whoWriteCommentThePost 속성에 사용자 uid를 추가하는 method
  static Future<void> addWhoWriteCommentThePost(PostModel postData, String userUid) async {
    // 반환 타입이 DocumentReference으로 DataBase에 게시물 데이터에 접근하는 method
    DocumentReference<Map<String, dynamic>> documentReference =
        documentReferenceGetPost(postData.postUid);

    /* 여러 사용자가 동시에 접근하여 대량의 트래픽이 발생할 경우를 대비해 transaction을 이용한다. 
       왜냐하면 DataBase에 IT 요청건 게시물(itRequestPosts)의 whoWriteCommentThePost 속성은 다른 사용자들이 언제든지 접근할 수 
       있는 속성이기 떄문이다. 의도하지 않은 update가 되는 것을 방지한다. */
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
  static DocumentReference<Map<String, dynamic>> getComment(
      CommentModel comment, PostModel postData) {
    DocumentReference<Map<String, dynamic>> documentRefrence =
        _firebaseFirestore
            .collection('itRequestPosts')
            .doc(postData.postUid)
            .collection('comments')
            .doc(comment.commentUid);

    return documentRefrence;
  }

  // DataBase에 comment(댓글)을 추가하는 method
  static Future<void> setComment(
      CommentModel commentModel, PostModel postData) async {
    // Database에 comment 정보를 set한다.
    await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(commentModel.belongCommentPostUid)
        .collection('comments')
        .doc(commentModel.commentUid)
        .set(CommentModel.toMap(commentModel));
  }

  // Database에서 IT 요청건 게시물(itRequestPosts)에 대한 여러 comment를 가져오는 method
  static Future<Map<String, dynamic>> getComments(PostModel postData) async {
    // 여러 Comment와 comment에 대한 사용자 정보를 담는 Map를 설정한다.
    Map<String, dynamic> commentAndUser = {};
    // 여러 comment를 저장하는 배열을 생성한다.
    List<CommentModel> commentArray = [];
    // 댓글에 대한 사용자 정보를 비동기 처리로 한번에 받는 배열
    List<Future<DocumentSnapshot<Map<String, dynamic>>>> commentUserDataFuture = [];
    // 여러 commen에 대한 사용자 정보를 저장하는 배열을 생성한다.
    List<UserModel> commentUserArray = [];

    // Database에서 게시물(post)에 해당하는 여러 comment을 가져온다.
    QuerySnapshot<Map<String, dynamic>> comments = await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(postData.postUid)
        .collection('comments')
        .orderBy('uploadTime', descending: false)
        .get();

    // 위 commentArray 배열에 여러 개 comment를 추가한다.
    comments.docs.forEach(
      (comment) {
        commentArray.add(CommentModel.fromMap(comment.data()));
      },
    );

    /* comment의 whoWriteUserUid 속성을 참고하여 
       비동기 처리로 comment 대한 사용자 정보를 DataBase에 동시에 요청하고 userDataFutures 배열에 추가하는 for문 */
    for (CommentModel comment in commentArray) {
      commentUserDataFuture.add(
        _firebaseFirestore
            .collection('users')
            .doc(comment.whoWriteUserUid)
            .get(),
      );
    }

    // 댓글에 대한 사용자 정보를 동시에 요청해서 받은 것을 순서대로 저장한다.
    List<DocumentSnapshot<Map<String, dynamic>>> commentUserDataSequential =
        await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(
            commentUserDataFuture);

    // 순서대로 저장한 userDataSequential 배열을 바탕으로 위 commentArray 배열을 추가하는 for문
    for (int i = 0; i < commentUserDataSequential.length; i++) {
      // 댓글에 대한 사용자 정보를 담고 있는 commentUserArray에 사용자 정보를 추가한다.
      commentUserArray.add(
        UserModel.fromMap(commentUserDataSequential[i].data()!),
      );
    }

    // Map에 commentArray와 comentUserArray을 추가한다.
    commentAndUser['commentArray'] = commentArray;
    commentAndUser['commnetUserArray'] = commentUserArray;

    return commentAndUser;
  }

  // Database에 comment을 삭제한다.
  static Future<void> deleteComment(CommentModel comment, PostModel postData) async {
    // Database의 comemnt을 가져온다.
    DocumentReference<Map<String, dynamic>> commentReference =
        getComment(comment, postData);

    // Database의 comment을 삭제한다.
    await commentReference.delete();

    // 반환 타입이 DocumentReference으로 DataBase에 게시물 데이터에 접근하는 method
    DocumentReference<Map<String, dynamic>> postReference =
        documentReferenceGetPost(postData.postUid);

    /* Database의 IT 요청건 게시물에 존재하는 whoWriteCommentThePost 속성에 comment를 쓴 사용자 uid를 삭제한다.
       대량의 트래픽이 발생할 경우를 대비해 transaction을 이용한다. */
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

  /* Database에 Users의 commentNotificationPostUid 속성에
     사용자가 알림 신청한 게시물 uid를 추가한다. */
  static Future<void> addCommentNotificationPostUid(
      String postUid, String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    List<String> commentNotificationPostUid =
        List<String>.from(user.data()!['commentNotificationPostUid'] as List);

    commentNotificationPostUid.add(postUid);

    await _firebaseFirestore.collection('users').doc(userUid).update(
      {'commentNotificationPostUid': commentNotificationPostUid},
    );
  }

  /* Database에 User의 commentNotificationPostUid 속성에
    사용자가 알림 신청한 게시물 uid를 삭제한다. */
  static Future<void> deleteCommentNotificationPostUid(
      String postUid, String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    List<String> commentNotificationPostUid =
        List<String>.from(user.data()!['commentNotificationPostUid'] as List);

    commentNotificationPostUid.remove(postUid);

    await _firebaseFirestore.collection('users').doc(userUid).update(
      {'commentNotificationPostUid': commentNotificationPostUid},
    );
  }

  // Database에 Users의 commentNotificationPostUid 속성을 가져오는 method
  static Future<List<String>> getCommentNotificationPostUid(
      String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await _firebaseFirestore.collection('users').doc(userUid).get();

    return List<String>.from(
        user.data()!['commentNotificationPostUid'] as List);
  }

  /* 위 필드의 commentNotificationPostUidList의 성분,즉 사용자가 알림 신청한 게시물 uid를 이용한다.
     게시물 uid를 이용하여 DataBase에 게시물에 대한 댓글 개수를 찾는 method */
  static Future<int> getPostCommentCount(String postUid) async {
    QuerySnapshot<Map<String, dynamic>> comments = await _firebaseFirestore
        .collection('itRequestPosts')
        .doc(postUid)
        .collection('comments')
        .get();

    // 해당 게시물에 대한 댓글 개수를 반환한다.
    return comments.size;
  }

  // Database에 commentNotificaions에 있는 알림 기록를 모두 가져오는 method
  static Future<List<NotificationModel>> getCommentNotificationModelList(
      String userUid) async {
    List<NotificationModel> commentNotificationModelList = [];

    QuerySnapshot<Map<String, dynamic>> notifications = await _firebaseFirestore
        .collection('users')
        .doc(userUid)
        .collection('commentNotifications')
        .orderBy('notiTime', descending: true)
        .get();

    notifications.docs.forEach(
      (QueryDocumentSnapshot<Map<String, dynamic>> commentNotificationModel) {
        commentNotificationModelList.add(
          NotificationModel.fromMap(commentNotificationModel.data()),
        );
      },
    );

    return commentNotificationModelList;
  }

  // Database에 requestNotificaions에 있는 알림 기록를 모두 가져오는 method
  static Future<List<NotificationModel>> getRequestNotificationModelList(
      String userUid) async {
    List<NotificationModel> requestNotificationModelList = [];

    QuerySnapshot<Map<String, dynamic>> notifications = await _firebaseFirestore
        .collection('users')
        .doc(userUid)
        .collection('requestNotifications')
        .orderBy('notiTime', descending: true)
        .get();

    notifications.docs.forEach(
      (QueryDocumentSnapshot<Map<String, dynamic>> requestNotificationModel) {
        requestNotificationModelList.add(
          NotificationModel.fromMap(requestNotificationModel.data()),
        );
      },
    );

    return requestNotificationModelList;
  }

  // Databse에 commentNotifications에 있는 어떤 알림을 삭제하는 method
  static Future<void> deleteCommentNotification(
      String notiUid, String userUid) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userUid)
        .collection('commentNotifications')
        .doc(notiUid)
        .delete();
  }

  // Databse에 requestNotifications에 있는 어떤 알림을 삭제하는 method
  static Future<void> deleteRequestNotification(
      String notiUid, String userUid) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userUid)
        .collection('requestNotifications')
        .doc(notiUid)
        .delete();
  }
}
