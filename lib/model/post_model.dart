// 게시물에 대한 Model class입니다.
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  // 이미지
  List<String> imageList;

  // 글 제목
  String postTitle;

  // 글 내용
  String postContent;

  // User Uid
  String userUid;

  // 게시물 Uid
  String postUid;

  // 게시물 올린 시간
  String postTime;

  // 게시물 변경 시간
  String changePostTime;

  // 게시물 좋아요 클릭한 사람들
  List<String> whoLikeThePost;

  // 게시물 댓글 단 사람들

  // Default Constructor
  PostModel({
    required this.imageList,
    required this.postTitle,
    required this.postContent,
    required this.userUid,
    required this.postUid,
    required this.postTime,
    required this.changePostTime,
    required this.whoLikeThePost,
  });

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(PostModel post) {
    return {
      // 게시물을 올릴 떄 사진을 올리는 경우가 있고, 그렇지 않은 경우가 있다.
      // 사진을 올리지 않으면 빈 배열로 설정한다.
      'imageList': post.imageList.isNotEmpty ? post.imageList : [],
      'postTitle': post.postTitle,
      'postContent': post.postContent,
      'userUid': post.userUid,
      'postUid': post.postUid,
      'postTime': post.postTime,
      'changePostTime': post.changePostTime,
      // 게시물을 올릴 때 whoLikeThePost는 무조건 []이다.
      'whoLikeThePost':
          post.whoLikeThePost.isNotEmpty ? post.whoLikeThePost : [],
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
      : imageList = List<String>.from(json['imageList'] as List),
        postTitle = json['postTitle'].toString(),
        postContent = json['postContent'].toString(),
        userUid = json['userUid'].toString(),
        postUid = json['postUid'].toString(),
        postTime = json['postTime'].toString(),
        changePostTime = json['changePostTime'].toString(),
        whoLikeThePost = List<String>.from(json['whoLikeThePost'] as List);
}
