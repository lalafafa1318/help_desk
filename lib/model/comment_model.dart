// Database에 Comment 관련 정보를 저장하기 위해 틀을 마련하는 class 입니다.
import 'package:help_desk/const/causeObsClassification.dart';
import 'package:help_desk/const/proClassification.dart';

class CommentModel {
  // 댓글 내용
  String content;

  // 댓글 업로드 시간
  String uploadTime;

  // 댓글이 소속된 게시글 Uid
  String belongCommentPostUid;

  // 댓글 Uid
  String commentUid;

  // 댓글을 작성한 사용자 Uid
  String whoWriteUserUid;

  // 처리상태
  ProClassification proStatus;

  // 장애원인 (장애 처리현황 게시물인 경우에만 값이 들어간다.)
  CauseObsClassification causeOfDisability;

  // 실제 처리일자 (장애 처리현황 게시물인 경우에만 값이 들어간다.)
  String? actualProcessDate;

  // 실제 처리시간 (장애 처리현황 게시물인 경우에만 값이 들어간다.)
  String? actualProcessTime;

  // Default Constructor
  CommentModel({
    required this.content,
    required this.uploadTime,
    required this.belongCommentPostUid,
    required this.commentUid,
    required this.whoWriteUserUid,
    required this.proStatus,
    required this.causeOfDisability,
    required this.actualProcessDate,
    required this.actualProcessTime,
  });

  // Model class를 Map으로 바꾼다.
  static Map<String, dynamic> toMap(CommentModel commentModel) {
    return {
      'content': commentModel.content,
      'uploadTime': commentModel.uploadTime,
      'belongCommentPostUid': commentModel.belongCommentPostUid,
      'commentUid': commentModel.commentUid,
      'whoWriteUserUid': commentModel.whoWriteUserUid,
      // 처리상태
      'proStatus': commentModel.proStatus.toString(),
      // 장애원인 (장애 처리현황 게시물에 한함)
      'causeOfDisability': commentModel.causeOfDisability.toString(),
      // 실제 처리일자 (장애 처리현황 게시물에 한함)
      'actualProcessDate': commentModel.actualProcessDate,
      // 실제 처리시간 (장애 처리현황 게시물에 한함)
      'actualProcessTime': commentModel.actualProcessTime,
    };
  }

  // map을 Model class로 변환한다.
  factory CommentModel.fromMap(Map<String, dynamic> comment) => CommentModel(
        content: comment['content'].toString(),
        uploadTime: comment['uploadTime'].toString(),
        belongCommentPostUid: comment['belongCommentPostUid'].toString(),
        commentUid: comment['commentUid'].toString(),
        whoWriteUserUid: comment['whoWriteUserUid'].toString(),
        // 처리상태
        proStatus: ProClassification.values.firstWhere(
          (element) => element.toString() == comment['proStatus'].toString(),
        ),
        // 장애원인 (장애 처리현황 게시물에 한함)
        causeOfDisability: CauseObsClassification.values.firstWhere(
          (element) =>
              element.toString() == comment['causeOfDisability'].toString(),
        ),
        // 실제 처리일자 (장애 처리현황 게시물에 한함)
        actualProcessDate: comment['actualProcessDate'].toString() == 'null'
            ? null
            : comment['actualProcessDate'].toString(),
        // 실제 처리시간 (장애 처리현황 게시물에 한함)
        actualProcessTime: comment['actualProcessTime'].toString() == 'null'
            ? null
            : comment['actualProcessTime'].toString(),
      );
}
