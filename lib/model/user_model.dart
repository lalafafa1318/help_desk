// User 계정의 토대가 되는 Model class 입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_desk/const/userClassification.dart';

class UserModel {
  // 일반 사용자인가? IT 담당자인가?
  UserClassification userType;
  // 이름
  String userName;
  // 설명
  String description;
  // 활동사진
  String image;
  // Uid
  String userUid;
  // 알림 신청한 게시물
  List<String> notiPost;

  // Default Constructor
  UserModel({
    required this.userType,
    required this.userName,
    required this.description,
    required this.image,
    required this.userUid,
    required this.notiPost,
  });

  // Instance를 복제하는 method
  UserModel copyWith({
    UserClassification? userType,
    String? userName,
    String? description,
    String? image,
    String? userUid,
    List<String>? notiPost,
  }) {
    return UserModel(
      userType: userType ?? this.userType,
      userName: userName ?? this.userName,
      description: description ?? this.description,
      image: image ?? this.image,
      userUid: userUid ?? this.userUid,
      notiPost: notiPost ?? this.notiPost,
    );
  }

  // Map를 Model class로 바꾸는 constructor
  UserModel.fromMap(Map<String, dynamic> mapData)
      : userType = UserClassification.values.firstWhere(
          (element) => element.toString() == mapData['userType'].toString(),
        ),
        userName = mapData['userName'].toString(),
        description = mapData['description'].toString(),
        image = mapData['image'].toString(),
        userUid = mapData['userUid'].toString(),
        notiPost = List<String>.from(mapData['notiPost'] as List);

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(UserModel user) {
    return {
      // UserClassification 타입을 String 타입으로 바꿔서 Database에 저장한다.
      'userType': user.userType.toString(),
      'userName': user.userName,
      'description': user.description,
      'image': user.image,
      'userUid': user.userUid,
      'notiPost': user.notiPost.isNotEmpty ? user.notiPost : [],
    };
  }
}
