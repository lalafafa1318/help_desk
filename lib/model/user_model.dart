// User 계정의 토대가 되는 Model class 입니다.
import 'package:help_desk/const/userClassification.dart';

class UserModel {
  // 일반 사용자인가? IT 담당자인가?
  UserClassification userType;
  // 이름
  String userName;
  // 활동사진
  String image;
  // Uid
  String userUid;
  // 사용자가 게시물 알림 신청했을 떄 해당 게시물 Uid
  List<String> commentNotificationPostUid;
  // 전화번호
  String phoneNumber;

  // Default Constructor
  UserModel({
    required this.userType,
    required this.userName,
    required this.image,
    required this.userUid,
    required this.commentNotificationPostUid,
    required this.phoneNumber,
  });

  // Instance를 복제하는 method
  UserModel copyWith({
    UserClassification? userType,
    String? userName,
    String? description,
    String? image,
    String? userUid,
    List<String>? commentNotificationPostUid,
    String? phoneNumber,
  }) {
    return UserModel(
      userType: userType ?? this.userType,
      userName: userName ?? this.userName,
      image: image ?? this.image,
      userUid: userUid ?? this.userUid,
      commentNotificationPostUid: commentNotificationPostUid ?? this.commentNotificationPostUid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  // Map를 Model class로 바꾸는 constructor
  UserModel.fromMap(Map<String, dynamic> mapData)
      : userType = UserClassification.values.firstWhere(
          (element) => element.toString() == mapData['userType'].toString(),
        ),
        userName = mapData['userName'].toString(),
        image = mapData['image'].toString(),
        userUid = mapData['userUid'].toString(),
        commentNotificationPostUid = List<String>.from(mapData['commentNotificationPostUid'] as List),
        phoneNumber = mapData['phoneNumber'].toString();

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(UserModel user) {
    return {
      // UserClassification 타입을 String 타입으로 바꿔서 Database에 저장한다.
      'userType': user.userType.toString(),
      'userName': user.userName,
      'image': user.image,
      'userUid': user.userUid,
      'commentNotificationPostUid': user.commentNotificationPostUid.isNotEmpty ? user.commentNotificationPostUid : [],
      'phoneNumber': user.phoneNumber,
    };
  }
}
