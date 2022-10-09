// 게시물에 대한 Model class입니다.
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  // 이미지
  List<String>? imageList;

  // 글 제목
  String? postTitle;

  // 글 내용
  String? postContent;

  // User Uid
  String? userUid;

  // 게시물 Uid
  String? postUid;

  // 게시물 올린 시간
  String? postTime;

  // 게시물 변경 시간
  String? changePostTime;

  // Default Constructor
  PostModel({
    this.imageList,
    this.postTitle,
    this.postContent,
    this.userUid,
    this.postUid,
    this.postTime,
    this.changePostTime,
  });

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(PostModel post) {
    return {
      'imageList': post.imageList ?? '',
      'postTitle': post.postTitle ?? '',
      'postContent': post.postContent ?? '',
      'userUid': post.userUid ?? '',
      'postUid': post.postUid ?? '',
      'postTime': post.postTime ?? '',
      'changePostTime': post.changePostTime ?? '',
    };
  }

  // QueryDocumentSnapshot를 Json 형식으로 바꾸는 Method
  PostModel.fromQueryDocumentSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> mapData,
  ) : this.fromJson(mapData.data());

  // Json 형식을 Model class 형식으로 바꾸는 Method
  PostModel.fromJson(Map<String, dynamic> json) {
    // imageList의 경우 List<dynamic> -> List<String>으로 바꾸는 작업
    List<dynamic> dynamic_imageList = json['imageList'];
    List<String>? listString_imageList =
        dynamic_imageList.map((e) => e.toString()).toList();

    // Model를 완성한다.
    imageList = listString_imageList;
    postTitle = json['postTitle'] ?? '';
    postContent = json['postContent'] ?? '';
    userUid = json['userUid'] ?? '';
    postUid = json['postUid'] ?? '';
    postTime = json['postTime'] ?? '';
    changePostTime = json['changePostTime'] ?? '';
    print('Model class 형식으로 바꾸는데 성공하였습니다 :)');
  }

  // Map를 Model class로 바꾸는 Method
  PostModel.fromMap(Map<String, dynamic> mapData)
      : imageList = mapData['imageList'] ?? '',
        postTitle = mapData['postTitle'] ?? '',
        postContent = mapData['postContent'] ?? '',
        userUid = mapData['userUid'] ?? '',
        postUid = mapData['postUid'] ?? '',
        postTime = mapData['postTime'] ?? '',
        changePostTime = mapData['changePostTime'] ?? '';
}
