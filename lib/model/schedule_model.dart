class ScheduleListResponseModel {
  final int appoId;
  final String subject;
  final int appoState;
  final String regDate;
  final String regUserId;
  final String regUserName;
  final String starts;

  ScheduleListResponseModel({
    required this.appoId,
    required this.subject,
    required this.appoState,
    required this.regDate,
    required this.regUserId,
    required this.regUserName,
    required this.starts,
  });

  factory ScheduleListResponseModel.fromJson(Map<String, dynamic> json) {
    return ScheduleListResponseModel(
      appoId: json['appo_id'] != null ? json['appo_id'] as int : 0,
      subject: json['subject'] != null ? json['subject'] as String : "",
      appoState: json['appo_state'] != null ? json['appo_state'] as int : 0,
      regDate: json['reg_date'] != null ? json['reg_date'] as String : "",
      regUserId:
          json['reg_user_id'] != null ? json['reg_user_id'] as String : "",
      regUserName: json['NAME'] != null ? json['NAME'] as String : "",
      starts: json['starts'] != null ? json['starts'] as String : "",
    );
  }
}

class ScheduleListResultModel {
  List<ScheduleListResponseModel> schedule;

  ScheduleListResultModel({required this.schedule});

  factory ScheduleListResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<ScheduleListResponseModel> scheduleList =
        list.map((i) => ScheduleListResponseModel.fromJson(i)).toList();
    return ScheduleListResultModel(schedule: scheduleList);
  }
}

class ScheduleDetailResponseModel {
  final int appoKind;
  final String subject;
  final String starts;
  final String ends;
  final int labelId;
  final int cateId;
  final int appoPercent;
  final int appoState;
  final int priority;
  final int privacy;
  final int notice;
  final String regUserId;
  final String refUserId;
  final String contents;
  final String regDate;
  final int lockFlag;
  final int stepId;
  final int stepNday;
  final int comId;
  final int comFlag;
  final String orderNo;
  final String shipNo;

  ScheduleDetailResponseModel({
    required this.appoKind,
    required this.subject,
    required this.starts,
    required this.ends,
    required this.labelId,
    required this.cateId,
    required this.appoPercent,
    required this.appoState,
    required this.priority,
    required this.privacy,
    required this.notice,
    required this.regUserId,
    required this.refUserId,
    required this.contents,
    required this.regDate,
    required this.lockFlag,
    required this.stepId,
    required this.stepNday,
    required this.comId,
    required this.comFlag,
    required this.orderNo,
    required this.shipNo,
  });

  factory ScheduleDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDetailResponseModel(
      appoKind: json['appo_kind'] != null ? json['appo_kind'] as int : 0,
      subject: json['subject'] != null ? json['subject'] as String : "",
      starts: json['starts'] != null ? json['starts'] as String : "",
      ends: json['ends'] != null ? json['ends'] as String : "",
      labelId: json['label_id'] != null ? json['label_id'] as int : 0,
      cateId: json['cate_id'] != null ? json['cate_id'] as int : 0,
      appoPercent:
          json['appo_percent'] != null ? json['appo_percent'] as int : 0,
      appoState: json['appo_state'] != null ? json['appo_state'] as int : 0,
      priority: json['priority'] != null ? json['priority'] as int : 0,
      privacy: json['privacy'] != null ? json['privacy'] as int : 0,
      notice: json['notice'] != null ? json['notice'] as int : 0,
      regUserId:
          json['reg_user_id'] != null ? json['reg_user_id'] as String : "",
      refUserId:
          json['ref_user_id'] != null ? json['ref_user_id'] as String : "",
      contents: json['contents'] != null ? json['contents'] as String : "",
      regDate: json['reg_date'] != null ? json['reg_date'] as String : "",
      lockFlag: json['lock_flag'] != null ? json['lock_flag'] as int : 0,
      stepId: json['step_id'] != null ? json['step_id'] as int : 0,
      stepNday: json['step_nday'] != null ? json['step_nday'] as int : 0,
      comId: json['com_id'] != null ? json['com_id'] as int : 0,
      comFlag: json['com_flag'] != null ? json['com_flag'] as int : 0,
      orderNo: json['order_no'] != null ? json['order_no'] as String : "",
      shipNo: json['ship_no'] != null ? json['ship_no'] as String : "",
    );
  }
}

class ScheduleDetailResultModel {
  List<ScheduleDetailResponseModel> detail;

  ScheduleDetailResultModel({required this.detail});

  factory ScheduleDetailResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<ScheduleDetailResponseModel> detailList =
        list.map((i) => ScheduleDetailResponseModel.fromJson(i)).toList();
    return ScheduleDetailResultModel(detail: detailList);
  }
}
