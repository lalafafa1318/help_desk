// User 계정의 토대가 되는 Model class 입니다.
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // 이름
  String? userName;
  // 설명
  String? description;
  // 활동사진
  String? image;
  // Uid
  String? userUid;

  // Default Constructor
  UserModel({
    this.userName,
    this.description,
    this.image,
    this.userUid,
  });

  // Instance를 복제하는 method
  UserModel copyWith({String? userName, String? description, String? image, String? userUid}) {
    return UserModel(
      userName: userName ?? this.userName,
      description: description ?? this.description,
      image: image ?? this.image,
      userUid: userUid ?? this.userUid,
    );
  }

  // Map를 Model class로 바꾸는 constructor
  UserModel.fromMap(Map<String, dynamic> mapData)
      : userName = mapData['userName'] ?? '',
        description = mapData['description'] ?? '',
        image = mapData['image'] ?? '',
        userUid = mapData['userUid'] ?? '';

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(UserModel user) {
    return {
      'userName': user.userName ?? '',
      'description': user.description ?? '',
      'image': user.image ?? '',
      'userUid': user.userUid ?? '',
    };
  }
}
