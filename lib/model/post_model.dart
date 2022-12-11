// 게시물에 대한 Model class입니다.
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';

class PostModel {
  // 게시물은 분류코드가 무엇인가?
  SysClassification sysClassficationCode;

  // 이미지
  List<String> imageList;

  // 글 내용
  String postContent;

  // 전화번호
  String phoneNumber;

  // 처리상태
  ProClassification proStatus;

  // UserUid
  String userUid;

  // 게시물 Uid
  String postUid;

  // 게시물 올린 시간
  String postTime;

  // 게시물에 대해 댓글을 단 사람들
  List<String> whoWriteCommentThePost;

  // Default Constructor
  PostModel({
    required this.sysClassficationCode,
    required this.imageList,
    required this.postContent,
    required this.phoneNumber,
    required this.proStatus,
    required this.userUid,
    required this.postUid,
    required this.postTime,
    required this.whoWriteCommentThePost,
  });

  // 일반 클래스를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(PostModel post) {
    return {
      'sysClassficationCode': post.sysClassficationCode.toString(),
      'imageList': post.imageList.isNotEmpty ? post.imageList : [],
      'postContent': post.postContent,
      'phoneNumber': post.phoneNumber,
      'proStatus': post.proStatus.toString(),
      'userUid': post.userUid,
      'postUid': post.postUid,
      'postTime': post.postTime,
      // 게시물을 올릴 떄 whoWriteCommentThePost는 무조건 []이다.
      'whoWriteCommentThePost': post.whoWriteCommentThePost.isNotEmpty
          ? post.whoWriteCommentThePost
          : [],
    };
  }

  // Map 형식을 일반 클래스 형식으로 바꾸는 Method
  PostModel.fromMap(Map<String, dynamic> mapData)
      : 
        sysClassficationCode = SysClassification.values.firstWhere(
          (enumValue) =>
              enumValue.toString() == mapData['sysClassficationCode'].toString(),
        ),
        imageList = List<String>.from(mapData['imageList'] as List),
        postContent = mapData['postContent'].toString(),
        phoneNumber = mapData['phoneNumber'].toString(),
        proStatus = ProClassification.values.firstWhere(
          (enumValue) => enumValue.toString() == mapData['proStatus'].toString(),
        ),
        userUid = mapData['userUid'].toString(),
        postUid = mapData['postUid'].toString(),
        postTime = mapData['postTime'].toString(),
        whoWriteCommentThePost =
            List<String>.from(mapData['whoWriteCommentThePost'] as List);

  // PostModel를 복제하는 Method
  PostModel copyWith({
    SysClassification? sysClassficationCode,
    List<String>? imageList,
    String? postTitle,
    String? postContent,
    String? phoneNumber,
    ProClassification? proStatus,
    String? userUid,
    String? postUid,
    String? postTime,
    List<String>? whoLikeThePost,
    List<String>? whoWriteCommentThePost,
  }) {
    return PostModel(
      sysClassficationCode: sysClassficationCode ?? this.sysClassficationCode,
      imageList: imageList ?? this.imageList,
      postContent: postContent ?? this.postContent,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      proStatus: proStatus ?? this.proStatus,
      userUid: userUid ?? this.userUid,
      postUid: postUid ?? this.postUid,
      postTime: postTime ?? this.postTime,
      whoWriteCommentThePost:
          whoWriteCommentThePost ?? this.whoWriteCommentThePost,
    );
  }
}
