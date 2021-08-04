// 회의 리스트

class MeetingResponseModel {
  final String meetCode;
  final String meetId;
  final String meetDate;
  final String meetName;
  final String meetPlace;
  final int status;
  final String sDate;
  final String eDate;
  final int appoId;
  final String name;
  final String departName;
  final String regName;
  final String meetRoom;
  final String meetDay;
  final int meetTime;
  final String members;

  MeetingResponseModel({
    required this.meetCode,
    required this.meetId,
    required this.meetDate,
    required this.meetName,
    required this.meetPlace,
    required this.status,
    required this.sDate,
    required this.eDate,
    required this.appoId,
    required this.name,
    required this.departName,
    required this.regName,
    required this.meetRoom,
    required this.meetDay,
    required this.meetTime,
    required this.members,
  });

  factory MeetingResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetingResponseModel(
      meetCode: json['MEETCODE'] != null ? json['MEETCODE'] as String : "",
      meetId: json['MEETID'] != null ? json['MEETID'] as String : "",
      meetDate: json['MEETDATE'] != null ? json['MEETDATE'] as String : "",
      meetName: json['MEETNAME'] != null ? json['MEETNAME'] as String : "",
      meetPlace: json['MEETPLACE'] != null ? json['MEETPLACE'] as String : "",
      status: json['STATUS'] != null ? json['STATUS'] as int : 0,
      sDate: json['SDATE'] != null ? json['SDATE'] as String : "",
      eDate: json['EDATE'] != null ? json['EDATE'] as String : "",
      appoId: json['appoid'] != null ? json['appoid'] as int : 0,
      name: json['NAME'] != null ? json['NAME'] as String : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      regName: json['REGNAME'] != null ? json['REGNAME'] as String : "",
      meetRoom: json['MEETROOM'] != null ? json['MEETROOM'] as String : "",
      meetDay: json['MEETDAY'] != null ? json['MEETDAY'] as String : "",
      meetTime: json['MEETTIME'] != null ? json['MEETTIME'] as int : 0,
      members: json['MEMBERS'] != null ? json['MEMBERS'] as String : "",
    );
  }
}

class MeetingResultModel {
  List<MeetingResponseModel> meeting;

  MeetingResultModel({required this.meeting});

  factory MeetingResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<MeetingResponseModel> meetingList =
        list.map((i) => MeetingResponseModel.fromJson(i)).toList();
    return MeetingResultModel(meeting: meetingList);
  }
}

// 회의 상세정보

class MeetingDetailResponseModel {
  final String meetCode;
  final String meetId;
  final String meetDate;
  final String meetName;
  final String meetPlace;
  final int status;
  final String sDate;
  final String eDate;
  final int appoId;
  final String name;
  final String contents;
  final String departName;
  final String regName;
  final String meetRoom;
  final String meetDay;
  final int meetTime;
  final String members;
  final String hpToken;

  MeetingDetailResponseModel({
    required this.meetCode,
    required this.meetId,
    required this.meetDate,
    required this.meetName,
    required this.meetPlace,
    required this.status,
    required this.sDate,
    required this.eDate,
    required this.appoId,
    required this.contents,
    required this.name,
    required this.departName,
    required this.regName,
    required this.meetRoom,
    required this.meetDay,
    required this.meetTime,
    required this.members,
    required this.hpToken,
  });

  factory MeetingDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetingDetailResponseModel(
      meetCode: json['MEETCODE'] != null ? json['MEETCODE'] as String : "",
      meetId: json['MEETID'] != null ? json['MEETID'] as String : "",
      meetDate: json['MEETDATE'] != null ? json['MEETDATE'] as String : "",
      meetName: json['MEETNAME'] != null ? json['MEETNAME'] as String : "",
      meetPlace: json['MEETPLACE'] != null ? json['MEETPLACE'] as String : "",
      status: json['STATUS'] != null ? json['STATUS'] as int : 0,
      sDate: json['SDATE'] != null ? json['SDATE'] as String : "",
      eDate: json['EDATE'] != null ? json['EDATE'] as String : "",
      appoId: json['appoid'] != null ? json['appoid'] as int : 0,
      contents: json['CONTENTS'] != null ? json['CONTENTS'] as String : "",
      name: json['NAME'] != null ? json['NAME'] as String : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      regName: json['REGNAME'] != null ? json['REGNAME'] as String : "",
      meetRoom: json['MEETROOM'] != null ? json['MEETROOM'] as String : "",
      meetDay: json['MEETDAY'] != null ? json['MEETDAY'] as String : "",
      meetTime: json['MEETTIME'] != null ? json['MEETTIME'] as int : 0,
      members: json['MEMBERS'] != null ? json['MEMBERS'] as String : "",
      hpToken: json['HPTOKEN'] != null ? json['HPTOKEN'] as String : "",
    );
  }
}

class MeetingDetailResultModel {
  List<MeetingDetailResponseModel> detail;

  MeetingDetailResultModel({required this.detail});

  factory MeetingDetailResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<MeetingDetailResponseModel> detailList =
        list.map((i) => MeetingDetailResponseModel.fromJson(i)).toList();
    return MeetingDetailResultModel(detail: detailList);
  }
}

// 회의실 리스트

class MeetingPlaceResponseModel {
  final String codeId;
  final String codeBName;
  final String useYn;
  final int dispNo;

  MeetingPlaceResponseModel({
    required this.codeId,
    required this.codeBName,
    required this.useYn,
    required this.dispNo,
  });

  factory MeetingPlaceResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetingPlaceResponseModel(
      codeId: json['CODE_ID'] != null ? json['CODE_ID'] as String : "",
      codeBName: json['CODE_BNAME'] != null ? json['CODE_BNAME'] as String : "",
      useYn: json['USE_YN'] != null ? json['USE_YN'] as String : "",
      dispNo: json['DISP_NO'] != null ? json['DISP_NO'] as int : 0,
    );
  }
}

class MeetingPlaceResultModel {
  List<MeetingPlaceResponseModel> meetingPlace;

  MeetingPlaceResultModel({required this.meetingPlace});

  factory MeetingPlaceResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<MeetingPlaceResponseModel> meetingPlaceList =
        list.map((i) => MeetingPlaceResponseModel.fromJson(i)).toList();
    return MeetingPlaceResultModel(meetingPlace: meetingPlaceList);
  }
}

// 회의참석자 리스트

class MeetingMemberResponseModel {
  final String memberCode;
  final String meetCode;
  final String departCode;
  final String userId;
  final String departName;
  final String name;
  final String position;
  final String eMail;
  final int attend;
  final int agree;
  final String comment;

  MeetingMemberResponseModel({
    required this.memberCode,
    required this.meetCode,
    required this.departCode,
    required this.userId,
    required this.departName,
    required this.name,
    required this.position,
    required this.eMail,
    required this.attend,
    required this.agree,
    required this.comment,
  });

  factory MeetingMemberResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetingMemberResponseModel(
      memberCode:
          json['MEMBERCODE'] != null ? json['MEMBERCODE'] as String : "",
      meetCode: json['MEETCODE'] != null ? json['MEETCODE'] as String : "",
      departCode:
          json['DEPARTCODE'] != null ? json['DEPARTCODE'] as String : "",
      userId: json['USERID'] != null ? json['USERID'] as String : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      name: json['NAME'] != null ? json['NAME'] as String : "",
      position: json['POSITION'] != null ? json['POSITION'] as String : "",
      eMail: json['EMAIL'] != null ? json['EMAIL'] as String : "",
      attend: json['ATTEND'] != null ? json['ATTEND'] as int : 0,
      agree: json['AGREE'] != null ? json['AGREE'] as int : 0,
      comment: json['COMMENT'] != null ? json['COMMENT'] as String : "",
    );
  }
}

class MeetingMemberResultModel {
  List<MeetingMemberResponseModel> meetingMember;

  MeetingMemberResultModel({required this.meetingMember});

  factory MeetingMemberResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<MeetingMemberResponseModel> meetingMemberList =
        list.map((i) => MeetingMemberResponseModel.fromJson(i)).toList();
    return MeetingMemberResultModel(meetingMember: meetingMemberList);
  }
}

// 회의참석자 리스트

class MeetingCommentResponseModel {
  final String commentCode;
  final String parentCommentCode;
  final String departCode;
  final String userId;
  final String departName;
  final String name;
  final String comment;
  final String regId;
  final String regDate;

  MeetingCommentResponseModel({
    required this.commentCode,
    required this.parentCommentCode,
    required this.departCode,
    required this.userId,
    required this.departName,
    required this.name,
    required this.comment,
    required this.regId,
    required this.regDate,
  });

  factory MeetingCommentResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetingCommentResponseModel(
      commentCode:
          json['COMMENTCODE'] != null ? json['COMMENTCODE'] as String : "",
      parentCommentCode: json['PARENTCOMMENTCODE'] != null
          ? json['PARENTCOMMENTCODE'] as String
          : "",
      departCode:
          json['DEPARTCODE'] != null ? json['DEPARTCODE'] as String : "",
      userId: json['USERID'] != null ? json['USERID'] as String : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      name: json['NAME'] != null ? json['NAME'] as String : "",
      comment: json['COMMENT'] != null ? json['COMMENT'] as String : "",
      regId: json['REGID'] != null ? json['REGID'] as String : "",
      regDate: json['REGDATE'] != null ? json['REGDATE'] as String : "",
    );
  }
}

class MeetingCommentResultModel {
  List<MeetingCommentResponseModel> meetingComment;

  MeetingCommentResultModel({required this.meetingComment});

  factory MeetingCommentResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<MeetingCommentResponseModel> meetingCommentList =
        list.map((i) => MeetingCommentResponseModel.fromJson(i)).toList();
    return MeetingCommentResultModel(meetingComment: meetingCommentList);
  }
}
