// 게시물에 대한 Model class입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_desk/const/obsOrInqClassification.dart';
import 'package:help_desk/const/proClassification.dart';
import 'package:help_desk/const/sysClassification.dart';
import 'package:help_desk/screen/bottomNavigationBar/controller/posting_controller.dart';

class PostModel {
  // 게시물이 장애 처리 현황에 속해있는가? 아니면 문의 처리현황에 속해있는가?
  ObsOrInqClassification obsOrInq;

  // 게시물은 분류코드가 무엇인가?
  SysClassification sysClassficationCode;

  // 이미지
  List<String> imageList;

  // 글 제목
  String postTitle;

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
    required this.obsOrInq,
    required this.sysClassficationCode,
    required this.imageList,
    required this.postTitle,
    required this.postContent,
    required this.phoneNumber,
    required this.proStatus,
    required this.userUid,
    required this.postUid,
    required this.postTime,
    required this.whoWriteCommentThePost,
  });

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(PostModel post) {
    // 게시물을 올릴 떄 image을 올리는 경우가 있고, 그렇지 않은 경우가 있다.
    // image을 올리지 않으면 빈 배열로 설정한다.

    // Firebase에 데이터를 넣을 떄 원시 타입만 허용한다.
    // 여기서 enum 타입을 넣으려 하면 문제가 발생한다. 따라서 toString()를 이용해 string 타입으로 변환한다.
    return {
      'obsOrInq': post.obsOrInq.toString(),
      'sysClassficationCode': post.sysClassficationCode.toString(),
      'imageList': post.imageList.isNotEmpty ? post.imageList : [],
      'postTitle': post.postTitle,
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

  // QueryDocumentSnapshot를 Json 형식으로 바꾸는 Method
  PostModel.fromQueryDocumentSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> mapData,
  ) : this.fromJson(mapData.data());

  // Json 형식을 Model class 형식으로 바꾸는 Method
  // dynamic를 String으로 전환하는 것은 쉽지만
  // List<dynamic>을 List<String>으로 전환하는 작업이 어렵다.
  PostModel.fromJson(Map<String, dynamic> json)
      : obsOrInq = ObsOrInqClassification.values.firstWhere(
          (enumValue) => enumValue.toString() == json['obsOrInq'].toString(),
        ),
        sysClassficationCode = SysClassification.values.firstWhere(
          (enumValue) =>
              enumValue.toString() == json['sysClassficationCode'].toString(),
        ),
        imageList = List<String>.from(json['imageList'] as List),
        postTitle = json['postTitle'].toString(),
        postContent = json['postContent'].toString(),
        phoneNumber = json['phoneNumber'].toString(),
        proStatus = ProClassification.values.firstWhere(
          (enumValue) => enumValue.toString() == json['proStatus'].toString(),
        ),
        userUid = json['userUid'].toString(),
        postUid = json['postUid'].toString(),
        postTime = json['postTime'].toString(),
        whoWriteCommentThePost =
            List<String>.from(json['whoWriteCommentThePost'] as List);

  // PostModel를 복제하는 Method
  PostModel copyWith({
    ObsOrInqClassification? obsOrInq,
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
      obsOrInq: obsOrInq ?? this.obsOrInq,
      sysClassficationCode: sysClassficationCode ?? this.sysClassficationCode,
      imageList: imageList ?? this.imageList,
      postTitle: postTitle ?? this.postTitle,
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
