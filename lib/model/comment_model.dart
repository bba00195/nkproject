class CommentResponseModel {
  final String commentCode;
  final String parentCommentCode;
  final String subject;
  final String subjectCode;
  final String regId;
  final String departName;
  final String userId;
  final String userName;
  final String regDate;
  final String comment;

  CommentResponseModel({
    required this.commentCode,
    required this.parentCommentCode,
    required this.subject,
    required this.subjectCode,
    required this.regId,
    required this.departName,
    required this.userId,
    required this.userName,
    required this.regDate,
    required this.comment,
  });

  factory CommentResponseModel.fromJson(Map<String, dynamic> json) {
    return CommentResponseModel(
      commentCode:
          json['COMMENTCODE'] != null ? json['COMMENTCODE'] as String : "",
      parentCommentCode: json['PARENTCOMMENTCODE'] != null
          ? json['PARENTCOMMENTCODE'] as String
          : "",
      subject: json['SUBJECT'] != null ? json['SUBJECT'] as String : "",
      subjectCode:
          json['SUBJECTCODE'] != null ? json['SUBJECTCODE'] as String : "",
      regId: json['REGID'] != null ? json['REGID'] as String : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      userId: json['USERID'] != null ? json['USERID'] as String : "",
      userName: json['USERNAME'] != null ? json['USERNAME'] as String : "",
      regDate: json['REGDATE'] != null ? json['REGDATE'] as String : "",
      comment: json['COMMENT'] != null ? json['COMMENT'] as String : "",
    );
  }
}

class CommentResultModel {
  List<CommentResponseModel> comment;

  CommentResultModel({required this.comment});

  factory CommentResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<CommentResponseModel> commentList =
        list.map((i) => CommentResponseModel.fromJson(i)).toList();
    return CommentResultModel(comment: commentList);
  }
}
