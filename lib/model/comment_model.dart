// 서버에 Comment 관련 정보를 저장하기 위해 틀을 마련하는 class 입니다.
class CommentModel {
  // 댓글 내용
  String content;

  // 댓글 업로드 시간
  String uploadTime;

  // 댓글 좋아요 클릭한 사람들
  List<String> whoCommentLike;

  // 댓글이 소속된 게시글 Uid
  String belongCommentPostUid;

  // 댓글 Uid
  String commentUid;

  // 댓글을 작성한 사용자 Uid
  String whoWriteUserUid;

  // 그외 어떤 속성들이 있는지 모르겠다. 생각이 나면 추가하기로 하자...

  // Default Constructor
  CommentModel({
    required this.content,
    required this.uploadTime,
    required this.whoCommentLike,
    required this.belongCommentPostUid,
    required this.commentUid,
    required this.whoWriteUserUid,
  });

  // Model class를 Map으로 바꾸는 method
  static Map<String, dynamic> toMap(CommentModel comment) {
    return {
      'content': comment.content,
      'uploadTime': comment.uploadTime,
      // whoCommentLike는 처음에 무조건 배열이 비어있다. 따라서 무조건 []으로 들어간다.
      'whoCommentLike':
          comment.whoCommentLike.isEmpty ? [] : comment.whoCommentLike,
      'belongCommentPostUid': comment.belongCommentPostUid,
      'commentUid': comment.commentUid,
      'whoWriteUserUid': comment.whoWriteUserUid,
    };
  }

  // map을 Model class로 변환하는 method
  factory CommentModel.fromMap(Map<String, dynamic> comment) => CommentModel(
        content: comment['content'].toString(),
        uploadTime: comment['uploadTime'].toString(),
        whoCommentLike: List<String>.from(comment['whoCommentLike'] as List),
        belongCommentPostUid: comment['belongCommentPostUid'].toString(),
        commentUid: comment['commentUid'].toString(),
        whoWriteUserUid: comment['whoWriteUserUid'].toString(),
      );
}
