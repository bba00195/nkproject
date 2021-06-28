class User {
  String uniqueId; // 고유 ID
  String userId; // 유저 ID
  String passwd; // 패스워드_암호화
  String password; // 패스워드
  String authorId; // 권한 ID
  String dupInfo; // ?
  String employeeCode; // employee 번호
  String name; // 이름
  String position; // 직급
  String eMail; // 이메일
  String tel; // 전화번호
  String sex; // 성별
  String departCode; // 부서코드
  String departFullName; // 부서풀네임
  String departName; // 부서명
  String departHead; // 부서책임자
  String hpToken; // 부서책임자

  User({
    required this.uniqueId,
    required this.userId,
    required this.passwd,
    required this.password,
    required this.authorId,
    required this.dupInfo,
    required this.employeeCode,
    required this.name,
    required this.position,
    required this.eMail,
    required this.tel,
    required this.sex,
    required this.departCode,
    required this.departFullName,
    required this.departName,
    required this.departHead,
    required this.hpToken,
  });
}

class UserManager {
  late User _user;

  // ignore: unnecessary_getters_setters
  User get user => _user;

  // ignore: unnecessary_getters_setters
  set user(User user) {
    _user = user;
  }
}

class LoginResponseModel {
  final String uniqueId;
  final String userId;
  final String passwd;
  final String password;
  final String authorId;
  final String dupInfo;
  final String employeeCode;
  final String name;
  final String position;
  String eMail; // 이메일
  String tel; // 전화번호
  String sex; // 성별
  final String departCode;
  String departFullName; // 부서풀네임
  String departName; // 부서명
  final String departHead;
  final String hpToken;

  LoginResponseModel({
    required this.uniqueId,
    required this.userId,
    required this.passwd,
    required this.password,
    required this.authorId,
    required this.dupInfo,
    required this.employeeCode,
    required this.name,
    required this.position,
    required this.eMail,
    required this.tel,
    required this.sex,
    required this.departCode,
    required this.departFullName,
    required this.departName,
    required this.departHead,
    required this.hpToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      uniqueId: json['UNIQUEID'] != null ? json['UNIQUEID'] as String : "",
      userId: json['USERID'] != null ? json['USERID'] as String : "",
      passwd: json['PASSWD'] != null ? json['PASSWD'] as String : "",
      password: json['PASSWORD'] != null ? json['PASSWORD'] as String : "",
      authorId: json['AUTHORID'] != null ? json['AUTHORID'] as String : "",
      dupInfo: json['DUPINFO'] != null ? json['DUPINFO'] as String : "",
      employeeCode:
          json['EMPLOYEECODE'] != null ? json['EMPLOYEECODE'] as String : "",
      name: json['NAME'] != null ? json['NAME'] as String : "",
      position: json['POSITION'] != null ? json['POSITION'] as String : "",
      eMail: json['EMAIL'] != null ? json['EMAIL'] as String : "",
      tel: json['TEL'] != null ? json['TEL'] as String : "",
      sex: json['SEX'] != null ? json['SEX'] as String : "",
      departCode:
          json['DEPARTCODE'] != null ? json['DEPARTCODE'] as String : "",
      departFullName: json['DEPARTFULLNAME'] != null
          ? json['DEPARTFULLNAME'] as String
          : "",
      departName:
          json['DEPARTNAME'] != null ? json['DEPARTNAME'] as String : "",
      departHead:
          json['DEPARTHEAD'] != null ? json['DEPARTHEAD'] as String : "",
      hpToken: json['HPTOKEN'] != null ? json['HPTOKEN'] as String : "",
    );
  }
}

class LoginResultModel {
  List<LoginResponseModel> login;

  LoginResultModel({required this.login});

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    var list = json['RESULT'] != null ? json['RESULT'] as List : [];
    // print(list.runtimeType);
    List<LoginResponseModel> loginList =
        list.map((i) => LoginResponseModel.fromJson(i)).toList();
    return LoginResultModel(login: loginList);
  }
}
