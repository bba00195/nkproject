class EmployeeResponseModel {
  final String employeeCode;
  final String departCode;
  final String name;
  final String position;
  final String sex;
  final String mobile;
  final String eMail;
  final String task;
  final String hidden;
  final String realPhoto;
  final String savePhoto;
  final String departName; // 부서명
  final String departNameTwo; // 부서명
  final String userId;
  final String attCode;
  final String hpToken;

  EmployeeResponseModel({
    required this.employeeCode,
    required this.departCode,
    required this.name,
    required this.position,
    required this.sex,
    required this.mobile,
    required this.eMail,
    required this.task,
    required this.hidden,
    required this.realPhoto,
    required this.savePhoto,
    required this.departName, // 부서
    required this.departNameTwo, // 부서
    required this.userId,
    required this.attCode,
    required this.hpToken,
  });

  factory EmployeeResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeResponseModel(
      employeeCode:
          json['EMPLOYEECODE'] != null ? json['EMPLOYEECODE'] as String : "",
      departCode:
          json['DEPARTCODE'] != null ? json['DEPARTCODE'] as String : "",
      name: json['NAME'] != null ? json['NAME'] as String : "",
      position: json['POSITION'] != null ? json['POSITION'] as String : "",
      sex: json['SEX'] != null ? json['SEX'] as String : "",
      mobile: json['MOBILE'] != null ? json['MOBILE'] as String : "",
      eMail: json['EMAIL'] != null ? json['EMAIL'] as String : "",
      task: json['TASK'] != null ? json['TASK'] as String : "",
      hidden: json['HIDDEN'] != null ? json['HIDDEN'] as String : "",
      realPhoto: json['REALPHOTO'] != null ? json['REALPHOTO'] as String : "",
      savePhoto: json['SAVEPHOTO'] != null ? json['SAVEPHOTO'] as String : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      departNameTwo:
          json['DEPARTNAME2'] != null ? json['DEPARTNAME2'] as String : "",
      userId: json['USERID'] != null ? json['USERID'] as String : "",
      attCode: json['ATT_CODE'] != null ? json['ATT_CODE'] as String : "",
      hpToken: json['HPTOKEN'] != null ? json['HPTOKEN'] as String : "",
    );
  }
}

class EmployeeResultModel {
  List<EmployeeResponseModel> employee;

  EmployeeResultModel({required this.employee});

  factory EmployeeResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<EmployeeResponseModel> employeeList =
        list.map((i) => EmployeeResponseModel.fromJson(i)).toList();
    return EmployeeResultModel(employee: employeeList);
  }
}
